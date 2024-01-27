import * as fs from "fs";

export async function getTransferProof(path: string) {
    return (await getProof(path + "proofs/transfer.proof")) as `0x${string}`;
}

export async function getProcessDepositProof(path: string) {
    return (await getProof(path +
        "proofs/process_pending_deposits.proof"
    )) as `0x${string}`;
}

export async function getProcessTransfersProof(path: string) {
    return (await getProof(path +
        "proofs/process_pending_transfers.proof"
    )) as `0x${string}`;
}

export async function getAddEthSignerProof(path: string) {
    return (await getProof(path +
        "proofs/add_eth_signer.proof"
    )) as `0x${string}`
}

export async function getWithdrawProof(path: string) {
    return (await getProof(path + "proofs/withdraw.proof")) as `0x${string}`;
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
