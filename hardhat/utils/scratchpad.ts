import { ethers } from "ethers";
import { Abi, bytesToBigInt, encodeFunctionData, hexToBigInt, keccak256, recoverAddress, recoverMessageAddress, recoverPublicKey, toBytes, toHex, verifyMessage } from "viem";
import BabyJubJubUtils from "./babyJubJubUtils";
import { getDecryptedValue, getEncryptedValue } from "./utils";
import { BojAccount } from "./types";
import { generatePrivateKey, privateKeyToAccount } from "viem/accounts";
import dotenv from "dotenv";
dotenv.config({ path: "../.env" });
import { SMT, ChildNodes, HashFunction } from "@zk-kit/smt";
import { IMT } from "@zk-kit/imt";
import { BJJ_PRIME } from "./constants";

async function main() {
  const account = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);

  const recipient = "dc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa"
  const amount = {
    C1x: "034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368",
    C1y: "0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f",
    C2x: "20a08bc68201d32688f1ba415b168f1b78dfcb0af4c5c8741b8674d9aea97147",
    C2y: "137c478ed936487f6b0a7b850a256c8286c993a43f808ade344aa1dcccd2e126"
  }
  const message = `${recipient}${amount.C1x}${amount.C1y}${amount.C2x}${amount.C2y}`
  console.log(toBytes(message))
  const prefixedMessage = toBytes(`\x19Ethereum Signed Message:\n${message.length}${message}`)
  console.log(message.length)
  let hash = keccak256(prefixedMessage);
  // console.log(toBytes(hash))
  let signature = await account.signMessage({ message })

  const valid = await verifyMessage({
    address: account.address,
    message: message,
    signature,
  })

  const publicKey = await recoverPublicKey({
    hash,
    signature
  })

  const address1 = await recoverMessageAddress({
    message,
    signature
  })

  const address = await recoverAddress({
    hash,
    signature
  })

  console.log(address)


}

main();
