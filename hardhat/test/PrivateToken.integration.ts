import { assert, expect } from "chai";
import hre from "hardhat";
import BabyJubJubUtils from "../utils/babyJubJubUtils.ts";
import {
  EncryptedBalanceArray,
  EncryptedBalance,
  BojAccount,
} from "../utils/types.ts";
import { runNargoProve } from "../utils/generateNargoProof.ts";
import {
  account1,
  account2,
  transferProcessFee,
  transferRelayFee,
  depositAmount,
  depositProcessFee,
  random,
  transferAmount,
  withdrawAddress,
} from "../utils/constants.ts";

import { TransferCoordinator } from "../coordinators/TransferCoordinator.ts";
import { ProcessDepositCoordinator } from "../coordinators/ProcessDepositCoordinator.ts";
import { ProcessTransferCoordinator } from "../coordinators/ProcessTransferCoordinator.ts";
import { WithdrawCoordinator } from "../coordinators/WithdrawCoordinator.ts";

import { getWithdrawProof } from "../utils/config.ts";
import { createAndWriteToml } from "../../createToml.ts";
import {
  encryptedBalanceArrayToEncryptedBalance,
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getDecryptedValue,
  getEncryptedValue,
  getNonce,
} from "../utils/utils.ts";
import { Address, hexToBigInt, toBytes, toHex } from "viem";

const viem = hre.viem;

const babyjub = new BabyJubJubUtils();

let convertedAmount: bigint;

let privateTokenAddress: `0x${string}`;
let tokenAddress: `0x${string}`;

describe("Private Token integration testing", async function () {
  this.beforeAll(async () => {
    const { privateToken, token } = await setup();

    console.log("private token", privateToken.address);
    privateTokenAddress = privateToken.address;
    tokenAddress = token.address;
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
    const [sender] = await hre.viem.getWalletClients();

    const coordinator = new ProcessDepositCoordinator(
      privateToken,
      account1.packedPublicKey,
      sender.account.address
      //  [0n]
    );
    await coordinator.init();
    await coordinator.generateProof();
    await coordinator.sendProcessDeposit();

    let balance = await privateToken.read.balances([account1.packedPublicKey]);

    const decryptedBalance = await getDecryptedValue(account1, balance);
    expect(decryptedBalance == BigInt(999));
  });

  it("should perform transfers", async function () {
    const { privateToken } = await getContracts();
    const [sender] = await hre.viem.getWalletClients();

    let coordinator = new TransferCoordinator(
      transferAmount,
      privateToken,
      account2.packedPublicKey,
      account1,
      transferProcessFee,
      transferRelayFee,
      sender.account.address,
      true
    );
    await coordinator.init();
    await coordinator.generateProof();
    const hash = await coordinator.sendTransfer();

    let sender_balance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]);
    let recipient_balance = await privateToken.read.balances([
      account2.packedPublicKey,
    ]);

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
    const [sender] = await hre.viem.getWalletClients();
    const numTransfers = 2;

    let transferCoordinator = new TransferCoordinator(
      transferAmount,
      privateToken,
      account2.packedPublicKey,
      account1,
      transferProcessFee,
      transferRelayFee,
      sender.account.address,
      true
    );

    // Do a few transfers to stage them in pending
    for (let i = 0; i < numTransfers; i++) {
      await transferCoordinator.init();
      await transferCoordinator.generateProof();
      const hash = await transferCoordinator.sendTransfer();
    }

    const processTransferCoordinator = new ProcessTransferCoordinator(
      privateToken,
      account2.packedPublicKey,
      sender.account.address,
      0n
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
    const withdrawAmount = 7n;
    const withdrawRelayFee = 3n;
    const withdrawRelayRecipient = "0xdebe940f35737EDb9a9Ad2bB938A955F9b7892e3";
    const [sender] = await hre.viem.getWalletClients();

    const { privateToken } = await getContracts();

    const withdrawCoordinator = new WithdrawCoordinator(
      privateToken,
      sender.account.address,
      account1,
      withdrawAmount,
      withdrawRelayFee,
      withdrawRelayRecipient
    );

    await withdrawCoordinator.init();
    await withdrawCoordinator.generateProof();
    await withdrawCoordinator.sendWithdraw();

    console.log("TODO: finish withdraw test");

    const postBalance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]);
    const decryptedBalance = await getDecryptedValue(account1, postBalance);
    console.log("decrypted balance after withdraw", decryptedBalance);
    // expect(Number(decryptedBalance) == newBalanceClear);

    // check erc20 token balance of withdrawer and relayer
  });
});

async function deposit() {
  const { privateToken, token } = await getContracts();

  const [walletClient0, walletClient1] = await viem.getWalletClients();
  let balance = await token.read.balanceOf([walletClient0.account.address]);
  await token.write.approve([privateToken.address, balance]);

  let tokenDecimals = (await token.read.decimals()) as number;
  let bojDecimals = (await privateToken.read.decimals()) as number;

  convertedAmount =
    BigInt(depositAmount) / BigInt(10 ** (tokenDecimals - bojDecimals));

  await privateToken.write.deposit([
    walletClient0.account.address,
    depositAmount,
    account1.packedPublicKey,
    depositProcessFee,
  ]);
}

async function setup() {
  const publicClient = await hre.viem.getPublicClient();
  const [walletClient0, walletClient1] = await hre.viem.getWalletClients();
  let { contract: token } = await deploy("FunToken", []);
  const { contract: pendingDepositVerifier } = await deploy(
    "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: pendingTransferVerifier } = await deploy(
    "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferVerifier } = await deploy(
    "contracts/transfer/plonk_vk.sol:UltraVerifier",
    []
  );

  const { contract: withdrawVerifier } = await deploy(
    "contracts/withdraw/plonk_vk.sol:UltraVerifier",
    []
  );

  const { contract: lockVerifier } = await deploy(
    "contracts/lock/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: addEthSigners } = await deploy(
    "contracts/add_eth_signers/plonk_vk.sol:UltraVerifier",
    []
  );

  const { contract: accountController } = await deploy("AccountController", [
    addEthSigners.address,
  ]);

  const { contract: allTransferVerifier } = await deploy("TransferVerify", [
    transferVerifier.address,
    accountController.address,
  ]);

  const { contract: allWithdrawVerifier } = await deploy("WithdrawVerify", [
    withdrawVerifier.address,
    accountController.address,
  ]);

  const { contract: privateToken } = await deploy("PrivateToken", [
    pendingDepositVerifier.address,
    pendingTransferVerifier.address,
    allTransferVerifier.address,
    allWithdrawVerifier.address,
    lockVerifier.address,
    token.address,
    await token.read.decimals(),
  ]);

  return {
    publicClient,
    pendingDepositVerifier,
    pendingTransferVerifier,
    transferVerifier,
    withdrawVerifier,
    lockVerifier,
    token,
    privateToken,
    walletClient0,
    walletClient1,
  };
}

// A deployment function to set up the initial state
async function deploy(name: string, constructorArgs: any[]) {
  const contract = await hre.viem.deployContract(name, constructorArgs);

  return { contract };
}

async function getContracts() {
  let privateToken = await viem.getContractAt(
    "PrivateToken",
    privateTokenAddress
  );
  let token = await viem.getContractAt("FunToken", tokenAddress);
  return {
    privateToken,
    token,
  };
}
