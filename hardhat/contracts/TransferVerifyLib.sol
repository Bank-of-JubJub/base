// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {UltraVerifier as TransferVerifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as Transfer4337Verifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as TransferEthSignerVerifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as TransferMultisigVerifier} from "./transfer/plonk_vk.sol";
import "./PrivateToken.sol";
import "./AccountController.sol";

// Define your library here
library TransferVerifyLib {
    function verifyTransfer(
        uint256 txNonce,
        bytes32 from,
        bytes32 to,
        PrivateToken privateToken,
        uint40 _processFee,
        uint40 _relayFee,
        PrivateToken.EncryptedAmount memory _amountToSend,
        PrivateToken.EncryptedAmount memory _senderNewBalance,
        AccountController accountController,
        bytes memory _proof
    ) public {
        uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        TransferVerifier transferVerifier = privateToken.TRANSFER_VERIFIER();
        TransferEthSignerVerifier transferEthSignerVerifier = privateToken
            .TRANSFER_ETH_SIGNER_VERIFIER();
        Transfer4337Verifier transfer4337Verifier = privateToken
            .TRANSFER_4337_VERIFIER();
        TransferMultisigVerifier transferMultisigVerifier = privateToken
            .TRANSFER_MULTISIG_VERIFIER();

        (
            uint256 oldBalanceC1x,
            uint256 oldBalanceC1y,
            uint256 oldBalanceC2x,
            uint256 oldBalanceC2y
        ) = privateToken.balances(from);

        bytes32 messageHash = keccak256(
            abi.encodePacked(address(this), from, to, txNonce)
        );
        uint256 messageHashModulus = uint256(messageHash) % BJJ_PRIME;
        uint256 toModulus = uint256(to) % BJJ_PRIME;
        uint256 fromModulus = uint256(from) % BJJ_PRIME;

        AccountController.AccountType senderAccountType = accountController
            .getAccountType(from);

        if (senderAccountType == AccountController.AccountType.EthSigner) {
            // use the transfer_eth_signer circuit
            bytes32[] memory publicInputs = new bytes32[](18);
            publicInputs = _stageCommonTransferInputs(
                publicInputs,
                fromModulus,
                toModulus,
                _processFee,
                _relayFee,
                txNonce,
                oldBalanceC1x,
                oldBalanceC1y,
                oldBalanceC2x,
                oldBalanceC2y,
                _amountToSend,
                _senderNewBalance
            );
            publicInputs[16] = bytes32(
                uint256(uint160(accountController.ethSigner(from)))
            );
            publicInputs[17] = bytes32(messageHashModulus);

            require(
                TransferEthSignerVerifier(transferEthSignerVerifier).verify(
                    _proof,
                    publicInputs
                ),
                "Eth signer transfer proof is invalid"
            );
        } else if (
            senderAccountType == AccountController.AccountType.erc4337Account
        ) {
            bytes32[] memory publicInputs = new bytes32[](17);
            publicInputs = _stageCommonTransferInputs(
                publicInputs,
                fromModulus,
                toModulus,
                _processFee,
                _relayFee,
                txNonce,
                oldBalanceC1x,
                oldBalanceC1y,
                oldBalanceC2x,
                oldBalanceC2y,
                _amountToSend,
                _senderNewBalance
            );
            // msg.sender should be 4337 account address
            publicInputs[16] = bytes32(uint256(uint160(msg.sender)));

            require(
                Transfer4337Verifier(transfer4337Verifier).verify(
                    _proof,
                    publicInputs
                ),
                "4337 Transfer proof is invalid"
            );
        } else if (
            senderAccountType == AccountController.AccountType.Multisig
        ) {
            bytes32[] memory publicInputs = new bytes32[](28);
            publicInputs = _stageCommonTransferInputs(
                publicInputs,
                fromModulus,
                toModulus,
                _processFee,
                _relayFee,
                txNonce,
                oldBalanceC1x,
                oldBalanceC1y,
                oldBalanceC2x,
                oldBalanceC2y,
                _amountToSend,
                _senderNewBalance
            );
            AccountController.MultisigParams memory params = accountController
                .getMultisigEthSigners(from);
            for (uint8 i = 0; i < params.ethSigners.length; i++) {
                publicInputs[17 + i] = bytes32(
                    uint256(uint160(params.ethSigners[i]))
                );
            }
            // local.publicInputs[79 + signers.length] = bytes32(
            //     uint256(multisigEthSigners[_from].threshold)
            // );
            // local.publicInputs[79 + signers.length + 1] = bytes32(
            //     messageHashModulus
            // );
            uint256 length = publicInputs.length;
            for (uint8 i = 0; i < params.ethSigners.length; i++) {
                publicInputs[length + i] = bytes32(
                    uint256(uint160(params.ethSigners[i]))
                );
            }
            publicInputs[length + params.ethSigners.length] = bytes32(
                uint256(params.threshold)
            );
            publicInputs[length + params.ethSigners.length + 1] = bytes32(
                messageHashModulus
            );
            require(
                TransferMultisigVerifier(transferMultisigVerifier).verify(
                    _proof,
                    publicInputs
                ),
                "Multisig Transfer proof is invalid"
            );
        } else {
            bytes32[] memory publicInputs = new bytes32[](17);
            publicInputs = _stageCommonTransferInputs(
                publicInputs,
                fromModulus,
                toModulus,
                _processFee,
                _relayFee,
                txNonce,
                oldBalanceC1x,
                oldBalanceC1y,
                oldBalanceC2x,
                oldBalanceC2y,
                _amountToSend,
                _senderNewBalance
            );
            require(
                TransferVerifier(transferVerifier).verify(_proof, publicInputs),
                "Transfer proof is invalid"
            );
        }
    }

    function _stageCommonTransferInputs(
        bytes32[] memory publicInputs,
        uint256 _fromModulus,
        uint256 _toModulus,
        uint40 _processFee,
        uint40 _relayFee,
        uint256 txNonce,
        uint256 oldBalanceC1x,
        uint256 oldBalanceC1y,
        uint256 oldBalanceC2x,
        uint256 oldBalanceC2y,
        PrivateToken.EncryptedAmount memory _amountToSend,
        PrivateToken.EncryptedAmount memory _senderNewBalance
    ) internal pure returns (bytes32[] memory) {
        publicInputs[0] = bytes32(_fromModulus);
        publicInputs[1] = bytes32(_toModulus);
        publicInputs[2] = bytes32(uint256(_processFee));
        publicInputs[3] = bytes32(uint256(_relayFee));
        // this nonce should be unique because it uses the randomness calculated in the encrypted balance
        publicInputs[4] = bytes32(txNonce);
        publicInputs[5] = bytes32(oldBalanceC1x);
        publicInputs[6] = bytes32(oldBalanceC1y);
        publicInputs[7] = bytes32(oldBalanceC2x);
        publicInputs[8] = bytes32(oldBalanceC2y);
        publicInputs[9] = bytes32(_amountToSend.C1x);
        publicInputs[10] = bytes32(_amountToSend.C1y);
        publicInputs[11] = bytes32(_amountToSend.C2x);
        publicInputs[12] = bytes32(_amountToSend.C2y);
        publicInputs[13] = bytes32(_senderNewBalance.C1x);
        publicInputs[14] = bytes32(_senderNewBalance.C1y);
        publicInputs[15] = bytes32(_senderNewBalance.C2x);
        publicInputs[16] = bytes32(_senderNewBalance.C2y);
        return publicInputs;
    }
}
