// contracts/FunToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../PrivateToken.sol";
import "../TransferVerify.sol";
import "../AccountController.sol";
import {UltraVerifier as AdditionVerifier} from "../correct_addition/plonk_vk.sol";
import {UltraVerifier as ThresholdVerifier} from "../met_threshold/plonk_vk.sol";
import {UltraVerifier as ZeroVerifier} from "../correct_zero/plonk_vk.sol";
import {UltraVerifier as RevokeVerifier} from "../revoke_contribution/plonk_vk.sol";

contract FundraiserContract {
    PrivateToken privateToken;
    TransferVerify transferVerify;
    AdditionVerifier additionVerifier;
    ThresholdVerifier thresholdVerifier;
    ZeroVerifier zeroVerifier;
    RevokeVerifier revokeVerifier;
    AccountController accountController;

    // the recipient is the account that will receive the funds
    // users may want to verify that the recipient is the correct account (eg controlled by a multisig)
    mapping(bytes32 recipient => Fundraiser[] fundraisers) fundraisersMap;
    mapping(bytes32 sender => bool isPending) hasPendingContribution;
    uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    struct Fundraiser {
        uint256 endTime;
        uint256 threshold;
        bool isThresholdMet;
        PrivateToken.EncryptedAmount amountContributed;
        uint256 contributionCount;
        mapping(uint256 => PendingContribution) contributions;
    }
    // PendingContribution[] contributions;

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

    event Contribution(bytes32 to, bytes32 from, uint256 fundraiserIndex);
    event RevokedContribution(bytes32 to, bytes32 from, uint256 fundraiserIndex, uint256 contributionIndex);
    event ThresholdMet(bytes32 recipient, uint256 fundraiserIndex);
    event ContributionProcessed(bytes32 to, bytes32 from, uint256 fundraiserIndex, uint256 contributionIndex);
    event ManyProcessed(bytes32 _to, uint256 _fundraiserIndex, uint256 _startIndex);

    constructor(
        address _privateToken,
        address _transferVerify,
        address _additionVerifier,
        address _thresholdVerifier,
        address _zeroVerifier,
        address _accountController,
        address _revokeVerifier
    ) {
        privateToken = PrivateToken(_privateToken);
        transferVerify = TransferVerify(_transferVerify);
        additionVerifier = AdditionVerifier(_additionVerifier);
        thresholdVerifier = ThresholdVerifier(_thresholdVerifier);
        zeroVerifier = ZeroVerifier(_zeroVerifier);
        accountController = AccountController(_accountController);
        revokeVerifier = RevokeVerifier(_revokeVerifier);
    }

    function createFundriser(
        bytes32 _recipient,
        uint256 _threshold,
        PrivateToken.EncryptedAmount memory encryptedZero,
        bytes memory _proof,
        uint256 _endTime
    ) public {
        bool isThresholdMet = false;
        if (_threshold == 0) {
            isThresholdMet = true;
        }
        fundraisersMap[_recipient].push();
        Fundraiser storage fundraiser = fundraisersMap[_recipient][fundraisersMap[_recipient].length - 1];
        fundraiser.endTime = _endTime;
        fundraiser.threshold = _threshold;
        fundraiser.isThresholdMet = isThresholdMet;
        fundraiser.amountContributed = encryptedZero;
        fundraiser.contributionCount = 0;
        // Fundraiser memory fundraiser = Fundraiser(_endTime, _threshold, isThresholdMet, encryptedZero, 0);
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

    struct ContributeLocals {
        uint256 txNonce;
        uint256 senderBalanceC1x;
        uint256 senderBalanceC1y;
        uint256 senderBalanceC2x;
        uint256 senderBalanceC2y;
        PrivateToken.EncryptedAmount senderBalance;
        uint256 receiverBalanceC1x;
        uint256 receiverBalanceC1y;
        uint256 receiverBalanceC2x;
        uint256 receiverBalanceC2y;
        PrivateToken.EncryptedAmount receiverBalance;
        PrivateToken.TransferLocals transferLocals;
        bytes32[] publicInputs;
    }

    function contribute(
        uint256 _fundraiserIndex,
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
        ContributeLocals memory contributeLocals;
        contributeLocals.txNonce = uint256(keccak256(abi.encode(_amountToSend))) % BJJ_PRIME;
        require(privateToken.nonce(_from, contributeLocals.txNonce) == false, "Nonce must be unused");
        (
            contributeLocals.senderBalanceC1x,
            contributeLocals.senderBalanceC1y,
            contributeLocals.senderBalanceC2x,
            contributeLocals.senderBalanceC2y
        ) = privateToken.balances(_from);
        contributeLocals.senderBalance = PrivateToken.EncryptedAmount({
            C1x: contributeLocals.senderBalanceC1x,
            C1y: contributeLocals.senderBalanceC1y,
            C2x: contributeLocals.senderBalanceC2x,
            C2y: contributeLocals.senderBalanceC2y
        });

        (
            contributeLocals.receiverBalanceC1x,
            contributeLocals.receiverBalanceC1y,
            contributeLocals.receiverBalanceC2x,
            contributeLocals.receiverBalanceC2y
        ) = privateToken.balances(_to);
        contributeLocals.receiverBalance = PrivateToken.EncryptedAmount({
            C1x: contributeLocals.receiverBalanceC1x,
            C1y: contributeLocals.receiverBalanceC1y,
            C2x: contributeLocals.receiverBalanceC2x,
            C2y: contributeLocals.receiverBalanceC2y
        });
        contributeLocals.transferLocals = PrivateToken.TransferLocals({
            to: _to,
            from: _from,
            processFee: 0, // fundraisers are incentivized to pay the process fee if the fundraiser is successful
            relayFee: _relayFee,
            txNonce: contributeLocals.txNonce,
            oldBalance: contributeLocals.senderBalance,
            amountToSend: _amountToSend,
            receiverBalance: contributeLocals.receiverBalance,
            senderNewBalance: _senderNewBalance,
            proof: _proof_transfer,
            // the following dont matter
            lockedByAddress: address(0x0),
            transferCount: 0,
            privateToken: PrivateToken(address(0x0))
        });

        Fundraiser storage f = fundraisersMap[_to][_fundraiserIndex];

        // 1. verifies that the transfer is valid
        // this call ensures that if _from is controlled by an eth controller, the msg.sender is the eth controller
        transferVerify.verifyTransfer(contributeLocals.transferLocals);

        // 2. verify increaseAmountContributed
        contributeLocals.publicInputs = new bytes32[](12);
        contributeLocals.publicInputs[0] = bytes32(f.amountContributed.C1x);
        contributeLocals.publicInputs[1] = bytes32(f.amountContributed.C1y);
        contributeLocals.publicInputs[2] = bytes32(f.amountContributed.C2x);
        contributeLocals.publicInputs[3] = bytes32(f.amountContributed.C2y);
        contributeLocals.publicInputs[4] = bytes32(_amountToSend.C1x);
        contributeLocals.publicInputs[5] = bytes32(_amountToSend.C1y);
        contributeLocals.publicInputs[6] = bytes32(_amountToSend.C2x);
        contributeLocals.publicInputs[7] = bytes32(_amountToSend.C2y);
        contributeLocals.publicInputs[8] = bytes32(_newAmountContributed.C1x);
        contributeLocals.publicInputs[9] = bytes32(_newAmountContributed.C1y);
        contributeLocals.publicInputs[10] = bytes32(_newAmountContributed.C2x);
        contributeLocals.publicInputs[11] = bytes32(_newAmountContributed.C2y);

        // verifies that the amount contributed has been correctly updated
        additionVerifier.verify(_proof_increaseAmountContributed, contributeLocals.publicInputs);

        f.amountContributed = _newAmountContributed;

        uint256 index = fundraisersMap[_to][_fundraiserIndex].contributionCount;
        f.contributions[index] = PendingContribution(
            _to, _from, _relayFee, _relayFeeRecipient, 0, _amountToSend, _senderNewBalance, _proof_transfer
        );

        hasPendingContribution[_from] = true;
        emit Contribution(_to, _from, _fundraiserIndex);
    }

    // can only revoke after endTime has passed
    function revokeContribution(
        bytes32 _to,
        bytes32 _from,
        uint256 _fundraiserIndex,
        uint256 _contributionIndex,
        bytes memory _proof
    ) public {
        require(hasPendingContribution[_from], "No pending contribution");
        Fundraiser storage f = fundraisersMap[_to][_fundraiserIndex];
        require(f.endTime >= block.timestamp, "End time must has passed");
        require(f.isThresholdMet == false, "Fundraiser must not be successful");

        delete fundraisersMap[_to][_fundraiserIndex].contributions[_contributionIndex];
        hasPendingContribution[_from] = false;

        // check if the sender is controlled by an eth controller
        address controller = accountController.ethController(_from);
        if (controller != address(0x0)) {
            require(msg.sender == controller, "Transfer must be sent from the eth controller");
        }

        // check that the sender has the private key corresponding to the public key
        bytes32[] memory publicInputs = new bytes32[](32);
        for (uint8 i = 0; i < 32; i++) {
            // Noir takes an array of 32 bytes32 as public inputs
            bytes1 aByte = bytes1((_from << (i * 8)));
            publicInputs[i] = bytes32(uint256(uint8(aByte)));
        }
        revokeVerifier.verify(_proof, publicInputs);
        emit RevokedContribution(_to, _from, _fundraiserIndex, _contributionIndex);
    }

    // the recipient is the only account that can create a proof that the threshold has been met
    function setThresholdMet(bytes32 recipient, uint256 fundraiserIndex, bytes memory proof) public {
        fundraisersMap[recipient][fundraiserIndex].isThresholdMet = true;
        Fundraiser storage f = fundraisersMap[recipient][fundraiserIndex];
        require(f.endTime < block.timestamp, "Fundraiser must be open");

        bytes32[] memory publicInputs = new bytes32[](5);
        publicInputs[0] = bytes32(f.amountContributed.C1x);
        publicInputs[1] = bytes32(f.amountContributed.C1y);
        publicInputs[2] = bytes32(f.amountContributed.C2x);
        publicInputs[3] = bytes32(f.amountContributed.C2y);
        publicInputs[4] = bytes32(f.threshold);

        // checks that the threshold has been met without revealing the specific amount raised
        thresholdVerifier.verify(proof, publicInputs);
        emit ThresholdMet(recipient, fundraiserIndex);
    }

    function processContributions(bytes32 _to, uint256 _fundraiserIndex, uint256 _startIndex) public {
        Fundraiser storage f = fundraisersMap[_to][_fundraiserIndex];
        require(f.isThresholdMet, "Fundraising threshold must be met");
        // TODO: figure out how many loops this should do
        for (uint256 i = _startIndex; i < 10; i++) {
            PendingContribution memory contribution = f.contributions[i];
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
            emit ContributionProcessed(contribution.to, contribution.from, _fundraiserIndex, i);
        }
        emit ManyProcessed(_to, _fundraiserIndex, _startIndex);
    }

    function unlock(bytes32 _account) public {
        require(!hasPendingContribution[_account], "Has pending contribution");
        privateToken.unlock(_account);
    }
}
