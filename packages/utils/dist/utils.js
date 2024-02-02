import { keccak256, encodeAbiParameters, toBytes, bytesToBigInt, toHex, } from "viem";
import { BJJ_PRIME } from "./constants.js";
import { spawn } from "child_process";
import { BabyJubJubUtils } from "./babyjubjub_utils.js";
const babyjub = new BabyJubJubUtils();
babyjub.init();
export function getEncryptedValue(packedPublicKey, amount, isTest = false) {
    const publicKey = babyjub.unpackPoint(toBytes(packedPublicKey));
    const publicKeyObject = {
        x: bytesToBigInt(publicKey[0]),
        y: bytesToBigInt(publicKey[1]),
    };
    return babyjub.exp_elgamal_encrypt(publicKeyObject, amount, isTest);
}
export async function getDecryptedValue(account, value) {
    const decryptedEmbedded = babyjub.exp_elgamal_decrypt_embedded(account.privateKey, { x: value[0], y: value[1] }, { x: value[2], y: value[3] });
    const decryptedBalance = (await runRustScriptBabyGiant(babyjub.intToLittleEndianHex(decryptedEmbedded.x), babyjub.intToLittleEndianHex(decryptedEmbedded.y)));
    return decryptedBalance;
}
async function runRustScriptBabyGiant(X, Y) {
    // this is to compute the DLP during decryption of the balances with baby-step giant-step algo in circuits/exponential_elgamal/babygiant_native
    //  inside the browser this should be replaced by the WASM version in circuits/exponential_elgamal/babygiant
    return new Promise((resolve, reject) => {
        const rustProcess = spawn("../../circuits/exponential_elgamal/babygiant_native/target/release/babygiant", [X, Y]);
        let output = "";
        rustProcess.stdout.on("data", (data) => {
            output += data.toString();
        });
        rustProcess.stderr.on("data", (data) => {
            reject(new Error(`Rust Error: ${data}`));
        });
        rustProcess.on("close", (code) => {
            if (code !== 0) {
                reject(new Error(`Child process exited with code ${code}`));
            }
            else {
                resolve(BigInt(output.slice(0, -1)));
            }
        });
    });
}
// function uint8ArrayToBigInt(bytes: Uint8Array): bigint {
//   let hex = [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
//   return BigInt("0x" + hex);
// }
export function encryptedBalanceArrayToEncryptedBalance(balance) {
    return {
        C1x: balance[0],
        C1y: balance[1],
        C2x: balance[2],
        C2y: balance[3],
    };
}
export function encryptedBalanceArrayToPointObjects(balance) {
    return {
        C1: {
            x: balance[0],
            y: balance[1],
        },
        C2: {
            x: balance[2],
            y: balance[3],
        },
    };
}
export function encryptedBalanceToPointObjects(balance) {
    return {
        C1: {
            x: balance.C1x,
            y: balance.C1y,
        },
        C2: {
            x: balance.C2x,
            y: balance.C2y,
        },
    };
}
export function pointObjectsToEncryptedBalance(pointobject) {
    return {
        C1x: pointobject.C1.x,
        C1y: pointobject.C1.y,
        C2x: pointobject.C2.x,
        C2y: pointobject.C2.y,
    };
}
export function getC1PointFromEncryptedBalance(encBalance, isC1 = true) {
    if (isC1) {
        return {
            x: toHex(encBalance.C1x, { size: 32 }),
            y: toHex(encBalance.C1y, { size: 32 }),
        };
    }
    else {
        return {
            x: toHex(encBalance.C2x, { size: 32 }),
            y: toHex(encBalance.C2y, { size: 32 }),
        };
    }
}
export function getC2PointFromEncryptedBalance(encBalance) {
    return {
        x: toHex(encBalance.C2x, { size: 32 }),
        y: toHex(encBalance.C2y, { size: 32 }),
    };
}
export function encryptedValueToEncryptedBalance(encValue) {
    return {
        C1x: encValue.C1.x,
        C1y: encValue.C1.y,
        C2x: encValue.C2.x,
        C2y: encValue.C2.y,
    };
}
export function getNonce(encryptedAmount) {
    return (BigInt(keccak256(encodeAbiParameters([
        { name: "C1x", type: "uint256" },
        { name: "C1y", type: "uint256" },
        { name: "C2x", type: "uint256" },
        { name: "C1y", type: "uint256" },
    ], [
        encryptedAmount.C1x,
        encryptedAmount.C1y,
        encryptedAmount.C2x,
        encryptedAmount.C2y,
    ]))) % BJJ_PRIME);
}
export function delay(time) {
    return new Promise((resolve) => setTimeout(resolve, time));
}
export function fromRprLe(publicKey) {
    let y = BigInt(0);
    let v = BigInt(1);
    for (let i = 0; i < 32; i++) {
        y += (BigInt(toBytes(publicKey)[i]) * v) % BJJ_PRIME;
        v *= BigInt(256);
    }
    return toHex(y, { size: 32 });
}
