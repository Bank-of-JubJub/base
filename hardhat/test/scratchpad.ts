import { ethers } from "ethers";
import { toBytes, toHex } from "viem";
import BabyJubJubUtils from "../utils/babyJubJubUtils";
import { getDecryptedValue, getEncryptedValue } from "../utils/utils";
import { BojAccount } from "../utils/types";
import { generatePrivateKey, privateKeyToAccount } from "viem/accounts";
import dotenv from "dotenv";
dotenv.config({ path: "../.env" });

async function main() {
  const privateKey = process.env.PRIVATE_KEY as `0x${string}`;
  console.log(privateKeyToAccount(privateKey));
  // const babyjub = new BabyJubJubUtils();
  // await babyjub.init();
  // const { privateKey, publicKey } = babyjub.generatePrivateAndPublicKey();
  // const packed = toHex(
  //   babyjub.packPublicKey([toBytes(publicKey.x), toBytes(publicKey.y)])
  // );
  // const account = {
  //   packedPublicKey: packed,
  //   privateKey: toHex(privateKey),
  // } as BojAccount;
  // console.log("boj account", account);
  // let encryptedValue = getEncryptedValue(packed, 2);
  // let decrypted = getDecryptedValue(account, [
  //   encryptedValue.C1.x,
  //   encryptedValue.C1.y,
  //   encryptedValue.C2.x,
  //   encryptedValue.C2.y,
  // ]);
}

main();

function getMessageHash(message: string) {
  // Ethereum message prefix
  const prefix = `\x19Ethereum Signed Message:\n${message.length}`;
  // Concatenate the prefix with the message
  const prefixedMessage = `${prefix}${message}`;
  // Hash the message
  // Note: ethers.utils.id computes the keccak256 hash of the message
  const messageHash = ethers.utils.id(prefixedMessage);
  return messageHash;
}
