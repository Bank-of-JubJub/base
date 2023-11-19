import { exec } from "child_process";

export function runProcessDepositBash(
  randomness: bigint,
  amount_sum: number,
  packed_public_key: Uint8Array,
  old_enc_balance_1_x: string,
  old_enc_balance_1_y: string,
  old_enc_balance_2_x: string,
  old_enc_balance_2_y: string,
  new_enc_balance_1_x: string,
  new_enc_balance_1_y: string,
  new_enc_balance_2_x: string,
  new_enc_balance_2_y: string
) {
  // Convert packed_public_key array to string
  let packed_public_key_str = packed_public_key.join(" ");

  // Prepare the command
  let command = `./create_pending_deposit_prover.sh ${randomness} ${amount_sum} ${packed_public_key_str} \
   ${old_enc_balance_1_x} ${old_enc_balance_1_y}  ${old_enc_balance_2_x} ${old_enc_balance_2_y} \
   ${new_enc_balance_1_x} ${new_enc_balance_1_y}  ${new_enc_balance_2_x} ${new_enc_balance_2_y}`;

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
    console.error(`stderr: ${stderr}`);
  });
}
