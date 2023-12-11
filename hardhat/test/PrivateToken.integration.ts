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
} from "../utils/constants.ts";

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
  getC1PointFromEncryptedBalance,
  getDecryptedValue,
  getEncryptedValue,
  getNonce,
  pointObjectsToEncryptedBalance,
} from "../utils/utils.ts";
import { Address, toBytes, toHex } from "viem";

const viem = hre.viem;

const babyjub = new BabyJubJubUtils();

let convertedAmount: bigint;
let processDepositProof: `0x${string}`;
let transferProof: `0x${string}`;

let privateTokenAddress: `0x${string}`;
let tokenAddress: `0x${string}`;

let encryptedZero: EncryptedBalance;
let balanceAfterProcessDeposit: EncryptedBalance;

describe("Private Token integration testing", async function () {
  this.beforeAll(async () => {
    const { privateToken, token } = await setup();
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

    const processAmount = 999;

    const startingAmount = getEncryptedValue(account1.packedPublicKey, 0);
    encryptedZero = encryptedValueToEncryptedBalance(startingAmount);
    const amount = getEncryptedValue(account1.packedPublicKey, processAmount);
    const C1 = babyjub.add_points(startingAmount.C1, amount.C1);
    const C2 = babyjub.add_points(startingAmount.C2, amount.C2);
    balanceAfterProcessDeposit = {
      C1x: C1.x,
      C1y: C1.y,
      C2x: C2.x,
      C2y: C2.y,
    } as EncryptedBalance;

    await processPendingDeposit(
      [0n], // txs (indexes) to process
      encryptedZero,
      balanceAfterProcessDeposit
    );

    let balance = await privateToken.read.balances([account1.packedPublicKey]);

    expect(balance[0] == balanceAfterProcessDeposit.C1x);
    expect(balance[1] == balanceAfterProcessDeposit.C1y);
    expect(balance[2] == balanceAfterProcessDeposit.C2x);
    expect(balance[3] == balanceAfterProcessDeposit.C2y);

    const decryptedBalance = await getDecryptedValue(account1, balance);
    expect(decryptedBalance == BigInt(processAmount));
  });

  it("should perform transfers", async function () {
    const { privateToken } = await getContracts();

    let processFee = transferProcessFee;
    const preBalance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]);
    const preBalanceRecipient = await privateToken.read.balances([
      account2.packedPublicKey,
    ]);

    // zero out process fee if sending to new account
    if (
      preBalanceRecipient[0] == BigInt(0) &&
      preBalanceRecipient[1] == BigInt(0)
    ) {
      processFee = 0;
    }

    const preClearBalance = await getDecryptedValue(account1, preBalance);
    const newClearBalance =
      Number(preClearBalance) - transferAmount - transferRelayFee - processFee;

    const encryptedAmount = getEncryptedValue(
      account2.packedPublicKey,
      transferAmount
    );
    const encAmountToSend = encryptedValueToEncryptedBalance(encryptedAmount);
    const unfmtEncNewBalance = getEncryptedValue(
      account1.packedPublicKey,
      newClearBalance
    );
    const encNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);

    await transfer(
      account2, // to
      account1, // from
      encAmountToSend,
      encNewBalance,
      Number(preClearBalance),
      processFee,
      transferRelayFee
    );

    let sender_balance = await privateToken.read.balances([
      account1.packedPublicKey,
    ]);
    let recipient_balance = await privateToken.read.balances([
      account2.packedPublicKey,
    ]);

    expect(recipient_balance[0] == encAmountToSend.C1x);
    expect(recipient_balance[1] == encAmountToSend.C1y);
    expect(recipient_balance[2] == encAmountToSend.C2x);
    expect(recipient_balance[3] == encAmountToSend.C2y);
    expect(sender_balance[0] == encNewBalance.C1x);
    expect(sender_balance[1] == encNewBalance.C1y);
    expect(sender_balance[2] == encNewBalance.C2x);
    expect(sender_balance[3] == encNewBalance.C2y);

    // check token balance of the relayer
    // check that transfer event was emitted
    // check that nonce was correctly updated

    const recipientDecryptedBalance = await getDecryptedValue(
      account2,
      recipient_balance
    );
    expect(
      Number(recipientDecryptedBalance) == transferAmount,
      "decrypted balances should match"
    );
  });

  it("should process pending transfers", async () => {
    const { privateToken } = await getContracts();

    const encryptedAmount = getEncryptedValue(
      account2.packedPublicKey,
      transferAmount
    );
    const encAmountToSend = encryptedValueToEncryptedBalance(encryptedAmount);
    let encNewBalance;

    // Do a few transfers to stage them in pending
    for (let i = 0; i < 2; i++) {
      const preClearBalance = await getDecryptedValue(
        account1,
        await privateToken.read.balances([account1.packedPublicKey])
      );

      let newClearBalance =
        Number(preClearBalance) -
        (transferAmount + transferProcessFee + transferRelayFee);

      let unfmtEncNewBalance = getEncryptedValue(
        account1.packedPublicKey,
        newClearBalance
      );
      encNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);
      await transfer(
        account2, // to
        account1, // from
        encAmountToSend,
        encNewBalance,
        Number(preClearBalance),
        transferProcessFee,
        transferRelayFee
      );
    }

    await processPendingTransfer();

    let balance = (await privateToken.read.balances([
      account2.packedPublicKey,
    ])) as EncryptedBalanceArray;

    expect(balance[0] == encNewBalance!.C1x);
    expect(balance[1] == encNewBalance!.C1y);
    expect(balance[2] == encNewBalance!.C2x);
    expect(balance[3] == encNewBalance!.C2y);
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
      newBalanceClear
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

async function processPendingDeposit(
  txsToProcess: any,
  startingBalance: EncryptedBalance,
  newBalance: EncryptedBalance
) {
  await deposit();
  const { privateToken, token } = await getContracts();

  const proofInputs = {
    randomness: random,
    amount_sum: Number(convertedAmount) - depositProcessFee,
    packed_public_key: Array.from(toBytes(account1.packedPublicKey)),
    old_enc_balance_1: getC1PointFromEncryptedBalance(startingBalance, true),
    old_enc_balance_2: getC1PointFromEncryptedBalance(startingBalance, false),
    new_enc_balance_1: getC1PointFromEncryptedBalance(newBalance, true),
    new_enc_balance_2: getC1PointFromEncryptedBalance(newBalance, false),
  };

  if (processDepositProof == undefined) {
    createAndWriteToml("process_pending_deposits", proofInputs);
    await runNargoProve("process_pending_deposits", "Test.toml");
    processDepositProof = await getProcessDepositProof();
  }

  await privateToken.write.processPendingDeposit([
    processDepositProof,
    txsToProcess,
    processFeeRecipient,
    account1.packedPublicKey,
    startingBalance,
    newBalance,
  ]);
}

async function transfer(
  to: BojAccount,
  from: BojAccount,
  encryptedAmount: EncryptedBalance,
  encNewBalance: EncryptedBalance,
  clearOldBalance: number,
  processFee: number,
  relayFee: number
) {
  const { privateToken, token } = await getContracts();
  const [walletClient0, walletClient1] = await viem.getWalletClients();

  const encOldBalance = await privateToken.read.balances([
    from.packedPublicKey,
  ]);

  const recipientBalance = await privateToken.read.balances([
    to.packedPublicKey,
  ]);

  // if recipient balance == 0, process fee should be 0, per the smart contract
  if (
    recipientBalance[0] == 0n &&
    recipientBalance[1] == 0n &&
    recipientBalance[2] == 0n &&
    recipientBalance[3] == 0n
  ) {
    processFee = 0;
  }

  const proofInputs = {
    balance_old_me_clear: clearOldBalance,
    private_key: account1.privateKey,
    value: transferAmount,
    randomness: random,
    sender_pub_key: Array.from(toBytes(from.packedPublicKey)),
    recipient_pub_key: Array.from(toBytes(to.packedPublicKey)),
    process_fee: processFee,
    relay_fee: relayFee,
    nonce_private: toHex(getNonce(encNewBalance)),
    nonce: toHex(getNonce(encNewBalance)),
    old_balance_encrypted_1: {
      x: toHex(encOldBalance[0]),
      y: toHex(encOldBalance[1]),
    },
    old_balance_encrypted_2: {
      x: toHex(encOldBalance[2]),
      y: toHex(encOldBalance[3]),
    },
    encrypted_amount_1: getC1PointFromEncryptedBalance(encryptedAmount, true),
    encrypted_amount_2: getC1PointFromEncryptedBalance(encryptedAmount, false),
    new_balance_encrypted_1: getC1PointFromEncryptedBalance(
      encNewBalance,
      true
    ),
    new_balance_encrypted_2: getC1PointFromEncryptedBalance(
      encNewBalance,
      false
    ),
  };

  const relayFeeRecipient = walletClient1.account.address as `0x${string}`;

  try {
    createAndWriteToml("transfer", proofInputs);
    await runNargoProve("transfer", "Test.toml");
    transferProof = await getTransferProof();

    await privateToken.write.transfer([
      to.packedPublicKey,
      from.packedPublicKey,
      processFee,
      transferRelayFee,
      relayFeeRecipient,
      encryptedAmount,
      encNewBalance,
      transferProof,
    ]);
  } catch (e) {
    console.log(e);
  }
}

async function processPendingTransfer() {
  const { privateToken } = await getContracts();

  let oldBalanceArray = await privateToken.read.balances([
    account2.packedPublicKey,
  ]);
  const oldEncryptedBalance =
    encryptedBalanceArrayToPointObjects(oldBalanceArray);
  const pendingTransferCount = await privateToken.read.pendingTransferCounts([
    account2.packedPublicKey,
  ]);

  let balanceAfterProcessTransfer = oldEncryptedBalance;
  let encryptedValues = [];
  // pass indexes to contract to lookup and process
  let txIndexes = [];

  for (let i = 0; i <= Number(pendingTransferCount) - 1; i++) {
    let pendingTransfer = await privateToken.read.allPendingTransfersMapping([
      account2.packedPublicKey,
      BigInt(i),
    ]);
    txIndexes.push(i);
    // value will be 0 if it has been deleted or never set, skip this iteration
    if (pendingTransfer[0].C1x == BigInt(0)) {
      console.log(
        "pending transfer is empty. It has been deleted or never set."
      );
      continue;
    }
    const amount = encryptedBalanceToPointObjects(pendingTransfer[0]);

    encryptedValues.push({ x: toHex(amount.C1.x), y: toHex(amount.C1.y) });
    encryptedValues.push({ x: toHex(amount.C2.x), y: toHex(amount.C2.y) });

    const C1 = babyjub.add_points(balanceAfterProcessTransfer.C1, amount.C1);
    const C2 = babyjub.add_points(balanceAfterProcessTransfer.C2, amount.C2);
    balanceAfterProcessTransfer = { C1, C2 };

    if (encryptedValues.length == MAX_TXS_TO_PROCESS * 2) break;
  }
  for (let i = encryptedValues.length; i < MAX_TXS_TO_PROCESS * 2; i++) {
    encryptedValues.push({
      x: "0x0",
      y: "0x0",
    });
  }

  let newBalance = pointObjectsToEncryptedBalance(balanceAfterProcessTransfer);

  const proofInputs = {
    balance_old_to_encrypted_1: {
      // toBytes then toHex to make sure its padded properly
      x: toHex(toBytes(oldBalanceArray[0]), { size: 32 }),
      y: toHex(toBytes(oldBalanceArray[1]), { size: 32 }),
    },
    balance_old_to_encrypted_2: {
      x: toHex(toBytes(oldBalanceArray[2]), { size: 32 }),
      y: toHex(toBytes(oldBalanceArray[3]), { size: 32 }),
    },
    balance_new_to_encrypted_1: {
      x: toHex(newBalance.C1x),
      y: toHex(newBalance.C1y),
    },
    balance_new_to_encrypted_2: {
      x: toHex(newBalance.C2x),
      y: toHex(newBalance.C2y),
    },
    encrypted_values: encryptedValues,
  };

  createAndWriteToml("process_pending_transfers", proofInputs);
  await runNargoProve("process_pending_transfers", "Test.toml");
  const processTransfersProof = await getProcessTransfersProof();

  await privateToken.write.processPendingTransfer([
    processTransfersProof,
    txIndexes,
    processFeeRecipient,
    account2.packedPublicKey,
    newBalance,
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
    nonce_private: toHex(getNonce(encNewBalance)),
    nonce: toHex(getNonce(encNewBalance)),
    value: amount,
    relay_fee: relayFee,
    balance_old_encrypted_1: {
      x: toHex(encOldBalance.C1x),
      y: toHex(encOldBalance.C1y),
    },
    balance_old_encrypted_2: {
      x: toHex(encOldBalance.C2x),
      y: toHex(encOldBalance.C2y),
    },
    balance_new_encrypted_1: {
      x: toHex(encNewBalance.C1x),
      y: toHex(encNewBalance.C1y),
    },
    balance_new_encrypted_2: {
      x: toHex(encNewBalance.C2x),
      y: toHex(encNewBalance.C2y),
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
  const { contract: transfer4337Verifier } = await deploy(
    "contracts/transfer_4337/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferEthSignerVerifier } = await deploy(
    "contracts/transfer_eth_signer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferMultisigVerifier } = await deploy(
    "contracts/transfer_multisig/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawVerifier } = await deploy(
    "contracts/withdraw/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdraw4337Verifier } = await deploy(
    "contracts/withdraw_4337/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawEthSignerVerifier } = await deploy(
    "contracts/withdraw_eth_signer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawMultisigVerifier } = await deploy(
    "contracts/withdraw_multisig/plonk_vk.sol:UltraVerifier",
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
  const { contract: changeEthSigner } = await deploy(
    "contracts/change_eth_signer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: changeMultiEthSigners } = await deploy(
    "contracts/change_multi_eth_signers/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: privateTokenFactory } = await deploy(
    "PrivateTokenFactory",
    [
      pendingDepositVerifier.address,
      pendingTransferVerifier.address,
      transferVerifier.address,
      withdrawVerifier.address,
      lockVerifier.address,
      addEthSigners.address,
      changeEthSigner.address,
      changeMultiEthSigners.address,
    ]
  );
  await privateTokenFactory.write.deploy([token.address]);
  const logs = await publicClient.getContractEvents({
    address: privateTokenFactory.address,
    abi: privateTokenFactory.abi,
    eventName: "Deployed",
  });
  // @ts-ignore
  let privateTokenAddress = logs[0].args.token;
  const privateToken = await viem.getContractAt(
    "PrivateToken",
    privateTokenAddress
  );
  privateToken.write.initOtherVerifiers([
    transfer4337Verifier.address,
    transferEthSignerVerifier.address,
    transferMultisigVerifier.address,
    withdraw4337Verifier.address,
    withdrawEthSignerVerifier.address,
    withdrawMultisigVerifier.address,
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
