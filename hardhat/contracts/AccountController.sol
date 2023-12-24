// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {UltraVerifier as AddEthSignerVerifier} from "./add_eth_signers/plonk_vk.sol";

/// @title A simulator for trees
/// @author critesjosh
/// @notice Use this contract with PrivateToken.sol to use the non-default private/public key pairs

contract AccountController {
    /// @notice Mapping of packed public key to eth controller address
    mapping(bytes32 packedPublicKey => address ethController)
        public ethController;

    /// @notice Mapping of packed public key to nonce to prevent replay attacks when changing eth signers
    mapping(bytes32 packedPublicKey => uint256 otherNonce) public otherNonce;

    /// @notice The prime field that the circuit is constructed over. This is used to make message hashes fit in 1 field element
    uint256 BJJ_PRIME =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    /// @notice change functions can be used to revoke, just set to address(0)
    AddEthSignerVerifier public addEthSignerVerifier;

    event AddController(bytes32 packedPublicKey, address controllerAddress);

    event ChangeEthController(
        bytes32 packedPublicKey,
        address oldEthAddress,
        address newEthAddress
    );

    constructor(address _addEthSignerVerifier) {
        addEthSignerVerifier = AddEthSignerVerifier(_addEthSignerVerifier);
    }

    /// @notice This function allows a Private Token account to assign an eth account controller.
    /// The address associated with the packed public key must be 0x0.
    /// @param _packedPublicKey The packed public key of the account to update
    /// @param _ethAddress The eth address of the signer or the 4337 account
    /// @param _proof The proof that the caller has the private key corresponding to the packed public key
    /// @dev See the add_eth_signers circuit for circuit details
    function addEthController(
        bytes32 _packedPublicKey,
        address _ethAddress,
        bytes memory _proof
    ) public {
        require(
            ethController[_packedPublicKey] == address(0x0),
            "eth controller already exists"
        );

        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = bytes32(uint256(_packedPublicKey) % BJJ_PRIME);
        // The nonce ensures the proof cannot be reused in replay attackes
        publicInputs[1] = bytes32(otherNonce[_packedPublicKey]);

        // The proof checks that the caller has the private key corresponding to the public key
        addEthSignerVerifier.verify(_proof, publicInputs);

        otherNonce[_packedPublicKey] += 1;
        ethController[_packedPublicKey] = _ethAddress;
        emit AddController(_packedPublicKey, _ethAddress);
    }

    /// @notice This function updates the eth controller. It must be called by the current 4337 controller.
    /// @dev There is no proof validation required because the caller must be the current controller.
    /// @param _packedPublicKey The packed public key of the account to update
    /// @param _newAddress The new eth controller address. Can be address(0) to revoke.
    function changeEthController(
        bytes32 _packedPublicKey,
        address _newAddress
    ) public {
        require(msg.sender == ethController[_packedPublicKey]);
        ethController[_packedPublicKey] = _newAddress;
        emit ChangeEthController(
            _packedPublicKey,
            msg.sender,
            ethController[_packedPublicKey]
        );
    }
}
