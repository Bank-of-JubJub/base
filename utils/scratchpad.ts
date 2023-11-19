import * as babyjubjubUtils from "./babyjubjub_utils.js";
import { Point } from "circomlibjs";
// 21888242871839275222246405745257275088548364400416034343698204186575808495617 // Prime field order

async function main() {
  // const { privateKey, publicKey } = babyjubjubUtils.generatePrivateAndPublicKey();

  const priv_key =
    "0x0000bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4";
  const pub_key = babyjubjubUtils.privateToPublicKey(priv_key);
  const pub_key_array: Point = [
    bigintToUint8Array(pub_key.x),
    bigintToUint8Array(pub_key.y),
  ];
  console.log(uint8ArrayToHex(babyjubjubUtils.packPublicKey(pub_key_array)));

  const initial_balance = 100;
  const amount = 10;

  let hexArray = [
    0x0c, 0x07, 0x99, 0x9c, 0x15, 0xd4, 0x06, 0xbc, 0x08, 0xd7, 0xf3, 0xf3,
    0x1f, 0x62, 0xce, 0xdb, 0xc8, 0x9e, 0xbf, 0x3a, 0x53, 0xff, 0x4d, 0x3b,
    0xf7, 0xe2, 0xd0, 0xdd, 0xa9, 0x31, 0x49, 0x04,
  ];

  let hexstring = bytesArrayToHexString(hexArray);

  let packed = hexToUint8Array(hexstring);
  console.log("hex string", hexstring);

  // console.log('private key', priv_key)
  // console.log('pub key', pub_key.x.toString(16), pub_key.y.toString(16))
  // console.log('pub key ARRAY', pub_key_array)

  // console.log(21888242871839275222246405745257275088548364400416034343698204186575808495617n.toString(16) > priv_key)

  // console.log('array length', pub_key_array[0].length)

  // let packedPublicKey = babyjubjubUtils.packPublicKey(pub_key_array);
  // console.log("packed public key", packedPublicKey);
  // console.log("packed as hex", uint8ArrayToHex(packedPublicKey));
  let unpackedKey = babyjubjubUtils.unpackPoint(packed);

  // console.log(unpackedKey);

  let packed1 = babyjubjubUtils.packPublicKey(unpackedKey);

  // console.log(packed);
  // console.log(packed1);

  // console.log(
  //   "packed and unpacked points match",
  //   compareUint8Arrays(unpackedKey[0], bigintToUint8Array(pub_key.x)) &&
  //     compareUint8Arrays(unpackedKey[1], bigintToUint8Array(pub_key.y))
  // );
}

function bigintToUint8Array(bigint: bigint) {
  const bitLength = bigint.toString(2).length; // Get binary representation length
  const byteLength = Math.ceil(bitLength / 8); // Calculate byte length
  const uint8Array = new Uint8Array(byteLength);

  for (let i = 0; i < 32; i++) {
    uint8Array[32 - i - 1] = Number(bigint & 0xffn); // Get the least significant byte
    bigint >>= 8n; // Shift right by one byte
  }

  return uint8Array;
}

function compareUint8Arrays(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;

  for (let i = 0; i < a.length; i++) {
    if (a[i] !== b[i]) return false;
  }

  return true;
}

function uint8ArrayToBigInt(bytes: Uint8Array) {
  // Convert Uint8Array to a hexadecimal string
  let hex =
    "0x" +
    Array.from(bytes)
      .map((byte) => byte.toString(16).padStart(2, "0"))
      .join("");

  // Convert the hexadecimal string to a BigInt
  return BigInt(hex);
}

function uint8ArrayToHexArray(uint8Array: Uint8Array) {
  const hexArray = [];

  for (let i = 0; i < uint8Array.length; i++) {
    const hexByte = uint8Array[i].toString(16).padStart(2, "0");
    hexArray.push(hexByte);
  }

  return hexArray;
}

function uint8ArrayToHex(buffer: Uint8Array): string {
  return Array.from(buffer)
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}
function to32CharStrings(byteArray: number[]): string[] {
  // Convert each byte to a 2-character hex string and pad with zeros
  const paddedStrings: string[] = byteArray.map(
    (byte) => "0x" + "0".repeat(62) + byte.toString(16).padStart(2, "0")
  );
  return paddedStrings;
}

const byteArray: number[] = [
  0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16,
  0xe3, 0x49, 0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6,
  0x69, 0x6f, 0xf4, 0x15, 0x6b, 0xaa,
];

function bytesArrayToHexString(bytesArray: any) {
  // Check if the input is an array
  if (!Array.isArray(bytesArray)) {
    throw new TypeError("Input must be an array of bytes");
  }

  // Convert each byte to a hexadecimal string and concatenate
  return bytesArray
    .map(function (byte) {
      // Ensure the byte is within the valid range
      if (
        byte < 0 ||
        byte > 255 ||
        typeof byte !== "number" ||
        !Number.isInteger(byte)
      ) {
        throw new Error("Array must contain valid byte values (0-255)");
      }
      // Convert the byte to a hex string and pad with zero if needed
      return byte.toString(16).padStart(2, "0");
    })
    .join("");
}

main();

function hexToUint8Array(hexString: string): Uint8Array {
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

  console.log(arrayBuffer);

  return arrayBuffer;
}
