import dotenv from "dotenv";
dotenv.config({ path: "../.env" });
import { IMT } from "@zk-kit/imt";
import { poseidon2, poseidon3 } from "poseidon-lite";
import { toHex } from "viem";
import { privateKeyToAccount } from "viem/accounts";

async function main() {
  const secret =
    168986485046885582825082387270879151100288537211746581237924789162159767777n;
  const amount = 10n;
  const account = privateKeyToAccount(process.env.PRIVATE_KEY as `0x${string}`);
  const commitment = poseidon3([account.address, amount, secret]);

  console.log(account.address);

  const tree = new IMT(poseidon2, 20, 0);
  tree.insert(commitment);

  console.log(toHex(commitment));

  const index = tree.indexOf(commitment);

  const proof = tree.createProof(index);
  console.log(proof);
}

main();
