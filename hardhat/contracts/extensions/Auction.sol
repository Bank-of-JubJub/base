// contracts/FunToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../PrivateToken.sol";
import "../TransferVerify.sol";
import "../AccountController.sol";

contract AuctionContract {
    PrivateToken privateToken;
    TransferVerify transferVerify;
    AccountController accountController;

    // the recipient is the account that will receive the funds
    // users may want to verify that the recipient is the correct account (eg controlled by a multisig)
    uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    constructor(address _privateToken, address _transferVerify, address _accountController) {
        privateToken = PrivateToken(_privateToken);
        transferVerify = TransferVerify(_transferVerify);
        accountController = AccountController(_accountController);
    }

    function createAuction() public {}

    function bid() public {}

    // the recipient is the only account that can create a proof that the threshold has been met

    function unlock(bytes32 _account) public {
        require(!hasPendingContribution[_account], "Has pending contribution");
        privateToken.unlock(_account);
    }
}
