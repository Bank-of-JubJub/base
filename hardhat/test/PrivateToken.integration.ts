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
  processFeeRecipient,
  transferProcessFee,
  transferRelayFee,
  depositAmount,
  depositProcessFee,
  random,
  transferAmount,
  withdrawAddress,
  MAX_TXS_TO_PROCESS,
  BJJ_PRIME,
} from "../utils/constants.ts";

import { TransferCoordinator } from "../coordinators/TransferCoordinator.ts";
import { ProcessDepositCoordinator } from "../coordinators/ProcessDepositCoordinator.ts";
import { ProcessTransferCoordinator } from "../coordinators/ProcessTransferCoordinator.ts";

import {
  getTransferProof,
  getProcessDepositProof,
  getProcessTransfersProof,
  getWithdrawProof,
  getProcessTransferInputs,
} from "../utils/config.ts";
import { TomlKeyValue, createAndWriteToml } from "../../createToml.ts";
import {
  encryptedBalanceArrayToEncryptedBalance,
  encryptedBalanceArrayToPointObjects,
  encryptedBalanceToPointObjects,
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getC1PointFromEncryptedBalance,
  getC2PointFromEncryptedBalance,
  getDecryptedValue,
  getEncryptedValue,
  getNonce,
  pointObjectsToEncryptedBalance,
} from "../utils/utils.ts";
import { Address, hexToBigInt, toBytes, toHex } from "viem";

const viem = hre.viem;

const babyjub = new BabyJubJubUtils();

let convertedAmount: bigint;
let processDepositProof: `0x${string}`;
let transferProof: `0x${string}`;

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

    const encryptedAmount = getEncryptedValue(
      account2.packedPublicKey,
      transferAmount,
      true
    );
    const encAmountToSend = encryptedValueToEncryptedBalance(encryptedAmount);
    let encNewBalance;

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
      // const preClearBalance = await getDecryptedValue(
      //   account1,
      //   await privateToken.read.balances([account1.packedPublicKey])
      // );

      // let newClearBalance =
      //   Number(preClearBalance) -
      //   (transferAmount + transferProcessFee + transferRelayFee);

      // let unfmtEncNewBalance = getEncryptedValue(
      //   account1.packedPublicKey,
      //   newClearBalance,
      //   true
      // );
      // encNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);

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
    // await processPendingTransfer();

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

    const { privateToken, token } = await getContracts();
    const unfmtEncOldBalance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]);
    const encOldBalance =
      encryptedBalanceArrayToEncryptedBalance(unfmtEncOldBalance);

    const clearOldBalance = await getDecryptedValue(
      account1,
      unfmtEncOldBalance
    );
    const newBalanceClear =
      Number(clearOldBalance) - withdrawRelayFee - withdrawAmount;

    const unfmtEncNewBalance = getEncryptedValue(
      account1.packedPublicKey,
      newBalanceClear,
      true
    );
    const encNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);

    await withdraw(
      withdrawAddress,
      account1,
      withdrawAmount,
      withdrawRelayFee,
      withdrawRelayRecipient,
      encOldBalance,
      encNewBalance,
      Number(clearOldBalance)
    );
    console.log("TODO: finish withdraw test");

    const postBalance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]);
    const decryptedBalance = await getDecryptedValue(account1, postBalance);
    expect(Number(decryptedBalance) == newBalanceClear);

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

async function withdraw(
  to: Address,
  from: BojAccount,
  amount: number,
  relayFee: number,
  relayFeeRecipient: Address,
  encOldBalance: EncryptedBalance,
  encNewBalance: EncryptedBalance,
  clearOldBalance: number
) {
  const { privateToken, token } = await getContracts();
  const [walletClient0, walletClient1] = await viem.getWalletClients();

  const proofInputs = {
    private_key: account1.privateKey,
    randomness: random,
    balance_old_clear: Number(clearOldBalance),
    packed_public_key: Array.from(toBytes(account1.packedPublicKey)),
    packed_public_key_modulus: fromRprLe(account1.packedPublicKey),
    nonce_private: toHex(getNonce(encNewBalance), { size: 32 }),
    nonce: toHex(getNonce(encNewBalance), { size: 32 }),
    value: amount,
    relay_fee: relayFee,
    balance_old_encrypted_1: {
      x: toHex(encOldBalance.C1x, { size: 32 }),
      y: toHex(encOldBalance.C1y, { size: 32 }),
    },
    balance_old_encrypted_2: {
      x: toHex(encOldBalance.C2x, { size: 32 }),
      y: toHex(encOldBalance.C2y, { size: 32 }),
    },
    balance_new_encrypted_1: {
      x: toHex(encNewBalance.C1x, { size: 32 }),
      y: toHex(encNewBalance.C1y, { size: 32 }),
    },
    balance_new_encrypted_2: {
      x: toHex(encNewBalance.C2x, { size: 32 }),
      y: toHex(encNewBalance.C2y, { size: 32 }),
    },
  };

  try {
    createAndWriteToml("withdraw", proofInputs);
    await runNargoProve("withdraw", "Test.toml");
    const withdrawProof = await getWithdrawProof();

    await privateToken.write.withdraw([
      from.packedPublicKey,
      to,
      amount,
      relayFee,
      relayFeeRecipient,
      withdrawProof,
      encNewBalance,
    ]);
  } catch (e) {
    console.log(e);
  }
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
