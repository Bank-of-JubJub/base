// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "./verifiers/withdraw_from_subset_verifier.sol";
import "./MerkleTree.sol";

contract PrivacyPool is
    ReentrancyGuard,
    MerkleTree
    // WithdrawFromSubsetVerifier
{
    using SafeERC20 for IERC20;

    event Deposit(
        uint indexed commitment,
        uint amount,
        uint leafIndex,
        uint timestamp
    );
    event Withdrawal(
        address recipient,
        address indexed relayer,
        uint indexed subsetRoot,
        uint nullifier,
        uint fee
    );

    error FeeExceedsAmount();
    error InvalidZKProof();
    error MsgValueInvalid();
    error NoteAlreadySpent();
    error UnknownRoot();
    mapping(uint => bool) public nullifiers;
    address public token;

    constructor(
        address _token,
        address poseidon
    ) MerkleTree(poseidon, snarkHash(bytes("ALLOWED"))) {
        token = _token;
    }

    // commitment: poseidon(secret1, secret2, amount)
    function deposit(
        uint commitment,
        uint amount
    ) public payable nonReentrant returns (uint) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint assetMetadata = snarkHash(abi.encode(token, amount));
        uint leaf = hasher.poseidon([commitment, assetMetadata]);
        uint leafIndex = insert(leaf);
        emit Deposit(commitment, amount, leafIndex, block.timestamp);
        return leafIndex;
    }

    function withdraw(
        bytes memory proof,
        uint root,
        uint subsetRoot,
        uint nullifier,
        uint amount,
        address recipient,
        uint refund,
        address relayer,
        uint fee
    ) public payable nonReentrant returns (bool) {
        if (nullifiers[nullifier]) revert NoteAlreadySpent();
        if (!isKnownRoot(root)) revert UnknownRoot();
        if (fee > amount) revert FeeExceedsAmount();
        uint assetMetadata = snarkHash(abi.encode(token, amount));
        uint withdrawMetadata = snarkHash(
            abi.encode(recipient, refund, relayer, fee)
        );
        if (
            !_verifyWithdrawFromSubsetProof(
                flatProof,
                root,
                subsetRoot,
                nullifier,
                assetMetadata,
                withdrawMetadata
            )
            // false // TODO: update
        ) revert InvalidZKProof();
        nullifiers[nullifier] = true;

        if (refund > 0) {
            payable(recipient).transfer(refund);
        }

        if (msg.value != refund) revert MsgValueInvalid();

        if (fee > 0) {
            IERC20(token).safeTransfer(recipient, amount - fee);
            IERC20(token).safeTransfer(relayer, fee);
        } else {
            IERC20(token).safeTransfer(recipient, amount);
        }

        return true;
    }

    function snarkHash(bytes memory data) internal pure returns (uint) {
        return
            uint256(keccak256(data)) %
            21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }
}
