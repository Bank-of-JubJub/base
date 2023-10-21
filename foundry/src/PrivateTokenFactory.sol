// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {PrivateToken} from "./PrivateToken.sol";
import {UltraVerifier as ProcessDepositVerifier} from "./process_pending_deposits/plonk_vk.sol";
import {UltraVerifier as ProcessTransferVerifier} from "./process_pending_transfers/plonk_vk.sol";
import {UltraVerifier as TransferVerifier} from "./transfer/plonk_vk.sol";
import {UltraVerifier as WithdrawVerifier} from "./withdraw/plonk_vk.sol";
import {UltraVerifier as LockVerifier} from "./lock/plonk_vk.sol";

import {IERC20} from "./IERC20.sol";

contract PrivateTokenFactory {
    PrivateToken constant privateToken;
    ProcessDepositVerifier constant processDepositVerifier;
    ProcessTransferVerifier constant processTransferVerifier;
    TransferVerifier constant transferVerifier;
    WithdrawVerifier constant withdrawVerifier;
    LockVerifier constant lockVerifier;

    event Deployed(address indexed token, address indexed owner);

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
            processDepositVerifier,
            processTransferVerifier,
            transferVerifier,
            withdrawVerifier,
            lockVerifier,
            _token
        );
        emit Deployed(address(newToken));
    }
}
