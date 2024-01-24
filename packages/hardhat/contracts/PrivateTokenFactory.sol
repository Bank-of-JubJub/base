// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.20;

// import {PrivateToken} from "./PrivateToken.sol";
// import {IERC20} from "./IERC20.sol";

// contract PrivateTokenFactory {
//     address public processDepositVerifier;
//     address public processTransferVerifier;
//     address public transferVerifier;
//     address public withdrawVerifier;
//     address public lockVerifier;
//     address public accountController;
//     address public transferVerifyLib;

//     event Deployed(address indexed token);

//     // TODO: update to use the the all transfer and all withdraw verifiers
//     constructor(
//         address _pendingDepositVerifier,
//         address _pendingTransferVerifier,
//         address _transferVerifier,
//         address _withdrawVerifier,
//         address _lockVerifier,
//         address _accountController,
//         address _transferVerifyLib
//     ) {
//         processDepositVerifier = _pendingDepositVerifier;
//         processTransferVerifier = _pendingTransferVerifier;
//         transferVerifier = _transferVerifier;
//         withdrawVerifier = _withdrawVerifier;
//         lockVerifier = _lockVerifier;
//         accountController = _accountController;
//         transferVerifyLib = _transferVerifyLib;
//     }

//     function deploy(address _token) public {
//         PrivateToken newToken = new PrivateToken(
//             processDepositVerifier,
//             processTransferVerifier,
//             transferVerifier,
//             withdrawVerifier,
//             lockVerifier,
//             _token,
//             18
//         );
//         emit Deployed(address(newToken));
//     }
// }
