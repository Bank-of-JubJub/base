// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "hardhat/console.sol";
import {UltraVerifier as TransferVerifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as Transfer4337Verifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as TransferEthSignerVerifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as TransferMultisigVerifier} from "./transfer/plonk_vk.sol";
import "./PrivateToken.sol";
import "./AccountController.sol";

contract TransferVerify {
    struct LocalVars {
        uint256 fromModulus;
        uint256 toModulus;
        uint256 messageHashModulus;
        uint256 BJJ_PRIME;
        bytes32 messageHash;
        bytes32[] publicInputs;
        uint256 oldBalanceC1x;
        uint256 oldBalanceC1y;
        uint256 oldBalanceC2x;
        uint256 oldBalanceC2y;
        AccountController.AccountType senderAccountType;
    }

    TransferVerifier public transferVerifier;
    Transfer4337Verifier public transfer4337Verifier;
    TransferEthSignerVerifier public transferEthSignerVerifier;
    TransferMultisigVerifier public transferMultisigVerifier;
    AccountController public accountController;
    uint256 BJJ_PRIME =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    constructor(
        address _transferVerifier,
        address _transfer4337Verifier,
        address _transferEthSignerVerifier,
        address _transferMultisigVerifier,
        address _accountController
    ) {
        transferVerifier = TransferVerifier(_transferVerifier);
        transfer4337Verifier = Transfer4337Verifier(_transfer4337Verifier);
        transferEthSignerVerifier = TransferEthSignerVerifier(
            _transferEthSignerVerifier
        );
        transferMultisigVerifier = TransferMultisigVerifier(
            _transferMultisigVerifier
        );
        accountController = AccountController(_accountController);
    }

    function verifyTransfer(
        PrivateToken.TransferLocals memory inputs
    ) external {
        LocalVars memory local;
        local.messageHash = keccak256(
            abi.encodePacked(
                address(this),
                inputs.from,
                inputs.to,
                inputs.txNonce
            )
        );
        local.messageHashModulus = fromRprLe(local.messageHash);
        local.toModulus = fromRprLe(inputs.to);
        local.fromModulus = fromRprLe(inputs.from);

        local.senderAccountType = accountController.getAccountType(inputs.from);

        if (
            local.senderAccountType == AccountController.AccountType.EthSigner
        ) {
            // use the transfer_eth_signer circuit
            local.publicInputs = new bytes32[](18);
            local.publicInputs = _stageCommonTransferInputs(local, inputs);
            local.publicInputs[16] = bytes32(
                uint256(uint160(accountController.ethSigner(inputs.from)))
            );
            local.publicInputs[17] = bytes32(local.messageHashModulus);
            require(
                TransferEthSignerVerifier(transferEthSignerVerifier).verify(
                    inputs.proof,
                    local.publicInputs
                ),
                "Eth signer transfer proof is invalid"
            );
        } else if (
            local.senderAccountType ==
            AccountController.AccountType.erc4337Account
        ) {
            local.publicInputs = new bytes32[](17);
            local.publicInputs = _stageCommonTransferInputs(local, inputs);
            // msg.sender should be 4337 account address
            local.publicInputs[16] = bytes32(uint256(uint160(msg.sender)));

            require(
                Transfer4337Verifier(transfer4337Verifier).verify(
                    inputs.proof,
                    local.publicInputs
                ),
                "4337 Transfer proof is invalid"
            );
        } else if (
            local.senderAccountType == AccountController.AccountType.Multisig
        ) {
            local.publicInputs = new bytes32[](28);

            local.publicInputs = _stageCommonTransferInputs(local, inputs);

            AccountController.MultisigParams memory params = accountController
                .getMultisigEthSigners(inputs.from);
            for (uint8 i = 0; i < params.ethSigners.length; i++) {
                local.publicInputs[17 + i] = bytes32(
                    uint256(uint160(params.ethSigners[i]))
                );

                uint256 length = local.publicInputs.length;
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
                TransferMultisigVerifier(transferMultisigVerifier).verify(
                    inputs.proof,
                    local.publicInputs
                ),
                "Multisig Transfer proof is invalid"
            );
        } else {
            local.publicInputs = new bytes32[](17);
            local.publicInputs = _stageCommonTransferInputs(local, inputs);
            require(
                TransferVerifier(transferVerifier).verify(
                    inputs.proof,
                    local.publicInputs
                ),
                "Transfer proof is invalid"
            );
        }
    }

    function _stageCommonTransferInputs(
        LocalVars memory local,
        PrivateToken.TransferLocals memory inputs
    ) internal view returns (bytes32[] memory) {
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
