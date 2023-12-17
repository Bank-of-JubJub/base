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
    WithdrawVerifier public WITHDRAW_VERIFIER;
    Withdraw4337Verifier public WITHDRAW_4337_VERIFIER;
    WithdrawEthSignerVerifier public WITHDRAW_ETH_SIGNER_VERIFIER;
    WithdrawMultisigVerifier public WITHDRAW_MULTISIG_VERIFIER;
    LockVerifier public LOCK_VERIFIER;
    AccountController public ACCOUNT_CONTROLLER;
    address public allTransferVerifier;

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
    mapping(bytes32 => mapping(uint256 => bool)) public nonce;

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
     * @param _withdrawVerifier address of the withdrawVerifier contract
     * @param _lockVerifier address of the lockVerifier contract
     * @param _token - ERC20 token address
     */

    constructor(
        address _processDepositVerifier,
        address _processTransferVerifier,
        address _allTransferVerifier,
        address _withdrawVerifier,
        address _lockVerifier,
        address _token,
        uint256 _decimals,
        address _accountController
    ) {
        PROCESS_DEPOSIT_VERIFIER = ProcessDepositVerifier(_processDepositVerifier);
        PROCESS_TRANSFER_VERIFIER = ProcessTransferVerifier(_processTransferVerifier);
        allTransferVerifier = _allTransferVerifier;
        WITHDRAW_VERIFIER = WithdrawVerifier(_withdrawVerifier);
        LOCK_VERIFIER = LockVerifier(_lockVerifier);
        ACCOUNT_CONTROLLER = AccountController(_accountController);

        token = IERC20(_token);
        uint256 sourceDecimals = _decimals;
        try token.decimals() returns (uint256 returnedDecimals) {
            sourceDecimals = returnedDecimals;
        } catch {
            // do nothing
        }

        SOURCE_TOKEN_DECIMALS = sourceDecimals;
    }

    // TODO: protect this so it can only be called once
    // needed to break this out of the constructor because the constructor got too big
    function initOtherVerifiers(
        address _withdraw4337Verifier,
        address _withdrawEthSignerVerifier,
        address _withdrawMultisigVerifier
    ) public {
        WITHDRAW_4337_VERIFIER = Withdraw4337Verifier(_withdraw4337Verifier);
        WITHDRAW_ETH_SIGNER_VERIFIER = WithdrawEthSignerVerifier(_withdrawEthSignerVerifier);
        WITHDRAW_MULTISIG_VERIFIER = WithdrawMultisigVerifier(_withdrawMultisigVerifier);
    }

    // potentially mitigate DDoS attacks against relayers with RLNs

    /**
     * @notice Deposits the assocated token into the contract to be used privately.
     *  The deposited amount is pushed to the recepients PendingDeposits queue. The fee
     *  is the amount that will be paid to the processor of the tx (when processPendingDeposits
     *  is called)
     *  This function converts the token to 2 decimal places, the remainder is lost.
     * @dev
     * @param _from - sender of the tokens, an ETH address
     * @param _amount - amount to deposit
     * @param _to - the packed public key of the recipient in the system
     * @param _processFee - (optional, can be 0) amount to pay the processor of the tx (when processPendingDeposits is called)
     */

    function deposit(address _from, uint256 _amount, bytes32 _to, uint40 _processFee) public {
        // convert to decimals places. any decimals following 2 are lost
        // max value is u40 - 1, so 1099511627775. with 2 decimals
        // that gives us a max supply of ~11 billion erc20 tokens
        uint40 amount = uint40(_amount / 10 ** (SOURCE_TOKEN_DECIMALS - decimals));
        require(totalSupply + amount < type(uint40).max, "Amount is too big");
        token.transferFrom(_from, address(this), uint256(_amount));
        // keep the fee - users can add a fee to incentivize processPendingDeposits
        amount = amount - _processFee;
        uint256 depositCount = pendingDepositCounts[_to];
        allPendingDepositsMapping[_to][depositCount] = PendingDeposit(amount, _processFee);
        pendingDepositCounts[_to] += 1;
        totalSupply += amount;
        emit Deposit(_from, _to, amount, _processFee);
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
        AccountController accountController;
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
        local.lockedByAddress = lockedTo[_from];
        require(
            local.lockedByAddress == address(0) || local.lockedByAddress == msg.sender,
            "account is locked to another account"
        );
        local.oldBalance = balances[_from];
        local.receiverBalance = balances[_to];
        {
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
        }
        {
            balances[_from] = _senderNewBalance;
            emit Transfer(_from, _to, _amountToSend);
            if (_relayFee != 0) {
                token.transfer(_relayFeeRecipient, _relayFee * 10 ** (SOURCE_TOKEN_DECIMALS - decimals));
            }
        }

        // this makes sure the signature cannot be reused
        // bytes32 messageHash = keccak256(
        //     abi.encodePacked(address(this), _from, _to, local.txNonce)
        // );
        local.senderNewBalance = _senderNewBalance;
        local.privateToken = PrivateToken(address(this));
        local.proof = _proof_transfer;
        TransferVerify(allTransferVerifier).verifyTransfer(local);
        // _from,
        // _to,
        // PrivateToken(address(this)),
        // _processFee,
        // _relayFee,
        // _amountToSend,
        // _senderNewBalance,
        // AccountController(address(ACCOUNT_CONTROLLER)),
        // _proof_transfer
        // uint256 messageHashModulus = uint256(messageHash) % BJJ_PRIME;
        // uint256 toModulus = uint256(_to) % BJJ_PRIME;
        // uint256 fromModulus = uint256(_from) % BJJ_PRIME;

        // if (ethSigner[_from] != address(0)) {
        //     // use the transfer_eth_signer circuit
        //     local.publicInputs = new bytes32[](18);
        //     local = _stageCommonTransferInputs(
        //         local,
        //         fromModulus,
        //         toModulus,
        //         _processFee,
        //         _relayFee,
        //         _amountToSend,
        //         _senderNewBalance
        //     );
        //     local.publicInputs[16] = bytes32(
        //         uint256(uint160(ethSigner[_from]))
        //     );
        //     local.publicInputs[17] = bytes32(messageHashModulus);

        //     require(
        //         TRANSFER_ETH_SIGNER_VERIFIER.verify(
        //             _proof_transfer,
        //             local.publicInputs
        //         ),
        //         "Eth signer transfer proof is invalid"
        //     );
        // } else if (erc4337Controller[_from] != address(0)) {
        //     local.publicInputs = new bytes32[](17);
        //     local = _stageCommonTransferInputs(
        //         local,
        //         fromModulus,
        //         toModulus,
        //         _processFee,
        //         _relayFee,
        //         _amountToSend,
        //         _senderNewBalance
        //     );
        //     // msg.sender should be 4337 account address
        //     local.publicInputs[16] = bytes32(uint256(uint160(msg.sender)));

        //     require(
        //         TRANSFER_4337_VERIFIER.verify(
        //             _proof_transfer,
        //             local.publicInputs
        //         ),
        //         "4337 Transfer proof is invalid"
        //     );
        // } else if (multisigEthSigners[_from].threshold != 0) {
        //     local.publicInputs = new bytes32[](28);
        //     local = _stageCommonTransferInputs(
        //         local,
        //         fromModulus,
        //         toModulus,
        //         _processFee,
        //         _relayFee,
        //         _amountToSend,
        //         _senderNewBalance
        //     );
        //     address[] memory signers = multisigEthSigners[_from].ethSigners;
        //     for (uint8 i = 0; i < signers.length; i++) {
        //         local.publicInputs[79 + i] = bytes32(
        //             uint256(uint160(signers[i]))
        //         );
        //     }
        //     // local.publicInputs[79 + signers.length] = bytes32(
        //     //     uint256(multisigEthSigners[_from].threshold)
        //     // );
        //     // local.publicInputs[79 + signers.length + 1] = bytes32(
        //     //     messageHashModulus
        //     // );
        //     local.publicInputs = _getAndAddMultisigSigners(
        //         local.publicInputs,
        //         _from,
        //         messageHashModulus
        //     );
        //     require(
        //         TRANSFER_MULTISIG_VERIFIER.verify(
        //             _proof_transfer,
        //             local.publicInputs
        //         ),
        //         "Multisig Transfer proof is invalid"
        //     );
        // } else {
        //     local.publicInputs = new bytes32[](79);
        //     local = _stageCommonTransferInputs(
        //         local,
        //         fromModulus,
        //         toModulus,
        //         _processFee,
        //         _relayFee,
        //         _amountToSend,
        //         _senderNewBalance
        //     );
        //     require(
        //         TRANSFER_VERIFIER.verify(_proof_transfer, local.publicInputs),
        //         "Transfer proof is invalid"
        //     );
        // }
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

    function withdraw(
        bytes32 _from,
        address _to,
        uint40 _amount,
        uint40 _relayFee,
        address _relayFeeRecipient,
        bytes memory _withdraw_proof,
        EncryptedAmount memory _newEncryptedAmount
    ) public {
        uint256 txNonce = checkAndUpdateNonce(_from, _newEncryptedAmount);
        address lockedToAddress = lockedTo[_from];
        require(lockedToAddress == address(0) || lockedToAddress == msg.sender, "account is locked to another account");
        // TODO: fee
        EncryptedAmount memory oldEncryptedAmount = balances[_from];
        // calculate the new total encrypted supply offchain, replace existing value (not an increment)
        balances[_from] = _newEncryptedAmount;
        totalSupply -= _amount;
        if (_relayFee != 0) {
            token.transfer(_relayFeeRecipient, uint256(_relayFee * 10 ** (SOURCE_TOKEN_DECIMALS - decimals)));
        }
        uint256 convertedAmount = _amount * 10 ** (SOURCE_TOKEN_DECIMALS - decimals);
        token.transfer(_to, convertedAmount);
        emit Withdraw(_from, _to, convertedAmount, _relayFeeRecipient, _relayFee);

        // this makes sure the signature cannot be reused
        bytes32 messageHash = keccak256(abi.encodePacked(address(this), _from, _to, txNonce));
        uint256 messageHashModulus = uint256(messageHash) % BJJ_PRIME;
        uint256 fromModulus = uint256(_from) % BJJ_PRIME;
        // if (ethSigner[_from] != address(0)) {
        //     bytes32[] memory publicInputs = new bytes32[](14);
        //     publicInputs = _stageCommonWithdrawInputs(
        //         fromModulus,
        //         _amount,
        //         _relayFee,
        //         oldEncryptedAmount,
        //         _newEncryptedAmount,
        //         publicInputs,
        //         txNonce
        //     );
        //     publicInputs[publicInputs.length + 1] = bytes32(
        //         uint256(uint160(ethSigner[_from]))
        //     );
        //     publicInputs[publicInputs.length + 2] = bytes32(messageHashModulus);
        //     require(
        //         WITHDRAW_ETH_SIGNER_VERIFIER.verify(
        //             _withdraw_proof,
        //             publicInputs
        //         ),
        //         "Withdraw proof is invalid"
        //     );
        // } else if (erc4337Controller[_from] != address(0)) {
        //     bytes32[] memory publicInputs = new bytes32[](13);
        //     publicInputs = _stageCommonWithdrawInputs(
        //         fromModulus,
        //         _amount,
        //         _relayFee,
        //         oldEncryptedAmount,
        //         _newEncryptedAmount,
        //         publicInputs,
        //         txNonce
        //     );
        //     publicInputs[publicInputs.length + 1] = bytes32(
        //         uint256(uint160(msg.sender))
        //     );
        //     require(
        //         WITHDRAW_4337_VERIFIER.verify(_withdraw_proof, publicInputs),
        //         "Withdraw proof is invalid"
        //     );
        // } else if (multisigEthSigners[_from].threshold != 0) {
        //     bytes32[] memory publicInputs = new bytes32[](22);
        //     publicInputs = _stageCommonWithdrawInputs(
        //         fromModulus,
        //         _amount,
        //         _relayFee,
        //         oldEncryptedAmount,
        //         _newEncryptedAmount,
        //         publicInputs,
        //         txNonce
        //     );
        //     publicInputs = _getAndAddMultisigSigners(
        //         publicInputs,
        //         _from,
        //         messageHashModulus
        //     );
        //     require(
        //         WITHDRAW_MULTISIG_VERIFIER.verify(
        //             _withdraw_proof,
        //             publicInputs
        //         ),
        //         "Withdraw proof is invalid"
        //     );
        // } else {
        //     bytes32[] memory publicInputs = new bytes32[](12);
        //     publicInputs = _stageCommonWithdrawInputs(
        //         fromModulus,
        //         _amount,
        //         _relayFee,
        //         oldEncryptedAmount,
        //         _newEncryptedAmount,
        //         publicInputs,
        //         txNonce
        //     );
        //     require(
        //         WITHDRAW_VERIFIER.verify(_withdraw_proof, publicInputs),
        //         "Withdraw proof is invalid"
        //     );
        // }
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
        // for (uint8 i = 0; i < 32; i++) {
        //     // Noir takes an array of 32 bytes32 as public inputs
        //     bytes1 aByte = bytes1((_recipient << (i * 8)));
        //     publicInputs[i] = bytes32(uint256(uint8(aByte)));
        // }
        // console.log("recipientModulus", recipientModulus);
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
        if (totalFees != 0) {
            token.transfer(_feeRecipient, uint256(totalFees * 10 ** (SOURCE_TOKEN_DECIMALS - decimals)));
        }
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
    // function lock(
    //     bytes32 _from,
    //     address _lockToContract,
    //     uint40 _relayFee,
    //     address _relayFeeRecipient,
    //     bytes memory _proof,
    //     EncryptedAmount memory _newEncryptedAmount
    // ) public {
    //     uint256 txNonce = checkAndUpdateNonce(_from, _newEncryptedAmount);
    //     require(lockedTo[_from] == address(0), "account is already locked");
    //     // figure out actual function signature, this is just a placeholder
    //     require(_lockToContract.supportsInterface(0x80ac58cd), "contract does not implement unlock");
    //     lockedTo[_from] = _lockToContract;
    //     EncryptedAmount memory oldEncryptedAmount = balances[_from];

    //     bytes32[] memory publicInputs = new bytes32[](12);
    //     // this nonce should be unique because it uses the randomness calculated in the encrypted balance
    //     publicInputs[0] = bytes32(txNonce);
    //     publicInputs[1] = bytes32(_from);
    //     publicInputs[2] = bytes32(uint256(uint160(_lockToContract)));
    //     publicInputs[3] = bytes32(uint256(_relayFee));
    //     publicInputs[4] = bytes32(oldEncryptedAmount.C1x);
    //     publicInputs[5] = bytes32(oldEncryptedAmount.C1y);
    //     publicInputs[6] = bytes32(oldEncryptedAmount.C2x);
    //     publicInputs[7] = bytes32(oldEncryptedAmount.C2y);
    //     publicInputs[8] = bytes32(_newEncryptedAmount.C1x);
    //     publicInputs[9] = bytes32(_newEncryptedAmount.C1y);
    //     publicInputs[10] = bytes32(_newEncryptedAmount.C2x);
    //     publicInputs[11] = bytes32(_newEncryptedAmount.C2y);
    //     LOCK_VERIFIER.verify(_proof, publicInputs);
    //     if (_relayFee != 0) {
    //         token.transfer(_relayFeeRecipient, uint256(_relayFee * 10 ** (SOURCE_TOKEN_DECIMALS - decimals)));
    //     }
    //     emit Lock(_from, _lockToContract, _relayFee, _relayFeeRecipient);
    // }

    /**
     * @notice unlocks an account locked by a contract. This function must be called by the
     * contract that is locked to an account. Users must lock their account to a contract that
     * has a function that calls this function, or their funds will be locked forever.
     * @dev
     * @param publicKey - the packed public key of the account to unlock
     */

    // function unlock(bytes32 publicKey) public {
    //     address unlockedFrom = lockedTo[publicKey];
    //     require(msg.sender == unlockedFrom, "wrong sender");
    //     emit Unlock(publicKey, unlockedFrom);
    //     lockedTo[publicKey] = address(0);
    // }

    ///////////////////////
    // Utility functions //
    ///////////////////////

    function checkAndUpdateNonce(bytes32 _from, EncryptedAmount memory _encryptedAmount) internal returns (uint256) {
        uint256 txNonce = uint256(keccak256(abi.encode(_encryptedAmount))) % BJJ_PRIME;
        require(nonce[_from][txNonce] == false, "nonce is not unique");
        nonce[_from][txNonce] = true;
        return txNonce;
    }

    // function _stageCommonTransferInputs(
    //     transferLocals memory local,
    //     uint256 _fromModulus,
    //     uint256 _toModulus,
    //     uint40 _processFee,
    //     uint40 _relayFee,
    //     EncryptedAmount memory _amountToSend,
    //     EncryptedAmount memory _senderNewBalance
    // ) internal pure returns (transferLocals memory) {
    //     // for (uint8 i = 0; i < 32; i++) {
    //     //     // Noir takes an array of 32 bytes32 as public inputs
    //     //     bytes1 aByte = bytes1((_from << (i * 8)));
    //     //     local.publicInputs[i] = bytes32(uint256(uint8(aByte)));
    //     // }
    //     // for (uint8 i = 0; i < 32; i++) {
    //     //     bytes1 aByte = bytes1((_to << (i * 8)));
    //     //     local.publicInputs[i + 32] = bytes32(uint256(uint8(aByte)));
    //     // }
    //     local.publicInputs[0] = bytes32(_fromModulus);
    //     local.publicInputs[1] = bytes32(_toModulus);
    //     local.publicInputs[2] = bytes32(uint256(_processFee));
    //     local.publicInputs[3] = bytes32(uint256(_relayFee));
    //     // this nonce should be unique because it uses the randomness calculated in the encrypted balance
    //     local.publicInputs[4] = bytes32(local.txNonce);
    //     local.publicInputs[5] = bytes32(local.oldBalance.C1x);
    //     local.publicInputs[6] = bytes32(local.oldBalance.C1y);
    //     local.publicInputs[7] = bytes32(local.oldBalance.C2x);
    //     local.publicInputs[8] = bytes32(local.oldBalance.C2y);
    //     local.publicInputs[9] = bytes32(_amountToSend.C1x);
    //     local.publicInputs[10] = bytes32(_amountToSend.C1y);
    //     local.publicInputs[11] = bytes32(_amountToSend.C2x);
    //     local.publicInputs[12] = bytes32(_amountToSend.C2y);
    //     local.publicInputs[13] = bytes32(_senderNewBalance.C1x);
    //     local.publicInputs[14] = bytes32(_senderNewBalance.C1y);
    //     local.publicInputs[15] = bytes32(_senderNewBalance.C2x);
    //     local.publicInputs[16] = bytes32(_senderNewBalance.C2y);
    //     return local;
    // }

    function _stageCommonWithdrawInputs(
        uint256 _fromModulus,
        uint40 _amount,
        uint40 _relayFee,
        EncryptedAmount memory _oldEncryptedAmount,
        EncryptedAmount memory _newEncryptedAmount,
        bytes32[] memory publicInputs,
        uint256 _txNonce
    ) internal pure returns (bytes32[] memory) {
        // for (uint8 i = 0; i < 32; i++) {
        //     // Noir takes an array of 32 bytes32 as public inputs
        //     bytes1 aByte = bytes1((_from << (i * 8)));
        //     publicInputs[i] = bytes32(uint256(uint8(aByte)));
        // }
        publicInputs[0] = bytes32(_fromModulus);
        publicInputs[1] = bytes32(_txNonce);
        publicInputs[2] = bytes32(uint256(_amount));
        publicInputs[3] = bytes32(uint256(_relayFee));
        publicInputs[4] = bytes32(_oldEncryptedAmount.C1x);
        publicInputs[5] = bytes32(_oldEncryptedAmount.C1y);
        publicInputs[6] = bytes32(_oldEncryptedAmount.C2x);
        publicInputs[7] = bytes32(_oldEncryptedAmount.C2y);
        publicInputs[8] = bytes32(_newEncryptedAmount.C1x);
        publicInputs[9] = bytes32(_newEncryptedAmount.C1y);
        publicInputs[10] = bytes32(_newEncryptedAmount.C2x);
        publicInputs[11] = bytes32(_newEncryptedAmount.C2y);
        return publicInputs;
    }

    // function _getAndAddMultisigSigners(
    //     bytes32[] memory publicInputs,
    //     bytes32 _from,
    //     uint256 messageHashModulus
    // ) internal view returns (bytes32[] memory) {
    //     uint256 length = publicInputs.length;
    //     address[] memory signers = multisigEthSigners[_from].ethSigners;
    //     for (uint8 i = 0; i < signers.length; i++) {
    //         publicInputs[length + i] = bytes32(uint256(uint160(signers[i])));
    //     }
    //     publicInputs[length + signers.length] = bytes32(
    //         uint256(multisigEthSigners[_from].threshold)
    //     );
    //     publicInputs[length + signers.length + 1] = bytes32(messageHashModulus);
    //     return publicInputs;
    // }
    function fromRprLe(bytes32 publicKey) internal view returns (uint256) {
        uint256 y = 0;
        uint256 v = 1;
        bytes32[] memory publicKeyBytes = bytes32ToBytes(publicKey);
        for (uint8 i = 0; i < 32; i++) {
            y += (uint256(publicKeyBytes[i]) * v) % BJJ_PRIME;
            v *= 256;
        }
        return y;
    }

    function bytes32ToBytes(bytes32 _data) public pure returns (bytes32[] memory) {
        bytes32[] memory byteArray = new bytes32[](32);
        for (uint256 i = 0; i < 32; i++) {
            byteArray[i] = _data[i];
        }
        return byteArray;
    }
}
