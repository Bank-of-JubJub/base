// contracts/FunToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../PrivateToken.sol";

contract FundraiserContract {
    PrivateToken privateToken;

    // the recipient is the account that will receive the funds
    // users may want to verify that the recipient is the correct account (eg controlled by a multisig)
    mapping(bytes32 recipient => Fundraiser[] fundraisers) fundraisersMap;
    mapping(bytes32 sender => bool isPending) hasPendingContribution;

    struct Fundraiser {
        uint256 endTime; // a threshold must have been reached by this time for the fundraiser to be able to claim funds
        uint256 threshold;
        bool isThresholdMet;
        PrivateToken.EncryptedAmount amountContributed;
        PendingContribution[] contributions;
    }

    struct PendingContribution {
        bytes32 to;
        bytes32 from;
        PrivateToken.EncryptedAmount amountToSend;
        PrivateToken.EncryptedAmount senderNewBalance;
        bytes proof_transfer;
    }

    constructor(address _privateToken) {
        privateToken = PrivateToken(_privateToken);
    }

    function createFundriser(
        bytes32 _recipient,
        uint256 _endTime,
        uint256 _threshold,
        PrivateToken.EncryptedAmount memory encryptedZero
    ) public {
        bool isThresholdMet = false;
        if (_threshold == 0) {
            isThresholdMet = true;
        }
        Fundraiser memory fundraiser = Fundraiser({
            endTime: _endTime,
            threshold: _threshold,
            isThresholdMet: isThresholdMet,
            amountContributed: encryptedZero,
            contributions: new PendingContribution[](0)
        });
        fundraisersMap[_recipient].push(fundraiser);

        // TODO: write a circuit to check that encryptedZero is correct
    }

    function contribute(
        uint256 fundraiserIndex,
        bytes32 _to,
        bytes32 _from,
        uint40 _relayFee,
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
            amountToSend: _amountToSend,
            senderNewBalance: _senderNewBalance,
            proof_transfer: _proof_transfer
        });

        // TODO: handle relay fee
        // TODO: circuit to verify that inputs are valid and amount contributed is increased properly
        // essentially the verify transfer logic to verify the transfer is valid
        // and the process_transfer logic to verify the amount contributed is increased properly

        // TODO: need verify 2 proofs.
        // 1. verify transfer
        // 2. verify increaseAmountContributed

        Fundraiser memory f = fundraisersMap[_to][fundraiserIndex];
        // circuit to check correctly increased amount contributed
        f.amountContributed = _newAmountContributed;
        fundraisersMap[_to][fundraiserIndex].contributions.push(pendingContribution);
        hasPendingContribution[_from] = true;
    }

    // TODO: need to create a circuit to validate this is coming from the correct account
    function revokeContribution(bytes32 _to, bytes32 _from, uint256 fundraiserIndex, uint256 contributionIndex)
        public
    {}

    function setThresholdMet(bytes32 recipient, uint256 fundraiserIndex, bytes memory proof) public {
        Fundraiser memory f = fundraisersMap[recipient][fundraiserIndex];
        // TODO: write a circuit that allows the recipient to prove that the
        // f.amountContributed >= threshold
    }

    function processContributions(bytes32 _to, uint256 fundraiserIndex) public {
        require(fundraisersMap[_to][fundraiserIndex].endTime >= block.timestamp, "Fundraiser must be over");
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
                0, // relay fee
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
