// contracts/FunToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// consider using something like this: https://github.com/attestate/indexed-sparse-merkle-tree/tree/main
// but update to use poseidon hash function

// The private token contract will read the blacklistRoot from this contract
// updating the blacklist root will be a protected function, requiring
// multiple managers to sign off on an update and a new root

contract BlacklistManager {
    // updates must be signed off by multiple managers
    mapping(address => bool) public isManager;

    uint256 public blacklistRoot;

    constructor() {}
}
