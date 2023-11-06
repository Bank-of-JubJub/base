import * as fs from "fs";

export const processDepositInputs = {
  amount_sum: 999,
  old_enc_balance_1: {
    C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
    C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
    C2x: 0x26e2d952913cecf5261ce7caea0ded4a9c46a3a10dda292c565868d5f98aa5dbn,
    C2y: 0x1e8449b223a9d7b6215d5976bd0bec814de2115961f71590878e389a1cff5d09n,
  },
  new_enc_balance_1: {
    C1x: 0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0n,
    C1y: 0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2n,
    C2x: 0x06deb02e81b49cc0e215e0453b6135d52827629df1a12914da953199d39f333bn,
    C2y: 0x211de3374abedea3113aa1f312173764eb804dab7ead931971a4dbba832baf00n,
  },
};

export const processTransferInputs = {
  // 5, ecrypted to `to`
  amount: {
    C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
    C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
    C2x: 0x25bd68ade5a08a4a012250cff52bd6e92752413aacb5a01ef8157e7c65b1b1c6n,
    C2y: 0x22ce61a67a4ee826534fca1d6276fd1c80ff05a5831f90ce1c9f5963a6393e5fn,
  },
  // 992, encrypted to `from`
  newSenderBalance: {
    C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
    C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
    C2x: 0x2795109cf233e0d54d88f75d6c8b28b37ea224b6083e2f76efed55710e1fd425n,
    C2y: 0x3006aa76f9499aeee9080237f3c24005be7ca83627f6600f7b278dff77a37df5n,
  },
};

export const account2 =
  "0x0c07999c15d406bc08d7f3f31f62cedbc89ebf3a53ff4d3bf7e2d0dda9314904" as `0x${string}`;
export const account1 =
  "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`;
export const processFeeRecipient =
  "0xbEa2940f35737EDb9a9Ad2bB938A955F9b7892e3" as `0x${string}`;

export const BJJ_PRIME =
  21888242871839275222246405745257275088548364400416034343698204186575808495617n;

export async function getTransferProof() {
  return (await getProof("../proofs/transfer.proof")) as `0x${string}`;
}

export async function getProcessDepositProof() {
  return (await getProof("../proofs/process_pending_deposits.proof")) as `0x${string}`;
}

export async function getProcessTransfersProof() {
  return (await getProof("../proofs/process_pending_transfers.proof")) as `0x${string}`;
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