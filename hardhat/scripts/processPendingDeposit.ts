import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData } from "./saveDeploy";
import {
  delay,
  encryptedBalanceArrayToEncryptedBalance,
  encryptedValueToEncryptedBalance,
  getC1PointFromEncryptedBalance,
  getEncryptedValue,
} from "../utils/utils";
import { EncryptedBalance } from "../utils/types";
import BabyJubJubUtils from "../utils/babyJubJubUtils";
import { createAndWriteToml } from "../../createToml";
import { bytesToBigInt, toBytes, toHex } from "viem";
import { getProcessDepositProof } from "../utils/config";
import { runNargoProve } from "../utils/generateNargoProof";
import { send } from "process";
import crypto from "crypto";
import { BJJ_PRIME, random } from "../utils/constants";
dotenv.config({ path: "../.env" });
const babyjub = new BabyJubJubUtils();

// bytes memory _proof,
// uint256[] memory _txsToProcess,
// address _feeRecipient,
// bytes32 _recipient,
// EncryptedAmount calldata _zeroBalance,
// EncryptedAmount calldata _newBalance
const params = {
  to: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
  amount: 10 * 10 ** 2,
};

async function main() {
  await babyjub.init();
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();
  const network = hre.network.name;
  const { data: privateTokenData } = readDeploymentData("PrivateToken");
  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );

  let count = await privateToken.read.pendingDepositCounts([params.to]);

  // TODO: process multiple pending deposits
  let pending = await privateToken.read.allPendingDepositsMapping([
    params.to,
    0n,
  ]);
  const processFee = pending[1];

  let balanceArray = await privateToken.read.balances([params.to]);
  let balance = encryptedBalanceArrayToEncryptedBalance(balanceArray);

  // if balance == 0
  if (balanceArray[0] == 0n && balanceArray[1] == 0n) {
    const startingAmount = getEncryptedValue(params.to, 0);
    balance = encryptedValueToEncryptedBalance(startingAmount);
  }

  const amount = getEncryptedValue(params.to, params.amount);
  const randomness = toHex(amount.randomness);
  const C1 = babyjub.add_points({ x: balance.C1x, y: balance.C1y }, amount.C1);
  const C2 = babyjub.add_points({ x: balance.C2x, y: balance.C2y }, amount.C2);
  const balanceAfterProcessDeposit = {
    C1x: C1.x,
    C1y: C1.y,
    C2x: C2.x,
    C2y: C2.y,
  } as EncryptedBalance;

  //   const randomness =
  //     "0x" + (bytesToBigInt(crypto.randomBytes(32)) % BJJ_PRIME).toString(16);
  const proofInputs = {
    randomness,
    amount_sum: params.amount - processFee,
    packed_public_key: Array.from(toBytes(params.to)),
    old_enc_balance_1: getC1PointFromEncryptedBalance(balance, true),
    old_enc_balance_2: getC1PointFromEncryptedBalance(balance, false),
    new_enc_balance_1: getC1PointFromEncryptedBalance(
      balanceAfterProcessDeposit,
      true
    ),
    new_enc_balance_2: getC1PointFromEncryptedBalance(
      balanceAfterProcessDeposit,
      false
    ),
  };

  createAndWriteToml("process_pending_deposits", proofInputs);
  await runNargoProve("process_pending_deposits", "Test.toml");
  const processDepositProof = await getProcessDepositProof();
  // bytes memory _proof,
  // uint256[] memory _txsToProcess,
  // address _feeRecipient,
  // bytes32 _recipient,
  // EncryptedAmount calldata _zeroBalance,
  // EncryptedAmount calldata _newBalance

  const hash = await privateToken.write.processPendingDeposit([
    processDepositProof,
    [0n],
    sender.account.address,
    params.to,
    balance,
    balanceAfterProcessDeposit,
  ]);

  await delay(5000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
