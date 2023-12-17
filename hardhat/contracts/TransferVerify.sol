// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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

    constructor(
        address _transferVerifier,
        address _transfer4337Verifier,
        address _transferEthSignerVerifier,
        address _transferMultisigVerifier,
        address _accountController
    ) {
        transferVerifier = TransferVerifier(_transferVerifier);
        transfer4337Verifier = Transfer4337Verifier(_transfer4337Verifier);
        transferEthSignerVerifier = TransferEthSignerVerifier(_transferEthSignerVerifier);
        transferMultisigVerifier = TransferMultisigVerifier(_transferMultisigVerifier);
        accountController = AccountController(_accountController);
    }

    function verifyTransfer(
        PrivateToken.TransferLocals memory inputs // bytes32 from, // bytes32 to, // PrivateToken privateToken, // uint40 _processFee, // uint40 _relayFee, // PrivateToken.EncryptedAmount memory _amountToSend, // PrivateToken.EncryptedAmount memory _senderNewBalance, // AccountController accountController, // bytes memory _proof
    ) external {
        LocalVars memory local;
        local.BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

        (local.oldBalanceC1x, local.oldBalanceC1y, local.oldBalanceC2x, local.oldBalanceC2y) =
            inputs.privateToken.balances(inputs.from);

        local.messageHash = keccak256(abi.encodePacked(address(this), inputs.from, inputs.to, inputs.txNonce));
        local.messageHashModulus = uint256(local.messageHash) % local.BJJ_PRIME;
        local.toModulus = uint256(inputs.to) % local.BJJ_PRIME;
        local.fromModulus = uint256(inputs.from) % local.BJJ_PRIME;

        local.senderAccountType = accountController.getAccountType(inputs.from);

        if (local.senderAccountType == AccountController.AccountType.EthSigner) {
            // use the transfer_eth_signer circuit
            local.publicInputs = new bytes32[](18);
            {
                local.publicInputs = _stageCommonTransferInputs(
                    local.publicInputs,
                    local.fromModulus,
                    local.toModulus,
                    inputs.processFee,
                    inputs.relayFee,
                    inputs.txNonce,
                    local.oldBalanceC1x,
                    local.oldBalanceC1y,
                    local.oldBalanceC2x,
                    local.oldBalanceC2y,
                    inputs.amountToSend,
                    inputs.senderNewBalance
                );
            }
            {
                local.publicInputs[16] = bytes32(uint256(uint160(accountController.ethSigner(inputs.from))));
                local.publicInputs[17] = bytes32(local.messageHashModulus);
            }
            require(
                TransferEthSignerVerifier(transferEthSignerVerifier).verify(inputs.proof, local.publicInputs),
                "Eth signer transfer proof is invalid"
            );
        } else if (local.senderAccountType == AccountController.AccountType.erc4337Account) {
            local.publicInputs = new bytes32[](17);
            {
                local.publicInputs = _stageCommonTransferInputs(
                    local.publicInputs,
                    local.fromModulus,
                    local.toModulus,
                    inputs.processFee,
                    inputs.relayFee,
                    inputs.txNonce,
                    local.oldBalanceC1x,
                    local.oldBalanceC1y,
                    local.oldBalanceC2x,
                    local.oldBalanceC2y,
                    inputs.amountToSend,
                    inputs.senderNewBalance
                );
            }
            // msg.sender should be 4337 account address
            local.publicInputs[16] = bytes32(uint256(uint160(msg.sender)));

            require(
                Transfer4337Verifier(transfer4337Verifier).verify(inputs.proof, local.publicInputs),
                "4337 Transfer proof is invalid"
            );
        } else if (local.senderAccountType == AccountController.AccountType.Multisig) {
            local.publicInputs = new bytes32[](28);
            {
                local.publicInputs = _stageCommonTransferInputs(
                    local.publicInputs,
                    local.fromModulus,
                    local.toModulus,
                    inputs.processFee,
                    inputs.relayFee,
                    inputs.txNonce,
                    local.oldBalanceC1x,
                    local.oldBalanceC1y,
                    local.oldBalanceC2x,
                    local.oldBalanceC2y,
                    inputs.amountToSend,
                    inputs.senderNewBalance
                );
            }
            {
                AccountController.MultisigParams memory params = accountController.getMultisigEthSigners(inputs.from);
                for (uint8 i = 0; i < params.ethSigners.length; i++) {
                    local.publicInputs[17 + i] = bytes32(uint256(uint160(params.ethSigners[i])));
                }
                // local.publicInputs[79 + signers.length] = bytes32(
                //     uint256(multisigEthSigners[_from].threshold)
                // );
                // local.publicInputs[79 + signers.length + 1] = bytes32(
                //     messageHashModulus
                // );
                uint256 length = local.publicInputs.length;
                for (uint8 i = 0; i < params.ethSigners.length; i++) {
                    local.publicInputs[length + i] = bytes32(uint256(uint160(params.ethSigners[i])));
                }
                local.publicInputs[length + params.ethSigners.length] = bytes32(uint256(params.threshold));
                local.publicInputs[length + params.ethSigners.length + 1] = bytes32(local.messageHashModulus);
            }
            require(
                TransferMultisigVerifier(transferMultisigVerifier).verify(inputs.proof, local.publicInputs),
                "Multisig Transfer proof is invalid"
            );
        } else {
            local.publicInputs = new bytes32[](17);
            {
                local.publicInputs = _stageCommonTransferInputs(
                    local.publicInputs,
                    local.fromModulus,
                    local.toModulus,
                    inputs.processFee,
                    inputs.relayFee,
                    inputs.txNonce,
                    local.oldBalanceC1x,
                    local.oldBalanceC1y,
                    local.oldBalanceC2x,
                    local.oldBalanceC2y,
                    inputs.amountToSend,
                    inputs.senderNewBalance
                );
            }
            require(
                TransferVerifier(transferVerifier).verify(inputs.proof, local.publicInputs), "Transfer proof is invalid"
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
