import lock from "../target/lock.json" assert { type: "json" };
import withdraw from "../target/withdraw.json" assert { type: "json" };
import transfer from "../target/transfer.json" assert { type: "json" };
import process_pending_deposits from "../target/process_pending_deposits.json" assert { type: "json" };
import process_pending_transfers from "../target/process_pending_transfers.json" assert { type: "json" };
import { BarretenbergBackend } from "@noir-lang/backend_barretenberg";
import { Noir } from "@noir-lang/noir_js";

export async function genProof(circuit_name: string, inputs: any) {
  if (typeof inputs === "string") {
    inputs = JSON.parse(inputs); // this is to be able to use the cli_utils.js to generate proofs, otherwise, if genProof is called in the front-end, inputs should be an object with BigInt values : see examples in the commented tests at the bottom of this file
  }
  let noir;
  let backend;
  switch (circuit_name) {
    case "lock":
      backend = new BarretenbergBackend(lock as any);
      noir = new Noir(lock as any, backend);
      break;
    case "transfer":
      backend = new BarretenbergBackend(transfer as any);
      noir = new Noir(transfer as any, backend);
      break;
    case "withdraw":
      backend = new BarretenbergBackend(withdraw as any);
      noir = new Noir(withdraw as any, backend);
      break;
    case "processPendingDeposits":
      backend = new BarretenbergBackend(process_pending_deposits as any);
      noir = new Noir(process_pending_deposits as any, backend);
      break;
    case "processPendingTransfers":
      backend = new BarretenbergBackend(process_pending_transfers as any);
      noir = new Noir(process_pending_transfers as any, backend);
      break;
    default:
      console.log(`Circuit name not recognized`);
      return;
  }

  console.log("Witness generated!");
  const proofData = await noir.generateFinalProof(inputs);
  console.log("Proof generated!");
  await noir.verifyFinalProof(proofData);
  console.log("Proof verified!");

  return proofData;
}

// Tests (same as in the Noir files) : uncomment and run with node

const inputs_lock = {
  private_key: BigInt(
    "2291123624948246627368989940774052753470489062495018070576418670157516550852"
  ),
  randomness: BigInt(
    "168986485046885582825082387270879151100288537211746581237924789162159767775"
  ),
  public_key_x: BigInt(
    "11035571757224451620605786890790132844722231619710976007063020523319248877914"
  ),
  public_key_y: BigInt(
    "19186343803061871491190042465391631772251521601054015091722300428018876653532"
  ),
  value: BigInt("1000000000000"),
  C1_x: BigInt(
    "1496197583352242063455862221527010906604817232528901172130809043230997246824"
  ),
  C1_y: BigInt(
    "4254363608840175473367393558422388112815775052382181131620648571022664794991"
  ),
  C2_x: BigInt(
    "7863058870347436223955035015287191170578415873725324596171614557902562847106"
  ),
  C2_y: BigInt(
    "17145727302716684772667316947417711987630303167052440083419636140655821422533"
  ),
};

const inputs_process_deposits = {
  randomness:
    "168986485046885582825082387270879151100288537211746581237924789162159767775",
  packed_public_key: [
    "0xdc",
    "0x9f",
    "0x9f",
    "0xdb",
    "0x74",
    "0x6d",
    "0x0f",
    "0x07",
    "0xb0",
    "0x04",
    "0xcc",
    "0x43",
    "0x16",
    "0xe3",
    "0x49",
    "0x5a",
    "0x58",
    "0x57",
    "0x0b",
    "0x90",
    "0x66",
    "0x14",
    "0x99",
    "0xf8",
    "0xa6",
    "0xa6",
    "0x69",
    "0x6f",
    "0xf4",
    "0x15",
    "0x6b",
    "0xaa",
  ],
  amount_sum: 100,
  old_enc_balance_1: {
    x: "0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368",
    y: "0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f",
  },
  old_enc_balance_2: {
    x: "0x26e2d952913cecf5261ce7caea0ded4a9c46a3a10dda292c565868d5f98aa5db",
    y: "0x1e8449b223a9d7b6215d5976bd0bec814de2115961f71590878e389a1cff5d09",
  },
  new_enc_balance_1: {
    x: "0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0",
    y: "0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2",
  },
  new_enc_balance_2: {
    x: "0x15f22eb9e5e68af082365afb12c83997d06514835e1a34cf787d3b65831a03a2",
    y: "0x043495e2d574a451ed777f379c85fe3ac5230909f6aace57ff1900ebb74da265",
  },
};

let pendingDepositProof = await genProof(
  "processPendingDeposits",
  inputs_process_deposits
);
console.log(uint8ArrayToHex(pendingDepositProof!.proof));

function uint8ArrayToHex(buffer: Uint8Array): string {
  return Array.from(buffer)
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}
