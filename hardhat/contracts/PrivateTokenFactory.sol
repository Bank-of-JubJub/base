// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {PrivateToken} from "./PrivateToken.sol";
// import {UltraVerifier as ProcessDepositVerifier} from "./process_pending_deposits/plonk_vk.sol";
// import {UltraVerifier as ProcessTransferVerifier} from "./process_pending_transfers/plonk_vk.sol";
// import {UltraVerifier as TransferVerifier} from "./transfer/plonk_vk.sol";
// import {UltraVerifier as WithdrawVerifier} from "./withdraw/plonk_vk.sol";
// import {UltraVerifier as LockVerifier} from "./lock/plonk_vk.sol";

import {IERC20} from "./IERC20.sol";

contract PrivateTokenFactory {
    address public privateToken;
    address public processDepositVerifier;
    address public processTransferVerifier;
    address public transferVerifier;
    address public transfer4337Verifier;
    address public transferEthSignerVerifier;
    address public transferMultisigVerifier;
    address public withdrawVerifier;
    address public withdraw4337Verifier;
    address public withdrawEthSignerVerifier;
    address public withdrawMultisigVerifier;
    address public lockVerifier;
    address public accountController;
    PrivateToken public newToken;
    event Deployed(address indexed token);

    constructor(
        address _pendingDepositVerifier,
        address _pendingTransferVerifier,
        address _transferVerifier,
        address _withdrawVerifier,
        address _lockVerifier,
        address _accountController
    ) {
        processDepositVerifier = _pendingDepositVerifier;
        processTransferVerifier = _pendingTransferVerifier;
        transferVerifier = _transferVerifier;
        withdrawVerifier = _withdrawVerifier;
        lockVerifier = _lockVerifier;
        accountController = _accountController;
    }

    function deploy(address _token) public {
        newToken = new PrivateToken(
            processDepositVerifier,
            processTransferVerifier,
            transferVerifier,
            withdrawVerifier,
            lockVerifier,
            _token,
            18,
            accountController
        );
        emit Deployed(address(newToken));
        //return address(newToken);
    }
}
