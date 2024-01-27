import {
    keccak256,
    encodeAbiParameters,
    toBytes,
    bytesToBigInt,
    toHex,
} from "viem";
import { BJJ_PRIME } from "./constants.js";
import { PointObject } from "./babyjubjub_utils.js";
import {
    BojAccount,
    EncryptedBalance,
    EncryptedBalanceArray,
    PointObjects,
    PointObjectsWithRandomness,
} from "boj-types";
import { spawn } from "child_process";
import { BabyJubJubUtils } from "./babyjubjub_utils.js";

const babyjub = new BabyJubJubUtils();
babyjub.init();

export function getEncryptedValue(
    packedPublicKey: string,
    amount: number,
    isTest: boolean = false
) {
    const publicKey = babyjub.unpackPoint(toBytes(packedPublicKey));

    const publicKeyObject = {
        x: bytesToBigInt(publicKey[0]),
        y: bytesToBigInt(publicKey[1]),
    };

    return babyjub.exp_elgamal_encrypt(
        publicKeyObject,
        amount,
        isTest
    ) as PointObjectsWithRandomness;
}

export async function getDecryptedValue(
    account: BojAccount,
    value: EncryptedBalanceArray
) {
    const decryptedEmbedded = babyjub.exp_elgamal_decrypt_embedded(
        account.privateKey,
        { x: value[0], y: value[1] },
        { x: value[2], y: value[3] }
    );
    const decryptedBalance = (await runRustScriptBabyGiant(
        babyjub.intToLittleEndianHex(decryptedEmbedded.x),
        babyjub.intToLittleEndianHex(decryptedEmbedded.y)
    )) as BigInt;
    return decryptedBalance;
}

async function runRustScriptBabyGiant(X: any, Y: any) {
    // this is to compute the DLP during decryption of the balances with baby-step giant-step algo in circuits/exponential_elgamal/babygiant_native
    //  inside the browser this should be replaced by the WASM version in circuits/exponential_elgamal/babygiant
    return new Promise((resolve, reject) => {
        const rustProcess = spawn(
            "../../circuits/exponential_elgamal/babygiant_native/target/release/babygiant",
            [X, Y]
        );
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
            } else {
                resolve(BigInt(output.slice(0, -1)));
            }
        });
    });
}

// function uint8ArrayToBigInt(bytes: Uint8Array): bigint {
//   let hex = [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
//   return BigInt("0x" + hex);
// }

export function encryptedBalanceArrayToEncryptedBalance(
    balance: EncryptedBalanceArray
) {
    return {
        C1x: balance[0],
        C1y: balance[1],
        C2x: balance[2],
        C2y: balance[3],
    } as EncryptedBalance;
}

export function encryptedBalanceArrayToPointObjects(
    balance: EncryptedBalanceArray
) {
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

export function encryptedBalanceToPointObjects(balance: EncryptedBalance) {
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

export function pointObjectsToEncryptedBalance(pointobject: {
    C1: PointObject;
    C2: PointObject;
}) {
    return {
        C1x: pointobject.C1.x,
        C1y: pointobject.C1.y,
        C2x: pointobject.C2.x,
        C2y: pointobject.C2.y,
    };
}

export function getC1PointFromEncryptedBalance(
    encBalance: EncryptedBalance,
    isC1: boolean = true
) {
    if (isC1) {
        return {
            x: toHex(encBalance.C1x, { size: 32 }),
            y: toHex(encBalance.C1y, { size: 32 }),
        };
    } else {
        return {
            x: toHex(encBalance.C2x, { size: 32 }),
            y: toHex(encBalance.C2y, { size: 32 }),
        };
    }
}
export function getC2PointFromEncryptedBalance(encBalance: EncryptedBalance) {
    return {
        x: toHex(encBalance.C2x, { size: 32 }),
        y: toHex(encBalance.C2y, { size: 32 }),
    };
}

export function encryptedValueToEncryptedBalance(
    encValue: PointObjects | PointObjectsWithRandomness
) {
    return {
        C1x: encValue.C1.x,
        C1y: encValue.C1.y,
        C2x: encValue.C2.x,
        C2y: encValue.C2.y,
    } as EncryptedBalance;
}

export function getNonce(encryptedAmount: {
    C1x: bigint;
    C1y: bigint;
    C2x: bigint;
    C2y: bigint;
}) {
    return (
        BigInt(
            keccak256(
                encodeAbiParameters(
                    [
                        { name: "C1x", type: "uint256" },
                        { name: "C1y", type: "uint256" },
                        { name: "C2x", type: "uint256" },
                        { name: "C1y", type: "uint256" },
                    ],
                    [
                        encryptedAmount.C1x,
                        encryptedAmount.C1y,
                        encryptedAmount.C2x,
                        encryptedAmount.C2y,
                    ]
                )
            )
        ) % BJJ_PRIME
    );
}

export function delay(time: number) {
    return new Promise((resolve) => setTimeout(resolve, time));
}

export function fromRprLe(publicKey: `0x${string}`): string {
    let y = BigInt(0);
    let v = BigInt(1);
    for (let i = 0; i < 32; i++) {
        y += (BigInt(toBytes(publicKey)[i]) * v) % BJJ_PRIME;
        v *= BigInt(256);
    }
    return toHex(y, { size: 32 });
}