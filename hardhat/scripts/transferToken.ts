import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData } from "./saveDeploy";
import {
  delay,
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getC1PointFromEncryptedBalance,
  getC2PointFromEncryptedBalance,
  getDecryptedValue,
  getEncryptedValue,
  getNonce,
} from "../utils/utils";
import { send } from "process";
import { BojAccount } from "../utils/types";
import { getTransferProof } from "../utils/config";
import { runNargoProve } from "../utils/generateNargoProof";
import { createAndWriteToml } from "../../createToml";
import { toBytes, toHex } from "viem";
dotenv.config({ path: "../.env" });

// bytes32 _to,
// bytes32 _from,
// uint40 _processFee,
// uint40 _relayFee,
// address _relayFeeRecipient,
// EncryptedAmount calldata _amountToSend,
// EncryptedAmount calldata _senderNewBalance,
// bytes memory _proof_transfer
const params = {
  to: "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`,
  from: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
  amount: 5,
  processFee: 1,
  relayFee: 2,
};

async function main() {
  const publicClient = await hre.viem.getPublicClient();
  const [sender, relayFeeRecipient] = await hre.viem.getWalletClients();

  const bojAccount = {
    packedPublicKey: params.from,
    privateKey: process.env.BOJ_PACKED_PUBLIC_KEY,
  } as BojAccount;

  const network = hre.network.name;

  const { data: privateTokenData } = readDeploymentData("PrivateToken");

  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );

  // amount
  const unfmtAmount = getEncryptedValue(params.to, params.amount, false);
  const randomness2 = toHex(unfmtAmount.randomness, { size: 32 });
  const sendAmount = encryptedValueToEncryptedBalance(unfmtAmount);

  const encOldBalance = await privateToken.read.balances([
    bojAccount.packedPublicKey,
  ]);

  // calc new balance
  const preBalance = await privateToken.read.balances([params.from]);

  const preClearBalance = Number(
    await getDecryptedValue(bojAccount, preBalance)
  );

  console.log(preClearBalance);

  const newClearBalance =
    preClearBalance - params.amount - params.relayFee - params.processFee;
  const unfmtEncNewBalance = getEncryptedValue(
    bojAccount.packedPublicKey,
    newClearBalance
  );
  const randomness1 = toHex(unfmtEncNewBalance.randomness, { size: 32 });
  const encNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);

  const proofInputs = {
    balance_old_me_clear: preClearBalance,
    private_key: bojAccount.privateKey,
    value: params.amount,
    randomness1,
    randomness2,
    sender_pub_key: Array.from(toBytes(bojAccount.packedPublicKey)),
    recipient_pub_key: Array.from(toBytes(params.to)),
    sender_pub_key_modulus: fromRprLe(bojAccount.packedPublicKey),
    recipient_pub_key_modulus: fromRprLe(params.to),
    process_fee: params.processFee,
    relay_fee: params.relayFee,
    nonce_private: toHex(getNonce(encNewBalance), { size: 32 }),
    nonce: toHex(getNonce(encNewBalance), { size: 32 }),
    old_balance_encrypted_1: {
      x: toHex(encOldBalance[0], { size: 32 }),
      y: toHex(encOldBalance[1], { size: 32 }),
    },
    old_balance_encrypted_2: {
      x: toHex(encOldBalance[2], { size: 32 }),
      y: toHex(encOldBalance[3], { size: 32 }),
    },
    encrypted_amount_1: getC1PointFromEncryptedBalance(sendAmount),
    encrypted_amount_2: getC2PointFromEncryptedBalance(sendAmount),
    new_balance_encrypted_1: getC1PointFromEncryptedBalance(encNewBalance),
    new_balance_encrypted_2: getC2PointFromEncryptedBalance(encNewBalance),
  };

  createAndWriteToml("transfer", proofInputs);

  console.log("generating proof");

  await runNargoProve("transfer", "Test.toml");
  const proof = await getTransferProof();

  const hash = await privateToken.write.transfer([
    params.to,
    params.from,
    params.processFee,
    params.relayFee,
    relayFeeRecipient.account.address,
    sendAmount,
    encNewBalance,
    proof,
  ]);

  await delay(5000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
