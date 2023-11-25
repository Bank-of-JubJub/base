// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// import {UltraVerifier as } from "./withdraw/plonk_vk.sol";

contract UsingEthSigners {
    struct MultisigParams {
        address[] ethSigners;
        uint256 threshold;
    }

    mapping(bytes32 packedPublicKey => address ethSigner) public ethSigner;
    mapping(bytes32 packedPublicKey => MultisigParams signers)
        public multisigEthSigners;
    mapping(bytes32 packedPublicKey => uint256 ethSignerNonce)
        public ethSignerNonce;
    uint256 BJJ_PRIME =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Verifiers
    // change can be used to revoke, just set to address(0)
    address public addEthSignerVerifier;
    address public changeEthSignerVerifier;
    address public addMultisigEthSignerVerifier;
    address public changeMultisigEthSignerVerifier;

    constructor(
        address _addEthSignerVerifier,
        address _changeEthSignerVerfier,
        address _changeMultisigEthSignerVerifier
    ) {
        addEthSignerVerifier = _addEthSignerVerifier;
        changeEthSignerVerifier = _changeEthSignerVerfier;
        changeMultisigEthSignerVerifier = _changeMultisigEthSignerVerifier;
    }

    function addEthSigner(
        bytes32 _packedPublicKey,
        address _ethSignerAddress
    ) public {
        require(
            ethSigner[_packedPublicKey] == address(0x0),
            "eth signer already exists"
        );

        bytes32[] memory publicInputs = new bytes32[](32);
        for (uint8 i = 0; i < 32; i++) {
            // Noir takes an array of 32 bytes32 as public inputs
            bytes1 aByte = bytes1((_packedPublicKey << (i * 8)));
            publicInputs[i] = bytes32(uint256(uint8(aByte)));
        }
        // The nonce ensures the proof cannot be reused
        publicInputs[32] = bytes32(ethSignerNonce[_packedPublicKey]);

        // The proof checks that the caller has the private key corresponding to the public key
        // addEthSignerVerifier.verify(proof, publicInputs);

        ethSignerNonce[_packedPublicKey] += 1;
        ethSigner[_packedPublicKey] = _ethSignerAddress;
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

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                address(this),
                _packedPublicKey,
                _newEthSignerAddress,
                ethSignerNonce[_packedPublicKey]
            )
        );

        bytes32[] memory publicInputs = new bytes32[](32);
        // recover this address in the circuit
        publicInputs[0] = bytes32(uint256(uint160(signer)));
        // recover address with signature over this message hash
        // it should be unique and not reusable
        for (uint8 i = 0; i < 32; i++) {
            // Noir takes an array of 32 bytes32 as public inputs
            bytes1 aByte = bytes1((messageHash << (i * 8)));
            publicInputs[i] = bytes32(uint256(uint8(aByte)));
        }

        // the circuit must check that the caller has the private key corresponding to the public key
        // and that the signature is a valid signature of the messageHash and comes from the current
        // changeEthSignerVerifier.verify(_proof, publicInputs);
        ethSignerNonce[_packedPublicKey] += 1;
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
        bytes32[] memory publicInputs = new bytes32[](32);
        // private key corresponding to the packed public key controls the account until registered
        for (uint8 i = 0; i < 32; i++) {
            // Noir takes an array of 32 bytes32 as public inputs
            bytes1 aByte = bytes1((_packedPublicKey << (i * 8)));
            publicInputs[i] = bytes32(uint256(uint8(aByte)));
        }
        // this should be unique and not reusable
        publicInputs[32] = bytes32(ethSignerNonce[_packedPublicKey]);

        // the circuit must check that the caller has the private key corresponding to the public key
        // can use the same circuit as single addEthSigner
        // addEthSignerVerifier.verify(proof, publicInputs);
        ethSignerNonce[_packedPublicKey] += 1;
        multisigEthSigners[_packedPublicKey].ethSigners = _ethSignerAddresses;
    }

    function changeMultisigEthSigners(
        bytes memory _proof,
        bytes32 _packedPublicKey,
        address[] memory _newEthSignerAddresses,
        uint256 _threshold
    ) public {
        require(
            multisigEthSigners[_packedPublicKey].ethSigners.length > 0,
            "eth signer must exist"
        );

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                address(this),
                _packedPublicKey,
                _newEthSignerAddresses,
                _threshold,
                ethSignerNonce[_packedPublicKey]
            )
        );
        // public inputs
        bytes32[] memory publicInputs = new bytes32[](42);
        // hardcoded max of 10 signers, this can be increased
        for (uint8 i; i <= 10; i++) {
            publicInputs[i] = bytes32(
                uint256(
                    uint160(multisigEthSigners[_packedPublicKey].ethSigners[i])
                )
            );
        }
        for (uint8 i = 0; i < 32; i++) {
            // Noir takes an array of 32 bytes32 as public inputs
            bytes1 aByte = bytes1((messageHash << (i * 8)));
            publicInputs[i + 10] = bytes32(uint256(uint8(aByte)));
        }

        // the circuit must check that signatures (private inputs) are valid signatures of the messageHash
        // and come from the current list of signers and meet the signer threshold
        // changeMultisigEthSignerVerifier.verify(proof, publicInputs);

        ethSignerNonce[_packedPublicKey] += 1;
        multisigEthSigners[_packedPublicKey]
            .ethSigners = _newEthSignerAddresses;
    }
}
