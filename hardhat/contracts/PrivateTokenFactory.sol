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
    address public addEthSignerVerifier;
    address public changeEthSignerVerifier;
    address public changeMultisigEthSignerVerifier;

    event Deployed(address indexed token);

    constructor(
        address _pendingDepositVerifier,
        address _pendingTransferVerifier,
        address _transferVerifier,
        // address _transfer4337Verifier,
        // address _transferEthSignerVerifier,
        // address _transferMultisigVerifier,
        address _withdrawVerifier,
        // address _withdraw4337Verifier,
        // address _withdrawEthSignerVerifier,
        // address _withdrawMultisigVerifier,
        address _lockVerifier,
        address _addEthSignerVerifier,
        address _changeEthSignerVerfier,
        address _changeMultisigEthSignerVerifier
    ) {
        processDepositVerifier = _pendingDepositVerifier;
        processTransferVerifier = _pendingTransferVerifier;
        transferVerifier = _transferVerifier;
        // transfer4337Verifier = _transfer4337Verifier;
        // transferEthSignerVerifier = _transferEthSignerVerifier;
        // transferMultisigVerifier = _transferMultisigVerifier;
        withdrawVerifier = _withdrawVerifier;
        // withdraw4337Verifier = _withdraw4337Verifier;
        // withdrawEthSignerVerifier = _withdrawEthSignerVerifier;
        // withdrawMultisigVerifier = _withdrawMultisigVerifier;
        lockVerifier = _lockVerifier;
        addEthSignerVerifier = _addEthSignerVerifier;
        changeEthSignerVerifier = _changeEthSignerVerfier;
        changeMultisigEthSignerVerifier = _changeMultisigEthSignerVerifier;
    }

    function deploy(address _token) public {
        PrivateToken newToken = new PrivateToken(
            processDepositVerifier,
            processTransferVerifier,
            transferVerifier,
            // transfer4337Verifier,
            // transferEthSignerVerifier,
            // transferMultisigVerifier,
            withdrawVerifier,
            // withdraw4337Verifier,
            // withdrawEthSignerVerifier,
            // withdrawMultisigVerifier,
            lockVerifier,
            _token,
            18,
            addEthSignerVerifier,
            changeEthSignerVerifier,
            changeMultisigEthSignerVerifier
        );
        emit Deployed(address(newToken));
        // newToken.initOtherVerifiers(
        //     transfer4337Verifier,
        //     transferEthSignerVerifier,
        //     transferMultisigVerifier,
        //     withdraw4337Verifier,
        //     withdrawEthSignerVerifier,
        //     withdrawMultisigVerifier
        // );
        // return address(newToken);
    }
}
