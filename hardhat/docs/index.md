# Solidity API

## PrivateToken

_Implementation of PrivateToken.
total supply is set at construction by the deployer and cannot exceed type(uint40).max = 1099511627775 because during Exponential ElGamal decryption we must solve the DLP quickly
Balances are encrypted to each owner's public key, according to the registered keys inside the PublicKeyInfrastructure.
Because we use Exponential ElGamal encryption, each EncryptedAmount is a pair of points on Baby Jubjub (C1,C2) = ((C1x,C1y),(C2x,C2y))._

### EncryptedAmount

```solidity
struct EncryptedAmount {
  uint256 C1x;
  uint256 C1y;
  uint256 C2x;
  uint256 C2y;
}
```

### PendingTransfer

```solidity
struct PendingTransfer {
  struct PrivateToken.EncryptedAmount amount;
  uint40 fee;
  uint256 time;
}
```

### PendingDeposit

```solidity
struct PendingDeposit {
  uint256 amount;
  uint40 fee;
}
```

### PROCESS_DEPOSIT_VERIFIER

```solidity
contract UltraVerifier PROCESS_DEPOSIT_VERIFIER
```

### PROCESS_TRANSFER_VERIFIER

```solidity
contract UltraVerifier PROCESS_TRANSFER_VERIFIER
```

### TRANSFER_VERIFIER

```solidity
contract UltraVerifier TRANSFER_VERIFIER
```

### WITHDRAW_VERIFIER

```solidity
contract UltraVerifier WITHDRAW_VERIFIER
```

### LOCK_VERIFIER

```solidity
contract UltraVerifier LOCK_VERIFIER
```

### totalSupply

```solidity
uint40 totalSupply
```

### token

```solidity
contract IERC20 token
```

### SOURCE_TOKEN_DECIMALS

```solidity
uint256 SOURCE_TOKEN_DECIMALS
```

### decimals

```solidity
uint8 decimals
```

### balances

```solidity
mapping(bytes32 => struct PrivateToken.EncryptedAmount) balances
```

### pendingTransferCounts

```solidity
mapping(bytes32 => uint256) pendingTransferCounts
```

### pendingDepositCounts

```solidity
mapping(bytes32 => uint256) pendingDepositCounts
```

### allPendingTransfersMapping

```solidity
mapping(bytes32 => mapping(uint256 => struct PrivateToken.PendingTransfer)) allPendingTransfersMapping
```

### allPendingDepositsMapping

```solidity
mapping(bytes32 => mapping(uint256 => struct PrivateToken.PendingDeposit)) allPendingDepositsMapping
```

### nonce

```solidity
mapping(bytes32 => mapping(uint256 => bool)) nonce
```

### lockedTo

```solidity
mapping(bytes32 => address) lockedTo
```

### Transfer

```solidity
event Transfer(bytes32 to, bytes32 from, struct PrivateToken.EncryptedAmount amount)
```

### TransferProcessed

```solidity
event TransferProcessed(bytes32 to, struct PrivateToken.EncryptedAmount newBalance, uint256 processFee, address processFeeRecipient)
```

### Deposit

```solidity
event Deposit(address from, bytes32 to, uint256 amount, uint256 processFee)
```

### DepositProcessed

```solidity
event DepositProcessed(bytes32 to, uint256 amount, uint256 processFee, address feeRecipient)
```

### Withdraw

```solidity
event Withdraw(bytes32 from, address to, uint256 amount, address _relayFeeRecipient, uint256 relayFee)
```

### Lock

```solidity
event Lock(bytes32 publicKey, address lockedTo, uint256 relayerFee, address relayerFeeRecipient)
```

### Unlock

```solidity
event Unlock(bytes32 publicKey, address unlockedFrom)
```

### constructor

```solidity
constructor(address _processDepositVerifier, address _processTransferVerifier, address _transferVerifier, address _withdrawVerifier, address _lockVerifier, address _token, uint256 _decimals, address _addEthSignerVerifier, address _changeEthSignerVerfier, address _changeMultisigEthSignerVerifier) public
```

Constructor - setup up verifiers and link to token
@dev

#### Parameters

| Name                              | Type    | Description                                     |
| --------------------------------- | ------- | ----------------------------------------------- |
| \_processDepositVerifier          | address | address of the processDepositVerifier contract  |
| \_processTransferVerifier         | address | address of the processTransferVerifier contract |
| \_transferVerifier                | address | address of the transferVerifier contract        |
| \_withdrawVerifier                | address | address of the withdrawVerifier contract        |
| \_lockVerifier                    | address | address of the lockVerifier contract            |
| \_token                           | address | - ERC20 token address                           |
| \_decimals                        | uint256 |                                                 |
| \_addEthSignerVerifier            | address |                                                 |
| \_changeEthSignerVerfier          | address |                                                 |
| \_changeMultisigEthSignerVerifier | address |                                                 |

### deposit

```solidity
function deposit(address _from, uint256 _amount, bytes32 _to, uint40 _processFee) public
```

Deposits the assocated token into the contract to be used privately.
The deposited amount is pushed to the recepients PendingDeposits queue. The fee
is the amount that will be paid to the processor of the tx (when processPendingDeposits
is called)
This function converts the token to 2 decimal places, the remainder is lost.
@dev

#### Parameters

| Name         | Type    | Description                                                                                          |
| ------------ | ------- | ---------------------------------------------------------------------------------------------------- |
| \_from       | address | - sender of the tokens, an ETH address                                                               |
| \_amount     | uint256 | - amount to deposit                                                                                  |
| \_to         | bytes32 | - the packed public key of the recipient in the system                                               |
| \_processFee | uint40  | - (optional, can be 0) amount to pay the processor of the tx (when processPendingDeposits is called) |

### transferLocals

This functions transfers an encrypted amount of tokens to the recipient (\_to).
If the sender is sending to an account with a 0 balance, they can omit the fee, as the funds
will be directly added to their account. Otherwise a fee can be specified to incentivize
processing of the tx by an unknown third party (see processPendingTranfer). This is required
two account cannot simultaneously update the encrypted balance of the recipient. Having a pending
transfer queue allows the sender to always succeed in debiting their account, and the recipient
receiving the funds.
The account must not be locked to a contract to call this function.
@dev

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct transferLocals {
  uint256 txNonce;
  address lockedByAddress;
  struct PrivateToken.EncryptedAmount oldBalance;
  struct PrivateToken.EncryptedAmount receiverBalance;
  uint256 transferCount;
  bool zeroBalance;
  bytes32[] publicInputs;
}
```

### transfer

```solidity
function transfer(bytes32 _to, bytes32 _from, uint40 _processFee, uint40 _relayFee, address _relayFeeRecipient, struct PrivateToken.EncryptedAmount _amountToSend, struct PrivateToken.EncryptedAmount _senderNewBalance, bytes _proof_transfer) public
```

### withdraw

```solidity
function withdraw(bytes32 _from, address _to, uint40 _amount, uint40 _relayFee, address _relayFeeRecipient, bytes _withdraw_proof, struct PrivateToken.EncryptedAmount _newEncryptedAmount) public
```

withdraws the amount of tokens from the contract to the recipient (\_to). the account must
not be locked to a contract to call this function.
@dev
@param \_from - the packed public key of the sender in the system
@param \_to - the ETH address of the recipient
@param \_amount - amount to withdraw
@param \_relayFee - (optional, can be 0) amount to pay the relayer of the tx, if the sender of
the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels
the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx

#### Parameters

| Name                 | Type                                | Description                                                                                                                                                       |
| -------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| \_from               | bytes32                             |                                                                                                                                                                   |
| \_to                 | address                             |                                                                                                                                                                   |
| \_amount             | uint40                              |                                                                                                                                                                   |
| \_relayFee           | uint40                              |                                                                                                                                                                   |
| \_relayFeeRecipient  | address                             | - the recipient of the relay fee @param \_withdraw_proof - proof @param \_newEncryptedAmount - the new encrypted balance of the sender after the withdraw and fee |
| \_withdraw_proof     | bytes                               |                                                                                                                                                                   |
| \_newEncryptedAmount | struct PrivateToken.EncryptedAmount |                                                                                                                                                                   |

### processPendingDeposit

```solidity
function processPendingDeposit(bytes _proof, uint256[] _txsToProcess, address _feeRecipient, bytes32 _recipient, struct PrivateToken.EncryptedAmount _zeroBalance, struct PrivateToken.EncryptedAmount _newBalance) public
```

the circuit processing this takes in a fixes number of pending transactions.
It will take up to 4 at a time (TODO: research how big this num should this be?).
The circuit checks that the publicKey and recipient match. it encrypts the totalAmount
and adds it to the recipients encrypted balance. It checks that the provided encrypted
balance and the calculated encrypted balances match.
@dev

#### Parameters

| Name           | Type                                | Description                                                                                  |
| -------------- | ----------------------------------- | -------------------------------------------------------------------------------------------- |
| \_proof        | bytes                               | - proof to verify with the ProcessPendingTransfers circuit                                   |
| \_txsToProcess | uint256[]                           | - an array of keys of PendingDeposits to process from allPendingDepositsMapping max length 4 |
| \_feeRecipient | address                             | - the recipient of the fees (typically the processor of these txs)                           |
| \_recipient    | bytes32                             | - the packed public key of the recipient in the system                                       |
| \_zeroBalance  | struct PrivateToken.EncryptedAmount |                                                                                              |
| \_newBalance   | struct PrivateToken.EncryptedAmount | - the new balance of the recipient after processing the pending transfers                    |

### processPendingTransfer

```solidity
function processPendingTransfer(bytes _proof, uint8[] _txsToProcess, address _feeRecipient, bytes32 _recipient, struct PrivateToken.EncryptedAmount _newBalance) public
```

the circuit processing this takes in a fixes number of pending transactions.
It will take up to 4 at a time (TODO: research how big this num should this be?). The circuit adds all of the encrypted amounts sent
and then checks that the \_newBalance is the sum of the old balance and the sum of the
amounts to add. All of the fees are summed and sent to the \_feeRecipient
@dev

#### Parameters

| Name           | Type                                | Description                                                               |
| -------------- | ----------------------------------- | ------------------------------------------------------------------------- |
| \_proof        | bytes                               | - proof to verify with the ProcessPendingTransfers circuit                |
| \_txsToProcess | uint8[]                             | - the indexs of the userPendingTransfersArray to process; max length 4    |
| \_feeRecipient | address                             | - the recipient of the fees (typically the processor of these txs)        |
| \_recipient    | bytes32                             | - the recipient of the pending transfers within the system                |
| \_newBalance   | struct PrivateToken.EncryptedAmount | - the new balance of the recipient after processing the pending transfers |

### lock

```solidity
function lock(bytes32 _from, address _lockToContract, uint40 _relayFee, address _relayFeeRecipient, bytes _proof, struct PrivateToken.EncryptedAmount _newEncryptedAmount) public
```

the contract this is locked to must call unlock to give control back to this contract
locked contracts cannot transfer or withdraw funds.
@param \_from - the public key of the account to lock

#### Parameters

| Name                 | Type                                | Description                                                                                                                                                                                                                                                                              |
| -------------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| \_from               | bytes32                             |                                                                                                                                                                                                                                                                                          |
| \_lockToContract     | address                             | - the contract to lock the account to                                                                                                                                                                                                                                                    |
| \_relayFee           | uint40                              | - (optional, can be 0) amount to pay the relayer of the tx, if the sender of the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx |
| \_relayFeeRecipient  | address                             | - the recipient of the relay fee                                                                                                                                                                                                                                                         |
| \_proof              | bytes                               | - proof to verify with the ProcessPendingTransfers circuit                                                                                                                                                                                                                               |
| \_newEncryptedAmount | struct PrivateToken.EncryptedAmount | - the new encrypted balance of the sender after the fee                                                                                                                                                                                                                                  |

### unlock

```solidity
function unlock(bytes32 publicKey) public
```

unlocks an account locked by a contract. This function must be called by the
contract that is locked to an account. Users must lock their account to a contract that
has a function that calls this function, or their funds will be locked forever.
@dev

#### Parameters

| Name      | Type    | Description                                      |
| --------- | ------- | ------------------------------------------------ |
| publicKey | bytes32 | - the packed public key of the account to unlock |

### checkAndUpdateNonce

```solidity
function checkAndUpdateNonce(bytes32 _from, struct PrivateToken.EncryptedAmount _encryptedAmount) internal returns (uint256)
```

### \_stageCommonTransferInputs

```solidity
function _stageCommonTransferInputs(struct PrivateToken.transferLocals local, bytes32 _from, bytes32 _to, uint40 _processFee, uint40 _relayFee, struct PrivateToken.EncryptedAmount _amountToSend, struct PrivateToken.EncryptedAmount _senderNewBalance) internal pure returns (struct PrivateToken.transferLocals)
```

## PrivateTokenFactory

### privateToken

```solidity
address privateToken
```

### processDepositVerifier

```solidity
address processDepositVerifier
```

### processTransferVerifier

```solidity
address processTransferVerifier
```

### transferVerifier

```solidity
address transferVerifier
```

### withdrawVerifier

```solidity
address withdrawVerifier
```

### lockVerifier

```solidity
address lockVerifier
```

### addEthSignerVerifier

```solidity
address addEthSignerVerifier
```

### changeEthSignerVerifier

```solidity
address changeEthSignerVerifier
```

### changeMultisigEthSignerVerifier

```solidity
address changeMultisigEthSignerVerifier
```

### Deployed

```solidity
event Deployed(address token)
```

### constructor

```solidity
constructor(address _pendingDepositVerifier, address _pendingTransferVerifier, address _transferVerifier, address _withdrawVerifier, address _lockVerifier, address _addEthSignerVerifier, address _changeEthSignerVerfier, address _changeMultisigEthSignerVerifier) public
```

### deploy

```solidity
function deploy(address _token) public returns (address)
```

## UsingAccountControllers

Use this contract with PrivateToken.sol to use the non-default private/public key pairs

### MultisigParams

```solidity
struct MultisigParams {
  address[] ethSigners;
  uint256 threshold;
}
```

### ethSigner

```solidity
mapping(bytes32 => address) ethSigner
```

Mapping of packed public key to eth signer address

### erc4337Controller

```solidity
mapping(bytes32 => address) erc4337Controller
```

Mapping of packed public key to erc4337 controller address

### multisigEthSigners

```solidity
mapping(bytes32 => struct UsingAccountControllers.MultisigParams) multisigEthSigners
```

Mapping of packed public key to multisig params

### otherNonce

```solidity
mapping(bytes32 => uint256) otherNonce
```

Mapping of packed public key to nonce to prevent replay attacks when changing eth signers

### BJJ_PRIME

```solidity
uint256 BJJ_PRIME
```

The prime field that the circuit is constructed over. This is used to make message hashes fit in 1 field element

### addEthSignerVerifier

```solidity
contract UltraVerifier addEthSignerVerifier
```

change functions can be used to revoke, just set to address(0)

### changeEthSignerVerifier

```solidity
contract UltraVerifier changeEthSignerVerifier
```

### changeMultisigEthSignerVerifier

```solidity
contract UltraVerifier changeMultisigEthSignerVerifier
```

### AddController

```solidity
event AddController(bytes32 packedPublicKey, address controllerAddress)
```

### Change4337Controller

```solidity
event Change4337Controller(bytes32 packedPublicKey, address oldControllerAddress, address newControllerAddress)
```

### ChangeEthSigner

```solidity
event ChangeEthSigner(bytes32 packedPublicKey, address oldEthSignerAddress, address newEthSignerAddress)
```

### AddMultisigEthSigners

```solidity
event AddMultisigEthSigners(bytes32 packedPublicKey, address[] ethSignerAddresses, uint256 threshold)
```

### ChangeMultisigEthSigners

```solidity
event ChangeMultisigEthSigners(bytes32 packedPublicKey, address[] oldEthSignerAddresses, address[] newEthSignerAddresses, uint256 oldThreshold, uint256 newThreshold)
```

### constructor

```solidity
constructor(address _addEthSignerVerifier, address _changeEthSignerVerfier, address _changeMultisigEthSignerVerifier) public
```

### addOtherController

```solidity
function addOtherController(bytes32 _packedPublicKey, address _ethAddress, bytes _proof) public
```

This function allows a Private Token account to assign an eth signer or an erc4337 controller.
The address associated with the packed public key must be 0x0.

_See the add_eth_signer circuit for circuit details_

#### Parameters

| Name              | Type    | Description                                                                          |
| ----------------- | ------- | ------------------------------------------------------------------------------------ |
| \_packedPublicKey | bytes32 | The packed public key of the account to update                                       |
| \_ethAddress      | address | The eth address of the signer or the 4337 account                                    |
| \_proof           | bytes   | The proof that the caller has the private key corresponding to the packed public key |

### change4337Controller

```solidity
function change4337Controller(bytes32 _packedPublicKey, address _newAddress) public
```

This function updates the erc4337 controller. It must be called by the current 4337 controller.

_There is no proof validation required because the caller must be the current controller._

#### Parameters

| Name              | Type    | Description                                                      |
| ----------------- | ------- | ---------------------------------------------------------------- |
| \_packedPublicKey | bytes32 | The packed public key of the account to update                   |
| \_newAddress      | address | The new erc4337 controller address. Can be address(0) to revoke. |

### changeEthSigner

```solidity
function changeEthSigner(bytes _proof, bytes32 _packedPublicKey, address _newEthSignerAddress) public
```

This function updates the eth signer address. The proof will verify a signature from the current registered signer

_The message hash is calculated in the function to prevent replay attacks. The caller must sign the corresponding
hash and use it when generating the proof
See the change_eth_signer circuit for circuit details_

#### Parameters

| Name                  | Type    | Description                                                                                 |
| --------------------- | ------- | ------------------------------------------------------------------------------------------- |
| \_proof               | bytes   | The proof that the caller can create a signautre corresponding to the registered eth signer |
| \_packedPublicKey     | bytes32 | The packed public key of the account to update                                              |
| \_newEthSignerAddress | address | The new eth signer address. Can be address(0) to revoke.                                    |

### addMultisigEthSigners

```solidity
function addMultisigEthSigners(bytes _proof, bytes32 _packedPublicKey, address[] _ethSignerAddresses, uint256 _threshold) public
```

This function adds a multisig eth signer. It uses the addEthSignerVerifier circuit.

_See the add_eth_signer circuit for circuit details_

#### Parameters

| Name                 | Type      | Description                                                                          |
| -------------------- | --------- | ------------------------------------------------------------------------------------ |
| \_proof              | bytes     | The proof that the caller has the private key corresponding to the packed public key |
| \_packedPublicKey    | bytes32   | The packed public key of the account to update                                       |
| \_ethSignerAddresses | address[] | The new eth signer addresses on the multisig                                         |
| \_threshold          | uint256   | The threshold of signatures required to sign a message                               |

### changeMultisigEthSigners

```solidity
function changeMultisigEthSigners(bytes _proof, bytes32 _packedPublicKey, address[] _newEthSignerAddresses, uint256 _threshold) public
```

This function changes the multisig eth signers.

_See the change_multi_eth_signers circuit for circuit details_

#### Parameters

| Name                    | Type      | Description                                                                        |
| ----------------------- | --------- | ---------------------------------------------------------------------------------- |
| \_proof                 | bytes     | The proof that the caller has enough signatures to change the multisig eth signers |
| \_packedPublicKey       | bytes32   | The packed public key of the account to update                                     |
| \_newEthSignerAddresses | address[] | The new eth signer addresses on the multisig                                       |
| \_threshold             | uint256   | The threshold of signatures required                                               |
