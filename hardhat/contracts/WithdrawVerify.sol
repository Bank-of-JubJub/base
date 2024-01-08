// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// import "hardhat/console.sol";
import {UltraVerifier as WithdrawVerifier} from "./withdraw/plonk_vk.sol";
import "./PrivateToken.sol";

contract WithdrawVerify {
    WithdrawVerifier public withdrawVerifier;
    uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    constructor(address _withdrawVerifier) {
        withdrawVerifier = WithdrawVerifier(_withdrawVerifier);
    }

    struct Locals {
        bytes32 messageHash;
        uint256 messageHashModulus;
        uint256 fromModulus;
        bytes32[] publicInputs;
    }

    function verifyWithdraw(
        PrivateToken.WithdrawLocals memory inputs // bytes32 inputs.from, // address _to, // uint256 _txNonce, // uint256 _amount, // uint256 _relayFee, // PrivateToken.EncryptedAmount memory _oldEncryptedAmount, // PrivateToken.EncryptedAmount memory _newEncryptedAmount, // bytes memory _withdraw_proof
    ) external view {
        Locals memory local;
        local.fromModulus = fromRprLe(inputs.from);

        local.publicInputs = new bytes32[](12);
        local.publicInputs = _stageCommonWithdrawInputs(local, inputs);
        require(withdrawVerifier.verify(inputs.proof, local.publicInputs), "Withdraw proof is invalid");
    }

    function _stageCommonWithdrawInputs(Locals memory local, PrivateToken.WithdrawLocals memory inputs)
        internal
        pure
        returns (bytes32[] memory)
    {
        local.publicInputs[0] = bytes32(local.fromModulus);
        local.publicInputs[1] = bytes32(inputs.txNonce);
        local.publicInputs[2] = bytes32(uint256(inputs.amount));
        local.publicInputs[3] = bytes32(uint256(inputs.relayFee));
        local.publicInputs[4] = bytes32(inputs.oldBalance.C1x);
        local.publicInputs[5] = bytes32(inputs.oldBalance.C1y);
        local.publicInputs[6] = bytes32(inputs.oldBalance.C2x);
        local.publicInputs[7] = bytes32(inputs.oldBalance.C2y);
        local.publicInputs[8] = bytes32(inputs.newBalance.C1x);
        local.publicInputs[9] = bytes32(inputs.newBalance.C1y);
        local.publicInputs[10] = bytes32(inputs.newBalance.C2x);
        local.publicInputs[11] = bytes32(inputs.newBalance.C2y);
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
