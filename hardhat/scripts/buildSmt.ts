import dotenv from "dotenv";
dotenv.config({ path: "../.env" });
import { SMT, ChildNodes } from "@zk-kit/smt";
// @ts-ignore
import { poseidon } from "circomlibjs";

/*

This sparse merkle tree is used to store the blacklisted accounts.
The leaves are key: value pairs, where key is the index of the deposit in the commitment tree.
The value is 1 if the account is blacklisted, 0 otherwise.

*/

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
