import { keccak256, encodeAbiParameters } from "viem";
import { BJJ_PRIME } from "./config.ts";
import BabyJubJubUtils from "./babyJubJubUtils";
import { EncryptedBalance } from "./types.ts";
const babyjub = new BabyJubJubUtils();

export function getEncryptedValue(packedPublicKey: string, amount: number) {
  const publicKey = babyjub.unpackPoint(
    hexToUint8Array(packedPublicKey.slice(2))
  );
  const publicKeyObject = {
    x: uint8ArrayToBigInt(publicKey[0]),
    y: uint8ArrayToBigInt(publicKey[1]),
  };

  return babyjub.exp_elgamal_encrypt(publicKeyObject, amount);
}

function uint8ArrayToBigInt(bytes: Uint8Array): bigint {
  let hex = [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
  return BigInt("0x" + hex);
}

export function uint8ArrayToEncryptedBalance(
  bytes: Uint8Array[]
): EncryptedBalance {
  return {
    C1x: uint8ArrayToBigInt(bytes[0]),
    C1y: uint8ArrayToBigInt(bytes[1]),
    C2x: uint8ArrayToBigInt(bytes[2]),
    C2y: uint8ArrayToBigInt(bytes[3]),
  };
}

export function encryptedBalanceToUint8Array(balance: EncryptedBalance) {
  return [
    hexToUint8Array(toHexString(balance.C1x, 64)),
    hexToUint8Array(toHexString(balance.C1y, 64)),
    hexToUint8Array(toHexString(balance.C2x, 64)),
    hexToUint8Array(toHexString(balance.C2y, 64)),
  ];
}

export function uint8ArrayToHexString(arr: Uint8Array) {
  return (
    "0x" +
    Array.from(arr)
      .map((byte) => byte.toString(16).padStart(2, "0"))
      .join("")
  );
}

export function bigIntToHexString(bigIntValue: bigint) {
  let hexString = bigIntValue.toString(16);
  // Ensure it's 64 characters long (32 bytes), padding with leading zeros if necessary
  while (hexString.length < 64) {
    hexString = "0" + hexString;
  }
  return "0x" + hexString;
}

export function hexToUint8Array(hexString: string): Uint8Array {
  // Ensure the input string length is even
  if (hexString.length % 2 !== 0) {
    throw new Error("Hex string must have an even number of characters");
  }

  const arrayBuffer = new Uint8Array(hexString.length / 2);

  for (let i = 0; i < arrayBuffer.length; i++) {
    const byteValue = parseInt(hexString.substr(i * 2, 2), 16);
    if (Number.isNaN(byteValue)) {
      throw new Error("Invalid hex string");
    }
    arrayBuffer[i] = byteValue;
  }

  return arrayBuffer;
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

export function toHexString(
  bigintValue: bigint,
  desiredLength: number
): string {
  let hexString = bigintValue.toString(16);
  while (hexString.length < desiredLength) {
    hexString = "0" + hexString;
  }
  return hexString;
}
