// import { ethers } from "ethers";
// import { toBytes } from "viem";

// async function main() {
//   // hardhat wallet 0
//   const sender = new ethers.Wallet(
//     "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
//   );

//   const message = "test";

//   console.log("\x1b[34m%s\x1b[0m", "signing message 🖋: ", message);

//   const signature = await sender.signMessage(message); // get the signature of the message, this will be 130 bytes (concatenated r, s, and v)

//   console.log("signature 📝: ", toBytes(signature));

//   const digest = getMessageHash(message);

//   console.log("hashed message ", toBytes(digest));

//   let pubKey_uncompressed = ethers.utils.recoverPublicKey(digest, signature);
//   console.log("uncompressed pubkey: ", pubKey_uncompressed);

//   // recoverPublicKey returns `0x{hex"4"}{pubKeyXCoord}{pubKeyYCoord}` - so slice 0x04 to expose just the concatenated x and y
//   //    see https://github.com/indutny/elliptic/issues/86 for a non-explanation explanation 😂
//   let pubKey = pubKey_uncompressed.slice(4);

//   let pub_key_x = pubKey.substring(0, 64);
//   console.log("public key x coordinate 📊: ", toBytes("0x" + pub_key_x));

//   let pub_key_y = pubKey.substring(64);
//   console.log("public key y coordinate 📊: ", toBytes("0x" + pub_key_y));
// }

// main();

// function getMessageHash(message: string) {
//   // Ethereum message prefix
//   const prefix = `\x19Ethereum Signed Message:\n${message.length}`;
//   // Concatenate the prefix with the message
//   const prefixedMessage = `${prefix}${message}`;
//   // Hash the message
//   // Note: ethers.utils.id computes the keccak256 hash of the message
//   const messageHash = ethers.utils.id(prefixedMessage);
//   return messageHash;
// }
