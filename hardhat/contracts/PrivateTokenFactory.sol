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
    address public withdrawVerifier;
    address public lockVerifier;

    event Deployed(address indexed token);

    constructor(
        address _pendingDepositVerifier,
        address _pendingTransferVerifier,
        address _transferVerifier,
        address _withdrawVerifier,
        address _lockVerifier
    ) {
        processDepositVerifier = _pendingDepositVerifier;
        processTransferVerifier = _pendingTransferVerifier;
        transferVerifier = _transferVerifier;
        withdrawVerifier = _withdrawVerifier;
        lockVerifier = _lockVerifier;
    }

    function deploy(address _token) public {
        PrivateToken newToken = new PrivateToken(
            address(processDepositVerifier),
            processTransferVerifier,
            transferVerifier,
            withdrawVerifier,
            lockVerifier,
            address(0x0),
            _token,
            18
        );
        emit Deployed(address(newToken));
    }
}
