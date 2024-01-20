// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {UltraVerifier as AddEthSignerVerifier} from "./add_eth_signers/plonk_vk.sol";
import "./PrivateToken.sol";

/// @title A simulator for trees
/// @author critesjosh
/// @notice Use this contract with PrivateToken.sol to use the non-default private/public key pairs

contract AccountController {
    // this is the default controller and should be an EOA or contract account
    mapping(bytes32 packedPublicKey => address ethController) public ethController;

    /// @notice Mapping of packed public key to eth controller address
    // extension contracts that need to control the account should register here
    mapping(bytes32 packedPublicKey => mapping(address ethController => bool isController)) public extensionControllers;

    /// @notice Mapping of packed public key to nonce to prevent replay attacks when changing eth signers
    mapping(bytes32 packedPublicKey => uint256 nonce) public nonce;

    /// @notice The prime field that the circuit is constructed over. This is used to make message hashes fit in 1 field element
    uint256 BJJ_PRIME = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    /// @notice change functions can be used to revoke, just set to address(0)
    AddEthSignerVerifier public addEthSignerVerifier;
    PrivateToken public privateToken;

    event AddController(bytes32 packedPublicKey, address controllerAddress);
    event RevokeController(bytes32 packedPublicKey, address controllerAddress);

    constructor(address _addEthSignerVerifier, address _privateToken) {
        addEthSignerVerifier = AddEthSignerVerifier(_addEthSignerVerifier);
        privateToken = PrivateToken(_privateToken);
    }

    /// @notice This function allows a Private Token account to assign a first eth account controller.
    /// The address associated with the packed public key must be 0x0.
    /// @param _packedPublicKey The packed public key of the account to update
    /// @param _ethAddress The eth address of the signer or the 4337 account
    /// @param _proof The proof that the caller has the private key corresponding to the packed public key
    /// @dev See the add_eth_signers circuit for circuit details
    function addEthController(bytes32 _packedPublicKey, address _ethAddress, bool isExtension, bytes memory _proof)
        public
    {
        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = bytes32(uint256(_packedPublicKey) % BJJ_PRIME);
        // The nonce ensures the proof cannot be reused in replay attackes
        publicInputs[1] = bytes32(nonce[_packedPublicKey]);

        // The proof checks that the caller has the private key corresponding to the public key
        addEthSignerVerifier.verify(_proof, publicInputs);

        nonce[_packedPublicKey] += 1;
        //
        if (isExtension) {
            extensionControllers[_packedPublicKey][_ethAddress] = true;
        } else {
            ethController[_packedPublicKey] = _ethAddress;
        }
        emit AddController(_packedPublicKey, _ethAddress);
    }

    /// @notice This function allows an account to add additional eth controllers.
    /// Can revoke the default controller by setting it to address(0).
    /// @dev There is no proof validation required because the caller must be the current controller.
    /// @param _packedPublicKey The packed public key of the account to update
    /// @param _newAddress The new eth controller address.
    /// @param _proof The proof that the caller has the private key corresponding to the packed public key
    function updateEthControllers(bytes32 _packedPublicKey, bool _isExtension, address _newAddress, bytes memory _proof)
        public
    {
        if (ethController[_packedPublicKey] == address(0)) {
            addEthController(_packedPublicKey, _newAddress, _isExtension, _proof);
        } else {
            require(ethController[_packedPublicKey] == msg.sender);
            extensionControllers[_packedPublicKey][_newAddress] = true;
            emit AddController(_packedPublicKey, _newAddress);
        }
    }

    // allow a proof to be passed if the only controller is an extension contract (Account should still be controlled by the private key)
    function revokeEthController(bytes32 _packedPublicKey, address _removeAddress, bytes memory _proof) public {
        if (ethController[_packedPublicKey] == address(0)) {
            // addEthController(_packedPublicKey, _newAddress, _proof);
            bytes32[] memory publicInputs = new bytes32[](2);
            publicInputs[0] = bytes32(uint256(_packedPublicKey) % BJJ_PRIME);
            // The nonce ensures the proof cannot be reused in replay attackes
            publicInputs[1] = bytes32(nonce[_packedPublicKey]);
            // The proof checks that the caller has the private key corresponding to the public key
            addEthSignerVerifier.verify(_proof, publicInputs);
            nonce[_packedPublicKey] += 1;
        }
        require(privateToken.lockedTo(_packedPublicKey) != _removeAddress, "Cannot remove controller while locked");
        extensionControllers[_packedPublicKey][_removeAddress] = false;
        emit RevokeController(_packedPublicKey, _removeAddress);
    }
}
