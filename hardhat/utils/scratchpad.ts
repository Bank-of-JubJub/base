import { ethers } from "ethers";
import { bytesToBigInt, hexToBigInt, toBytes, toHex } from "viem";
import BabyJubJubUtils from "./babyJubJubUtils";
import { getDecryptedValue, getEncryptedValue } from "./utils";
import { BojAccount } from "./types";
import { generatePrivateKey, privateKeyToAccount } from "viem/accounts";
import dotenv from "dotenv";
dotenv.config({ path: "../.env" });
import { SMT, ChildNodes, HashFunction } from "@zk-kit/smt";
// @ts-ignore
import { poseidon } from "circomlibjs";
import { BJJ_PRIME } from "./constants";

async function main() {
  // The merkle tree represents blacklisted accounts
  const hash = (childNodes: ChildNodes) => poseidon(childNodes);
  const tree = new SMT(hash, true);

  // This entry indicates that the deposit at index 11, 12, 13 in the commitment tree are blacklisted
  tree.add(11n, 1n);
  tree.add(12n, 1n);
  tree.add(13n, 1n);
  // creates a non membership proof that the key 6 does not exist in the tree
  const nonMembershipProof = tree.createProof(6n);
  console.log(nonMembershipProof);
}

main();
