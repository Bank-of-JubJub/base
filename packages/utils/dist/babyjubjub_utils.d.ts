import { Point } from "circomlibjs";
export type BigNumberish = string | bigint | number | Uint8Array;
export type PointObject = {
    x: bigint;
    y: bigint;
};
export declare class BabyJubJubUtils {
    private babyJub;
    constructor();
    init(): Promise<void>;
    getP(): any;
    getPm1d2(): any;
    getF(): any;
    private _uint8ArrayToBigInt;
    private _getRandomBigInt;
    _bigIntToUint8Array(bigInt: bigint): Uint8Array;
    privateToPublicKey(privateKey: BigNumberish): PointObject;
    generatePrivateAndPublicKey(): {
        privateKey: bigint;
        publicKey: PointObject;
    };
    exp_elgamal_encrypt(public_key: PointObject, plaintext: BigNumberish, isTest?: boolean): {
        C1: {
            x: bigint;
            y: bigint;
        };
        C2: {
            x: bigint;
            y: bigint;
        };
        randomness: bigint;
    };
    exp_elgamal_decrypt_embedded(private_key: BigNumberish, C1: PointObject, C2: PointObject): {
        x: bigint;
        y: bigint;
    };
    add_points(P1: PointObject, P2: PointObject): PointObject;
    intToLittleEndianHex(n: bigint): string;
    packPublicKey(P1: Point): Uint8Array;
    unpackPoint(point: Uint8Array): Point;
}
