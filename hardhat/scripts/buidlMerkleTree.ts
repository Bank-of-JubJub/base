import dotenv from "dotenv";
dotenv.config({ path: "../.env" });
import { IMT } from "@zk-kit/imt";
import { poseidon2 } from "poseidon-lite";
import { toHex } from "viem";

async function main() {
  const secret =
    168986485046885582825082387270879151100288537211746581237924789162159767777n;
  const amount = 5n;
  const commitment = poseidon2([secret, amount]);

  const tree = new IMT(poseidon2, 20, 0);
  tree.insert(commitment);

  console.log(toHex(commitment));

  const index = tree.indexOf(commitment);

  const proof = tree.createProof(index);
  console.log(proof);
}

main();
