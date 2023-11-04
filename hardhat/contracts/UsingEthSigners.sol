// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// import {UltraVerifier as } from "./withdraw/plonk_vk.sol";
// import {UltraVerifier as LockVerifier} from "./lock/plonk_vk.sol";

contract UsingEthSingers {
    struct MultisigParams {
        address[] ethSigners;
        uint256 threshold;
    }

    mapping(bytes32 packedPublicKey => address ethSigner) public ethSigner;
    mapping(bytes32 packedPublicKey => MultisigParams signers)
        public multisigEthSigners;
    mapping(bytes32 packedPublicKey => uint256 nonce) public nonce;

    // Verifiers
    address public addEthSignerVerifier;
    address public revokeEthSignerVerifier;
    address public changeEthSignerVerifier;
    address public addMultisigEthSignerVerifier;
    address public revokeMultisigEthSignerVerifier;
    address public changeMultisigEthSignerVerifier;

    constructor(
        address _addEthSignerVerifier,
        address _revokeEthSignerVerifier,
        address _changeEthSignerVerfier,
        address _addMultisigEthSignerVerifier,
        address _revokeMultisigEthSignerVerifier,
        address _changeMultisigEthSignerVerifier
    ) {
        addEthSignerVerifier = _addEthSignerVerifier;
        revokeEthSignerVerifier = _revokeEthSignerVerifier;
        changeEthSignerVerifier = _changeEthSignerVerfier;
        addMultisigEthSignerVerifier = _addMultisigEthSignerVerifier;
        revokeMultisigEthSignerVerifier = _revokeMultisigEthSignerVerifier;
        changeMultisigEthSignerVerifier = _changeMultisigEthSignerVerifier;
    }

    function addEthSigner(
        bytes32 packedPublicKey,
        address ethSignerAddress
    ) public {
        require(
            ethSigner[packedPublicKey] == address(0x0),
            "eth signer already exists"
        );
        // public inputs
        // packed public key
        // eth signer address
        // nonce

        // The proof checks that the caller has the private key corresponding to the public key
        // addEthSignerVerifier.verify(proof, publicInputs);

        nonce[packedPublicKey] += 1;
        ethSigner[packedPublicKey] = ethSignerAddress;
    }

    function revokeEthSigner(
        bytes memory _proof,
        bytes32 packedPublicKey
    ) public {
        require(
            ethSigner[packedPublicKey] != address(0x0),
            "eth signer does not exist"
        );
        address signer = ethSigner[packedPublicKey];
        // public input
        // signer address
        // messageHash. the signed message should include the contract address, the packed public key and the nonce
        bytes32 messageHash = getMessageHash(
            packedPublicKey,
            nonce[packedPublicKey]
        );
        // the circuit must check that signature (private inputs) is a valid signature of the messageHash
        // and comes from the signer
        // revokeEthSignerVerifier.verify(proof, publicInputs);
        nonce[packedPublicKey] += 1;
        delete ethSigner[packedPublicKey];
    }

    function changeEthSigner(
        bytes memory _proof,
        bytes32 _packedPublicKey,
        address _newEthSignerAddress
    ) public {
        require(
            ethSigner[_packedPublicKey] == address(0x0),
            "eth signer must not exist"
        );
        address signer = ethSigner[_packedPublicKey];

        // public inputs
        // signer address
        bytes32 messageHash = getMessageHash(
            _packedPublicKey,
            nonce[_packedPublicKey]
        );

        // the circuit must check that the caller has the private key corresponding to the public key
        // and that the signature is a valid signature of the messageHash and comes from the current
        // changeEthSignerVerifier.verify(proof, publicInputs);
        nonce[_packedPublicKey] += 1;
        ethSigner[_packedPublicKey] = _newEthSignerAddress;
    }

    function addMultisigEthSigners(
        bytes memory _proof,
        bytes32 _packedPublicKey,
        address[] memory _ethSignerAddresses,
        uint256 _threshold
    ) public {
        require(
            ethSigner[_packedPublicKey] == address(0x0),
            "eth signer must not exist"
        );
        require(
            multisigEthSigners[_packedPublicKey].ethSigners.length == 0,
            "multisig eth signer must not exist"
        );

        multisigEthSigners[_packedPublicKey] = MultisigParams(
            _ethSignerAddresses,
            _threshold
        );

        // public inputs
        // packed public key
        // eth signer addresses array
        // nonce
        // the circuit must check that the caller has the private key corresponding to the public key
        // addMultisigEthSignerVerifier.verify(proof, publicInputs);
        nonce[_packedPublicKey] += 1;
        multisigEthSigners[_packedPublicKey].ethSigners = _ethSignerAddresses;
    }

    function revokeMultisigEthSigners(
        bytes memory _proof,
        bytes32 _packedPublicKey,
        address[] memory _ethSignerAddresses
    ) public {
        require(
            multisigEthSigners[_packedPublicKey].ethSigners.length > 0,
            "eth signer must exist"
        );
        // public inputs
        // _ethSignerAddresses
        // signer threshold
        bytes32 messageHash = getMessageHash(
            _packedPublicKey,
            nonce[_packedPublicKey]
        );

        // the circuit must check that signatures (private inputs) are valid signature of the messageHash
        // and comes from the signers and meets the signer threshold
        // revokeMultisigEthSignerVerifier.verify(proof, publicInputs);
        nonce[_packedPublicKey] += 1;
        delete multisigEthSigners[_packedPublicKey];
    }

    function changeMultisigEthSigners(
        bytes memory _proof,
        bytes32 _packedPublicKey,
        address[] memory _newEthSignerAddresses
    ) public {
        require(
            multisigEthSigners[_packedPublicKey].ethSigners.length > 0,
            "eth signer must exist"
        );
        // public inputs
        // _newEthSignerAddresses
        // signer threshold
        bytes32 messageHash = getMessageHash(
            _packedPublicKey,
            nonce[_packedPublicKey]
        );

        // the circuit must check that signatures (private inputs) are valid signatures of the messageHash
        // and come from the current list of signers and meet the signer threshold
        // changeMultisigEthSignerVerifier.verify(proof, publicInputs);

        nonce[_packedPublicKey] += 1;
        multisigEthSigners[_packedPublicKey]
            .ethSigners = _newEthSignerAddresses;
    }

    function getMessageHash(
        bytes32 _packedPublicKey,
        uint256 _nonce
    ) internal returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(address(this), _packedPublicKey, _nonce)
            );
    }
}
