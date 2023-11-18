export type EncryptedBalanceArray = [bigint, bigint, bigint, bigint];
export type EncryptedBalance = {
  C1x: bigint;
  C1y: bigint;
  C2x: bigint;
  C2y: bigint;
};
export type BankAccount = {
  packedPublicKey: `0x${string}`;
  privateKey: `0x${string}`;
};
