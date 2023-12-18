// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "hardhat/console.sol";
import {UltraVerifier as WithdrawVerifier} from "./withdraw/plonk_vk.sol";
import {UltraVerifier as Withdraw4337Verifier} from "./withdraw_4337/plonk_vk.sol";
import {UltraVerifier as WithdrawEthSignerVerifier} from "./withdraw_eth_signer/plonk_vk.sol";
import {UltraVerifier as WithdrawMultisigVerifier} from "./withdraw_multisig/plonk_vk.sol";
import "./PrivateToken.sol";
import "./AccountController.sol";

contract WithdrawVerify {
    WithdrawVerifier public withdrawVerifier;
    Withdraw4337Verifier public withdraw4337Verifier;
    WithdrawEthSignerVerifier public withdrawEthSignerVerifier;
    WithdrawMultisigVerifier public withdrawMultisigVerifier;
    AccountController public accountController;
    uint256 BJJ_PRIME =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    constructor(
        address _withdrawVerifier,
        address _withdraw4337Verifier,
        address _withdrawEthSignerVerifier,
        address _withdrawMultisigVerifier,
        address _accountController
    ) {
        withdrawVerifier = WithdrawVerifier(_withdrawVerifier);
        withdraw4337Verifier = Withdraw4337Verifier(_withdraw4337Verifier);
        withdrawEthSignerVerifier = WithdrawEthSignerVerifier(
            _withdrawEthSignerVerifier
        );
        withdrawMultisigVerifier = WithdrawMultisigVerifier(
            _withdrawMultisigVerifier
        );
        accountController = AccountController(_accountController);
    }

    struct Locals {
        bytes32 messageHash;
        uint256 messageHashModulus;
        uint256 fromModulus;
        AccountController.AccountType senderAccountType;
        bytes32[] publicInputs;
    }

    function verifyWithdraw(
        PrivateToken.WithdrawLocals memory inputs // bytes32 inputs.from, // address _to, // uint256 _txNonce, // uint256 _amount, // uint256 _relayFee, // PrivateToken.EncryptedAmount memory _oldEncryptedAmount, // PrivateToken.EncryptedAmount memory _newEncryptedAmount, // bytes memory _withdraw_proof
    ) external {
        Locals memory local;
        local.messageHash = keccak256(
            abi.encodePacked(
                address(this),
                inputs.from,
                inputs.to,
                inputs.txNonce
            )
        );
        local.messageHashModulus = fromRprLe(local.messageHash);
        local.fromModulus = fromRprLe(inputs.from);
        AccountController.AccountType senderAccountType = accountController
            .getAccountType(inputs.from);

        if (
            local.senderAccountType == AccountController.AccountType.EthSigner
        ) {
            local.publicInputs = new bytes32[](14);
            local.publicInputs = _stageCommonWithdrawInputs(local, inputs);
            local.publicInputs[local.publicInputs.length + 1] = bytes32(
                uint256(uint160(accountController.ethSigner(inputs.from)))
            );
            local.publicInputs[local.publicInputs.length + 2] = bytes32(
                local.messageHashModulus
            );
            require(
                withdrawEthSignerVerifier.verify(
                    inputs.proof,
                    local.publicInputs
                ),
                "Withdraw proof is invalid"
            );
        } else if (
            local.senderAccountType ==
            AccountController.AccountType.erc4337Account
        ) {
            local.publicInputs = new bytes32[](13);
            local.publicInputs = _stageCommonWithdrawInputs(local, inputs);
            local.publicInputs[local.publicInputs.length + 1] = bytes32(
                uint256(uint160(msg.sender))
            );
            require(
                withdraw4337Verifier.verify(inputs.proof, local.publicInputs),
                "Withdraw proof is invalid"
            );
        } else if (
            senderAccountType == AccountController.AccountType.Multisig
        ) {
            bytes32[] memory publicInputs = new bytes32[](22);
            publicInputs = _stageCommonWithdrawInputs(local, inputs);
            AccountController.MultisigParams memory params = accountController
                .getMultisigEthSigners(inputs.from);
            for (uint8 i = 0; i < params.ethSigners.length; i++) {
                local.publicInputs[17 + i] = bytes32(
                    uint256(uint160(params.ethSigners[i]))
                );

                uint256 length = publicInputs.length;
                for (uint8 i = 0; i < params.ethSigners.length; i++) {
                    local.publicInputs[length + i] = bytes32(
                        uint256(uint160(params.ethSigners[i]))
                    );
                }
                local.publicInputs[length + params.ethSigners.length] = bytes32(
                    uint256(params.threshold)
                );
                local.publicInputs[
                    length + params.ethSigners.length + 1
                ] = bytes32(local.messageHashModulus);
            }
            require(
                withdrawMultisigVerifier.verify(
                    inputs.proof,
                    local.publicInputs
                ),
                "Withdraw proof is invalid"
            );
        } else {
            local.publicInputs = new bytes32[](12);
            local.publicInputs = _stageCommonWithdrawInputs(local, inputs);
            require(
                withdrawVerifier.verify(inputs.proof, local.publicInputs),
                "Withdraw proof is invalid"
            );
        }
    }

    function _stageCommonWithdrawInputs(
        Locals memory local,
        PrivateToken.WithdrawLocals memory inputs
    ) internal pure returns (bytes32[] memory) {
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
