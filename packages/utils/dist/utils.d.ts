import { PointObject } from "./babyjubjub_utils.js";
import { BojAccount, EncryptedBalance, EncryptedBalanceArray, PointObjects, PointObjectsWithRandomness } from "boj-types";
export declare function getEncryptedValue(packedPublicKey: string, amount: number, isTest?: boolean): PointObjectsWithRandomness;
export declare function getDecryptedValue(account: BojAccount, value: EncryptedBalanceArray): Promise<BigInt>;
export declare function encryptedBalanceArrayToEncryptedBalance(balance: EncryptedBalanceArray): EncryptedBalance;
export declare function encryptedBalanceArrayToPointObjects(balance: EncryptedBalanceArray): {
    C1: {
        x: bigint;
        y: bigint;
    };
    C2: {
        x: bigint;
        y: bigint;
    };
};
export declare function encryptedBalanceToPointObjects(balance: EncryptedBalance): {
    C1: {
        x: bigint;
        y: bigint;
    };
    C2: {
        x: bigint;
        y: bigint;
    };
};
export declare function pointObjectsToEncryptedBalance(pointobject: {
    C1: PointObject;
    C2: PointObject;
}): {
    C1x: bigint;
    C1y: bigint;
    C2x: bigint;
    C2y: bigint;
};
export declare function getC1PointFromEncryptedBalance(encBalance: EncryptedBalance, isC1?: boolean): {
    x: `0x${string}`;
    y: `0x${string}`;
};
export declare function getC2PointFromEncryptedBalance(encBalance: EncryptedBalance): {
    x: `0x${string}`;
    y: `0x${string}`;
};
export declare function encryptedValueToEncryptedBalance(encValue: PointObjects | PointObjectsWithRandomness): EncryptedBalance;
export declare function getNonce(encryptedAmount: {
    C1x: bigint;
    C1y: bigint;
    C2x: bigint;
    C2y: bigint;
}): bigint;
export declare function delay(time: number): Promise<unknown>;
export declare function fromRprLe(publicKey: `0x${string}`): string;
