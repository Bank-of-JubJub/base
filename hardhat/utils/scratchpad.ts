import { ethers } from "ethers";
import { Abi, bytesToBigInt, encodeFunctionData, hexToBigInt, toBytes, toHex } from "viem";
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

  const abiItem = {
    inputs: [{
      "components": [
        {
          "internalType": "uint256",
          "name": "C1x",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "C1y",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "C2x",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "C2y",
          "type": "uint256"
        }
      ],
      "internalType": "struct PrivateToken.EncryptedAmount",
      "name": "EncryptedAmount",
      "type": "tuple"
    }, { name: "recipient", type: "bytes32" }],
    name: "messageToSign",
    outputs: [{ name: '', type: 'bytes' }],
    stateMutability: 'view',
    type: 'function'
  }
  const encoded = encodeFunctionData({ abi: [abiItem], args: ["0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368", "0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f", "0x20a08bc68201d32688f1ba415b168f1b78dfcb0af4c5c8741b8674d9aea97147", "0x137c478ed936487f6b0a7b850a256c8286c993a43f808ade344aa1dcccd2e126"] })
  // account.signMessage()
  const secret =
    1689864850468855828250823872708791511002885372117465812379247895436524654321621597677787n;

  console.log(toHex(secret % BJJ_PRIME))

}

main();
