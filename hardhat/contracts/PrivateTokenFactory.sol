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
    address public addEthSignerVerifier;
    address public changeEthSignerVerifier;
    address public changeMultisigEthSignerVerifier;

    event Deployed(address indexed token);

    constructor(
        address _pendingDepositVerifier,
        address _pendingTransferVerifier,
        address _transferVerifier,
        address _withdrawVerifier,
        address _lockVerifier,
        address _addEthSignerVerifier,
        address _changeEthSignerVerfier,
        address _changeMultisigEthSignerVerifier
    ) {
        processDepositVerifier = _pendingDepositVerifier;
        processTransferVerifier = _pendingTransferVerifier;
        transferVerifier = _transferVerifier;
        withdrawVerifier = _withdrawVerifier;
        lockVerifier = _lockVerifier;
        addEthSignerVerifier = _addEthSignerVerifier;
        changeEthSignerVerifier = _changeEthSignerVerfier;
        changeMultisigEthSignerVerifier = _changeMultisigEthSignerVerifier;
    }

    function deploy(address _token) public returns (address) {
        PrivateToken newToken = new PrivateToken(
            address(processDepositVerifier),
            processTransferVerifier,
            transferVerifier,
            withdrawVerifier,
            lockVerifier,
            _token,
            18,
            addEthSignerVerifier,
            changeEthSignerVerifier,
            changeMultisigEthSignerVerifier
        );
        emit Deployed(address(newToken));
        return address(newToken);
    }
}
