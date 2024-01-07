// contracts/FunToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../PrivateToken.sol";
import "../TransferVerify.sol";
import {UltraVerifier as AdditionVerifier} from "../correct_addition/plonk_vk.sol";
import {UltraVerifier as ThresholdVerifier} from "../met_threshold/plonk_vk.sol";
import {UltraVerifier as ZeroVerifier} from "../correct_zero/plonk_vk.sol";

contract FundraiserContract {
    PrivateToken privateToken;
    TransferVerify transferVerify;
    AdditionVerifier additionVerifier;
    ThresholdVerifier thresholdVerifier;
    ZeroVerifier zeroVerifier;

    // the recipient is the account that will receive the funds
    // users may want to verify that the recipient is the correct account (eg controlled by a multisig)
    mapping(bytes32 recipient => Fundraiser[] fundraisers) fundraisersMap;
    mapping(bytes32 sender => bool isPending) hasPendingContribution;

    struct Fundraiser {
        // removed endTime,  probably not needed
        uint256 threshold;
        bool isThresholdMet;
        PrivateToken.EncryptedAmount amountContributed;
        PendingContribution[] contributions;
    }

    struct PendingContribution {
        bytes32 to;
        bytes32 from;
        uint40 relayFee; // this wont be paid until the fundraiser is over, and only if it's successful
        address relayFeeRecipient;
        uint40 processFee; // consider removing this, the fundraiser is incentivized to pay it if it's successful
        PrivateToken.EncryptedAmount amountToSend;
        PrivateToken.EncryptedAmount senderNewBalance;
        bytes proof_transfer;
    }

    constructor(
        address _privateToken,
        address _transferVerify,
        address _additionVerifier,
        address _thresholdVerifier,
        address _zeroVerifier
    ) {
        privateToken = PrivateToken(_privateToken);
        transferVerify = TransferVerify(_transferVerify);
        additionVerifier = AdditionVerifier(_additionVerifier);
        thresholdVerifier = ThresholdVerifier(_thresholdVerifier);
        zeroVerifier = ZeroVerifier(_zeroVerifier);
    }

    function createFundriser(
        bytes32 _recipient,
        uint256 _threshold,
        PrivateToken.EncryptedAmount memory encryptedZero,
        bytes memory _proof
    ) public {
        bool isThresholdMet = false;
        if (_threshold == 0) {
            isThresholdMet = true;
        }
        Fundraiser memory fundraiser = Fundraiser({
            threshold: _threshold,
            isThresholdMet: isThresholdMet,
            amountContributed: encryptedZero,
            contributions: new PendingContribution[](0)
        });
        fundraisersMap[_recipient].push(fundraiser);
        bytes32[] memory publicInputs = new bytes32[](36);
        for (uint8 i = 0; i < 32; i++) {
            // Noir takes an array of 32 bytes32 as public inputs
            bytes1 aByte = bytes1((_recipient << (i * 8)));
            publicInputs[i] = bytes32(uint256(uint8(aByte)));
        }
        publicInputs[32] = bytes32(encryptedZero.C1x);
        publicInputs[33] = bytes32(encryptedZero.C1y);
        publicInputs[34] = bytes32(encryptedZero.C2x);
        publicInputs[35] = bytes32(encryptedZero.C2y);
        zeroVerifier.verify(_proof, publicInputs);
    }

    function contribute(
        uint256 fundraiserIndex,
        bytes32 _to,
        bytes32 _from,
        uint40 _relayFee, // relay fee is only paid if the fundraiser is successful
        address _relayFeeRecipient,
        PrivateToken.EncryptedAmount calldata _amountToSend,
        PrivateToken.EncryptedAmount calldata _senderNewBalance,
        bytes memory _proof_transfer,
        bytes memory _proof_increaseAmountContributed,
        PrivateToken.EncryptedAmount memory _newAmountContributed
    ) public {
        require(privateToken.lockedTo(_from) == address(this), "Not locked to fundraiser");
        PendingContribution memory pendingContribution = PendingContribution({
            to: _to,
            from: _from,
            relayFee: _relayFee,
            relayFeeRecipient: _relayFeeRecipient,
            amountToSend: _amountToSend,
            senderNewBalance: _senderNewBalance,
            proof_transfer: _proof_transfer
        });

        uint256 txNonce = uint256(keccak256(abi.encode(_amountToSend))) % BJJ_PRIME;
        require(privateToken.nonce(_from)(txNonce) == false, "Nonce must be unused");
        PrivateToken.TransferLocals memory locals = PrivateToken.TransferLocals({
            to: _to,
            from: _from,
            processFee: 0, // fundraisers are incentivized to pay the process fee if the fundraiser is successful
            relayFee: _relayFee,
            txNonce: txNonce,
            oldBalance: privateToken.balances(_from),
            amountToSend: _amountToSend,
            receiverBalance: privateToken.balances(_to),
            senderNewBalance: _senderNewBalance,
            proof: _proof_transfer
        });

        Fundraiser memory f = fundraisersMap[_to][fundraiserIndex];

        // 1. verifies that the transfer is valid
        transferVerify.verifyTransfer(locals);

        // 2. verify increaseAmountContributed
        bytes32[] memory publicInputs = new bytes32[](12);
        publicInputs[0] = bytes32(f.amountContributed.C1x);
        publicInputs[1] = bytes32(f.amountContributed.C1y);
        publicInputs[2] = bytes32(f.amountContributed.C2x);
        publicInputs[3] = bytes32(f.amountContributed.C2y);
        publicInputs[4] = bytes32(_amountToSend.C1x);
        publicInputs[5] = bytes32(_amountToSend.C1y);
        publicInputs[6] = bytes32(_amountToSend.C2x);
        publicInputs[7] = bytes32(_amountToSend.C2y);
        publicInputs[8] = bytes32(_newAmountContributed.C1x);
        publicInputs[9] = bytes32(_newAmountContributed.C1y);
        publicInputs[10] = bytes32(_newAmountContributed.C2x);
        publicInputs[11] = bytes32(_newAmountContributed.C2y);

        // verifies that the amount contributed has been correctly updated
        additionVerifier.verify(_proof_increaseAmountContributed, publicInputs);

        // circuit to check correctly increased amount contributed
        f.amountContributed = _newAmountContributed;
        fundraisersMap[_to][fundraiserIndex].contributions.push(pendingContribution);
        hasPendingContribution[_from] = true;
    }

    // cant have a revoke function, no way to decrement the Fundraiser.amountContributed
    // function revokeContribution()

    // the recipient is the only account that can create a proof that the threshold has been met
    function setThresholdMet(bytes32 recipient, uint256 fundraiserIndex, bytes memory proof) public {
        fundraisersMap[recipient][fundraiserIndex].isThresholdMet = true;
        Fundraiser memory f = fundraisersMap[recipient][fundraiserIndex];

        bytes32[] memory publicInputs = new bytes32[](5);
        publicInputs[0] = bytes32(f.amountContributed.C1x);
        publicInputs[1] = bytes32(f.amountContributed.C1y);
        publicInputs[2] = bytes32(f.amountContributed.C2x);
        publicInputs[3] = bytes32(f.amountContributed.C2y);
        publicInputs[4] = bytes32(f.threshold);

        // checks that the threshold has been met without revealing the specific amount raised
        thresholdVerifier.verify(proof, publicInputs);
    }

    function processContributions(bytes32 _to, uint256 fundraiserIndex) public {
        // is this needed?
        // require(fundraisersMap[_to][fundraiserIndex].endTime >= block.timestamp, "Fundraiser must be over");
        Fundraiser memory f = fundraisersMap[_to][fundraiserIndex];
        require(f.isThresholdMet, "Fundraising threshold must be met");
        PendingContribution[] memory contributions = f.contributions;

        // TODO: handle 10(?) deposits per tx
        for (uint256 i = 0; i < contributions.length; i++) {
            PendingContribution memory contribution = contributions[i];
            privateToken.transfer(
                contribution.to,
                contribution.from,
                0, // process fee
                contribution.relayFee, // relay fee
                address(0), // relay fee recipient
                contribution.amountToSend,
                contribution.senderNewBalance,
                contribution.proof_transfer
            );
            // must not have a pending contribution to unlock the account
            hasPendingContribution[contribution.from] = false;
        }
    }

    function unlock(bytes32 _account) public {
        require(!hasPendingContribution[_account], "Has pending contribution");
        privateToken.unlock(_account);
    }
}
