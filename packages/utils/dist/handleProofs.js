import * as fs from "fs";
export async function getTransferProof(path) {
    return (await getProof(path + "proofs/transfer.proof"));
}
export async function getProcessDepositProof(path) {
    return (await getProof(path +
        "proofs/process_pending_deposits.proof"));
}
export async function getProcessTransfersProof(path) {
    return (await getProof(path +
        "proofs/process_pending_transfers.proof"));
}
export async function getAddEthSignerProof(path) {
    return (await getProof(path +
        "proofs/add_eth_signer.proof"));
}
export async function getWithdrawProof(path) {
    return (await getProof(path + "proofs/withdraw.proof"));
}
async function getProof(filePath) {
    let proof = "";
    try {
        const data = fs.readFileSync(filePath, { encoding: "utf-8" });
        proof = `0x${data}`;
    }
    catch (error) {
        console.error("Error reading file:", error);
    }
    return proof;
}
