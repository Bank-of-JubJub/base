import * as fs from "fs";
import BabyJubJubUtils from "./babyJubJubUtils";
import {
  hexToUint8Array,
  getEncryptedValue,
  toHexString,
  encryptedBalanceToUint8Array,
  uint8ArrayToHexString,
} from "./utils";
import { EncryptedBalance, EncryptedBalanceArray } from "./types";
import {
  BarretenbergBackend,
  CompiledCircuit,
  ProofData,
} from "@noir-lang/backend_barretenberg";
import { Noir } from "@noir-lang/noir_js";
import { Fr } from "@aztec/bb.js";

import lockCircuit from "../../target/lock.json";
import processDepositsCircuit from "../../target/process_pending_deposits.json";
import processTransferCircuit from "../../target/process_pending_transfers.json";
import transferCircuit from "../../target/transfer.json";
import withdrawCircuit from "../../target/withdraw.json";

const babyjub = new BabyJubJubUtils();

// let circuits = [
//   lockCircuit,
//   processDepositsCircuit,
//   processTransferCircuit,
//   transferCircuit,
//   withdrawCircuit,
// ];

// const backend = new BarretenbergBackend(circuit);
// const noir = new Noir(circuit, backend);

export async function generateProcessDepositProof(
  account: string,
  previousBalance: number,
  value: number,
  randomness: string
): Promise<ProofData> {
  const inputs = getProcessDepositInputs(account, previousBalance, value);
  const backend = new BarretenbergBackend(
    processDepositsCircuit as CompiledCircuit,
    { threads: 8 }
  );
  const inputMap = {
    randomness,
    amount_sum: value,
    packed_public_key: [
      220, 159, 159, 219, 116, 109, 15, 7, 176, 4, 204, 67, 22, 227, 73, 90, 88,
      87, 11, 144, 102, 20, 153, 248, 166, 166, 105, 111, 244, 21, 107, 170,
    ],
    old_enc_balance_1: {
      x: "0x" + toHexString(inputs.oldBalance.C1x, 64),
      y: "0x" + toHexString(inputs.oldBalance.C1y, 64),
    },
    old_enc_balance_2: {
      x: "0x" + toHexString(inputs.oldBalance.C2x, 64),
      y: "0x" + toHexString(inputs.oldBalance.C2y, 64),
    },
    new_enc_balance_1: {
      x: "0x" + toHexString(inputs.newBalance.C1x, 64),
      y: "0x" + toHexString(inputs.newBalance.C1y, 64),
    },
    new_enc_balance_2: {
      x: "0x" + toHexString(inputs.newBalance.C2x, 64),
      y: "0x" + toHexString(inputs.newBalance.C2y, 64),
    },
  };
  const noir = new Noir(processDepositsCircuit as CompiledCircuit, backend);

  const proof = await noir.generateFinalProof(inputMap);

  // works!
  // const verification = await noir.verifyFinalProof(proof);
  // if (verification) {
  //   console.log("logs", "Verifying proof... ✅");
  // }

  return proof;
}

export function getProcessDepositInputs(
  account: string,
  previousBalance: number,
  value: number
) {
  const oldUnformatted = getEncryptedValue(account, previousBalance);
  const oldBalance = {
    C1x: oldUnformatted.C1.x,
    C1y: oldUnformatted.C1.y,
    C2x: oldUnformatted.C2.x,
    C2y: oldUnformatted.C2.y,
  } as EncryptedBalance;
  const amount = getEncryptedValue(account, value);
  const C1 = babyjub.add_points(oldUnformatted.C1, amount.C1);
  const C2 = babyjub.add_points(oldUnformatted.C2, amount.C2);
  const newBalance = {
    C1x: C1.x,
    C1y: C1.y,
    C2x: C2.x,
    C2y: C2.y,
  } as EncryptedBalance;
  return { oldBalance, newBalance };
}

export function getTransferInputs(
  to: string,
  from: string,
  amount: number,
  newBalance: number
) {
  const unformattedEncryptedAmount = getEncryptedValue(to, amount);
  const encryptedAmount = {
    C1x: unformattedEncryptedAmount.C1.x,
    C1y: unformattedEncryptedAmount.C1.y,
    C2x: unformattedEncryptedAmount.C2.x,
    C2y: unformattedEncryptedAmount.C2.y,
  } as EncryptedBalance;
  const unformattedNewBalance = getEncryptedValue(from, newBalance);
  const encryptedNewBalance = {
    C1x: unformattedNewBalance.C1.x,
    C1y: unformattedNewBalance.C1.y,
    C2x: unformattedNewBalance.C2.x,
    C2y: unformattedNewBalance.C2.y,
  } as EncryptedBalance;

  return {
    encryptedAmount,
    encryptedNewBalance,
  };
}

export function getProcessTransferInputs(
  to: string,
  oldEncBalance: EncryptedBalanceArray,
  newBalance: number
) {}

export const account2 =
  "0x0c07999c15d406bc08d7f3f31f62cedbc89ebf3a53ff4d3bf7e2d0dda9314904" as `0x${string}`;
export const account1 =
  "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`;
export const processFeeRecipient =
  "0xbEa2940f35737EDb9a9Ad2bB938A955F9b7892e3" as `0x${string}`;

export const depositProcessFee = 1;
export const transferProcessFee = 1;
export const transferRelayFee = 2;
export const withdrawRelayFee = 1;

export const BJJ_PRIME =
  21888242871839275222246405745257275088548364400416034343698204186575808495617n;

export const randomness =
  "0x" +
  168986485046885582825082387270879151100288537211746581237924789162159767775n.toString(
    16
  );

export async function getTransferProof() {
  return (await getProof("../proofs/transfer.proof")) as `0x${string}`;
}

export async function createTransferProof() {}

export async function getProcessDepositProof() {
  return (await getProof(
    "../proofs/process_pending_deposits.proof"
  )) as `0x${string}`;
}

export async function getProcessTransfersProof() {
  return (await getProof(
    "../proofs/process_pending_transfers.proof"
  )) as `0x${string}`;
}

export async function getWithdrawProof() {
  return (await getProof("../proofs/withdraw.proof")) as `0x${string}`;
}

async function getProof(filePath: string) {
  let proof = "";
  try {
    const data = fs.readFileSync(filePath, { encoding: "utf-8" });
    proof = `0x${data}`;
  } catch (error) {
    console.error("Error reading file:", error);
  }
  return proof;
}
