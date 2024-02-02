// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// import "hardhat/console.sol";
import {UltraVerifier as ProcessDepositVerifier} from "./process_pending_deposits/plonk_vk.sol";
import {UltraVerifier as ProcessTransferVerifier} from "./process_pending_transfers/plonk_vk.sol";
import {UltraVerifier as WithdrawVerifier} from "./withdraw/plonk_vk.sol";
import {UltraVerifier as Withdraw4337Verifier} from "./withdraw/plonk_vk.sol";
import {UltraVerifier as WithdrawEthSignerVerifier} from "./withdraw/plonk_vk.sol";
import {UltraVerifier as WithdrawMultisigVerifier} from "./withdraw/plonk_vk.sol";
import {UltraVerifier as LockVerifier} from "./lock/plonk_vk.sol";
import {IERC20} from "./IERC20.sol";
import {IERC165} from "./IERC165.sol";
import {ERC165Checker} from "./ERC165Checker.sol";
import {AccountController} from "./AccountController.sol";
import {TransferVerify} from "./TransferVerify.sol";
import {WithdrawVerify} from "./WithdrawVerify.sol";

/**
 * @dev Implementation of PrivateToken.
 * total supply is set at construction by the deployer and cannot exceed type(uint40).max = 1099511627775 because during Exponential ElGamal decryption we must solve the DLP quickly
 * Balances are encrypted to each owner's public key, according to the registered keys inside the PublicKeyInfrastructure.
 * Because we use Exponential ElGamal encryption, each EncryptedAmount is a pair of points on Baby Jubjub (C1,C2) = ((C1x,C1y),(C2x,C2y)).
 */
contract PrivateToken {
    using ERC165Checker for address;

    struct EncryptedAmount {
        // #TODO : We could pack those in 2 uints instead of 4 to save storage costs (for e.g using circomlibjs library to pack points on BabyJubjub)
        uint256 C1x;
        uint256 C1y;
        uint256 C2x;
        uint256 C2y;
    }

    // breaking up deposits/transfer into two steps allow all of them to succeed.
    // without this, te people trying to send the same person money in the same block would fail
    // because they would both be trying to update the same ecrypted state
    // debiting the senders account in the first tx and doing the addtion in another allows
    // the send to always succeed. at worst the claim of the token would fail if multiple people
    // try to update simultaneously, but at the tx doesn't fail
    struct PendingTransfer {
        EncryptedAmount amount;
        // add a fee to incentivize someone to process the pending tx
        // otherwise leave as 0 and the recipient can process the tx themselves at cost
        uint40 fee;
        // the time the tx was created, processing must happen at least 1 block later
        uint256 time;
    }

    struct PendingDeposit {
        uint256 amount;
        // add a fee to incentivize someone to process the pending tx
        // otherwise leave as 0 and the recipient can process the tx themselves at cost
        uint40 fee;
    }

    /// @notice The prime field that the circuit is constructed over. This is used to make message hashes fit in 1 field element
    uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    // struct PublicKey {
    //     // We could pack those in a single uint256 to save storage costs (for e.g using circomlibjs library to pack points on BabyJubjub)
    //     uint256 X;
    //     uint256 Y;
    // } // The Public Key should be a point on Baby JubJub elliptic curve : checks must be done offchain before registering to ensure that X<p and Y<p and (X,Y) is on the curve
    ProcessDepositVerifier public PROCESS_DEPOSIT_VERIFIER;
    ProcessTransferVerifier public PROCESS_TRANSFER_VERIFIER;
    // WithdrawVerifier public WITHDRAW_VERIFIER;
    // Withdraw4337Verifier public WITHDRAW_4337_VERIFIER;
    // WithdrawEthSignerVerifier public WITHDRAW_ETH_SIGNER_VERIFIER;
    // WithdrawMultisigVerifier public WITHDRAW_MULTISIG_VERIFIER;
    LockVerifier public LOCK_VERIFIER;
    address public allTransferVerifier;
    address public allWithdrawVerifier;
    AccountController public accountController;

    uint40 public totalSupply;

    IERC20 token;
    uint256 public SOURCE_TOKEN_DECIMALS;

    //TODO: allow this to be set in the constructor
    uint8 public immutable decimals = 2;

    // packed public key => encrypted balance
    // packed using this algo: https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/babyjub.js#L97
    // unpack (in circuit) using this algo: https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/babyjub.js#L108
    mapping(bytes32 packedPublicKey => EncryptedAmount) public balances;

    // packed public key => the key for the allPendingTransfersMapping
    mapping(bytes32 packedPublicKey => uint256 count) public pendingTransferCounts;

    mapping(bytes32 packedPublicKey => uint256 count) public pendingDepositCounts;

    mapping(bytes32 packedPublicKey => mapping(uint256 => PendingTransfer)) public allPendingTransfersMapping;
    mapping(bytes32 packedPublicKey => mapping(uint256 => PendingDeposit)) public allPendingDepositsMapping;

    // This prevents replay attacks in the transfer fn
    // packed public key => keccak(new encrypted balance), this should be random enough bc it leverages randomness for encryption
    mapping(bytes32 packeedPublicKey => mapping(uint256 balanceHash => bool isUsed)) public nonce;

    // account can be locked and controlled by a contract
    mapping(bytes32 packedPublicKey => address lockedToContract) public lockedTo;

    /*
        A PendingTransaction is added to this array when transfer is called.
        The transfer fn debits the senders balance by the amount sent.
        The sender encrypts the amount with the receivers public key

        The processPendingTransfer fn takes a batch of PendingTransfers, and 
        does computes the updates for the homonorphic addition of the encrypted 
        amounts to the receivers and updates the recievers encrypted balances.

    */

    event Transfer(bytes32 indexed to, bytes32 indexed from, EncryptedAmount amount);
    event TransferProcessed(bytes32 to, EncryptedAmount newBalance, uint256 processFee, address processFeeRecipient);
    event Deposit(address from, bytes32 to, uint256 amount, uint256 processFee);
    event DepositProcessed(bytes32 to, uint256 amount, uint256 processFee, address feeRecipient);
    event Withdraw(bytes32 from, address to, uint256 amount, address _relayFeeRecipient, uint256 relayFee);
    event Lock(bytes32 publicKey, address lockedTo, uint256 relayerFee, address relayerFeeRecipient);
    event Unlock(bytes32 publicKey, address unlockedFrom);

    /**
     * @notice Constructor - setup up verifiers and link to token
     * @dev
     * @param _processDepositVerifier address of the processDepositVerifier contract
     * @param _processTransferVerifier address of the processTransferVerifier contract
     * @param _allTransferVerifier address of the contract that verifies all of the transfers
     * @param _allWithdrawVerifier address of the withdrawVerifier contract
     * @param _lockVerifier address of the lockVerifier contract
     * @param _token - ERC20 token address
     */

    constructor(
        address _processDepositVerifier,
        address _processTransferVerifier,
        address _allTransferVerifier,
        address _allWithdrawVerifier,
        address _lockVerifier,
        address _token,
        uint256 _decimals,
        address _accountController
    ) {
        PROCESS_DEPOSIT_VERIFIER = ProcessDepositVerifier(_processDepositVerifier);
        PROCESS_TRANSFER_VERIFIER = ProcessTransferVerifier(_processTransferVerifier);
        allTransferVerifier = _allTransferVerifier;
        allWithdrawVerifier = _allWithdrawVerifier;
        LOCK_VERIFIER = LockVerifier(_lockVerifier);
        accountController = AccountController(_accountController);

        token = IERC20(_token);
        uint256 sourceDecimals = _decimals;
        try token.decimals() returns (uint256 returnedDecimals) {
            sourceDecimals = returnedDecimals;
        } catch {
            // do nothing
        }

        SOURCE_TOKEN_DECIMALS = sourceDecimals;
    }

    // potentially mitigate DDoS attacks against relayers with RLNs

    /**
     * @notice Deposits the assocated token into the contract to be used privately.
     *  The deposited amount is pushed to the recepients PendingDeposits queue. The fee
     *  is the amount that will be paid to the processor of the tx (when processPendingDeposits
     *  is called)
     *  This function converts the token to 2 decimal places, the remainder is lost.
     * @dev
     * @param _amount - amount to deposit
     * @param _to - the packed public key of the recipient in the system
     * @param _processFee - (optional, can be 0) amount to pay the processor of the tx (when processPendingDeposits is called)
     */

    function deposit(uint256 _amount, bytes32 _to, uint40 _processFee) public {
        // convert to decimals places. any decimals following 2 are lost
        // max value is u40 - 1, so 1099511627775. with 2 decimals
        // that gives us a max supply of ~11 billion erc20 tokens
        uint40 amount = uint40(_amount / 10 ** (SOURCE_TOKEN_DECIMALS - decimals));
        require(totalSupply + amount < type(uint40).max, "Amount is too big");
        token.transferFrom(msg.sender, address(this), uint256(_amount));
        // keep the fee - users can add a fee to incentivize processPendingDeposits
        amount = amount - _processFee;
        uint256 depositCount = pendingDepositCounts[_to];
        allPendingDepositsMapping[_to][depositCount] = PendingDeposit(amount, _processFee);
        pendingDepositCounts[_to] += 1;
        totalSupply += amount;
        emit Deposit(msg.sender, _to, amount, _processFee);
    }

    /**
     * @notice This functions transfers an encrypted amount of tokens to the recipient (_to).
     *  If the sender is sending to an account with a 0 balance, they can omit the fee, as the funds
     *  will be directly added to their account. Otherwise a fee can be specified to incentivize
     *  processing of the tx by an unknown third party (see processPendingTranfer). This is required
     *  two account cannot simultaneously update the encrypted balance of the recipient. Having a pending
     *  transfer queue allows the sender to always succeed in debiting their account, and the recipient
     *  receiving the funds.
     *
     *  The account must not be locked to a contract to call this function.
     *
     * This function will check if the account is controlled by a 4337 account, another eth signer, or multiple
     * eth signers, and call the appropriate verifier.
     * @dev
     * @param _to - the packed public key of the recipient in the system
     * @param _from - the packed public key of the sender in the system
     * @param _processFee - (optional, can be 0) amount to pay the processor of the tx (when processPendingTransfers is called)
     *   if there is no fee supplied, the recipient can process it themselves
     * @param _relayFee - (optional, can be 0) amount to pay the relayer of the tx, if the sender of
     *   the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels
     *   the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx
     * @param _relayFeeRecipient - the recipient of the relay fee
     * @param _amountToSend - amount to send, encrypted with the recipients public key
     * @param _senderNewBalance - sender's new balance, minus the amount sent and the fee
     * @param _proof_transfer - proof
     */

    // stack to deep so storing local variables in a struct
    // https://medium.com/1milliondevs/compilererror-stack-too-deep-try-removing-local-variables-solved-a6bcecc16231
    struct TransferLocals {
        uint256 txNonce;
        address lockedByAddress;
        EncryptedAmount oldBalance;
        EncryptedAmount receiverBalance;
        uint256 transferCount;
        bytes32 to;
        bytes32 from;
        uint40 processFee;
        uint40 relayFee;
        EncryptedAmount amountToSend;
        EncryptedAmount senderNewBalance;
        PrivateToken privateToken;
        bytes proof;
    }

    // bytes32[] publicInputs;

    function transfer(
        bytes32 _to,
        bytes32 _from,
        uint40 _processFee,
        uint40 _relayFee,
        address _relayFeeRecipient,
        EncryptedAmount calldata _amountToSend,
        EncryptedAmount calldata _senderNewBalance,
        bytes memory _proof_transfer
    ) public {
        TransferLocals memory local;
        local.txNonce = checkAndUpdateNonce(_from, _senderNewBalance);
        _checkLocked(_from);
        _checkController(_from);
        local.oldBalance = balances[_from];
        local.receiverBalance = balances[_to];
        bool zeroBalance = (
            local.receiverBalance.C1x == 0 && local.receiverBalance.C2x == 0 && local.receiverBalance.C1y == 0
                && local.receiverBalance.C2y == 0
        );
        if (zeroBalance) {
            // no fee required if a new account
            _processFee = 0;
            balances[_to] = _amountToSend;
        } else {
            local.transferCount = pendingTransferCounts[_to];
            allPendingTransfersMapping[_to][local.transferCount] =
                PendingTransfer(_amountToSend, _processFee, block.timestamp);
            pendingTransferCounts[_to] += 1;
        }

        balances[_from] = _senderNewBalance;
        emit Transfer(_from, _to, _amountToSend);
        _processRelayFee(_relayFee, _relayFeeRecipient);

        local.to = _to;
        local.from = _from;
        local.relayFee = _relayFee;
        local.processFee = _processFee;
        local.senderNewBalance = _senderNewBalance;
        local.amountToSend = _amountToSend;
        local.privateToken = PrivateToken(address(this));
        local.proof = _proof_transfer;
        TransferVerify(allTransferVerifier).verifyTransfer(local);
    }

    /**
     * @notice withdraws the amount of tokens from the contract to the recipient (_to). the account must
     *  not be locked to a contract to call this function.
     * @dev
     *  @param _from - the packed public key of the sender in the system
     *  @param _to - the ETH address of the recipient
     *  @param _amount - amount to withdraw
     *  @param _relayFee - (optional, can be 0) amount to pay the relayer of the tx, if the sender of
     *   the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels
     *   the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx
     * @param _relayFeeRecipient - the recipient of the relay fee
     *  @param _withdraw_proof - proof
     *  @param _newEncryptedAmount - the new encrypted balance of the sender after the withdraw and fee
     */

    // TODO: update withdraw function to have validational conditional on the type of accounts, 4337, eth signer, multisig

    struct WithdrawLocals {
        uint256 txNonce;
        address lockedToAddress;
        EncryptedAmount oldBalance;
        EncryptedAmount newBalance;
        uint256 amount;
        uint256 relayFee;
        bytes32 to;
        bytes32 from;
        bytes proof;
    }

    function withdraw(
        bytes32 _from,
        address _to,
        uint40 _amount,
        uint40 _relayFee,
        address _relayFeeRecipient,
        bytes memory _withdraw_proof,
        EncryptedAmount memory _newEncryptedAmount
    ) public {
        WithdrawLocals memory local;
        local.txNonce = checkAndUpdateNonce(_from, _newEncryptedAmount);
        _checkLocked(_from);
        _checkController(_from);
        // TODO: fee
        local.oldBalance = balances[_from];
        balances[_from] = _newEncryptedAmount;
        totalSupply -= _amount;
        _processRelayFee(_relayFee, _relayFeeRecipient);
        {
            uint256 convertedAmount = _amount * 10 ** (SOURCE_TOKEN_DECIMALS - decimals);
            token.transfer(_to, convertedAmount);
            emit Withdraw(_from, _to, convertedAmount, _relayFeeRecipient, _relayFee);
        }

        local.to = bytes32(uint256(uint160(_to)));
        local.from = _from;
        local.relayFee = _relayFee;
        local.amount = _amount;
        local.proof = _withdraw_proof;
        local.newBalance = _newEncryptedAmount;
        WithdrawVerify(allWithdrawVerifier).verifyWithdraw(local);
    }

    /**
     * @notice the circuit processing this takes in a fixes number of pending transactions.
     *  It will take up to 4 at a time (TODO: research how big this num should this be?).
     *  The circuit checks that the publicKey and recipient match. it encrypts the totalAmount
     *  and adds it to the recipients encrypted balance. It checks that the provided encrypted
     *  balance and the calculated encrypted balances match.
     * @dev
     * @param _proof - proof to verify with the ProcessPendingTransfers circuit
     * @param _txsToProcess - an array of keys of PendingDeposits to process from allPendingDepositsMapping
     *      max length 4
     * @param _feeRecipient - the recipient of the fees (typically the processor of these txs)
     * @param _recipient - the packed public key of the recipient in the system
     * @param _newBalance - the new balance of the recipient after processing the pending transfers
     */

    function processPendingDeposit(
        bytes memory _proof,
        uint256[] memory _txsToProcess,
        address _feeRecipient,
        bytes32 _recipient,
        EncryptedAmount calldata _zeroBalance,
        EncryptedAmount calldata _newBalance
    ) public {
        uint8 numTxsToProcess = uint8(_txsToProcess.length);
        require(numTxsToProcess <= 4, "Too many txs to process");
        uint40 totalFees;
        uint256 totalAmount;
        EncryptedAmount memory oldBalance = balances[_recipient];
        if (oldBalance.C1x == 0 && oldBalance.C1y == 0 && oldBalance.C2x == 0 && oldBalance.C2y == 0) {
            // if this is a fresh account, use the encrypted zero balance
            oldBalance = _zeroBalance;
        }

        PendingDeposit[] memory userPendingDepositsArray = new PendingDeposit[](
            4
        );

        for (uint8 i = 0; i < numTxsToProcess; i++) {
            userPendingDepositsArray[i] = allPendingDepositsMapping[_recipient][_txsToProcess[i]];
            delete allPendingDepositsMapping[_recipient][_txsToProcess[i]];
            totalAmount += userPendingDepositsArray[i].amount;
            totalFees += userPendingDepositsArray[i].fee;
        }

        uint256 recipientModulus = fromRprLe(_recipient);
        bytes32[] memory publicInputs = new bytes32[](10);
        publicInputs[0] = bytes32(recipientModulus);
        publicInputs[1] = bytes32(totalAmount);
        publicInputs[2] = bytes32(oldBalance.C1x);
        publicInputs[3] = bytes32(oldBalance.C1y);
        publicInputs[4] = bytes32(oldBalance.C2x);
        publicInputs[5] = bytes32(oldBalance.C2y);
        publicInputs[6] = bytes32(_newBalance.C1x);
        publicInputs[7] = bytes32(_newBalance.C1y);
        publicInputs[8] = bytes32(_newBalance.C2x);
        publicInputs[9] = bytes32(_newBalance.C2y);

        require(PROCESS_DEPOSIT_VERIFIER.verify(_proof, publicInputs), "Process pending proof is invalid");
        balances[_recipient] = _newBalance;
        if (totalFees != 0) {
            token.transfer(_feeRecipient, uint256(totalFees * 10 ** (SOURCE_TOKEN_DECIMALS - decimals)));
        }
        emit DepositProcessed(_recipient, totalAmount, totalFees, _feeRecipient);
    }

    /**
     * @notice the circuit processing this takes in a fixes number of pending transactions.
     *  It will take up to 4 at a time (TODO: research how big this num should this be?). The circuit adds all of the encrypted amounts sent
     *  and then checks that the _newBalance is the sum of the old balance and the sum of the
     *  amounts to add. All of the fees are summed and sent to the _feeRecipient
     * @dev
     * @param _proof - proof to verify with the ProcessPendingTransfers circuit
     * @param _txsToProcess - the indexs of the userPendingTransfersArray to process; max length 4
     * @param _feeRecipient - the recipient of the fees (typically the processor of these txs)
     * @param _recipient - the recipient of the pending transfers within the system
     * @param _newBalance - the new balance of the recipient after processing the pending transfers
     */

    function processPendingTransfer(
        bytes memory _proof,
        uint8[] memory _txsToProcess,
        address _feeRecipient,
        bytes32 _recipient,
        EncryptedAmount calldata _newBalance
    ) public {
        uint8 numTxsToProcess = uint8(_txsToProcess.length);
        require(_txsToProcess.length <= 4, "Too many txs to process");
        uint256 totalFees;
        EncryptedAmount memory oldBalance = balances[_recipient];

        bytes32[] memory publicInputs = new bytes32[](24);
        publicInputs[0] = bytes32(oldBalance.C1x);
        publicInputs[1] = bytes32(oldBalance.C1y);
        publicInputs[2] = bytes32(oldBalance.C2x);
        publicInputs[3] = bytes32(oldBalance.C2y);
        publicInputs[4] = bytes32(_newBalance.C1x);
        publicInputs[5] = bytes32(_newBalance.C1y);
        publicInputs[6] = bytes32(_newBalance.C2x);
        publicInputs[7] = bytes32(_newBalance.C2y);

        PendingTransfer[] memory pendingTransfers = new PendingTransfer[](4);

        for (uint8 i = 0; i < 4; i++) {
            if (i >= numTxsToProcess) {
                // if there are less than 4 txs to process, pad the public inputs with 0s
                publicInputs[8 + 4 * i] = bytes32(0);
                publicInputs[9 + 4 * i] = bytes32(0);
                publicInputs[10 + 4 * i] = bytes32(0);
                publicInputs[11 + 4 * i] = bytes32(0);
            } else {
                pendingTransfers[i] = allPendingTransfersMapping[_recipient][_txsToProcess[i]];
                delete allPendingTransfersMapping[_recipient][_txsToProcess[i]];
                require(block.timestamp > pendingTransfers[i].time);
                publicInputs[8 + 4 * i] = bytes32(pendingTransfers[i].amount.C1x);
                publicInputs[9 + 4 * i] = bytes32(pendingTransfers[i].amount.C1y);
                publicInputs[10 + 4 * i] = bytes32(pendingTransfers[i].amount.C2x);
                publicInputs[11 + 4 * i] = bytes32(pendingTransfers[i].amount.C2y);
                totalFees += pendingTransfers[i].fee;
            }
        }

        require(PROCESS_TRANSFER_VERIFIER.verify(_proof, publicInputs), "Process pending proof is invalid");
        balances[_recipient] = _newBalance;
        _processRelayFee(totalFees, _feeRecipient);
        emit TransferProcessed(_recipient, _newBalance, totalFees, _feeRecipient);
    }

    // the contract this is locked to must call unlock to give control back to this contract
    // locked contracts cannot transfer or withdraw funds
    /**
     * @notice the contract this is locked to must call unlock to give control back to this contract
     *  locked contracts cannot transfer or withdraw funds.
     *  @param _from - the public key of the account to lock
     * @param _lockToContract - the contract to lock the account to
     * @param _relayFee - (optional, can be 0) amount to pay the relayer of the tx, if the sender of
     *   the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels
     *   the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx
     * @param _relayFeeRecipient - the recipient of the relay fee
     * @param _proof - proof to verify with the ProcessPendingTransfers circuit
     * @param _newEncryptedAmount - the new encrypted balance of the sender after the fee
     */
    function lock(
        bytes32 _from,
        address _lockToContract,
        uint40 _relayFee,
        address _relayFeeRecipient,
        bytes memory _proof,
        EncryptedAmount memory _newEncryptedAmount
    ) public {
        uint256 txNonce = checkAndUpdateNonce(_from, _newEncryptedAmount);
        require(lockedTo[_from] == address(0), "account is already locked");
        _checkController(_from);
        // figure out actual function signature, this is just a placeholder
        require(_lockToContract.supportsInterface(0x80ac58cd), "contract does not implement unlock");
        lockedTo[_from] = _lockToContract;
        EncryptedAmount memory oldEncryptedAmount = balances[_from];

        bytes32[] memory publicInputs = new bytes32[](12);
        // this nonce should be unique because it uses the randomness calculated in the encrypted balance
        publicInputs[0] = bytes32(txNonce);
        publicInputs[1] = bytes32(_from);
        publicInputs[2] = bytes32(uint256(uint160(_lockToContract)));
        publicInputs[3] = bytes32(uint256(_relayFee));
        publicInputs[4] = bytes32(oldEncryptedAmount.C1x);
        publicInputs[5] = bytes32(oldEncryptedAmount.C1y);
        publicInputs[6] = bytes32(oldEncryptedAmount.C2x);
        publicInputs[7] = bytes32(oldEncryptedAmount.C2y);
        publicInputs[8] = bytes32(_newEncryptedAmount.C1x);
        publicInputs[9] = bytes32(_newEncryptedAmount.C1y);
        publicInputs[10] = bytes32(_newEncryptedAmount.C2x);
        publicInputs[11] = bytes32(_newEncryptedAmount.C2y);
        LOCK_VERIFIER.verify(_proof, publicInputs);
        _processRelayFee(_relayFee, _relayFeeRecipient);
        emit Lock(_from, _lockToContract, _relayFee, _relayFeeRecipient);
    }

    /**
     * @notice unlocks an account locked by a contract. This function must be called by the
     * contract that is locked to an account. Users must lock their account to a contract that
     * has a function that calls this function, or their funds will be locked forever.
     * @dev
     * @param publicKey - the packed public key of the account to unlock
     */

    function unlock(bytes32 publicKey) public {
        address unlockedFrom = lockedTo[publicKey];
        require(msg.sender == unlockedFrom, "wrong sender");
        emit Unlock(publicKey, unlockedFrom);
        lockedTo[publicKey] = address(0);
    }

    ///////////////////////
    // Utility functions //
    ///////////////////////

    function checkAndUpdateNonce(bytes32 _from, EncryptedAmount memory _encryptedAmount) internal returns (uint256) {
        uint256 txNonce = uint256(keccak256(abi.encode(_encryptedAmount))) % BJJ_PRIME;
        require(nonce[_from][txNonce] == false, "nonce is not unique");
        nonce[_from][txNonce] = true;
        return txNonce;
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

    function bytes32ToBytes(bytes32 _data) internal pure returns (bytes memory) {
        bytes memory byteArray = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            byteArray[i] = _data[i];
        }
        return byteArray;
    }

    function _checkLocked(bytes32 _from) internal view {
        address lockedToAddress = lockedTo[_from];
        if (lockedToAddress != address(0)) {
            require(lockedToAddress == msg.sender, "account is locked to another account");
        }
    }

    function _checkController(bytes32 _from) internal view {
        address ethController = accountController.ethController(_from);
        if (ethController != address(0) && lockedTo[_from] == address(0)) {
            require(ethController == msg.sender, "account is controlled by another account");
        }
    }

    function _processRelayFee(uint256 _relayFee, address _relayFeeRecipient) internal {
        if (_relayFee != 0) {
            token.transfer(_relayFeeRecipient, uint256(_relayFee * 10 ** (SOURCE_TOKEN_DECIMALS - decimals)));
        }
    }
}
