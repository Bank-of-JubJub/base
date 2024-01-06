// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "./verifiers/withdraw_from_subset_verifier.sol";
import "./MerkleTree.sol";

contract PrivacyPool is ReentrancyGuard, MerkleTree {
    // WithdrawFromSubsetVerifier

    using SafeERC20 for IERC20;

    event Deposit(uint256 indexed commitment, uint256 amount, uint256 leafIndex, uint256 timestamp);
    event Withdrawal(
        address recipient, address indexed relayer, uint256 indexed subsetRoot, uint256 nullifier, uint256 fee
    );

    error FeeExceedsAmount();
    error InvalidZKProof();
    error MsgValueInvalid();
    error NoteAlreadySpent();
    error UnknownRoot();

    mapping(uint256 => bool) public nullifiers;
    address public token;

    constructor(address _token, address poseidon) MerkleTree(poseidon, 0) {
        token = _token;
    }

    // commitment: poseidon(eth_address, amount, timestamp, secret)
    // need amounts because deposit amount is variable, should be an input to the withdraw
    function deposit(uint256 commitment, uint256 amount) public payable nonReentrant returns (uint256) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        // use the following if PrivateToken is modified to handle any token
        // uint assetMetadata = snarkHash(abi.encode(token, amount));
        // uint leaf = hasher.poseidon([commitment, assetMetadata]);
        uint256 leafIndex = insert(commitment);
        emit Deposit(commitment, amount, leafIndex, block.timestamp);
        return leafIndex;
    }

    // nullifier = poseidon(secret, commitment_tree_index)
    function withdraw(
        bytes memory proof,
        uint256 root,
        uint256 subsetRoot,
        uint256 nullifier,
        uint256 amount,
        address recipient,
        uint256 refund,
        address relayer,
        uint256 fee
    ) public payable nonReentrant returns (bool) {
        if (nullifiers[nullifier]) revert NoteAlreadySpent();
        if (!isKnownRoot(root)) revert UnknownRoot();
        if (fee > amount) revert FeeExceedsAmount();
        // uint assetMetadata = snarkHash(abi.encode(token, amount));
        // uint withdrawMetadata = snarkHash(
        //     abi.encode(recipient, refund, relayer, fee)
        // );
        if (
            // !_verifyWithdrawFromSubsetProof(
            //     flatProof,
            //     root,
            //     subsetRoot,
            //     nullifier,
            //     assetMetadata,
            //     withdrawMetadata
            // )
            false // TODO: update
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

    function snarkHash(bytes memory data) internal pure returns (uint256) {
        return uint256(keccak256(data)) % 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }
}
