#!/bin/bash

LOCATIONS=(
    "lock"
    "process_pending_deposits"
    "process_pending_transfers"
    "transfer"
    "withdraw"
)

DEST_PATH="hardhat/contracts"

# Loop through each source path in PATHS
for LOCATION in "${LOCATIONS[@]}"; do
    # Check if the current source folder exists
    SRC_PATH="circuits/${LOCATION}/contract/${LOCATION}/plonk_vk.sol"
    if [[ -f "$SRC_PATH" ]]; then
        # Extract the folder name from the source path
        FOLDER_NAME=$(basename "$SRC_PATH")
        echo  "$DEST_PATH/{$LOCATION}/"
        # Use the cp command with the -r (recursive) option to copy the folder
        mkdir -p "$DEST_PATH/$LOCATION"
        cp -r "$SRC_PATH" "$DEST_PATH/$LOCATION/plonk_vk.sol"
        echo "Copied $SRC_PATH to $DEST_PATH/$LOCATION successfully!"
    else
        echo "Error: $SRC_PATH does not exist."
    fi
done
