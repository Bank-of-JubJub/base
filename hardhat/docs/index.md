# Solidity API

## ERC165Checker

_Library used to query support of an interface declared via {IERC165}.

Note that these functions return the actual result of the query: they do not
`revert` if an interface is not supported. It is up to the caller to decide
what to do in these cases._

### supportsERC165

```solidity
function supportsERC165(address account) internal view returns (bool)
```

_Returns true if `account` supports the {IERC165} interface._

### supportsInterface

```solidity
function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool)
```

_Returns true if `account` supports the interface defined by
`interfaceId`. Support for {IERC165} itself is queried automatically.

See {IERC165-supportsInterface}._

### getSupportedInterfaces

```solidity
function getSupportedInterfaces(address account, bytes4[] interfaceIds) internal view returns (bool[])
```

_Returns a boolean array where each value corresponds to the
interfaces passed in and whether they're supported or not. This allows
you to batch check interfaces for a contract where your expectation
is that some interfaces may not be supported.

See {IERC165-supportsInterface}._

### supportsAllInterfaces

```solidity
function supportsAllInterfaces(address account, bytes4[] interfaceIds) internal view returns (bool)
```

_Returns true if `account` supports all the interfaces defined in
`interfaceIds`. Support for {IERC165} itself is queried automatically.

Batch-querying can lead to gas savings by skipping repeated checks for
{IERC165} support.

See {IERC165-supportsInterface}._

### supportsERC165InterfaceUnchecked

```solidity
function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool)
```

Query if a contract implements an interface, does not check ERC165 support

_Assumes that account contains a contract that supports ERC165, otherwise
the behavior of this method is undefined. This precondition can be checked
with {supportsERC165}.

Some precompiled contracts will falsely indicate support for a given interface, so caution
should be exercised when using this function.

Interface identification is specified in ERC-165._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address of the contract to query for support of an interface |
| interfaceId | bytes4 | The interface identifier, as specified in ERC-165 |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true if the contract at account indicates support of the interface with identifier interfaceId, false otherwise |

## IERC165

_Interface of the ERC165 standard, as defined in the
https://eips.ethereum.org/EIPS/eip-165[EIP].

Implementers can declare support of contract interfaces, which can then be
queried by others ({ERC165Checker}).

For an implementation, see {ERC165}._

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```

_Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.

This function call must use less than 30 000 gas._

## IERC20

_Interface of the ERC20 standard as defined in the EIP._

### Transfer

```solidity
event Transfer(address from, address to, uint256 value)
```

_Emitted when `value` tokens are moved from one account (`from`) to
another (`to`).

Note that `value` may be zero._

### Approval

```solidity
event Approval(address owner, address spender, uint256 value)
```

_Emitted when the allowance of a `spender` for an `owner` is set by
a call to {approve}. `value` is the new allowance._

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

_Returns the value of tokens in existence._

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```

_Returns the value of tokens owned by `account`._

### transfer

```solidity
function transfer(address to, uint256 value) external returns (bool)
```

_Moves a `value` amount of tokens from the caller's account to `to`.

Returns a boolean value indicating whether the operation succeeded.

Emits a {Transfer} event._

### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```

_Returns the remaining number of tokens that `spender` will be
allowed to spend on behalf of `owner` through {transferFrom}. This is
zero by default.

This value changes when {approve} or {transferFrom} are called._

### approve

```solidity
function approve(address spender, uint256 value) external returns (bool)
```

_Sets a `value` amount of tokens as the allowance of `spender` over the
caller's tokens.

Returns a boolean value indicating whether the operation succeeded.

IMPORTANT: Beware that changing an allowance with this method brings the risk
that someone may use both the old and the new allowance by unfortunate
transaction ordering. One possible solution to mitigate this race
condition is to first reduce the spender's allowance to 0 and set the
desired value afterwards:
https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

Emits an {Approval} event._

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 value) external returns (bool)
```

_Moves a `value` amount of tokens from `from` to `to` using the
allowance mechanism. `value` is then deducted from the caller's
allowance.

Returns a boolean value indicating whether the operation succeeded.

Emits a {Transfer} event._

### decimals

```solidity
function decimals() external view returns (uint256)
```

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

| Name | Type | Description |
| ---- | ---- | ----------- |
| _processDepositVerifier | address | address of the processDepositVerifier contract |
| _processTransferVerifier | address | address of the processTransferVerifier contract |
| _transferVerifier | address | address of the transferVerifier contract |
| _withdrawVerifier | address | address of the withdrawVerifier contract |
| _lockVerifier | address | address of the lockVerifier contract |
| _token | address | - ERC20 token address |
| _decimals | uint256 |  |
| _addEthSignerVerifier | address |  |
| _changeEthSignerVerfier | address |  |
| _changeMultisigEthSignerVerifier | address |  |

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

| Name | Type | Description |
| ---- | ---- | ----------- |
| _from | address | - sender of the tokens, an ETH address |
| _amount | uint256 | - amount to deposit |
| _to | bytes32 | - the packed public key of the recipient in the system |
| _processFee | uint40 | - (optional, can be 0) amount to pay the processor of the tx (when processPendingDeposits is called) |

### tranferLocals

This functions transfers an encrypted amount of tokens to the recipient (_to).
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
struct tranferLocals {
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

withdraws the amount of tokens from the contract to the recipient (_to). the account must
 not be locked to a contract to call this function.
@dev
 @param _from - the packed public key of the sender in the system
 @param _to - the ETH address of the recipient
 @param _amount - amount to withdraw
 @param _relayFee - (optional, can be 0) amount to pay the relayer of the tx, if the sender of
  the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels
  the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _from | bytes32 |  |
| _to | address |  |
| _amount | uint40 |  |
| _relayFee | uint40 |  |
| _relayFeeRecipient | address | - the recipient of the relay fee  @param _withdraw_proof - proof  @param _newEncryptedAmount - the new encrypted balance of the sender after the withdraw and fee |
| _withdraw_proof | bytes |  |
| _newEncryptedAmount | struct PrivateToken.EncryptedAmount |  |

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

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - proof to verify with the ProcessPendingTransfers circuit |
| _txsToProcess | uint256[] | - an array of keys of PendingDeposits to process from allPendingDepositsMapping      max length 4 |
| _feeRecipient | address | - the recipient of the fees (typically the processor of these txs) |
| _recipient | bytes32 | - the packed public key of the recipient in the system |
| _zeroBalance | struct PrivateToken.EncryptedAmount |  |
| _newBalance | struct PrivateToken.EncryptedAmount | - the new balance of the recipient after processing the pending transfers |

### processPendingTransfer

```solidity
function processPendingTransfer(bytes _proof, uint8[] _txsToProcess, address _feeRecipient, bytes32 _recipient, struct PrivateToken.EncryptedAmount _newBalance) public
```

the circuit processing this takes in a fixes number of pending transactions.
 It will take up to 4 at a time (TODO: research how big this num should this be?). The circuit adds all of the encrypted amounts sent
 and then checks that the _newBalance is the sum of the old balance and the sum of the
 amounts to add. All of the fees are summed and sent to the _feeRecipient
@dev

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - proof to verify with the ProcessPendingTransfers circuit |
| _txsToProcess | uint8[] | - the indexs of the userPendingTransfersArray to process; max length 4 |
| _feeRecipient | address | - the recipient of the fees (typically the processor of these txs) |
| _recipient | bytes32 | - the recipient of the pending transfers within the system |
| _newBalance | struct PrivateToken.EncryptedAmount | - the new balance of the recipient after processing the pending transfers |

### lock

```solidity
function lock(bytes32 _from, address _lockToContract, uint40 _relayFee, address _relayFeeRecipient, bytes _proof, struct PrivateToken.EncryptedAmount _newEncryptedAmount) public
```

the contract this is locked to must call unlock to give control back to this contract
 locked contracts cannot transfer or withdraw funds.
 @param _from - the public key of the account to lock

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _from | bytes32 |  |
| _lockToContract | address | - the contract to lock the account to |
| _relayFee | uint40 | - (optional, can be 0) amount to pay the relayer of the tx, if the sender of   the ETH tx is not the creator of the proof. sharing of the proof can happen in off-chain channels   the relayer can check that they will get the fee by verifing the proof off-chain before submitting the tx |
| _relayFeeRecipient | address | - the recipient of the relay fee |
| _proof | bytes | - proof to verify with the ProcessPendingTransfers circuit |
| _newEncryptedAmount | struct PrivateToken.EncryptedAmount | - the new encrypted balance of the sender after the fee |

### unlock

```solidity
function unlock(bytes32 publicKey) public
```

unlocks an account locked by a contract. This function must be called by the
contract that is locked to an account. Users must lock their account to a contract that
has a function that calls this function, or their funds will be locked forever.
@dev

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| publicKey | bytes32 | - the packed public key of the account to unlock |

### checkAndUpdateNonce

```solidity
function checkAndUpdateNonce(bytes32 _from, struct PrivateToken.EncryptedAmount _encryptedAmount) internal returns (uint256)
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

## UsingEthSigners

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

### erc4337Controller

```solidity
mapping(bytes32 => address) erc4337Controller
```

### multisigEthSigners

```solidity
mapping(bytes32 => struct UsingEthSigners.MultisigParams) multisigEthSigners
```

### otherNonce

```solidity
mapping(bytes32 => uint256) otherNonce
```

### BJJ_PRIME

```solidity
uint256 BJJ_PRIME
```

### addEthSignerVerifier

```solidity
contract UltraVerifier addEthSignerVerifier
```

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

### change4337Controller

```solidity
function change4337Controller(bytes32 _packedPublicKey, address _newAddress) public
```

### changeEthSigner

```solidity
function changeEthSigner(bytes _proof, bytes32 _packedPublicKey, address _newEthSignerAddress) public
```

### addMultisigEthSigners

```solidity
function addMultisigEthSigners(bytes _proof, bytes32 _packedPublicKey, address[] _ethSignerAddresses, uint256 _threshold) public
```

### changeMultisigEthSigners

```solidity
function changeMultisigEthSigners(bytes _proof, bytes32 _packedPublicKey, address[] _newEthSignerAddresses, uint256 _threshold) public
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## UltraVerificationKey

### verificationKeyHash

```solidity
function verificationKeyHash() internal pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure
```

## BaseUltraVerifier

_Top level Plonk proof verification contract, which allows Plonk proof to be verified_

### N_LOC

```solidity
uint256 N_LOC
```

### NUM_INPUTS_LOC

```solidity
uint256 NUM_INPUTS_LOC
```

### OMEGA_LOC

```solidity
uint256 OMEGA_LOC
```

### DOMAIN_INVERSE_LOC

```solidity
uint256 DOMAIN_INVERSE_LOC
```

### Q1_X_LOC

```solidity
uint256 Q1_X_LOC
```

### Q1_Y_LOC

```solidity
uint256 Q1_Y_LOC
```

### Q2_X_LOC

```solidity
uint256 Q2_X_LOC
```

### Q2_Y_LOC

```solidity
uint256 Q2_Y_LOC
```

### Q3_X_LOC

```solidity
uint256 Q3_X_LOC
```

### Q3_Y_LOC

```solidity
uint256 Q3_Y_LOC
```

### Q4_X_LOC

```solidity
uint256 Q4_X_LOC
```

### Q4_Y_LOC

```solidity
uint256 Q4_Y_LOC
```

### QM_X_LOC

```solidity
uint256 QM_X_LOC
```

### QM_Y_LOC

```solidity
uint256 QM_Y_LOC
```

### QC_X_LOC

```solidity
uint256 QC_X_LOC
```

### QC_Y_LOC

```solidity
uint256 QC_Y_LOC
```

### QARITH_X_LOC

```solidity
uint256 QARITH_X_LOC
```

### QARITH_Y_LOC

```solidity
uint256 QARITH_Y_LOC
```

### QSORT_X_LOC

```solidity
uint256 QSORT_X_LOC
```

### QSORT_Y_LOC

```solidity
uint256 QSORT_Y_LOC
```

### QELLIPTIC_X_LOC

```solidity
uint256 QELLIPTIC_X_LOC
```

### QELLIPTIC_Y_LOC

```solidity
uint256 QELLIPTIC_Y_LOC
```

### QAUX_X_LOC

```solidity
uint256 QAUX_X_LOC
```

### QAUX_Y_LOC

```solidity
uint256 QAUX_Y_LOC
```

### SIGMA1_X_LOC

```solidity
uint256 SIGMA1_X_LOC
```

### SIGMA1_Y_LOC

```solidity
uint256 SIGMA1_Y_LOC
```

### SIGMA2_X_LOC

```solidity
uint256 SIGMA2_X_LOC
```

### SIGMA2_Y_LOC

```solidity
uint256 SIGMA2_Y_LOC
```

### SIGMA3_X_LOC

```solidity
uint256 SIGMA3_X_LOC
```

### SIGMA3_Y_LOC

```solidity
uint256 SIGMA3_Y_LOC
```

### SIGMA4_X_LOC

```solidity
uint256 SIGMA4_X_LOC
```

### SIGMA4_Y_LOC

```solidity
uint256 SIGMA4_Y_LOC
```

### TABLE1_X_LOC

```solidity
uint256 TABLE1_X_LOC
```

### TABLE1_Y_LOC

```solidity
uint256 TABLE1_Y_LOC
```

### TABLE2_X_LOC

```solidity
uint256 TABLE2_X_LOC
```

### TABLE2_Y_LOC

```solidity
uint256 TABLE2_Y_LOC
```

### TABLE3_X_LOC

```solidity
uint256 TABLE3_X_LOC
```

### TABLE3_Y_LOC

```solidity
uint256 TABLE3_Y_LOC
```

### TABLE4_X_LOC

```solidity
uint256 TABLE4_X_LOC
```

### TABLE4_Y_LOC

```solidity
uint256 TABLE4_Y_LOC
```

### TABLE_TYPE_X_LOC

```solidity
uint256 TABLE_TYPE_X_LOC
```

### TABLE_TYPE_Y_LOC

```solidity
uint256 TABLE_TYPE_Y_LOC
```

### ID1_X_LOC

```solidity
uint256 ID1_X_LOC
```

### ID1_Y_LOC

```solidity
uint256 ID1_Y_LOC
```

### ID2_X_LOC

```solidity
uint256 ID2_X_LOC
```

### ID2_Y_LOC

```solidity
uint256 ID2_Y_LOC
```

### ID3_X_LOC

```solidity
uint256 ID3_X_LOC
```

### ID3_Y_LOC

```solidity
uint256 ID3_Y_LOC
```

### ID4_X_LOC

```solidity
uint256 ID4_X_LOC
```

### ID4_Y_LOC

```solidity
uint256 ID4_Y_LOC
```

### CONTAINS_RECURSIVE_PROOF_LOC

```solidity
uint256 CONTAINS_RECURSIVE_PROOF_LOC
```

### RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC

```solidity
uint256 RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC
```

### G2X_X0_LOC

```solidity
uint256 G2X_X0_LOC
```

### G2X_X1_LOC

```solidity
uint256 G2X_X1_LOC
```

### G2X_Y0_LOC

```solidity
uint256 G2X_Y0_LOC
```

### G2X_Y1_LOC

```solidity
uint256 G2X_Y1_LOC
```

### W1_X_LOC

```solidity
uint256 W1_X_LOC
```

### W1_Y_LOC

```solidity
uint256 W1_Y_LOC
```

### W2_X_LOC

```solidity
uint256 W2_X_LOC
```

### W2_Y_LOC

```solidity
uint256 W2_Y_LOC
```

### W3_X_LOC

```solidity
uint256 W3_X_LOC
```

### W3_Y_LOC

```solidity
uint256 W3_Y_LOC
```

### W4_X_LOC

```solidity
uint256 W4_X_LOC
```

### W4_Y_LOC

```solidity
uint256 W4_Y_LOC
```

### S_X_LOC

```solidity
uint256 S_X_LOC
```

### S_Y_LOC

```solidity
uint256 S_Y_LOC
```

### Z_X_LOC

```solidity
uint256 Z_X_LOC
```

### Z_Y_LOC

```solidity
uint256 Z_Y_LOC
```

### Z_LOOKUP_X_LOC

```solidity
uint256 Z_LOOKUP_X_LOC
```

### Z_LOOKUP_Y_LOC

```solidity
uint256 Z_LOOKUP_Y_LOC
```

### T1_X_LOC

```solidity
uint256 T1_X_LOC
```

### T1_Y_LOC

```solidity
uint256 T1_Y_LOC
```

### T2_X_LOC

```solidity
uint256 T2_X_LOC
```

### T2_Y_LOC

```solidity
uint256 T2_Y_LOC
```

### T3_X_LOC

```solidity
uint256 T3_X_LOC
```

### T3_Y_LOC

```solidity
uint256 T3_Y_LOC
```

### T4_X_LOC

```solidity
uint256 T4_X_LOC
```

### T4_Y_LOC

```solidity
uint256 T4_Y_LOC
```

### W1_EVAL_LOC

```solidity
uint256 W1_EVAL_LOC
```

### W2_EVAL_LOC

```solidity
uint256 W2_EVAL_LOC
```

### W3_EVAL_LOC

```solidity
uint256 W3_EVAL_LOC
```

### W4_EVAL_LOC

```solidity
uint256 W4_EVAL_LOC
```

### S_EVAL_LOC

```solidity
uint256 S_EVAL_LOC
```

### Z_EVAL_LOC

```solidity
uint256 Z_EVAL_LOC
```

### Z_LOOKUP_EVAL_LOC

```solidity
uint256 Z_LOOKUP_EVAL_LOC
```

### Q1_EVAL_LOC

```solidity
uint256 Q1_EVAL_LOC
```

### Q2_EVAL_LOC

```solidity
uint256 Q2_EVAL_LOC
```

### Q3_EVAL_LOC

```solidity
uint256 Q3_EVAL_LOC
```

### Q4_EVAL_LOC

```solidity
uint256 Q4_EVAL_LOC
```

### QM_EVAL_LOC

```solidity
uint256 QM_EVAL_LOC
```

### QC_EVAL_LOC

```solidity
uint256 QC_EVAL_LOC
```

### QARITH_EVAL_LOC

```solidity
uint256 QARITH_EVAL_LOC
```

### QSORT_EVAL_LOC

```solidity
uint256 QSORT_EVAL_LOC
```

### QELLIPTIC_EVAL_LOC

```solidity
uint256 QELLIPTIC_EVAL_LOC
```

### QAUX_EVAL_LOC

```solidity
uint256 QAUX_EVAL_LOC
```

### TABLE1_EVAL_LOC

```solidity
uint256 TABLE1_EVAL_LOC
```

### TABLE2_EVAL_LOC

```solidity
uint256 TABLE2_EVAL_LOC
```

### TABLE3_EVAL_LOC

```solidity
uint256 TABLE3_EVAL_LOC
```

### TABLE4_EVAL_LOC

```solidity
uint256 TABLE4_EVAL_LOC
```

### TABLE_TYPE_EVAL_LOC

```solidity
uint256 TABLE_TYPE_EVAL_LOC
```

### ID1_EVAL_LOC

```solidity
uint256 ID1_EVAL_LOC
```

### ID2_EVAL_LOC

```solidity
uint256 ID2_EVAL_LOC
```

### ID3_EVAL_LOC

```solidity
uint256 ID3_EVAL_LOC
```

### ID4_EVAL_LOC

```solidity
uint256 ID4_EVAL_LOC
```

### SIGMA1_EVAL_LOC

```solidity
uint256 SIGMA1_EVAL_LOC
```

### SIGMA2_EVAL_LOC

```solidity
uint256 SIGMA2_EVAL_LOC
```

### SIGMA3_EVAL_LOC

```solidity
uint256 SIGMA3_EVAL_LOC
```

### SIGMA4_EVAL_LOC

```solidity
uint256 SIGMA4_EVAL_LOC
```

### W1_OMEGA_EVAL_LOC

```solidity
uint256 W1_OMEGA_EVAL_LOC
```

### W2_OMEGA_EVAL_LOC

```solidity
uint256 W2_OMEGA_EVAL_LOC
```

### W3_OMEGA_EVAL_LOC

```solidity
uint256 W3_OMEGA_EVAL_LOC
```

### W4_OMEGA_EVAL_LOC

```solidity
uint256 W4_OMEGA_EVAL_LOC
```

### S_OMEGA_EVAL_LOC

```solidity
uint256 S_OMEGA_EVAL_LOC
```

### Z_OMEGA_EVAL_LOC

```solidity
uint256 Z_OMEGA_EVAL_LOC
```

### Z_LOOKUP_OMEGA_EVAL_LOC

```solidity
uint256 Z_LOOKUP_OMEGA_EVAL_LOC
```

### TABLE1_OMEGA_EVAL_LOC

```solidity
uint256 TABLE1_OMEGA_EVAL_LOC
```

### TABLE2_OMEGA_EVAL_LOC

```solidity
uint256 TABLE2_OMEGA_EVAL_LOC
```

### TABLE3_OMEGA_EVAL_LOC

```solidity
uint256 TABLE3_OMEGA_EVAL_LOC
```

### TABLE4_OMEGA_EVAL_LOC

```solidity
uint256 TABLE4_OMEGA_EVAL_LOC
```

### PI_Z_X_LOC

```solidity
uint256 PI_Z_X_LOC
```

### PI_Z_Y_LOC

```solidity
uint256 PI_Z_Y_LOC
```

### PI_Z_OMEGA_X_LOC

```solidity
uint256 PI_Z_OMEGA_X_LOC
```

### PI_Z_OMEGA_Y_LOC

```solidity
uint256 PI_Z_OMEGA_Y_LOC
```

### X1_EVAL_LOC

```solidity
uint256 X1_EVAL_LOC
```

### X2_EVAL_LOC

```solidity
uint256 X2_EVAL_LOC
```

### X3_EVAL_LOC

```solidity
uint256 X3_EVAL_LOC
```

### Y1_EVAL_LOC

```solidity
uint256 Y1_EVAL_LOC
```

### Y2_EVAL_LOC

```solidity
uint256 Y2_EVAL_LOC
```

### Y3_EVAL_LOC

```solidity
uint256 Y3_EVAL_LOC
```

### QBETA_LOC

```solidity
uint256 QBETA_LOC
```

### QBETA_SQR_LOC

```solidity
uint256 QBETA_SQR_LOC
```

### QSIGN_LOC

```solidity
uint256 QSIGN_LOC
```

### C_BETA_LOC

```solidity
uint256 C_BETA_LOC
```

### C_GAMMA_LOC

```solidity
uint256 C_GAMMA_LOC
```

### C_ALPHA_LOC

```solidity
uint256 C_ALPHA_LOC
```

### C_ETA_LOC

```solidity
uint256 C_ETA_LOC
```

### C_ETA_SQR_LOC

```solidity
uint256 C_ETA_SQR_LOC
```

### C_ETA_CUBE_LOC

```solidity
uint256 C_ETA_CUBE_LOC
```

### C_ZETA_LOC

```solidity
uint256 C_ZETA_LOC
```

### C_CURRENT_LOC

```solidity
uint256 C_CURRENT_LOC
```

### C_V0_LOC

```solidity
uint256 C_V0_LOC
```

### C_V1_LOC

```solidity
uint256 C_V1_LOC
```

### C_V2_LOC

```solidity
uint256 C_V2_LOC
```

### C_V3_LOC

```solidity
uint256 C_V3_LOC
```

### C_V4_LOC

```solidity
uint256 C_V4_LOC
```

### C_V5_LOC

```solidity
uint256 C_V5_LOC
```

### C_V6_LOC

```solidity
uint256 C_V6_LOC
```

### C_V7_LOC

```solidity
uint256 C_V7_LOC
```

### C_V8_LOC

```solidity
uint256 C_V8_LOC
```

### C_V9_LOC

```solidity
uint256 C_V9_LOC
```

### C_V10_LOC

```solidity
uint256 C_V10_LOC
```

### C_V11_LOC

```solidity
uint256 C_V11_LOC
```

### C_V12_LOC

```solidity
uint256 C_V12_LOC
```

### C_V13_LOC

```solidity
uint256 C_V13_LOC
```

### C_V14_LOC

```solidity
uint256 C_V14_LOC
```

### C_V15_LOC

```solidity
uint256 C_V15_LOC
```

### C_V16_LOC

```solidity
uint256 C_V16_LOC
```

### C_V17_LOC

```solidity
uint256 C_V17_LOC
```

### C_V18_LOC

```solidity
uint256 C_V18_LOC
```

### C_V19_LOC

```solidity
uint256 C_V19_LOC
```

### C_V20_LOC

```solidity
uint256 C_V20_LOC
```

### C_V21_LOC

```solidity
uint256 C_V21_LOC
```

### C_V22_LOC

```solidity
uint256 C_V22_LOC
```

### C_V23_LOC

```solidity
uint256 C_V23_LOC
```

### C_V24_LOC

```solidity
uint256 C_V24_LOC
```

### C_V25_LOC

```solidity
uint256 C_V25_LOC
```

### C_V26_LOC

```solidity
uint256 C_V26_LOC
```

### C_V27_LOC

```solidity
uint256 C_V27_LOC
```

### C_V28_LOC

```solidity
uint256 C_V28_LOC
```

### C_V29_LOC

```solidity
uint256 C_V29_LOC
```

### C_V30_LOC

```solidity
uint256 C_V30_LOC
```

### C_U_LOC

```solidity
uint256 C_U_LOC
```

### DELTA_NUMERATOR_LOC

```solidity
uint256 DELTA_NUMERATOR_LOC
```

### DELTA_DENOMINATOR_LOC

```solidity
uint256 DELTA_DENOMINATOR_LOC
```

### ZETA_POW_N_LOC

```solidity
uint256 ZETA_POW_N_LOC
```

### PUBLIC_INPUT_DELTA_LOC

```solidity
uint256 PUBLIC_INPUT_DELTA_LOC
```

### ZERO_POLY_LOC

```solidity
uint256 ZERO_POLY_LOC
```

### L_START_LOC

```solidity
uint256 L_START_LOC
```

### L_END_LOC

```solidity
uint256 L_END_LOC
```

### R_ZERO_EVAL_LOC

```solidity
uint256 R_ZERO_EVAL_LOC
```

### PLOOKUP_DELTA_NUMERATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_NUMERATOR_LOC
```

### PLOOKUP_DELTA_DENOMINATOR_LOC

```solidity
uint256 PLOOKUP_DELTA_DENOMINATOR_LOC
```

### PLOOKUP_DELTA_LOC

```solidity
uint256 PLOOKUP_DELTA_LOC
```

### ACCUMULATOR_X_LOC

```solidity
uint256 ACCUMULATOR_X_LOC
```

### ACCUMULATOR_Y_LOC

```solidity
uint256 ACCUMULATOR_Y_LOC
```

### ACCUMULATOR2_X_LOC

```solidity
uint256 ACCUMULATOR2_X_LOC
```

### ACCUMULATOR2_Y_LOC

```solidity
uint256 ACCUMULATOR2_Y_LOC
```

### PAIRING_LHS_X_LOC

```solidity
uint256 PAIRING_LHS_X_LOC
```

### PAIRING_LHS_Y_LOC

```solidity
uint256 PAIRING_LHS_Y_LOC
```

### PAIRING_RHS_X_LOC

```solidity
uint256 PAIRING_RHS_X_LOC
```

### PAIRING_RHS_Y_LOC

```solidity
uint256 PAIRING_RHS_Y_LOC
```

### GRAND_PRODUCT_SUCCESS_FLAG

```solidity
uint256 GRAND_PRODUCT_SUCCESS_FLAG
```

### ARITHMETIC_TERM_SUCCESS_FLAG

```solidity
uint256 ARITHMETIC_TERM_SUCCESS_FLAG
```

### BATCH_OPENING_SUCCESS_FLAG

```solidity
uint256 BATCH_OPENING_SUCCESS_FLAG
```

### OPENING_COMMITMENT_SUCCESS_FLAG

```solidity
uint256 OPENING_COMMITMENT_SUCCESS_FLAG
```

### PAIRING_PREAMBLE_SUCCESS_FLAG

```solidity
uint256 PAIRING_PREAMBLE_SUCCESS_FLAG
```

### PAIRING_SUCCESS_FLAG

```solidity
uint256 PAIRING_SUCCESS_FLAG
```

### RESULT_FLAG

```solidity
uint256 RESULT_FLAG
```

### OMEGA_INVERSE_LOC

```solidity
uint256 OMEGA_INVERSE_LOC
```

### C_ALPHA_SQR_LOC

```solidity
uint256 C_ALPHA_SQR_LOC
```

### C_ALPHA_CUBE_LOC

```solidity
uint256 C_ALPHA_CUBE_LOC
```

### C_ALPHA_QUAD_LOC

```solidity
uint256 C_ALPHA_QUAD_LOC
```

### C_ALPHA_BASE_LOC

```solidity
uint256 C_ALPHA_BASE_LOC
```

### RECURSIVE_P1_X_LOC

```solidity
uint256 RECURSIVE_P1_X_LOC
```

### RECURSIVE_P1_Y_LOC

```solidity
uint256 RECURSIVE_P1_Y_LOC
```

### RECURSIVE_P2_X_LOC

```solidity
uint256 RECURSIVE_P2_X_LOC
```

### RECURSIVE_P2_Y_LOC

```solidity
uint256 RECURSIVE_P2_Y_LOC
```

### PUBLIC_INPUTS_HASH_LOCATION

```solidity
uint256 PUBLIC_INPUTS_HASH_LOCATION
```

### PERMUTATION_IDENTITY

```solidity
uint256 PERMUTATION_IDENTITY
```

### PLOOKUP_IDENTITY

```solidity
uint256 PLOOKUP_IDENTITY
```

### ARITHMETIC_IDENTITY

```solidity
uint256 ARITHMETIC_IDENTITY
```

### SORT_IDENTITY

```solidity
uint256 SORT_IDENTITY
```

### ELLIPTIC_IDENTITY

```solidity
uint256 ELLIPTIC_IDENTITY
```

### AUX_IDENTITY

```solidity
uint256 AUX_IDENTITY
```

### AUX_NON_NATIVE_FIELD_EVALUATION

```solidity
uint256 AUX_NON_NATIVE_FIELD_EVALUATION
```

### AUX_LIMB_ACCUMULATOR_EVALUATION

```solidity
uint256 AUX_LIMB_ACCUMULATOR_EVALUATION
```

### AUX_RAM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_RAM_CONSISTENCY_EVALUATION
```

### AUX_ROM_CONSISTENCY_EVALUATION

```solidity
uint256 AUX_ROM_CONSISTENCY_EVALUATION
```

### AUX_MEMORY_EVALUATION

```solidity
uint256 AUX_MEMORY_EVALUATION
```

### QUOTIENT_EVAL_LOC

```solidity
uint256 QUOTIENT_EVAL_LOC
```

### ZERO_POLY_INVERSE_LOC

```solidity
uint256 ZERO_POLY_INVERSE_LOC
```

### NU_CHALLENGE_INPUT_LOC_A

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_A
```

### NU_CHALLENGE_INPUT_LOC_B

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_B
```

### NU_CHALLENGE_INPUT_LOC_C

```solidity
uint256 NU_CHALLENGE_INPUT_LOC_C
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
```

### PUBLIC_INPUT_GE_P_SELECTOR

```solidity
bytes4 PUBLIC_INPUT_GE_P_SELECTOR
```

### MOD_EXP_FAILURE_SELECTOR

```solidity
bytes4 MOD_EXP_FAILURE_SELECTOR
```

### EC_SCALAR_MUL_FAILURE_SELECTOR

```solidity
bytes4 EC_SCALAR_MUL_FAILURE_SELECTOR
```

### PROOF_FAILURE_SELECTOR

```solidity
bytes4 PROOF_FAILURE_SELECTOR
```

### ETA_INPUT_LENGTH

```solidity
uint256 ETA_INPUT_LENGTH
```

### NU_INPUT_LENGTH

```solidity
uint256 NU_INPUT_LENGTH
```

### NU_CALLDATA_SKIP_LENGTH

```solidity
uint256 NU_CALLDATA_SKIP_LENGTH
```

### NEGATIVE_INVERSE_OF_2_MODULO_P

```solidity
uint256 NEGATIVE_INVERSE_OF_2_MODULO_P
```

### LIMB_SIZE

```solidity
uint256 LIMB_SIZE
```

### SUBLIMB_SHIFT

```solidity
uint256 SUBLIMB_SHIFT
```

### GRUMPKIN_CURVE_B_PARAMETER_NEGATED

```solidity
uint256 GRUMPKIN_CURVE_B_PARAMETER_NEGATED
```

### PUBLIC_INPUT_COUNT_INVALID

```solidity
error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual)
```

### PUBLIC_INPUT_INVALID_BN128_G1_POINT

```solidity
error PUBLIC_INPUT_INVALID_BN128_G1_POINT()
```

### PUBLIC_INPUT_GE_P

```solidity
error PUBLIC_INPUT_GE_P()
```

### MOD_EXP_FAILURE

```solidity
error MOD_EXP_FAILURE()
```

### EC_SCALAR_MUL_FAILURE

```solidity
error EC_SCALAR_MUL_FAILURE()
```

### PROOF_FAILURE

```solidity
error PROOF_FAILURE()
```

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure virtual returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 _vk, uint256 _omegaInverseLoc) internal pure virtual
```

### verify

```solidity
function verify(bytes _proof, bytes32[] _publicInputs) external view returns (bool)
```

Verify a Ultra Plonk proof

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _proof | bytes | - The serialized proof |
| _publicInputs | bytes32[] | - An array of the public inputs |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if proof is valid, reverts otherwise |

## UltraVerifier

### getVerificationKeyHash

```solidity
function getVerificationKeyHash() public pure returns (bytes32)
```

### loadVerificationKey

```solidity
function loadVerificationKey(uint256 vk, uint256 _omegaInverseLoc) internal pure virtual
```

## FunToken

### initialSupply

```solidity
uint256 initialSupply
```

### constructor

```solidity
constructor() public
```

