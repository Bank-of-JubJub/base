import * as fs from "fs";

export async function getTransferProof() {
    return (await getProof("proofs/transfer.proof")) as `0x${string}`;
}

export async function getProcessDepositProof() {
    return (await getProof(
        "proofs/process_pending_deposits.proof"
    )) as `0x${string}`;
}

export async function getProcessTransfersProof() {
    return (await getProof(
        "proofs/process_pending_transfers.proof"
    )) as `0x${string}`;
}

export async function getAddEthSignerProof() {
    return (await getProof(
        "proofs/add_eth_signer.proof"
    )) as `0x${string}`
}

export async function getWithdrawProof() {
    return (await getProof("proofs/withdraw.proof")) as `0x${string}`;
}

async function getProof(filePath: string) {
    let proof = "";
    try {
        const data = fs.readFileSync("../../" + filePath, { encoding: "utf-8" });
        proof = `0x${data}`;
    } catch (error) {
        console.error("Error reading file:", error);
    }
    return proof;
}
