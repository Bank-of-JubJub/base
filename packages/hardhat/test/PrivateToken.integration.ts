import { assert, expect } from "chai";
import { createWalletClient, getContract } from "viem";
import hre from "hardhat";
import { EncryptedBalanceArray } from "boj-types";
import {
  account1,
  account2,
  BabyJubJubUtils,
  transferProcessFee,
  transferRelayFee,
  depositAmount,
  depositProcessFee,
  transferAmount,
  getDecryptedValue
} from "boj-utils";
import {
  TransferCoordinator,
  ProcessDepositCoordinator,
  ProcessTransferCoordinator,
  WithdrawCoordinator
} from "boj-coordinators";
import { deployContracts } from "../scripts/deploy.ts";
import * as bojArtifact from "../artifacts/contracts/PrivateToken.sol/PrivateToken.json"  assert { type: 'json' };
import * as tokenArtifact from "../artifacts/contracts/ERC20.sol/FunToken.json"  assert { type: 'json' };
import { createPublicClient, http } from 'viem'
import { hardhat } from 'viem/chains'
import { send } from "process";

// const viem = hre.viem;
const babyjub = new BabyJubJubUtils();
let convertedAmount: bigint;

let privateTokenAddress: `0x${string}`;
let tokenAddress: `0x${string}`;

const publicClient = createPublicClient({
  chain: hardhat,
  transport: http()
})

const sender = createWalletClient({
  chain: hardhat,
  transport: http(),
  account: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
})

describe("Private Token integration testing", async function () {
  this.beforeAll(async () => {
    const contracts = await deployContracts(true);
    // @ts-ignore
    privateTokenAddress = contracts!.privateToken.address;
    // @ts-ignore
    tokenAddress = contracts!.token.address;
    await babyjub.init();
  });

  it("should add a deposit", async () => {
    const { privateToken } = await getContracts();
    await deposit();

    let pending = await privateToken.read.pendingDepositCounts([
      account1.packedPublicKey,
    ]);
    assert(pending == 1n, "Pending deposits should be 1.");

    let pendingDeposit = (await privateToken.read.allPendingDepositsMapping([
      account1.packedPublicKey,
      0n,
    ])) as [bigint, number];

    const expectedAmount = convertedAmount - BigInt(depositProcessFee);
    let totalSupply = await privateToken.read.totalSupply();

    assert(
      pendingDeposit[0] == expectedAmount,
      "pending deposit should match deposit amount"
    );
    assert(
      pendingDeposit[1] == depositProcessFee,
      "pending deposit fee should match input"
    );
    assert(
      totalSupply == Number(expectedAmount),
      "deposit amount should be the total supply"
    );
  });

  it("should process pending deposits", async function () {
    await deposit();
    const { privateToken } = await getContracts();
    // const publicClient = await hre.viem.getPublicClient();
    // const [sender] = await hre.viem.getWalletClients();

    const coordinator = new ProcessDepositCoordinator(
      account1.packedPublicKey,
      sender.account.address,
      0,
      privateTokenAddress,
      // @ts-ignore
      publicClient,
      sender
    );
    await coordinator.init();
    await coordinator.generateProof();
    await coordinator.sendProcessDeposit();

    let balance = await privateToken.read.balances([account1.packedPublicKey]) as EncryptedBalanceArray

    const decryptedBalance = await getDecryptedValue(account1, balance);
    expect(decryptedBalance == BigInt(999));
  });

  it("should perform transfers", async function () {
    const { privateToken } = await getContracts();
    // const publicClient = await hre.viem.getPublicClient();
    // const [sender] = await hre.viem.getWalletClients();

    let coordinator = new TransferCoordinator(
      transferAmount,
      account2.packedPublicKey,
      account1,
      transferProcessFee,
      transferRelayFee,
      sender.account.address,
      privateTokenAddress,
      // @ts-ignore
      publicClient,
      sender,
      true
    );
    await coordinator.init();
    await coordinator.generateProof();
    const hash = await coordinator.sendTransfer();

    let sender_balance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]) as EncryptedBalanceArray;
    let recipient_balance = await privateToken.read.balances([
      account2.packedPublicKey,
    ]) as EncryptedBalanceArray;

    // check token balance of the relayer
    // check that transfer event was emitted
    // check that nonce was correctly updated
    const senderDecryptedBalance = await getDecryptedValue(
      account1,
      sender_balance
    );
    expect(
      Number(senderDecryptedBalance) == transferAmount,
      "sender decrypted balances should match"
    );

    const recipientDecryptedBalance = await getDecryptedValue(
      account2,
      recipient_balance
    );
    expect(
      Number(recipientDecryptedBalance) == transferAmount,
      "recipient decrypted balances should match"
    );
  });

  it("should process pending transfers", async () => {
    const { privateToken } = await getContracts();
    // const publicClient = await hre.viem.getPublicClient();
    // const [sender] = await hre.viem.getWalletClients();
    const numTransfers = 2;

    let transferCoordinator = new TransferCoordinator(
      transferAmount,
      account2.packedPublicKey,
      account1,
      transferProcessFee,
      transferRelayFee,
      sender.account.address,
      privateTokenAddress,
      // @ts-ignore
      publicClient,
      sender,
      true
    );

    // Do a few transfers to stage them in pending
    for (let i = 0; i < numTransfers; i++) {
      await transferCoordinator.init();
      await transferCoordinator.generateProof();
      const hash = await transferCoordinator.sendTransfer();
    }

    const processTransferCoordinator = new ProcessTransferCoordinator(
      account2.packedPublicKey,
      sender.account.address,
      0,
      privateTokenAddress,
      // @ts-ignore
      publicClient,
      sender
    );
    await processTransferCoordinator.init();
    await processTransferCoordinator.generateProof();
    await processTransferCoordinator.sendProcessTransfer();

    let balance = (await privateToken.read.balances([
      account2.packedPublicKey,
    ])) as EncryptedBalanceArray;
    const recipientDecryptedBalance = await getDecryptedValue(
      account2,
      balance
    );
    expect(
      recipientDecryptedBalance == BigInt(transferAmount * numTransfers),
      "decrypted balance should be the number of transfers * transfer amount"
    );
  });

  it("should do withdrawals", async () => {
    const withdrawAmount = 7;
    const withdrawRelayFee = 3;
    const withdrawRelayRecipient = "0xdebe940f35737EDb9a9Ad2bB938A955F9b7892e3";
    // const publicClient = await hre.viem.getPublicClient();
    // const [sender] = await hre.viem.getWalletClients();

    const { privateToken } = await getContracts();
    const unfmtEncOldBalance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]) as EncryptedBalanceArray;
    const clearOldBalance = Number(
      await getDecryptedValue(account1, unfmtEncOldBalance)
    );

    const withdrawCoordinator = new WithdrawCoordinator(
      sender.account.address,
      account1,
      withdrawAmount,
      withdrawRelayFee,
      withdrawRelayRecipient,
      privateTokenAddress,
      // @ts-ignore
      publicClient,
      sender
    );

    await withdrawCoordinator.init();
    await withdrawCoordinator.generateProof();
    await withdrawCoordinator.sendWithdraw();

    console.log("TODO: finish withdraw test");

    const postBalance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]) as EncryptedBalanceArray;
    const decryptedBalance = Number(
      await getDecryptedValue(account1, postBalance)
    );
    expect(
      decryptedBalance == clearOldBalance - withdrawAmount,
      "balance after withdraw should be the old balance minus the withdraw amount"
    );

    // TODO: check erc20 token balance of withdrawer and relayer
  });
});

async function deposit() {
  const { privateToken, token } = await getContracts();

  // const [walletClient0, walletClient1] = await hre.viem.getWalletClients();
  let balance = await token.read.balanceOf([sender.account.address]);
  await token.write.approve([privateToken.address, balance]);

  let tokenDecimals = (await token.read.decimals()) as number;
  let bojDecimals = (await privateToken.read.decimals()) as number;

  convertedAmount =
    BigInt(depositAmount) / BigInt(10 ** (tokenDecimals - bojDecimals));

  await privateToken.write.deposit([
    depositAmount,
    account1.packedPublicKey,
    depositProcessFee,
  ]);
}

export async function getContracts() {

  // const wallet = createWalletClient({
  //   chain: hardhat,
  //   transport: http(),
  //   account: '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
  // })
  // const publicClient = createPublicClient({
  //   chain: hardhat,
  //   transport: http()
  // })

  let privateToken = await getContract({
    abi: bojArtifact.default.abi,
    address: privateTokenAddress,
    client: {
      wallet: sender,
      public: publicClient
    }
  });
  let token = await getContract({
    abi: tokenArtifact.default.abi,
    address: tokenAddress,
    client: {
      wallet: sender,
      public: publicClient
    }
  });

  return {
    privateToken,
    token,
  };
}
