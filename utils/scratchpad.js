import * as babyjubjubUtils from "./babyjubjub_utils.js";
// 21888242871839275222246405745257275088548364400416034343698204186575808495617 // Prime field order
async function main() {
    // const { privateKey, publicKey } = babyjubjubUtils.generatePrivateAndPublicKey();
    const priv_key = "0x0510bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4";
    const pub_key = babyjubjubUtils.privateToPublicKey(priv_key);
    const pub_key_array = [
        bigintToUint8Array(pub_key.x),
        bigintToUint8Array(pub_key.y),
    ];
    const initial_balance = 100;
    const amount = 10;
    // console.log('private key', priv_key)
    // console.log('pub key', pub_key.x.toString(16), pub_key.y.toString(16))
    // console.log('pub key ARRAY', pub_key_array)
    // console.log(21888242871839275222246405745257275088548364400416034343698204186575808495617n.toString(16) > priv_key)
    // console.log('array length', pub_key_array[0].length)
    let packedPublicKey = babyjubjubUtils.packPublicKey(pub_key_array);
    console.log("packed public key", packedPublicKey);
    console.log("packed as hex", uint8ArrayToHexArray(packedPublicKey));
    // The unpacked key is different than the original Public Key,
    // but additional packing/unpacking will always produce the same
    // packed/unpacked key
    let unpackedKey = babyjubjubUtils.unpackPoint(packedPublicKey);
    // console.log('unpacked pub key', unpackedKey)
    console.log("packed and unpacked points match", compareUint8Arrays(unpackedKey[0], bigintToUint8Array(pub_key.x)) &&
        compareUint8Arrays(unpackedKey[1], bigintToUint8Array(pub_key.y)));
    const initial_balance_enc = babyjubjubUtils.exp_elgamal_encrypt(pub_key, initial_balance);
    const amount_to_add = 100;
    const encrypted_amount = babyjubjubUtils.exp_elgamal_encrypt(pub_key, amount_to_add);
    const new_balance = {
        C1: babyjubjubUtils.add_points(initial_balance_enc.C1, encrypted_amount.C1),
        C2: babyjubjubUtils.add_points(initial_balance_enc.C2, encrypted_amount.C2),
    };
    console.log("balance after encrypted addition", new_balance);
    // console.log("F half", (babyjubjubUtils.getF()).half)
    // console.log("pm1d2", babyjubjubUtils.getPm1d2())
}
function bigintToUint8Array(bigint) {
    const bitLength = bigint.toString(2).length; // Get binary representation length
    const byteLength = Math.ceil(bitLength / 8); // Calculate byte length
    const uint8Array = new Uint8Array(byteLength);
    for (let i = 0; i < 32; i++) {
        uint8Array[32 - i - 1] = Number(bigint & 0xffn); // Get the least significant byte
        bigint >>= 8n; // Shift right by one byte
    }
    return uint8Array;
}
function compareUint8Arrays(a, b) {
    if (a.length !== b.length)
        return false;
    for (let i = 0; i < a.length; i++) {
        if (a[i] !== b[i])
            return false;
    }
    return true;
}
function uint8ArrayToBigInt(bytes) {
    // Convert Uint8Array to a hexadecimal string
    let hex = "0x" +
        Array.from(bytes)
            .map((byte) => byte.toString(16).padStart(2, "0"))
            .join("");
    // Convert the hexadecimal string to a BigInt
    return BigInt(hex);
}
function uint8ArrayToHexArray(uint8Array) {
    const hexArray = [];
    for (let i = 0; i < uint8Array.length; i++) {
        const hexByte = uint8Array[i].toString(16).padStart(2, "0");
        hexArray.push(hexByte);
    }
    return hexArray;
}
function uint8ArrayToHex(buffer) {
    return Array.from(buffer)
        .map((byte) => byte.toString(16).padStart(2, "0"))
        .join("");
}
function to32CharStrings(byteArray) {
    // Convert each byte to a 2-character hex string and pad with zeros
    const paddedStrings = byteArray.map((byte) => "0x" + "0".repeat(62) + byte.toString(16).padStart(2, "0"));
    return paddedStrings;
}
const byteArray = [
    0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16,
    0xe3, 0x49, 0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6,
    0x69, 0x6f, 0xf4, 0x15, 0x6b, 0xaa,
];
main();
