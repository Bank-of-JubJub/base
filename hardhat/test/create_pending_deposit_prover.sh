#!/bin/bash

filePath = "../../circuits/process_pending_deposits/Test.toml"

# Assign variables from the passed arguments
randomness=$1
amount_sum=$2
packed_public_key=(${@:3:32})  # Next 32 arguments are the public key
old_enc_balance_1_x=${@: -8}    # Last 8 arguments
old_enc_balance_1_y=${@: -7}
old_enc_balance_2_x=${@: -6}
old_enc_balance_2_y=${@: -5}
new_enc_balance_1_x=${@: -4}
new_enc_balance_1_y=${@: -3}
new_enc_balance_2_x=${@: -2}
new_enc_balance_2_y=${@: -1}

echo "randomness = \"$randomness\"" > filePath
echo "amount_sum = $amount_sum" >> filePath

echo "packed_public_key = [" >> filePath
for val in "${packed_public_key[@]}"; do
    echo "  $val," >> filePath
done
echo "]" >> filePath

echo "[old_enc_balance_1]" >> filePath
echo "x=\"$old_enc_balance_1_x\"" >> filePath
echo "y=\"$old_enc_balance_1_y\"" >> filePath

echo "[old_enc_balance_2]" >> filePath
echo "x=\"$old_enc_balance_2_x\"" >> filePath
echo "y=\"$old_enc_balance_2_y\"" >> filePath

echo "[new_enc_balance_1]" >> filePath
echo "x=\"$new_enc_balance_1_x\"" >> filePath
echo "y=\"$new_enc_balance_1_y\"" >> filePath

echo "[new_enc_balance_2]" >> filePath
echo "x=\"$new_enc_balance_2_x\"" >> filePath
echo "y=\"$new_enc_balance_2_y\"" >> filePath

echo "$filePath file created successfully."