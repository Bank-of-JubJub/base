export type EncryptedBalanceArray = [bigint, bigint, bigint, bigint];
export type EncryptedBalance = {
    C1x: bigint;
    C1y: bigint;
    C2x: bigint;
    C2y: bigint;
};
export type PointObject = {
    x: bigint;
    y: bigint;
};
export type PointObjectHex = {
    x: `0x${string}`;
    y: `0x${string}`;
};
export type PointObjects = {
    C1: {
        x: bigint;
        y: bigint;
    };
    C2: {
        x: bigint;
        y: bigint;
    };
};
export type PointObjectsWithRandomness = {
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
export type BojAccount = {
    packedPublicKey: `0x${string}`;
    privateKey: `0x${string}`;
};
