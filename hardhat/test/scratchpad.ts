import { ethers } from "ethers";
import { hexToBigInt, toBytes, toHex } from "viem";
import BabyJubJubUtils from "../utils/babyJubJubUtils";
import { getDecryptedValue, getEncryptedValue } from "../utils/utils";
import { BojAccount } from "../utils/types";
import { generatePrivateKey, privateKeyToAccount } from "viem/accounts";
import dotenv from "dotenv";
dotenv.config({ path: "../.env" });

async function main() {
  // const babyjub = new BabyJubJubUtils();
  // await babyjub.init();
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
