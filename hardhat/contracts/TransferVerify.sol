// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// import "hardhat/console.sol";
import {UltraVerifier as TransferVerifier} from "./transfer/plonk_vk.sol";
import "./PrivateToken.sol";

contract TransferVerify {
    struct LocalVars {
        uint256 fromModulus;
        uint256 toModulus;
        uint256 BJJ_PRIME;
        bytes32 messageHash;
        bytes32[] publicInputs;
        uint256 oldBalanceC1x;
        uint256 oldBalanceC1y;
        uint256 oldBalanceC2x;
        uint256 oldBalanceC2y;
    }

    TransferVerifier public transferVerifier;
    uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    constructor(address _transferVerifier) {
        transferVerifier = TransferVerifier(_transferVerifier);
    }

    function verifyTransfer(PrivateToken.TransferLocals memory inputs) external view {
        LocalVars memory local;

        local.toModulus = fromRprLe(inputs.to);
        local.fromModulus = fromRprLe(inputs.from);

        local.publicInputs = new bytes32[](17);
        local.publicInputs = _stageCommonTransferInputs(local, inputs);
        require(
            TransferVerifier(transferVerifier).verify(inputs.proof, local.publicInputs), "Transfer proof is invalid"
        );
    }

    function _stageCommonTransferInputs(LocalVars memory local, PrivateToken.TransferLocals memory inputs)
        internal
        pure
        returns (bytes32[] memory)
    {
        local.publicInputs[0] = bytes32(local.fromModulus);
        local.publicInputs[1] = bytes32(local.toModulus);
        local.publicInputs[2] = bytes32(uint256(inputs.processFee));
        local.publicInputs[3] = bytes32(uint256(inputs.relayFee));
        // this nonce should be unique because it uses the randomness calculated in the encrypted balance
        local.publicInputs[4] = bytes32(inputs.txNonce);
        local.publicInputs[5] = bytes32(inputs.oldBalance.C1x);
        local.publicInputs[6] = bytes32(inputs.oldBalance.C1y);
        local.publicInputs[7] = bytes32(inputs.oldBalance.C2x);
        local.publicInputs[8] = bytes32(inputs.oldBalance.C2y);
        local.publicInputs[9] = bytes32(inputs.amountToSend.C1x);
        local.publicInputs[10] = bytes32(inputs.amountToSend.C1y);
        local.publicInputs[11] = bytes32(inputs.amountToSend.C2x);
        local.publicInputs[12] = bytes32(inputs.amountToSend.C2y);
        local.publicInputs[13] = bytes32(inputs.senderNewBalance.C1x);
        local.publicInputs[14] = bytes32(inputs.senderNewBalance.C1y);
        local.publicInputs[15] = bytes32(inputs.senderNewBalance.C2x);
        local.publicInputs[16] = bytes32(inputs.senderNewBalance.C2y);
        return local.publicInputs;
    }

    function fromRprLe(bytes32 publicKey) internal view returns (uint256) {
        uint256 y = 0;
        uint256 v = 1;
        bytes memory publicKeyBytes = bytes32ToBytes(publicKey);
        for (uint8 i = 0; i < 32; i++) {
            y += (uint8(publicKeyBytes[i]) * v) % BJJ_PRIME;
            if (i != 31) {
                v *= 256;
            }
        }
        return y;
    }

    function bytes32ToBytes(bytes32 _data) public pure returns (bytes memory) {
        bytes memory byteArray = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            byteArray[i] = _data[i];
        }
        return byteArray;
    }
}
