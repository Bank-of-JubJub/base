import { TomlKeyValue } from "./createToml";
import { runNargoProve } from "./generateNargoProof";
import { createAndWriteToml } from "./createToml";

async function main() {
  const proofInputs: Array<TomlKeyValue> = [
    {
      key: "randomness",
      value:
        "168986485046885582825082387270879151100288537211746581237924789162159767775",
    },
    {
      key: "amount_sum",
      value: 999,
    },
    {
      key: "packed_public_key",
      value: [
        220, 159, 159, 219, 116, 109, 15, 7, 176, 4, 204, 67, 22, 227, 73, 90,
        88, 87, 11, 144, 102, 20, 153, 248, 166, 166, 105, 111, 244, 21, 107,
        170,
      ],
    },
    {
      key: "old_enc_balance_1",
      value: {
        x: "0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368",
        y: "0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f",
      },
    },
    {
      key: "old_enc_balance_2",
      value: {
        x: "0x26e2d952913cecf5261ce7caea0ded4a9c46a3a10dda292c565868d5f98aa5db",
        y: "0x1e8449b223a9d7b6215d5976bd0bec814de2115961f71590878e389a1cff5d09",
      },
    },
    {
      key: "new_enc_balance_1",
      value: {
        x: "0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0",
        y: "0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2",
      },
    },
    {
      key: "new_enc_balance_2",
      value: {
        x: "0x06deb02e81b49cc0e215e0453b6135d52827629df1a12914da953199d39f333b",
        y: "0x211de3374abedea3113aa1f312173764eb804dab7ead931971a4dbba832baf00",
      },
    },
  ];
  createAndWriteToml(
    "../../circuits/process_pending_deposits/Test.toml",
    proofInputs
  );
  await runNargoProve("process_pending_deposits", "Test.toml");

  console;
}

main();
