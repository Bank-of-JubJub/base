// Verification Key Hash: 371031ff284bc8c6a261f866155773c82b569159ad2298be0ee83d8e79f5a140
// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec
pragma solidity >=0.8.4;

library UltraVerificationKey {
    function verificationKeyHash() internal pure returns (bytes32) {
        return
            0x371031ff284bc8c6a261f866155773c82b569159ad2298be0ee83d8e79f5a140;
    }

    function loadVerificationKey(
        uint256 _vk,
        uint256 _omegaInverseLoc
    ) internal pure {
        assembly {
            mstore(
                add(_vk, 0x00),
                0x0000000000000000000000000000000000000000000000000000000000020000
            ) // vk.circuit_size
            mstore(
                add(_vk, 0x20),
                0x000000000000000000000000000000000000000000000000000000000000002b
            ) // vk.num_inputs
            mstore(
                add(_vk, 0x40),
                0x1bf82deba7d74902c3708cc6e70e61f30512eca95655210e276e5858ce8f58e5
            ) // vk.work_root
            mstore(
                add(_vk, 0x60),
                0x30643640b9f82f90e83b698e5ea6179c7c05542e859533b48b9953a2f5360801
            ) // vk.domain_inverse
            mstore(
                add(_vk, 0x80),
                0x29746595064d5d6f3c2328c373c436a60631086038e0e411e9cfc43a244ef92c
            ) // vk.Q1.x
            mstore(
                add(_vk, 0xa0),
                0x14175e1fc74f124ad1745529c427802147ea3970ccf3fa5c3c7c83c60242d132
            ) // vk.Q1.y
            mstore(
                add(_vk, 0xc0),
                0x1dc9b22d20014d27b93899c3ec314a387dae84f70b4ce130d2f3a31402082ea8
            ) // vk.Q2.x
            mstore(
                add(_vk, 0xe0),
                0x2e6343d0217c618eb407f1e5dc42d9947d8f495b38fc446805dbc3dfd3083572
            ) // vk.Q2.y
            mstore(
                add(_vk, 0x100),
                0x1acbf05cdf94709f08b42cce0f7c36cf9483d529b3aef0efa37be50dc77b4137
            ) // vk.Q3.x
            mstore(
                add(_vk, 0x120),
                0x04c5ad4c3a1679eaff68467c5ef4350ea111ed2075316e6029c9a68c174a9699
            ) // vk.Q3.y
            mstore(
                add(_vk, 0x140),
                0x07c651eed16a429de27c1ee5af634d1610b7ec853c2b7586922023d09191284d
            ) // vk.Q4.x
            mstore(
                add(_vk, 0x160),
                0x03484c66c1d4ee85f92e6f119475c50f6cd64a40c3998f4c0925615057ddcfcb
            ) // vk.Q4.y
            mstore(
                add(_vk, 0x180),
                0x1d3cdcaf845a9c8e18368208addbedda8b55636a2889b78f9946dd9e076fbd83
            ) // vk.Q_M.x
            mstore(
                add(_vk, 0x1a0),
                0x14f8e9d5638ec3a1384e76dcfd16d52d9663cb52992e52bc2af71306daf628fd
            ) // vk.Q_M.y
            mstore(
                add(_vk, 0x1c0),
                0x21a62c67d586d22e7adb01910625623aa6afc95bd71889d887b9613ffe6bc10d
            ) // vk.Q_C.x
            mstore(
                add(_vk, 0x1e0),
                0x22041940344a2505c104d22d791f9d22ee63643e08bf671893bf11d1d09824eb
            ) // vk.Q_C.y
            mstore(
                add(_vk, 0x200),
                0x1603b3b9699be66982f6474c0ef2d0efd9ba63f8c4abfd71444ac46b8736129c
            ) // vk.Q_ARITHMETIC.x
            mstore(
                add(_vk, 0x220),
                0x21fb424c78fd868d88653ea91eee7361dfa3df4d6a1f5c4793ff549e6056f38b
            ) // vk.Q_ARITHMETIC.y
            mstore(
                add(_vk, 0x240),
                0x2a774e4de6632be27f10f2865a59f5cf56a0351671a64a00b1997b85ebfc51b8
            ) // vk.QSORT.x
            mstore(
                add(_vk, 0x260),
                0x0829eb6cf9702285fe2abe2b4c14f0bc322aa00d29efb2987717118cb5a12417
            ) // vk.QSORT.y
            mstore(
                add(_vk, 0x280),
                0x28b955aac4c043cbcfde06eee59b44363f96fe0a6fa93b0b36ef07fbe285d4c7
            ) // vk.Q_ELLIPTIC.x
            mstore(
                add(_vk, 0x2a0),
                0x16e1bbb0a7728dcb7696fdf3361b39510c6a4f83cc2159f5fc65ceb2be0599f9
            ) // vk.Q_ELLIPTIC.y
            mstore(
                add(_vk, 0x2c0),
                0x1414af76247139fa9e8fef8b393a3e03227ee3a6fedb1e55f5db82cb2352782a
            ) // vk.Q_AUX.x
            mstore(
                add(_vk, 0x2e0),
                0x2c7895a68d2fab5b2bce4d7703daebf9011e63d675bc6898c7f06087d6d83d99
            ) // vk.Q_AUX.y
            mstore(
                add(_vk, 0x300),
                0x0879c9142039e91206c64656ac7330118de59e4625e8779e7204ab8b0c7a11aa
            ) // vk.SIGMA1.x
            mstore(
                add(_vk, 0x320),
                0x05a0186710e0bb2f267e65e3c6feb86d2075985d910dfc360ee07ebaa34ed896
            ) // vk.SIGMA1.y
            mstore(
                add(_vk, 0x340),
                0x2f830ed1758e00c9bc9d94490d6e357c2e4c91fa78ba647aec24a40c73c28efd
            ) // vk.SIGMA2.x
            mstore(
                add(_vk, 0x360),
                0x0673e8f84d12980e34d19aec604c2e065a074da32e24f0da35aa8dba43fcd251
            ) // vk.SIGMA2.y
            mstore(
                add(_vk, 0x380),
                0x0455bf098878abaeb3a1b9f436b8c00a4f06cce7e39e6eead68e81913691fced
            ) // vk.SIGMA3.x
            mstore(
                add(_vk, 0x3a0),
                0x03df19f60c28505646c439e7785ebf46cf544f5c8f550992dd141044866eaa15
            ) // vk.SIGMA3.y
            mstore(
                add(_vk, 0x3c0),
                0x2307b81a52a0292249c9e3e7621bd1a85ba74da94b240528ed26c2b732ad8818
            ) // vk.SIGMA4.x
            mstore(
                add(_vk, 0x3e0),
                0x177f0bfaabd455d55b04b4d9938e431f6282b8d5de3c126c4f23c87a8f763ef3
            ) // vk.SIGMA4.y
            mstore(
                add(_vk, 0x400),
                0x0153cf448ba93b36fb1a3e334bf985bb0e7f671d7ca657c2510b8b64fc1390ea
            ) // vk.TABLE1.x
            mstore(
                add(_vk, 0x420),
                0x0652d5f62437967a51f7f604f8274bd2d3b946ce89c72e43d52520c3964218ea
            ) // vk.TABLE1.y
            mstore(
                add(_vk, 0x440),
                0x007fc1b76eaddd115bf2b07aa9de92811a55b0e5fd5ff8ae0c9dc2d3dc12cc74
            ) // vk.TABLE2.x
            mstore(
                add(_vk, 0x460),
                0x2b0360fd5e0824f832aef7327db2d2ef03f7ebde15daf8ec220a994226945ae4
            ) // vk.TABLE2.y
            mstore(
                add(_vk, 0x480),
                0x0b7f2f921abdf05965e7e2e61ec35a51ef68d0289e22322f7762acba675c1719
            ) // vk.TABLE3.x
            mstore(
                add(_vk, 0x4a0),
                0x0166014fbfd0b94710674e2dfe3e12c7afaa55282cd731d68a7487d569b92a5f
            ) // vk.TABLE3.y
            mstore(
                add(_vk, 0x4c0),
                0x09ec9b0aca4e9671903e0577f2a4efd36f7a58af0a5102f5a42e1b8061f62421
            ) // vk.TABLE4.x
            mstore(
                add(_vk, 0x4e0),
                0x15affeadf66c8428f4f44d2ebe66e9dc0f04215bef81efbbee166d3f4544feab
            ) // vk.TABLE4.y
            mstore(
                add(_vk, 0x500),
                0x1b21900cebd201c3388aec6606e5d68020df213b333f1417e779178d652dc806
            ) // vk.TABLE_TYPE.x
            mstore(
                add(_vk, 0x520),
                0x10445b4acc1d0342cbc27ee8a06e9fc23ee2ee0a9fed5a82a5fd077e1f63d369
            ) // vk.TABLE_TYPE.y
            mstore(
                add(_vk, 0x540),
                0x27d1c592be40cf981709129598e0c39ca7427549b927e5c2a7f73fd227e190c8
            ) // vk.ID1.x
            mstore(
                add(_vk, 0x560),
                0x166351c9e2885881c8811de5918f4814de2f6a50919bdb9b5e30238049b67e27
            ) // vk.ID1.y
            mstore(
                add(_vk, 0x580),
                0x189ed0a14edcbda6bbe8ad6d39cce6220a0ec71535c0059f3e163829c047efae
            ) // vk.ID2.x
            mstore(
                add(_vk, 0x5a0),
                0x01d0d640c56bc84983b5719c2595f75e559bc59bca817a4fd5a1ace90c4a1d2d
            ) // vk.ID2.y
            mstore(
                add(_vk, 0x5c0),
                0x083a836ed97ba63e23a82b0361a48d9cc329baa3410d13ebe2b0521e8f8e3bef
            ) // vk.ID3.x
            mstore(
                add(_vk, 0x5e0),
                0x0cc0c1731949c84dedcbfeabbfed4a1c10d96cc0443f6df7e92476486d42917d
            ) // vk.ID3.y
            mstore(
                add(_vk, 0x600),
                0x26dda3aa6fca417ebc5aeceeec73866abfced4c3ebf0c871216c32407bfe4309
            ) // vk.ID4.x
            mstore(
                add(_vk, 0x620),
                0x25ba6e2f5918b9f91c2d384c40903b97bc6219f2ba681b2e58fdacef2e45b10a
            ) // vk.ID4.y
            mstore(add(_vk, 0x640), 0x00) // vk.contains_recursive_proof
            mstore(add(_vk, 0x660), 0) // vk.recursive_proof_public_input_indices
            mstore(
                add(_vk, 0x680),
                0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1
            ) // vk.g2_x.X.c1
            mstore(
                add(_vk, 0x6a0),
                0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0
            ) // vk.g2_x.X.c0
            mstore(
                add(_vk, 0x6c0),
                0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4
            ) // vk.g2_x.Y.c1
            mstore(
                add(_vk, 0x6e0),
                0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55
            ) // vk.g2_x.Y.c0
            mstore(
                _omegaInverseLoc,
                0x0b5d56b77fe704e8e92338c0082f37e091126414c830e4c6922d5ac802d842d4
            ) // vk.work_root_inverse
        }
    }
}

/**
 * @title Ultra Plonk proof verification contract
 * @dev Top level Plonk proof verification contract, which allows Plonk proof to be verified
 */

abstract contract BaseUltraVerifier {
    // VERIFICATION KEY MEMORY LOCATIONS
    uint256 internal constant N_LOC = 0x380;
    uint256 internal constant NUM_INPUTS_LOC = 0x3a0;
    uint256 internal constant OMEGA_LOC = 0x3c0;
    uint256 internal constant DOMAIN_INVERSE_LOC = 0x3e0;
    uint256 internal constant Q1_X_LOC = 0x400;
    uint256 internal constant Q1_Y_LOC = 0x420;
    uint256 internal constant Q2_X_LOC = 0x440;
    uint256 internal constant Q2_Y_LOC = 0x460;
    uint256 internal constant Q3_X_LOC = 0x480;
    uint256 internal constant Q3_Y_LOC = 0x4a0;
    uint256 internal constant Q4_X_LOC = 0x4c0;
    uint256 internal constant Q4_Y_LOC = 0x4e0;
    uint256 internal constant QM_X_LOC = 0x500;
    uint256 internal constant QM_Y_LOC = 0x520;
    uint256 internal constant QC_X_LOC = 0x540;
    uint256 internal constant QC_Y_LOC = 0x560;
    uint256 internal constant QARITH_X_LOC = 0x580;
    uint256 internal constant QARITH_Y_LOC = 0x5a0;
    uint256 internal constant QSORT_X_LOC = 0x5c0;
    uint256 internal constant QSORT_Y_LOC = 0x5e0;
    uint256 internal constant QELLIPTIC_X_LOC = 0x600;
    uint256 internal constant QELLIPTIC_Y_LOC = 0x620;
    uint256 internal constant QAUX_X_LOC = 0x640;
    uint256 internal constant QAUX_Y_LOC = 0x660;
    uint256 internal constant SIGMA1_X_LOC = 0x680;
    uint256 internal constant SIGMA1_Y_LOC = 0x6a0;
    uint256 internal constant SIGMA2_X_LOC = 0x6c0;
    uint256 internal constant SIGMA2_Y_LOC = 0x6e0;
    uint256 internal constant SIGMA3_X_LOC = 0x700;
    uint256 internal constant SIGMA3_Y_LOC = 0x720;
    uint256 internal constant SIGMA4_X_LOC = 0x740;
    uint256 internal constant SIGMA4_Y_LOC = 0x760;
    uint256 internal constant TABLE1_X_LOC = 0x780;
    uint256 internal constant TABLE1_Y_LOC = 0x7a0;
    uint256 internal constant TABLE2_X_LOC = 0x7c0;
    uint256 internal constant TABLE2_Y_LOC = 0x7e0;
    uint256 internal constant TABLE3_X_LOC = 0x800;
    uint256 internal constant TABLE3_Y_LOC = 0x820;
    uint256 internal constant TABLE4_X_LOC = 0x840;
    uint256 internal constant TABLE4_Y_LOC = 0x860;
    uint256 internal constant TABLE_TYPE_X_LOC = 0x880;
    uint256 internal constant TABLE_TYPE_Y_LOC = 0x8a0;
    uint256 internal constant ID1_X_LOC = 0x8c0;
    uint256 internal constant ID1_Y_LOC = 0x8e0;
    uint256 internal constant ID2_X_LOC = 0x900;
    uint256 internal constant ID2_Y_LOC = 0x920;
    uint256 internal constant ID3_X_LOC = 0x940;
    uint256 internal constant ID3_Y_LOC = 0x960;
    uint256 internal constant ID4_X_LOC = 0x980;
    uint256 internal constant ID4_Y_LOC = 0x9a0;
    uint256 internal constant CONTAINS_RECURSIVE_PROOF_LOC = 0x9c0;
    uint256 internal constant RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC = 0x9e0;
    uint256 internal constant G2X_X0_LOC = 0xa00;
    uint256 internal constant G2X_X1_LOC = 0xa20;
    uint256 internal constant G2X_Y0_LOC = 0xa40;
    uint256 internal constant G2X_Y1_LOC = 0xa60;

    // ### PROOF DATA MEMORY LOCATIONS
    uint256 internal constant W1_X_LOC = 0x1200;
    uint256 internal constant W1_Y_LOC = 0x1220;
    uint256 internal constant W2_X_LOC = 0x1240;
    uint256 internal constant W2_Y_LOC = 0x1260;
    uint256 internal constant W3_X_LOC = 0x1280;
    uint256 internal constant W3_Y_LOC = 0x12a0;
    uint256 internal constant W4_X_LOC = 0x12c0;
    uint256 internal constant W4_Y_LOC = 0x12e0;
    uint256 internal constant S_X_LOC = 0x1300;
    uint256 internal constant S_Y_LOC = 0x1320;
    uint256 internal constant Z_X_LOC = 0x1340;
    uint256 internal constant Z_Y_LOC = 0x1360;
    uint256 internal constant Z_LOOKUP_X_LOC = 0x1380;
    uint256 internal constant Z_LOOKUP_Y_LOC = 0x13a0;
    uint256 internal constant T1_X_LOC = 0x13c0;
    uint256 internal constant T1_Y_LOC = 0x13e0;
    uint256 internal constant T2_X_LOC = 0x1400;
    uint256 internal constant T2_Y_LOC = 0x1420;
    uint256 internal constant T3_X_LOC = 0x1440;
    uint256 internal constant T3_Y_LOC = 0x1460;
    uint256 internal constant T4_X_LOC = 0x1480;
    uint256 internal constant T4_Y_LOC = 0x14a0;

    uint256 internal constant W1_EVAL_LOC = 0x1600;
    uint256 internal constant W2_EVAL_LOC = 0x1620;
    uint256 internal constant W3_EVAL_LOC = 0x1640;
    uint256 internal constant W4_EVAL_LOC = 0x1660;
    uint256 internal constant S_EVAL_LOC = 0x1680;
    uint256 internal constant Z_EVAL_LOC = 0x16a0;
    uint256 internal constant Z_LOOKUP_EVAL_LOC = 0x16c0;
    uint256 internal constant Q1_EVAL_LOC = 0x16e0;
    uint256 internal constant Q2_EVAL_LOC = 0x1700;
    uint256 internal constant Q3_EVAL_LOC = 0x1720;
    uint256 internal constant Q4_EVAL_LOC = 0x1740;
    uint256 internal constant QM_EVAL_LOC = 0x1760;
    uint256 internal constant QC_EVAL_LOC = 0x1780;
    uint256 internal constant QARITH_EVAL_LOC = 0x17a0;
    uint256 internal constant QSORT_EVAL_LOC = 0x17c0;
    uint256 internal constant QELLIPTIC_EVAL_LOC = 0x17e0;
    uint256 internal constant QAUX_EVAL_LOC = 0x1800;
    uint256 internal constant TABLE1_EVAL_LOC = 0x1840;
    uint256 internal constant TABLE2_EVAL_LOC = 0x1860;
    uint256 internal constant TABLE3_EVAL_LOC = 0x1880;
    uint256 internal constant TABLE4_EVAL_LOC = 0x18a0;
    uint256 internal constant TABLE_TYPE_EVAL_LOC = 0x18c0;
    uint256 internal constant ID1_EVAL_LOC = 0x18e0;
    uint256 internal constant ID2_EVAL_LOC = 0x1900;
    uint256 internal constant ID3_EVAL_LOC = 0x1920;
    uint256 internal constant ID4_EVAL_LOC = 0x1940;
    uint256 internal constant SIGMA1_EVAL_LOC = 0x1960;
    uint256 internal constant SIGMA2_EVAL_LOC = 0x1980;
    uint256 internal constant SIGMA3_EVAL_LOC = 0x19a0;
    uint256 internal constant SIGMA4_EVAL_LOC = 0x19c0;
    uint256 internal constant W1_OMEGA_EVAL_LOC = 0x19e0;
    uint256 internal constant W2_OMEGA_EVAL_LOC = 0x2000;
    uint256 internal constant W3_OMEGA_EVAL_LOC = 0x2020;
    uint256 internal constant W4_OMEGA_EVAL_LOC = 0x2040;
    uint256 internal constant S_OMEGA_EVAL_LOC = 0x2060;
    uint256 internal constant Z_OMEGA_EVAL_LOC = 0x2080;
    uint256 internal constant Z_LOOKUP_OMEGA_EVAL_LOC = 0x20a0;
    uint256 internal constant TABLE1_OMEGA_EVAL_LOC = 0x20c0;
    uint256 internal constant TABLE2_OMEGA_EVAL_LOC = 0x20e0;
    uint256 internal constant TABLE3_OMEGA_EVAL_LOC = 0x2100;
    uint256 internal constant TABLE4_OMEGA_EVAL_LOC = 0x2120;

    uint256 internal constant PI_Z_X_LOC = 0x2300;
    uint256 internal constant PI_Z_Y_LOC = 0x2320;
    uint256 internal constant PI_Z_OMEGA_X_LOC = 0x2340;
    uint256 internal constant PI_Z_OMEGA_Y_LOC = 0x2360;

    // Used for elliptic widget. These are alias names for wire + shifted wire evaluations
    uint256 internal constant X1_EVAL_LOC = W2_EVAL_LOC;
    uint256 internal constant X2_EVAL_LOC = W1_OMEGA_EVAL_LOC;
    uint256 internal constant X3_EVAL_LOC = W2_OMEGA_EVAL_LOC;
    uint256 internal constant Y1_EVAL_LOC = W3_EVAL_LOC;
    uint256 internal constant Y2_EVAL_LOC = W4_OMEGA_EVAL_LOC;
    uint256 internal constant Y3_EVAL_LOC = W3_OMEGA_EVAL_LOC;
    uint256 internal constant QBETA_LOC = Q3_EVAL_LOC;
    uint256 internal constant QBETA_SQR_LOC = Q4_EVAL_LOC;
    uint256 internal constant QSIGN_LOC = Q1_EVAL_LOC;

    // ### CHALLENGES MEMORY OFFSETS

    uint256 internal constant C_BETA_LOC = 0x2600;
    uint256 internal constant C_GAMMA_LOC = 0x2620;
    uint256 internal constant C_ALPHA_LOC = 0x2640;
    uint256 internal constant C_ETA_LOC = 0x2660;
    uint256 internal constant C_ETA_SQR_LOC = 0x2680;
    uint256 internal constant C_ETA_CUBE_LOC = 0x26a0;

    uint256 internal constant C_ZETA_LOC = 0x26c0;
    uint256 internal constant C_CURRENT_LOC = 0x26e0;
    uint256 internal constant C_V0_LOC = 0x2700;
    uint256 internal constant C_V1_LOC = 0x2720;
    uint256 internal constant C_V2_LOC = 0x2740;
    uint256 internal constant C_V3_LOC = 0x2760;
    uint256 internal constant C_V4_LOC = 0x2780;
    uint256 internal constant C_V5_LOC = 0x27a0;
    uint256 internal constant C_V6_LOC = 0x27c0;
    uint256 internal constant C_V7_LOC = 0x27e0;
    uint256 internal constant C_V8_LOC = 0x2800;
    uint256 internal constant C_V9_LOC = 0x2820;
    uint256 internal constant C_V10_LOC = 0x2840;
    uint256 internal constant C_V11_LOC = 0x2860;
    uint256 internal constant C_V12_LOC = 0x2880;
    uint256 internal constant C_V13_LOC = 0x28a0;
    uint256 internal constant C_V14_LOC = 0x28c0;
    uint256 internal constant C_V15_LOC = 0x28e0;
    uint256 internal constant C_V16_LOC = 0x2900;
    uint256 internal constant C_V17_LOC = 0x2920;
    uint256 internal constant C_V18_LOC = 0x2940;
    uint256 internal constant C_V19_LOC = 0x2960;
    uint256 internal constant C_V20_LOC = 0x2980;
    uint256 internal constant C_V21_LOC = 0x29a0;
    uint256 internal constant C_V22_LOC = 0x29c0;
    uint256 internal constant C_V23_LOC = 0x29e0;
    uint256 internal constant C_V24_LOC = 0x2a00;
    uint256 internal constant C_V25_LOC = 0x2a20;
    uint256 internal constant C_V26_LOC = 0x2a40;
    uint256 internal constant C_V27_LOC = 0x2a60;
    uint256 internal constant C_V28_LOC = 0x2a80;
    uint256 internal constant C_V29_LOC = 0x2aa0;
    uint256 internal constant C_V30_LOC = 0x2ac0;

    uint256 internal constant C_U_LOC = 0x2b00;

    // ### LOCAL VARIABLES MEMORY OFFSETS
    uint256 internal constant DELTA_NUMERATOR_LOC = 0x3000;
    uint256 internal constant DELTA_DENOMINATOR_LOC = 0x3020;
    uint256 internal constant ZETA_POW_N_LOC = 0x3040;
    uint256 internal constant PUBLIC_INPUT_DELTA_LOC = 0x3060;
    uint256 internal constant ZERO_POLY_LOC = 0x3080;
    uint256 internal constant L_START_LOC = 0x30a0;
    uint256 internal constant L_END_LOC = 0x30c0;
    uint256 internal constant R_ZERO_EVAL_LOC = 0x30e0;

    uint256 internal constant PLOOKUP_DELTA_NUMERATOR_LOC = 0x3100;
    uint256 internal constant PLOOKUP_DELTA_DENOMINATOR_LOC = 0x3120;
    uint256 internal constant PLOOKUP_DELTA_LOC = 0x3140;

    uint256 internal constant ACCUMULATOR_X_LOC = 0x3160;
    uint256 internal constant ACCUMULATOR_Y_LOC = 0x3180;
    uint256 internal constant ACCUMULATOR2_X_LOC = 0x31a0;
    uint256 internal constant ACCUMULATOR2_Y_LOC = 0x31c0;
    uint256 internal constant PAIRING_LHS_X_LOC = 0x31e0;
    uint256 internal constant PAIRING_LHS_Y_LOC = 0x3200;
    uint256 internal constant PAIRING_RHS_X_LOC = 0x3220;
    uint256 internal constant PAIRING_RHS_Y_LOC = 0x3240;

    // ### SUCCESS FLAG MEMORY LOCATIONS
    uint256 internal constant GRAND_PRODUCT_SUCCESS_FLAG = 0x3300;
    uint256 internal constant ARITHMETIC_TERM_SUCCESS_FLAG = 0x3020;
    uint256 internal constant BATCH_OPENING_SUCCESS_FLAG = 0x3340;
    uint256 internal constant OPENING_COMMITMENT_SUCCESS_FLAG = 0x3360;
    uint256 internal constant PAIRING_PREAMBLE_SUCCESS_FLAG = 0x3380;
    uint256 internal constant PAIRING_SUCCESS_FLAG = 0x33a0;
    uint256 internal constant RESULT_FLAG = 0x33c0;

    // misc stuff
    uint256 internal constant OMEGA_INVERSE_LOC = 0x3400;
    uint256 internal constant C_ALPHA_SQR_LOC = 0x3420;
    uint256 internal constant C_ALPHA_CUBE_LOC = 0x3440;
    uint256 internal constant C_ALPHA_QUAD_LOC = 0x3460;
    uint256 internal constant C_ALPHA_BASE_LOC = 0x3480;

    // ### RECURSION VARIABLE MEMORY LOCATIONS
    uint256 internal constant RECURSIVE_P1_X_LOC = 0x3500;
    uint256 internal constant RECURSIVE_P1_Y_LOC = 0x3520;
    uint256 internal constant RECURSIVE_P2_X_LOC = 0x3540;
    uint256 internal constant RECURSIVE_P2_Y_LOC = 0x3560;

    uint256 internal constant PUBLIC_INPUTS_HASH_LOCATION = 0x3580;

    // sub-identity storage
    uint256 internal constant PERMUTATION_IDENTITY = 0x3600;
    uint256 internal constant PLOOKUP_IDENTITY = 0x3620;
    uint256 internal constant ARITHMETIC_IDENTITY = 0x3640;
    uint256 internal constant SORT_IDENTITY = 0x3660;
    uint256 internal constant ELLIPTIC_IDENTITY = 0x3680;
    uint256 internal constant AUX_IDENTITY = 0x36a0;
    uint256 internal constant AUX_NON_NATIVE_FIELD_EVALUATION = 0x36c0;
    uint256 internal constant AUX_LIMB_ACCUMULATOR_EVALUATION = 0x36e0;
    uint256 internal constant AUX_RAM_CONSISTENCY_EVALUATION = 0x3700;
    uint256 internal constant AUX_ROM_CONSISTENCY_EVALUATION = 0x3720;
    uint256 internal constant AUX_MEMORY_EVALUATION = 0x3740;

    uint256 internal constant QUOTIENT_EVAL_LOC = 0x3760;
    uint256 internal constant ZERO_POLY_INVERSE_LOC = 0x3780;

    // when hashing public inputs we use memory at NU_CHALLENGE_INPUT_LOC_A, as the hash input size is unknown at compile time
    uint256 internal constant NU_CHALLENGE_INPUT_LOC_A = 0x37a0;
    uint256 internal constant NU_CHALLENGE_INPUT_LOC_B = 0x37c0;
    uint256 internal constant NU_CHALLENGE_INPUT_LOC_C = 0x37e0;

    bytes4 internal constant PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR =
        0xeba9f4a6;
    bytes4 internal constant PUBLIC_INPUT_GE_P_SELECTOR = 0x374a972f;
    bytes4 internal constant MOD_EXP_FAILURE_SELECTOR = 0xf894a7bc;
    bytes4 internal constant EC_SCALAR_MUL_FAILURE_SELECTOR = 0xf755f369;
    bytes4 internal constant PROOF_FAILURE_SELECTOR = 0x0711fcec;

    uint256 internal constant ETA_INPUT_LENGTH = 0xc0; // W1, W2, W3 = 6 * 0x20 bytes

    // We need to hash 41 field elements when generating the NU challenge
    // w1, w2, w3, w4, s, z, z_lookup, q1, q2, q3, q4, qm, qc, qarith (14)
    // qsort, qelliptic, qaux, sigma1, sigma2, sigma, sigma4, (7)
    // table1, table2, table3, table4, tabletype, id1, id2, id3, id4, (9)
    // w1_omega, w2_omega, w3_omega, w4_omega, s_omega, z_omega, z_lookup_omega, (7)
    // table1_omega, table2_omega, table3_omega, table4_omega (4)
    uint256 internal constant NU_INPUT_LENGTH = 0x520; // 0x520 = 41 * 0x20

    // There are ELEVEN G1 group elements added into the transcript in the `beta` round, that we need to skip over
    // W1, W2, W3, W4, S, Z, Z_LOOKUP, T1, T2, T3, T4
    uint256 internal constant NU_CALLDATA_SKIP_LENGTH = 0x2c0; // 11 * 0x40 = 0x2c0

    uint256 internal constant NEGATIVE_INVERSE_OF_2_MODULO_P =
        0x183227397098d014dc2822db40c0ac2e9419f4243cdcb848a1f0fac9f8000000;
    uint256 internal constant LIMB_SIZE = 0x100000000000000000; // 2<<68
    uint256 internal constant SUBLIMB_SHIFT = 0x4000; // 2<<14

    // y^2 = x^3 + ax + b
    // for Grumpkin, a = 0 and b = -17. We use b in a custom gate relation that evaluates elliptic curve arithmetic
    uint256 internal constant GRUMPKIN_CURVE_B_PARAMETER_NEGATED = 17;

    error PUBLIC_INPUT_COUNT_INVALID(uint256 expected, uint256 actual);
    error PUBLIC_INPUT_INVALID_BN128_G1_POINT();
    error PUBLIC_INPUT_GE_P();
    error MOD_EXP_FAILURE();
    error EC_SCALAR_MUL_FAILURE();
    error PROOF_FAILURE();

    function getVerificationKeyHash() public pure virtual returns (bytes32);

    function loadVerificationKey(
        uint256 _vk,
        uint256 _omegaInverseLoc
    ) internal pure virtual;

    /**
     * @notice Verify a Ultra Plonk proof
     * @param _proof - The serialized proof
     * @param _publicInputs - An array of the public inputs
     * @return True if proof is valid, reverts otherwise
     */
    function verify(
        bytes calldata _proof,
        bytes32[] calldata _publicInputs
    ) external view returns (bool) {
        loadVerificationKey(N_LOC, OMEGA_INVERSE_LOC);

        uint256 requiredPublicInputCount;
        assembly {
            requiredPublicInputCount := mload(NUM_INPUTS_LOC)
        }
        if (requiredPublicInputCount != _publicInputs.length) {
            revert PUBLIC_INPUT_COUNT_INVALID(
                requiredPublicInputCount,
                _publicInputs.length
            );
        }

        assembly {
            let
                q
            := 21888242871839275222246405745257275088696311157297823662689037894645226208583 // EC group order
            let
                p
            := 21888242871839275222246405745257275088548364400416034343698204186575808495617 // Prime field order

            /**
             * LOAD PROOF FROM CALLDATA
             */
            {
                let data_ptr := add(calldataload(0x04), 0x24)

                mstore(W1_Y_LOC, mod(calldataload(data_ptr), q))
                mstore(W1_X_LOC, mod(calldataload(add(data_ptr, 0x20)), q))

                mstore(W2_Y_LOC, mod(calldataload(add(data_ptr, 0x40)), q))
                mstore(W2_X_LOC, mod(calldataload(add(data_ptr, 0x60)), q))

                mstore(W3_Y_LOC, mod(calldataload(add(data_ptr, 0x80)), q))
                mstore(W3_X_LOC, mod(calldataload(add(data_ptr, 0xa0)), q))

                mstore(W4_Y_LOC, mod(calldataload(add(data_ptr, 0xc0)), q))
                mstore(W4_X_LOC, mod(calldataload(add(data_ptr, 0xe0)), q))

                mstore(S_Y_LOC, mod(calldataload(add(data_ptr, 0x100)), q))
                mstore(S_X_LOC, mod(calldataload(add(data_ptr, 0x120)), q))
                mstore(Z_Y_LOC, mod(calldataload(add(data_ptr, 0x140)), q))
                mstore(Z_X_LOC, mod(calldataload(add(data_ptr, 0x160)), q))
                mstore(
                    Z_LOOKUP_Y_LOC,
                    mod(calldataload(add(data_ptr, 0x180)), q)
                )
                mstore(
                    Z_LOOKUP_X_LOC,
                    mod(calldataload(add(data_ptr, 0x1a0)), q)
                )
                mstore(T1_Y_LOC, mod(calldataload(add(data_ptr, 0x1c0)), q))
                mstore(T1_X_LOC, mod(calldataload(add(data_ptr, 0x1e0)), q))

                mstore(T2_Y_LOC, mod(calldataload(add(data_ptr, 0x200)), q))
                mstore(T2_X_LOC, mod(calldataload(add(data_ptr, 0x220)), q))

                mstore(T3_Y_LOC, mod(calldataload(add(data_ptr, 0x240)), q))
                mstore(T3_X_LOC, mod(calldataload(add(data_ptr, 0x260)), q))

                mstore(T4_Y_LOC, mod(calldataload(add(data_ptr, 0x280)), q))
                mstore(T4_X_LOC, mod(calldataload(add(data_ptr, 0x2a0)), q))

                mstore(W1_EVAL_LOC, mod(calldataload(add(data_ptr, 0x2c0)), p))
                mstore(W2_EVAL_LOC, mod(calldataload(add(data_ptr, 0x2e0)), p))
                mstore(W3_EVAL_LOC, mod(calldataload(add(data_ptr, 0x300)), p))
                mstore(W4_EVAL_LOC, mod(calldataload(add(data_ptr, 0x320)), p))
                mstore(S_EVAL_LOC, mod(calldataload(add(data_ptr, 0x340)), p))
                mstore(Z_EVAL_LOC, mod(calldataload(add(data_ptr, 0x360)), p))
                mstore(
                    Z_LOOKUP_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x380)), p)
                )
                mstore(Q1_EVAL_LOC, mod(calldataload(add(data_ptr, 0x3a0)), p))
                mstore(Q2_EVAL_LOC, mod(calldataload(add(data_ptr, 0x3c0)), p))
                mstore(Q3_EVAL_LOC, mod(calldataload(add(data_ptr, 0x3e0)), p))
                mstore(Q4_EVAL_LOC, mod(calldataload(add(data_ptr, 0x400)), p))
                mstore(QM_EVAL_LOC, mod(calldataload(add(data_ptr, 0x420)), p))
                mstore(QC_EVAL_LOC, mod(calldataload(add(data_ptr, 0x440)), p))
                mstore(
                    QARITH_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x460)), p)
                )
                mstore(
                    QSORT_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x480)), p)
                )
                mstore(
                    QELLIPTIC_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x4a0)), p)
                )
                mstore(
                    QAUX_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x4c0)), p)
                )

                mstore(
                    SIGMA1_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x4e0)), p)
                )
                mstore(
                    SIGMA2_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x500)), p)
                )

                mstore(
                    SIGMA3_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x520)), p)
                )
                mstore(
                    SIGMA4_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x540)), p)
                )

                mstore(
                    TABLE1_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x560)), p)
                )
                mstore(
                    TABLE2_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x580)), p)
                )
                mstore(
                    TABLE3_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x5a0)), p)
                )
                mstore(
                    TABLE4_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x5c0)), p)
                )
                mstore(
                    TABLE_TYPE_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x5e0)), p)
                )

                mstore(ID1_EVAL_LOC, mod(calldataload(add(data_ptr, 0x600)), p))
                mstore(ID2_EVAL_LOC, mod(calldataload(add(data_ptr, 0x620)), p))
                mstore(ID3_EVAL_LOC, mod(calldataload(add(data_ptr, 0x640)), p))
                mstore(ID4_EVAL_LOC, mod(calldataload(add(data_ptr, 0x660)), p))

                mstore(
                    W1_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x680)), p)
                )
                mstore(
                    W2_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x6a0)), p)
                )
                mstore(
                    W3_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x6c0)), p)
                )
                mstore(
                    W4_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x6e0)), p)
                )
                mstore(
                    S_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x700)), p)
                )

                mstore(
                    Z_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x720)), p)
                )

                mstore(
                    Z_LOOKUP_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x740)), p)
                )
                mstore(
                    TABLE1_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x760)), p)
                )
                mstore(
                    TABLE2_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x780)), p)
                )
                mstore(
                    TABLE3_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x7a0)), p)
                )
                mstore(
                    TABLE4_OMEGA_EVAL_LOC,
                    mod(calldataload(add(data_ptr, 0x7c0)), p)
                )

                mstore(PI_Z_Y_LOC, mod(calldataload(add(data_ptr, 0x7e0)), q))
                mstore(PI_Z_X_LOC, mod(calldataload(add(data_ptr, 0x800)), q))

                mstore(
                    PI_Z_OMEGA_Y_LOC,
                    mod(calldataload(add(data_ptr, 0x820)), q)
                )
                mstore(
                    PI_Z_OMEGA_X_LOC,
                    mod(calldataload(add(data_ptr, 0x840)), q)
                )
            }

            /**
             * LOAD RECURSIVE PROOF INTO MEMORY
             */
            {
                if mload(CONTAINS_RECURSIVE_PROOF_LOC) {
                    let public_inputs_ptr := add(calldataload(0x24), 0x24)
                    let index_counter := add(
                        shl(5, mload(RECURSIVE_PROOF_PUBLIC_INPUT_INDICES_LOC)),
                        public_inputs_ptr
                    )

                    let x0 := calldataload(index_counter)
                    x0 := add(
                        x0,
                        shl(68, calldataload(add(index_counter, 0x20)))
                    )
                    x0 := add(
                        x0,
                        shl(136, calldataload(add(index_counter, 0x40)))
                    )
                    x0 := add(
                        x0,
                        shl(204, calldataload(add(index_counter, 0x60)))
                    )
                    let y0 := calldataload(add(index_counter, 0x80))
                    y0 := add(
                        y0,
                        shl(68, calldataload(add(index_counter, 0xa0)))
                    )
                    y0 := add(
                        y0,
                        shl(136, calldataload(add(index_counter, 0xc0)))
                    )
                    y0 := add(
                        y0,
                        shl(204, calldataload(add(index_counter, 0xe0)))
                    )
                    let x1 := calldataload(add(index_counter, 0x100))
                    x1 := add(
                        x1,
                        shl(68, calldataload(add(index_counter, 0x120)))
                    )
                    x1 := add(
                        x1,
                        shl(136, calldataload(add(index_counter, 0x140)))
                    )
                    x1 := add(
                        x1,
                        shl(204, calldataload(add(index_counter, 0x160)))
                    )
                    let y1 := calldataload(add(index_counter, 0x180))
                    y1 := add(
                        y1,
                        shl(68, calldataload(add(index_counter, 0x1a0)))
                    )
                    y1 := add(
                        y1,
                        shl(136, calldataload(add(index_counter, 0x1c0)))
                    )
                    y1 := add(
                        y1,
                        shl(204, calldataload(add(index_counter, 0x1e0)))
                    )
                    mstore(RECURSIVE_P1_X_LOC, x0)
                    mstore(RECURSIVE_P1_Y_LOC, y0)
                    mstore(RECURSIVE_P2_X_LOC, x1)
                    mstore(RECURSIVE_P2_Y_LOC, y1)

                    // validate these are valid bn128 G1 points
                    if iszero(
                        and(
                            and(lt(x0, q), lt(x1, q)),
                            and(lt(y0, q), lt(y1, q))
                        )
                    ) {
                        mstore(
                            0x00,
                            PUBLIC_INPUT_INVALID_BN128_G1_POINT_SELECTOR
                        )
                        revert(0x00, 0x04)
                    }
                }
            }

            {
                /**
                 * Generate initial challenge
                 */
                mstore(0x00, shl(224, mload(N_LOC)))
                mstore(0x04, shl(224, mload(NUM_INPUTS_LOC)))
                let challenge := keccak256(0x00, 0x08)

                /**
                 * Generate eta challenge
                 */
                mstore(PUBLIC_INPUTS_HASH_LOCATION, challenge)
                // The public input location is stored at 0x24, we then add 0x24 to skip selector and the length of public inputs
                let public_inputs_start := add(calldataload(0x24), 0x24)
                // copy the public inputs over
                let public_input_size := mul(mload(NUM_INPUTS_LOC), 0x20)
                calldatacopy(
                    add(PUBLIC_INPUTS_HASH_LOCATION, 0x20),
                    public_inputs_start,
                    public_input_size
                )

                // copy W1, W2, W3 into challenge. Each point is 0x40 bytes, so load 0xc0 = 3 * 0x40 bytes (ETA input length)
                let w_start := add(calldataload(0x04), 0x24)
                calldatacopy(
                    add(
                        add(PUBLIC_INPUTS_HASH_LOCATION, 0x20),
                        public_input_size
                    ),
                    w_start,
                    ETA_INPUT_LENGTH
                )

                // Challenge is the old challenge + public inputs + W1, W2, W3 (0x20 + public_input_size + 0xc0)
                let challenge_bytes_size := add(
                    0x20,
                    add(public_input_size, ETA_INPUT_LENGTH)
                )

                challenge := keccak256(
                    PUBLIC_INPUTS_HASH_LOCATION,
                    challenge_bytes_size
                )
                {
                    let eta := mod(challenge, p)
                    mstore(C_ETA_LOC, eta)
                    mstore(C_ETA_SQR_LOC, mulmod(eta, eta, p))
                    mstore(C_ETA_CUBE_LOC, mulmod(mload(C_ETA_SQR_LOC), eta, p))
                }

                /**
                 * Generate beta challenge
                 */
                mstore(0x00, challenge)
                mstore(0x20, mload(W4_Y_LOC))
                mstore(0x40, mload(W4_X_LOC))
                mstore(0x60, mload(S_Y_LOC))
                mstore(0x80, mload(S_X_LOC))
                challenge := keccak256(0x00, 0xa0)
                mstore(C_BETA_LOC, mod(challenge, p))

                /**
                 * Generate gamma challenge
                 */
                mstore(0x00, challenge)
                mstore8(0x20, 0x01)
                challenge := keccak256(0x00, 0x21)
                mstore(C_GAMMA_LOC, mod(challenge, p))

                /**
                 * Generate alpha challenge
                 */
                mstore(0x00, challenge)
                mstore(0x20, mload(Z_Y_LOC))
                mstore(0x40, mload(Z_X_LOC))
                mstore(0x60, mload(Z_LOOKUP_Y_LOC))
                mstore(0x80, mload(Z_LOOKUP_X_LOC))
                challenge := keccak256(0x00, 0xa0)
                mstore(C_ALPHA_LOC, mod(challenge, p))

                /**
                 * Compute and store some powers of alpha for future computations
                 */
                let alpha := mload(C_ALPHA_LOC)
                mstore(C_ALPHA_SQR_LOC, mulmod(alpha, alpha, p))
                mstore(
                    C_ALPHA_CUBE_LOC,
                    mulmod(mload(C_ALPHA_SQR_LOC), alpha, p)
                )
                mstore(
                    C_ALPHA_QUAD_LOC,
                    mulmod(mload(C_ALPHA_CUBE_LOC), alpha, p)
                )
                mstore(C_ALPHA_BASE_LOC, alpha)

                /**
                 * Generate zeta challenge
                 */
                mstore(0x00, challenge)
                mstore(0x20, mload(T1_Y_LOC))
                mstore(0x40, mload(T1_X_LOC))
                mstore(0x60, mload(T2_Y_LOC))
                mstore(0x80, mload(T2_X_LOC))
                mstore(0xa0, mload(T3_Y_LOC))
                mstore(0xc0, mload(T3_X_LOC))
                mstore(0xe0, mload(T4_Y_LOC))
                mstore(0x100, mload(T4_X_LOC))

                challenge := keccak256(0x00, 0x120)

                mstore(C_ZETA_LOC, mod(challenge, p))
                mstore(C_CURRENT_LOC, challenge)
            }

            /**
             * EVALUATE FIELD OPERATIONS
             */

            /**
             * COMPUTE PUBLIC INPUT DELTA
             * ΔPI = ∏ᵢ∈ℓ(wᵢ + β σ(i) + γ) / ∏ᵢ∈ℓ(wᵢ + β σ'(i) + γ)
             */
            {
                let beta := mload(C_BETA_LOC) // β
                let gamma := mload(C_GAMMA_LOC) // γ
                let work_root := mload(OMEGA_LOC) // ω
                let numerator_value := 1
                let denominator_value := 1

                let p_clone := p // move p to the front of the stack
                let valid_inputs := true

                // Load the starting point of the public inputs (jump over the selector and the length of public inputs [0x24])
                let public_inputs_ptr := add(calldataload(0x24), 0x24)

                // endpoint_ptr = public_inputs_ptr + num_inputs * 0x20. // every public input is 0x20 bytes
                let endpoint_ptr := add(
                    public_inputs_ptr,
                    mul(mload(NUM_INPUTS_LOC), 0x20)
                )

                // root_1 = β * 0x05
                let root_1 := mulmod(beta, 0x05, p_clone) // k1.β
                // root_2 = β * 0x0c
                let root_2 := mulmod(beta, 0x0c, p_clone)
                // @note 0x05 + 0x07 == 0x0c == external coset generator

                for {

                } lt(public_inputs_ptr, endpoint_ptr) {
                    public_inputs_ptr := add(public_inputs_ptr, 0x20)
                } {
                    /**
                     * input = public_input[i]
                     * valid_inputs &= input < p
                     * temp = input + gamma
                     * numerator_value *= (β.σ(i) + wᵢ + γ)  // σ(i) = 0x05.ωⁱ
                     * denominator_value *= (β.σ'(i) + wᵢ + γ) // σ'(i) = 0x0c.ωⁱ
                     * root_1 *= ω
                     * root_2 *= ω
                     */

                    let input := calldataload(public_inputs_ptr)
                    valid_inputs := and(valid_inputs, lt(input, p_clone))
                    let temp := addmod(input, gamma, p_clone)

                    numerator_value := mulmod(
                        numerator_value,
                        add(root_1, temp),
                        p_clone
                    )
                    denominator_value := mulmod(
                        denominator_value,
                        add(root_2, temp),
                        p_clone
                    )

                    root_1 := mulmod(root_1, work_root, p_clone)
                    root_2 := mulmod(root_2, work_root, p_clone)
                }

                // Revert if not all public inputs are field elements (i.e. < p)
                if iszero(valid_inputs) {
                    mstore(0x00, PUBLIC_INPUT_GE_P_SELECTOR)
                    revert(0x00, 0x04)
                }

                mstore(DELTA_NUMERATOR_LOC, numerator_value)
                mstore(DELTA_DENOMINATOR_LOC, denominator_value)
            }

            /**
             * Compute Plookup delta factor [γ(1 + β)]^{n-k}
             * k = num roots cut out of Z_H = 4
             */
            {
                let delta_base := mulmod(
                    mload(C_GAMMA_LOC),
                    addmod(mload(C_BETA_LOC), 1, p),
                    p
                )
                let delta_numerator := delta_base
                {
                    let exponent := mload(N_LOC)
                    let count := 1
                    for {

                    } lt(count, exponent) {
                        count := add(count, count)
                    } {
                        delta_numerator := mulmod(
                            delta_numerator,
                            delta_numerator,
                            p
                        )
                    }
                }
                mstore(PLOOKUP_DELTA_NUMERATOR_LOC, delta_numerator)

                let delta_denominator := mulmod(delta_base, delta_base, p)
                delta_denominator := mulmod(
                    delta_denominator,
                    delta_denominator,
                    p
                )
                mstore(PLOOKUP_DELTA_DENOMINATOR_LOC, delta_denominator)
            }
            /**
             * Compute lagrange poly and vanishing poly fractions
             */
            {
                /**
                 * vanishing_numerator = zeta
                 * ZETA_POW_N = zeta^n
                 * vanishing_numerator -= 1
                 * accumulating_root = omega_inverse
                 * work_root = p - accumulating_root
                 * domain_inverse = domain_inverse
                 * vanishing_denominator = zeta + work_root
                 * work_root *= accumulating_root
                 * vanishing_denominator *= (zeta + work_root)
                 * work_root *= accumulating_root
                 * vanishing_denominator *= (zeta + work_root)
                 * vanishing_denominator *= (zeta + (zeta + accumulating_root))
                 * work_root = omega
                 * lagrange_numerator = vanishing_numerator * domain_inverse
                 * l_start_denominator = zeta - 1
                 * accumulating_root = work_root^2
                 * l_end_denominator = accumulating_root^2 * work_root * zeta - 1
                 * Note: l_end_denominator term contains a term \omega^5 to cut out 5 roots of unity from vanishing poly
                 */

                let zeta := mload(C_ZETA_LOC)

                // compute zeta^n, where n is a power of 2
                let vanishing_numerator := zeta
                {
                    // pow_small
                    let exponent := mload(N_LOC)
                    let count := 1
                    for {

                    } lt(count, exponent) {
                        count := add(count, count)
                    } {
                        vanishing_numerator := mulmod(
                            vanishing_numerator,
                            vanishing_numerator,
                            p
                        )
                    }
                }
                mstore(ZETA_POW_N_LOC, vanishing_numerator)
                vanishing_numerator := addmod(vanishing_numerator, sub(p, 1), p)

                let accumulating_root := mload(OMEGA_INVERSE_LOC)
                let work_root := sub(p, accumulating_root)
                let domain_inverse := mload(DOMAIN_INVERSE_LOC)

                let vanishing_denominator := addmod(zeta, work_root, p)
                work_root := mulmod(work_root, accumulating_root, p)
                vanishing_denominator := mulmod(
                    vanishing_denominator,
                    addmod(zeta, work_root, p),
                    p
                )
                work_root := mulmod(work_root, accumulating_root, p)
                vanishing_denominator := mulmod(
                    vanishing_denominator,
                    addmod(zeta, work_root, p),
                    p
                )
                vanishing_denominator := mulmod(
                    vanishing_denominator,
                    addmod(zeta, mulmod(work_root, accumulating_root, p), p),
                    p
                )

                work_root := mload(OMEGA_LOC)

                let lagrange_numerator := mulmod(
                    vanishing_numerator,
                    domain_inverse,
                    p
                )
                let l_start_denominator := addmod(zeta, sub(p, 1), p)

                accumulating_root := mulmod(work_root, work_root, p)

                let l_end_denominator := addmod(
                    mulmod(
                        mulmod(
                            mulmod(accumulating_root, accumulating_root, p),
                            work_root,
                            p
                        ),
                        zeta,
                        p
                    ),
                    sub(p, 1),
                    p
                )

                /**
                 * Compute inversions using Montgomery's batch inversion trick
                 */
                let accumulator := mload(DELTA_DENOMINATOR_LOC)
                let t0 := accumulator
                accumulator := mulmod(accumulator, vanishing_denominator, p)
                let t1 := accumulator
                accumulator := mulmod(accumulator, vanishing_numerator, p)
                let t2 := accumulator
                accumulator := mulmod(accumulator, l_start_denominator, p)
                let t3 := accumulator
                accumulator := mulmod(
                    accumulator,
                    mload(PLOOKUP_DELTA_DENOMINATOR_LOC),
                    p
                )
                let t4 := accumulator
                {
                    mstore(0, 0x20)
                    mstore(0x20, 0x20)
                    mstore(0x40, 0x20)
                    mstore(0x60, mulmod(accumulator, l_end_denominator, p))
                    mstore(0x80, sub(p, 2))
                    mstore(0xa0, p)
                    if iszero(staticcall(gas(), 0x05, 0x00, 0xc0, 0x00, 0x20)) {
                        mstore(0x0, MOD_EXP_FAILURE_SELECTOR)
                        revert(0x00, 0x04)
                    }
                    accumulator := mload(0x00)
                }

                t4 := mulmod(accumulator, t4, p)
                accumulator := mulmod(accumulator, l_end_denominator, p)

                t3 := mulmod(accumulator, t3, p)
                accumulator := mulmod(
                    accumulator,
                    mload(PLOOKUP_DELTA_DENOMINATOR_LOC),
                    p
                )

                t2 := mulmod(accumulator, t2, p)
                accumulator := mulmod(accumulator, l_start_denominator, p)

                t1 := mulmod(accumulator, t1, p)
                accumulator := mulmod(accumulator, vanishing_numerator, p)

                t0 := mulmod(accumulator, t0, p)
                accumulator := mulmod(accumulator, vanishing_denominator, p)

                accumulator := mulmod(
                    mulmod(accumulator, accumulator, p),
                    mload(DELTA_DENOMINATOR_LOC),
                    p
                )

                mstore(
                    PUBLIC_INPUT_DELTA_LOC,
                    mulmod(mload(DELTA_NUMERATOR_LOC), accumulator, p)
                )
                mstore(ZERO_POLY_LOC, mulmod(vanishing_numerator, t0, p))
                mstore(
                    ZERO_POLY_INVERSE_LOC,
                    mulmod(vanishing_denominator, t1, p)
                )
                mstore(L_START_LOC, mulmod(lagrange_numerator, t2, p))
                mstore(
                    PLOOKUP_DELTA_LOC,
                    mulmod(mload(PLOOKUP_DELTA_NUMERATOR_LOC), t3, p)
                )
                mstore(L_END_LOC, mulmod(lagrange_numerator, t4, p))
            }

            /**
             * UltraPlonk Widget Ordering:
             *
             * 1. Permutation widget
             * 2. Plookup widget
             * 3. Arithmetic widget
             * 4. Fixed base widget (?)
             * 5. GenPermSort widget
             * 6. Elliptic widget
             * 7. Auxiliary widget
             */

            /**
             * COMPUTE PERMUTATION WIDGET EVALUATION
             */
            {
                let alpha := mload(C_ALPHA_LOC)
                let beta := mload(C_BETA_LOC)
                let gamma := mload(C_GAMMA_LOC)

                /**
                 * t1 = (W1 + gamma + beta * ID1) * (W2 + gamma + beta * ID2)
                 * t2 = (W3 + gamma + beta * ID3) * (W4 + gamma + beta * ID4)
                 * result = alpha_base * z_eval * t1 * t2
                 * t1 = (W1 + gamma + beta * sigma_1_eval) * (W2 + gamma + beta * sigma_2_eval)
                 * t2 = (W2 + gamma + beta * sigma_3_eval) * (W3 + gamma + beta * sigma_4_eval)
                 * result -= (alpha_base * z_omega_eval * t1 * t2)
                 */
                let t1 := mulmod(
                    add(
                        add(mload(W1_EVAL_LOC), gamma),
                        mulmod(beta, mload(ID1_EVAL_LOC), p)
                    ),
                    add(
                        add(mload(W2_EVAL_LOC), gamma),
                        mulmod(beta, mload(ID2_EVAL_LOC), p)
                    ),
                    p
                )
                let t2 := mulmod(
                    add(
                        add(mload(W3_EVAL_LOC), gamma),
                        mulmod(beta, mload(ID3_EVAL_LOC), p)
                    ),
                    add(
                        add(mload(W4_EVAL_LOC), gamma),
                        mulmod(beta, mload(ID4_EVAL_LOC), p)
                    ),
                    p
                )
                let result := mulmod(
                    mload(C_ALPHA_BASE_LOC),
                    mulmod(mload(Z_EVAL_LOC), mulmod(t1, t2, p), p),
                    p
                )
                t1 := mulmod(
                    add(
                        add(mload(W1_EVAL_LOC), gamma),
                        mulmod(beta, mload(SIGMA1_EVAL_LOC), p)
                    ),
                    add(
                        add(mload(W2_EVAL_LOC), gamma),
                        mulmod(beta, mload(SIGMA2_EVAL_LOC), p)
                    ),
                    p
                )
                t2 := mulmod(
                    add(
                        add(mload(W3_EVAL_LOC), gamma),
                        mulmod(beta, mload(SIGMA3_EVAL_LOC), p)
                    ),
                    add(
                        add(mload(W4_EVAL_LOC), gamma),
                        mulmod(beta, mload(SIGMA4_EVAL_LOC), p)
                    ),
                    p
                )
                result := addmod(
                    result,
                    sub(
                        p,
                        mulmod(
                            mload(C_ALPHA_BASE_LOC),
                            mulmod(
                                mload(Z_OMEGA_EVAL_LOC),
                                mulmod(t1, t2, p),
                                p
                            ),
                            p
                        )
                    ),
                    p
                )

                /**
                 * alpha_base *= alpha
                 * result += alpha_base . (L_{n-k}(ʓ) . (z(ʓ.ω) - ∆_{PI}))
                 * alpha_base *= alpha
                 * result += alpha_base . (L_1(ʓ)(Z(ʓ) - 1))
                 * alpha_Base *= alpha
                 */
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_LOC), p)
                )
                result := addmod(
                    result,
                    mulmod(
                        mload(C_ALPHA_BASE_LOC),
                        mulmod(
                            mload(L_END_LOC),
                            addmod(
                                mload(Z_OMEGA_EVAL_LOC),
                                sub(p, mload(PUBLIC_INPUT_DELTA_LOC)),
                                p
                            ),
                            p
                        ),
                        p
                    ),
                    p
                )
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_LOC), p)
                )
                mstore(
                    PERMUTATION_IDENTITY,
                    addmod(
                        result,
                        mulmod(
                            mload(C_ALPHA_BASE_LOC),
                            mulmod(
                                mload(L_START_LOC),
                                addmod(mload(Z_EVAL_LOC), sub(p, 1), p),
                                p
                            ),
                            p
                        ),
                        p
                    )
                )
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_LOC), p)
                )
            }

            /**
             * COMPUTE PLOOKUP WIDGET EVALUATION
             */
            {
                /**
                 * Goal: f = (w1(z) + q2.w1(zω)) + η(w2(z) + qm.w2(zω)) + η²(w3(z) + qc.w_3(zω)) + q3(z).η³
                 * f = η.q3(z)
                 * f += (w3(z) + qc.w_3(zω))
                 * f *= η
                 * f += (w2(z) + qm.w2(zω))
                 * f *= η
                 * f += (w1(z) + q2.w1(zω))
                 */
                let f := mulmod(mload(C_ETA_LOC), mload(Q3_EVAL_LOC), p)
                f := addmod(
                    f,
                    addmod(
                        mload(W3_EVAL_LOC),
                        mulmod(mload(QC_EVAL_LOC), mload(W3_OMEGA_EVAL_LOC), p),
                        p
                    ),
                    p
                )
                f := mulmod(f, mload(C_ETA_LOC), p)
                f := addmod(
                    f,
                    addmod(
                        mload(W2_EVAL_LOC),
                        mulmod(mload(QM_EVAL_LOC), mload(W2_OMEGA_EVAL_LOC), p),
                        p
                    ),
                    p
                )
                f := mulmod(f, mload(C_ETA_LOC), p)
                f := addmod(
                    f,
                    addmod(
                        mload(W1_EVAL_LOC),
                        mulmod(mload(Q2_EVAL_LOC), mload(W1_OMEGA_EVAL_LOC), p),
                        p
                    ),
                    p
                )

                // t(z) = table4(z).η³ + table3(z).η² + table2(z).η + table1(z)
                let t := addmod(
                    addmod(
                        addmod(
                            mulmod(
                                mload(TABLE4_EVAL_LOC),
                                mload(C_ETA_CUBE_LOC),
                                p
                            ),
                            mulmod(
                                mload(TABLE3_EVAL_LOC),
                                mload(C_ETA_SQR_LOC),
                                p
                            ),
                            p
                        ),
                        mulmod(mload(TABLE2_EVAL_LOC), mload(C_ETA_LOC), p),
                        p
                    ),
                    mload(TABLE1_EVAL_LOC),
                    p
                )

                // t(zw) = table4(zw).η³ + table3(zw).η² + table2(zw).η + table1(zw)
                let t_omega := addmod(
                    addmod(
                        addmod(
                            mulmod(
                                mload(TABLE4_OMEGA_EVAL_LOC),
                                mload(C_ETA_CUBE_LOC),
                                p
                            ),
                            mulmod(
                                mload(TABLE3_OMEGA_EVAL_LOC),
                                mload(C_ETA_SQR_LOC),
                                p
                            ),
                            p
                        ),
                        mulmod(
                            mload(TABLE2_OMEGA_EVAL_LOC),
                            mload(C_ETA_LOC),
                            p
                        ),
                        p
                    ),
                    mload(TABLE1_OMEGA_EVAL_LOC),
                    p
                )

                /**
                 * Goal: numerator = (TABLE_TYPE_EVAL * f(z) + γ) * (t(z) + βt(zω) + γ(β + 1)) * (β + 1)
                 * gamma_beta_constant = γ(β + 1)
                 * numerator = f * TABLE_TYPE_EVAL + gamma
                 * temp0 = t(z) + t(zω) * β + gamma_beta_constant
                 * numerator *= temp0
                 * numerator *= (β + 1)
                 * temp0 = alpha * l_1
                 * numerator += temp0
                 * numerator *= z_lookup(z)
                 * numerator -= temp0
                 */
                let gamma_beta_constant := mulmod(
                    mload(C_GAMMA_LOC),
                    addmod(mload(C_BETA_LOC), 1, p),
                    p
                )
                let numerator := addmod(
                    mulmod(f, mload(TABLE_TYPE_EVAL_LOC), p),
                    mload(C_GAMMA_LOC),
                    p
                )
                let temp0 := addmod(
                    addmod(t, mulmod(t_omega, mload(C_BETA_LOC), p), p),
                    gamma_beta_constant,
                    p
                )
                numerator := mulmod(numerator, temp0, p)
                numerator := mulmod(
                    numerator,
                    addmod(mload(C_BETA_LOC), 1, p),
                    p
                )
                temp0 := mulmod(mload(C_ALPHA_LOC), mload(L_START_LOC), p)
                numerator := addmod(numerator, temp0, p)
                numerator := mulmod(numerator, mload(Z_LOOKUP_EVAL_LOC), p)
                numerator := addmod(numerator, sub(p, temp0), p)

                /**
                 * Goal: denominator = z_lookup(zω)*[s(z) + βs(zω) + γ(1 + β)] - [z_lookup(zω) - [γ(1 + β)]^{n-k}]*α²L_end(z)
                 * note: delta_factor = [γ(1 + β)]^{n-k}
                 * denominator = s(z) + βs(zω) + γ(β + 1)
                 * temp1 = α²L_end(z)
                 * denominator -= temp1
                 * denominator *= z_lookup(zω)
                 * denominator += temp1 * delta_factor
                 * PLOOKUP_IDENTITY = (numerator - denominator).alpha_base
                 * alpha_base *= alpha^3
                 */
                let denominator := addmod(
                    addmod(
                        mload(S_EVAL_LOC),
                        mulmod(mload(S_OMEGA_EVAL_LOC), mload(C_BETA_LOC), p),
                        p
                    ),
                    gamma_beta_constant,
                    p
                )
                let temp1 := mulmod(mload(C_ALPHA_SQR_LOC), mload(L_END_LOC), p)
                denominator := addmod(denominator, sub(p, temp1), p)
                denominator := mulmod(
                    denominator,
                    mload(Z_LOOKUP_OMEGA_EVAL_LOC),
                    p
                )
                denominator := addmod(
                    denominator,
                    mulmod(temp1, mload(PLOOKUP_DELTA_LOC), p),
                    p
                )

                mstore(
                    PLOOKUP_IDENTITY,
                    mulmod(
                        addmod(numerator, sub(p, denominator), p),
                        mload(C_ALPHA_BASE_LOC),
                        p
                    )
                )

                // update alpha
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_CUBE_LOC), p)
                )
            }

            /**
             * COMPUTE ARITHMETIC WIDGET EVALUATION
             */
            {
                /**
                 * The basic arithmetic gate identity in standard plonk is as follows.
                 * (w_1 . w_2 . q_m) + (w_1 . q_1) + (w_2 . q_2) + (w_3 . q_3) + (w_4 . q_4) + q_c = 0
                 * However, for Ultraplonk, we extend this to support "passing" wires between rows (shown without alpha scaling below):
                 * q_arith * ( ( (-1/2) * (q_arith - 3) * q_m * w_1 * w_2 + q_1 * w_1 + q_2 * w_2 + q_3 * w_3 + q_4 * w_4 + q_c ) +
                 * (q_arith - 1)*( α * (q_arith - 2) * (w_1 + w_4 - w_1_omega + q_m) + w_4_omega) ) = 0
                 *
                 * This formula results in several cases depending on q_arith:
                 * 1. q_arith == 0: Arithmetic gate is completely disabled
                 *
                 * 2. q_arith == 1: Everything in the minigate on the right is disabled. The equation is just a standard plonk equation
                 * with extra wires: q_m * w_1 * w_2 + q_1 * w_1 + q_2 * w_2 + q_3 * w_3 + q_4 * w_4 + q_c = 0
                 *
                 * 3. q_arith == 2: The (w_1 + w_4 - ...) term is disabled. THe equation is:
                 * (1/2) * q_m * w_1 * w_2 + q_1 * w_1 + q_2 * w_2 + q_3 * w_3 + q_4 * w_4 + q_c + w_4_omega = 0
                 * It allows defining w_4 at next index (w_4_omega) in terms of current wire values
                 *
                 * 4. q_arith == 3: The product of w_1 and w_2 is disabled, but a mini addition gate is enabled. α allows us to split
                 * the equation into two:
                 *
                 * q_1 * w_1 + q_2 * w_2 + q_3 * w_3 + q_4 * w_4 + q_c + 2 * w_4_omega = 0
                 * and
                 * w_1 + w_4 - w_1_omega + q_m = 0  (we are reusing q_m here)
                 *
                 * 5. q_arith > 3: The product of w_1 and w_2 is scaled by (q_arith - 3), while the w_4_omega term is scaled by (q_arith - 1).
                 * The equation can be split into two:
                 *
                 * (q_arith - 3)* q_m * w_1 * w_ 2 + q_1 * w_1 + q_2 * w_2 + q_3 * w_3 + q_4 * w_4 + q_c + (q_arith - 1) * w_4_omega = 0
                 * and
                 * w_1 + w_4 - w_1_omega + q_m = 0
                 *
                 * The problem that q_m is used both in both equations can be dealt with by appropriately changing selector values at
                 * the next gate. Then we can treat (q_arith - 1) as a simulated q_6 selector and scale q_m to handle (q_arith - 3) at
                 * product.
                 */

                let w1q1 := mulmod(mload(W1_EVAL_LOC), mload(Q1_EVAL_LOC), p)
                let w2q2 := mulmod(mload(W2_EVAL_LOC), mload(Q2_EVAL_LOC), p)
                let w3q3 := mulmod(mload(W3_EVAL_LOC), mload(Q3_EVAL_LOC), p)
                let w4q3 := mulmod(mload(W4_EVAL_LOC), mload(Q4_EVAL_LOC), p)

                // @todo - Add a explicit test that hits QARITH == 3
                // w1w2qm := (w_1 . w_2 . q_m . (QARITH_EVAL_LOC - 3)) / 2
                let w1w2qm := mulmod(
                    mulmod(
                        mulmod(
                            mulmod(mload(W1_EVAL_LOC), mload(W2_EVAL_LOC), p),
                            mload(QM_EVAL_LOC),
                            p
                        ),
                        addmod(mload(QARITH_EVAL_LOC), sub(p, 3), p),
                        p
                    ),
                    NEGATIVE_INVERSE_OF_2_MODULO_P,
                    p
                )

                // (w_1 . w_2 . q_m . (q_arith - 3)) / -2) + (w_1 . q_1) + (w_2 . q_2) + (w_3 . q_3) + (w_4 . q_4) + q_c
                let identity := addmod(
                    mload(QC_EVAL_LOC),
                    addmod(
                        w4q3,
                        addmod(
                            w3q3,
                            addmod(w2q2, addmod(w1q1, w1w2qm, p), p),
                            p
                        ),
                        p
                    ),
                    p
                )

                // if q_arith == 3 we evaluate an additional mini addition gate (on top of the regular one), where:
                // w_1 + w_4 - w_1_omega + q_m = 0
                // we use this gate to save an addition gate when adding or subtracting non-native field elements
                // α * (q_arith - 2) * (w_1 + w_4 - w_1_omega + q_m)
                let extra_small_addition_gate_identity := mulmod(
                    mload(C_ALPHA_LOC),
                    mulmod(
                        addmod(mload(QARITH_EVAL_LOC), sub(p, 2), p),
                        addmod(
                            mload(QM_EVAL_LOC),
                            addmod(
                                sub(p, mload(W1_OMEGA_EVAL_LOC)),
                                addmod(
                                    mload(W1_EVAL_LOC),
                                    mload(W4_EVAL_LOC),
                                    p
                                ),
                                p
                            ),
                            p
                        ),
                        p
                    ),
                    p
                )

                // if q_arith == 2 OR q_arith == 3 we add the 4th wire of the NEXT gate into the arithmetic identity
                // N.B. if q_arith > 2, this wire value will be scaled by (q_arith - 1) relative to the other gate wires!
                // alpha_base * q_arith * (identity + (q_arith - 1) * (w_4_omega + extra_small_addition_gate_identity))
                mstore(
                    ARITHMETIC_IDENTITY,
                    mulmod(
                        mload(C_ALPHA_BASE_LOC),
                        mulmod(
                            mload(QARITH_EVAL_LOC),
                            addmod(
                                identity,
                                mulmod(
                                    addmod(
                                        mload(QARITH_EVAL_LOC),
                                        sub(p, 1),
                                        p
                                    ),
                                    addmod(
                                        mload(W4_OMEGA_EVAL_LOC),
                                        extra_small_addition_gate_identity,
                                        p
                                    ),
                                    p
                                ),
                                p
                            ),
                            p
                        ),
                        p
                    )
                )

                // update alpha
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_SQR_LOC), p)
                )
            }

            /**
             * COMPUTE GENPERMSORT WIDGET EVALUATION
             */
            {
                /**
                 * D1 = (w2 - w1)
                 * D2 = (w3 - w2)
                 * D3 = (w4 - w3)
                 * D4 = (w1_omega - w4)
                 *
                 * α_a = alpha_base
                 * α_b = alpha_base * α
                 * α_c = alpha_base * α^2
                 * α_d = alpha_base * α^3
                 *
                 * range_accumulator = (
                 *   D1(D1 - 1)(D1 - 2)(D1 - 3).α_a +
                 *   D2(D2 - 1)(D2 - 2)(D2 - 3).α_b +
                 *   D3(D3 - 1)(D3 - 2)(D3 - 3).α_c +
                 *   D4(D4 - 1)(D4 - 2)(D4 - 3).α_d +
                 * ) . q_sort
                 */
                let minus_two := sub(p, 2)
                let minus_three := sub(p, 3)
                let d1 := addmod(
                    mload(W2_EVAL_LOC),
                    sub(p, mload(W1_EVAL_LOC)),
                    p
                )
                let d2 := addmod(
                    mload(W3_EVAL_LOC),
                    sub(p, mload(W2_EVAL_LOC)),
                    p
                )
                let d3 := addmod(
                    mload(W4_EVAL_LOC),
                    sub(p, mload(W3_EVAL_LOC)),
                    p
                )
                let d4 := addmod(
                    mload(W1_OMEGA_EVAL_LOC),
                    sub(p, mload(W4_EVAL_LOC)),
                    p
                )

                let range_accumulator := mulmod(
                    mulmod(
                        mulmod(
                            addmod(mulmod(d1, d1, p), sub(p, d1), p),
                            addmod(d1, minus_two, p),
                            p
                        ),
                        addmod(d1, minus_three, p),
                        p
                    ),
                    mload(C_ALPHA_BASE_LOC),
                    p
                )
                range_accumulator := addmod(
                    range_accumulator,
                    mulmod(
                        mulmod(
                            mulmod(
                                addmod(mulmod(d2, d2, p), sub(p, d2), p),
                                addmod(d2, minus_two, p),
                                p
                            ),
                            addmod(d2, minus_three, p),
                            p
                        ),
                        mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_LOC), p),
                        p
                    ),
                    p
                )
                range_accumulator := addmod(
                    range_accumulator,
                    mulmod(
                        mulmod(
                            mulmod(
                                addmod(mulmod(d3, d3, p), sub(p, d3), p),
                                addmod(d3, minus_two, p),
                                p
                            ),
                            addmod(d3, minus_three, p),
                            p
                        ),
                        mulmod(
                            mload(C_ALPHA_BASE_LOC),
                            mload(C_ALPHA_SQR_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                range_accumulator := addmod(
                    range_accumulator,
                    mulmod(
                        mulmod(
                            mulmod(
                                addmod(mulmod(d4, d4, p), sub(p, d4), p),
                                addmod(d4, minus_two, p),
                                p
                            ),
                            addmod(d4, minus_three, p),
                            p
                        ),
                        mulmod(
                            mload(C_ALPHA_BASE_LOC),
                            mload(C_ALPHA_CUBE_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                range_accumulator := mulmod(
                    range_accumulator,
                    mload(QSORT_EVAL_LOC),
                    p
                )

                mstore(SORT_IDENTITY, range_accumulator)

                // update alpha
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_QUAD_LOC), p)
                )
            }

            /**
             * COMPUTE ELLIPTIC WIDGET EVALUATION
             */
            {
                /**
                 * endo_term = (-x_2) * x_1 * (x_3 * 2 + x_1) * q_beta
                 * endo_sqr_term = x_2^2
                 * endo_sqr_term *= (x_3 - x_1)
                 * endo_sqr_term *= q_beta^2
                 * leftovers = x_2^2
                 * leftovers *= x_2
                 * leftovers += x_1^2 * (x_3 + x_1) @follow-up Invalid comment in BB widget
                 * leftovers -= (y_2^2 + y_1^2)
                 * sign_term = y_2 * y_1
                 * sign_term += sign_term
                 * sign_term *= q_sign
                 */
                // q_elliptic * (x3 + x2 + x1)(x2 - x1)(x2 - x1) - y2^2 - y1^2 + 2(y2y1)*q_sign = 0
                let x_diff := addmod(
                    mload(X2_EVAL_LOC),
                    sub(p, mload(X1_EVAL_LOC)),
                    p
                )
                let y2_sqr := mulmod(mload(Y2_EVAL_LOC), mload(Y2_EVAL_LOC), p)
                let y1_sqr := mulmod(mload(Y1_EVAL_LOC), mload(Y1_EVAL_LOC), p)
                let y1y2 := mulmod(
                    mulmod(mload(Y1_EVAL_LOC), mload(Y2_EVAL_LOC), p),
                    mload(QSIGN_LOC),
                    p
                )

                let x_add_identity := addmod(
                    mulmod(
                        addmod(
                            mload(X3_EVAL_LOC),
                            addmod(mload(X2_EVAL_LOC), mload(X1_EVAL_LOC), p),
                            p
                        ),
                        mulmod(x_diff, x_diff, p),
                        p
                    ),
                    addmod(
                        sub(p, addmod(y2_sqr, y1_sqr, p)),
                        addmod(y1y2, y1y2, p),
                        p
                    ),
                    p
                )
                x_add_identity := mulmod(
                    mulmod(
                        x_add_identity,
                        addmod(1, sub(p, mload(QM_EVAL_LOC)), p),
                        p
                    ),
                    mload(C_ALPHA_BASE_LOC),
                    p
                )

                // q_elliptic * (x3 + x2 + x1)(x2 - x1)(x2 - x1) - y2^2 - y1^2 + 2(y2y1)*q_sign = 0
                let y1_plus_y3 := addmod(
                    mload(Y1_EVAL_LOC),
                    mload(Y3_EVAL_LOC),
                    p
                )
                let y_diff := addmod(
                    mulmod(mload(Y2_EVAL_LOC), mload(QSIGN_LOC), p),
                    sub(p, mload(Y1_EVAL_LOC)),
                    p
                )
                let y_add_identity := addmod(
                    mulmod(y1_plus_y3, x_diff, p),
                    mulmod(
                        addmod(
                            mload(X3_EVAL_LOC),
                            sub(p, mload(X1_EVAL_LOC)),
                            p
                        ),
                        y_diff,
                        p
                    ),
                    p
                )
                y_add_identity := mulmod(
                    mulmod(
                        y_add_identity,
                        addmod(1, sub(p, mload(QM_EVAL_LOC)), p),
                        p
                    ),
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_LOC), p),
                    p
                )

                // ELLIPTIC_IDENTITY = (x_identity + y_identity) * Q_ELLIPTIC_EVAL
                mstore(
                    ELLIPTIC_IDENTITY,
                    mulmod(
                        addmod(x_add_identity, y_add_identity, p),
                        mload(QELLIPTIC_EVAL_LOC),
                        p
                    )
                )
            }
            {
                /**
                 * x_pow_4 = (y_1_sqr - curve_b) * x_1;
                 * y_1_sqr_mul_4 = y_1_sqr + y_1_sqr;
                 * y_1_sqr_mul_4 += y_1_sqr_mul_4;
                 * x_1_pow_4_mul_9 = x_pow_4;
                 * x_1_pow_4_mul_9 += x_1_pow_4_mul_9;
                 * x_1_pow_4_mul_9 += x_1_pow_4_mul_9;
                 * x_1_pow_4_mul_9 += x_1_pow_4_mul_9;
                 * x_1_pow_4_mul_9 += x_pow_4;
                 * x_1_sqr_mul_3 = x_1_sqr + x_1_sqr + x_1_sqr;
                 * x_double_identity = (x_3 + x_1 + x_1) * y_1_sqr_mul_4 - x_1_pow_4_mul_9;
                 * y_double_identity = x_1_sqr_mul_3 * (x_1 - x_3) - (y_1 + y_1) * (y_1 + y_3);
                 */
                // (x3 + x1 + x1) (4y1*y1) - 9 * x1 * x1 * x1 * x1 = 0
                let x1_sqr := mulmod(mload(X1_EVAL_LOC), mload(X1_EVAL_LOC), p)
                let y1_sqr := mulmod(mload(Y1_EVAL_LOC), mload(Y1_EVAL_LOC), p)
                let x_pow_4 := mulmod(
                    addmod(y1_sqr, GRUMPKIN_CURVE_B_PARAMETER_NEGATED, p),
                    mload(X1_EVAL_LOC),
                    p
                )
                let y1_sqr_mul_4 := mulmod(y1_sqr, 4, p)
                let x1_pow_4_mul_9 := mulmod(x_pow_4, 9, p)
                let x1_sqr_mul_3 := mulmod(x1_sqr, 3, p)
                let x_double_identity := addmod(
                    mulmod(
                        addmod(
                            mload(X3_EVAL_LOC),
                            addmod(mload(X1_EVAL_LOC), mload(X1_EVAL_LOC), p),
                            p
                        ),
                        y1_sqr_mul_4,
                        p
                    ),
                    sub(p, x1_pow_4_mul_9),
                    p
                )
                // (y1 + y1) (2y1) - (3 * x1 * x1)(x1 - x3) = 0
                let y_double_identity := addmod(
                    mulmod(
                        x1_sqr_mul_3,
                        addmod(
                            mload(X1_EVAL_LOC),
                            sub(p, mload(X3_EVAL_LOC)),
                            p
                        ),
                        p
                    ),
                    sub(
                        p,
                        mulmod(
                            addmod(mload(Y1_EVAL_LOC), mload(Y1_EVAL_LOC), p),
                            addmod(mload(Y1_EVAL_LOC), mload(Y3_EVAL_LOC), p),
                            p
                        )
                    ),
                    p
                )
                x_double_identity := mulmod(
                    x_double_identity,
                    mload(C_ALPHA_BASE_LOC),
                    p
                )
                y_double_identity := mulmod(
                    y_double_identity,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_LOC), p),
                    p
                )
                x_double_identity := mulmod(
                    x_double_identity,
                    mload(QM_EVAL_LOC),
                    p
                )
                y_double_identity := mulmod(
                    y_double_identity,
                    mload(QM_EVAL_LOC),
                    p
                )
                // ELLIPTIC_IDENTITY += (x_double_identity + y_double_identity) * Q_DOUBLE_EVAL
                mstore(
                    ELLIPTIC_IDENTITY,
                    addmod(
                        mload(ELLIPTIC_IDENTITY),
                        mulmod(
                            addmod(x_double_identity, y_double_identity, p),
                            mload(QELLIPTIC_EVAL_LOC),
                            p
                        ),
                        p
                    )
                )

                // update alpha
                mstore(
                    C_ALPHA_BASE_LOC,
                    mulmod(mload(C_ALPHA_BASE_LOC), mload(C_ALPHA_QUAD_LOC), p)
                )
            }

            /**
             * COMPUTE AUXILIARY WIDGET EVALUATION
             */
            {
                {
                    /**
                     * Non native field arithmetic gate 2
                     *             _                                                                               _
                     *            /   _                   _                               _       14                \
                     * q_2 . q_4 |   (w_1 . w_2) + (w_1 . w_2) + (w_1 . w_4 + w_2 . w_3 - w_3) . 2    - w_3 - w_4   |
                     *            \_                                                                               _/
                     *
                     * limb_subproduct = w_1 . w_2_omega + w_1_omega . w_2
                     * non_native_field_gate_2 = w_1 * w_4 + w_4 * w_3 - w_3_omega
                     * non_native_field_gate_2 = non_native_field_gate_2 * limb_size
                     * non_native_field_gate_2 -= w_4_omega
                     * non_native_field_gate_2 += limb_subproduct
                     * non_native_field_gate_2 *= q_4
                     * limb_subproduct *= limb_size
                     * limb_subproduct += w_1_omega * w_2_omega
                     * non_native_field_gate_1 = (limb_subproduct + w_3 + w_4) * q_3
                     * non_native_field_gate_3 = (limb_subproduct + w_4 - (w_3_omega + w_4_omega)) * q_m
                     * non_native_field_identity = (non_native_field_gate_1 + non_native_field_gate_2 + non_native_field_gate_3) * q_2
                     */

                    let limb_subproduct := addmod(
                        mulmod(mload(W1_EVAL_LOC), mload(W2_OMEGA_EVAL_LOC), p),
                        mulmod(mload(W1_OMEGA_EVAL_LOC), mload(W2_EVAL_LOC), p),
                        p
                    )

                    let non_native_field_gate_2 := addmod(
                        addmod(
                            mulmod(mload(W1_EVAL_LOC), mload(W4_EVAL_LOC), p),
                            mulmod(mload(W2_EVAL_LOC), mload(W3_EVAL_LOC), p),
                            p
                        ),
                        sub(p, mload(W3_OMEGA_EVAL_LOC)),
                        p
                    )
                    non_native_field_gate_2 := mulmod(
                        non_native_field_gate_2,
                        LIMB_SIZE,
                        p
                    )
                    non_native_field_gate_2 := addmod(
                        non_native_field_gate_2,
                        sub(p, mload(W4_OMEGA_EVAL_LOC)),
                        p
                    )
                    non_native_field_gate_2 := addmod(
                        non_native_field_gate_2,
                        limb_subproduct,
                        p
                    )
                    non_native_field_gate_2 := mulmod(
                        non_native_field_gate_2,
                        mload(Q4_EVAL_LOC),
                        p
                    )
                    limb_subproduct := mulmod(limb_subproduct, LIMB_SIZE, p)
                    limb_subproduct := addmod(
                        limb_subproduct,
                        mulmod(
                            mload(W1_OMEGA_EVAL_LOC),
                            mload(W2_OMEGA_EVAL_LOC),
                            p
                        ),
                        p
                    )
                    let non_native_field_gate_1 := mulmod(
                        addmod(
                            limb_subproduct,
                            sub(
                                p,
                                addmod(
                                    mload(W3_EVAL_LOC),
                                    mload(W4_EVAL_LOC),
                                    p
                                )
                            ),
                            p
                        ),
                        mload(Q3_EVAL_LOC),
                        p
                    )
                    let non_native_field_gate_3 := mulmod(
                        addmod(
                            addmod(limb_subproduct, mload(W4_EVAL_LOC), p),
                            sub(
                                p,
                                addmod(
                                    mload(W3_OMEGA_EVAL_LOC),
                                    mload(W4_OMEGA_EVAL_LOC),
                                    p
                                )
                            ),
                            p
                        ),
                        mload(QM_EVAL_LOC),
                        p
                    )
                    let non_native_field_identity := mulmod(
                        addmod(
                            addmod(
                                non_native_field_gate_1,
                                non_native_field_gate_2,
                                p
                            ),
                            non_native_field_gate_3,
                            p
                        ),
                        mload(Q2_EVAL_LOC),
                        p
                    )

                    mstore(
                        AUX_NON_NATIVE_FIELD_EVALUATION,
                        non_native_field_identity
                    )
                }

                {
                    /**
                     * limb_accumulator_1 = w_2_omega;
                     * limb_accumulator_1 *= SUBLIMB_SHIFT;
                     * limb_accumulator_1 += w_1_omega;
                     * limb_accumulator_1 *= SUBLIMB_SHIFT;
                     * limb_accumulator_1 += w_3;
                     * limb_accumulator_1 *= SUBLIMB_SHIFT;
                     * limb_accumulator_1 += w_2;
                     * limb_accumulator_1 *= SUBLIMB_SHIFT;
                     * limb_accumulator_1 += w_1;
                     * limb_accumulator_1 -= w_4;
                     * limb_accumulator_1 *= q_4;
                     */
                    let limb_accumulator_1 := mulmod(
                        mload(W2_OMEGA_EVAL_LOC),
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_1 := addmod(
                        limb_accumulator_1,
                        mload(W1_OMEGA_EVAL_LOC),
                        p
                    )
                    limb_accumulator_1 := mulmod(
                        limb_accumulator_1,
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_1 := addmod(
                        limb_accumulator_1,
                        mload(W3_EVAL_LOC),
                        p
                    )
                    limb_accumulator_1 := mulmod(
                        limb_accumulator_1,
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_1 := addmod(
                        limb_accumulator_1,
                        mload(W2_EVAL_LOC),
                        p
                    )
                    limb_accumulator_1 := mulmod(
                        limb_accumulator_1,
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_1 := addmod(
                        limb_accumulator_1,
                        mload(W1_EVAL_LOC),
                        p
                    )
                    limb_accumulator_1 := addmod(
                        limb_accumulator_1,
                        sub(p, mload(W4_EVAL_LOC)),
                        p
                    )
                    limb_accumulator_1 := mulmod(
                        limb_accumulator_1,
                        mload(Q4_EVAL_LOC),
                        p
                    )

                    /**
                     * limb_accumulator_2 = w_3_omega;
                     * limb_accumulator_2 *= SUBLIMB_SHIFT;
                     * limb_accumulator_2 += w_2_omega;
                     * limb_accumulator_2 *= SUBLIMB_SHIFT;
                     * limb_accumulator_2 += w_1_omega;
                     * limb_accumulator_2 *= SUBLIMB_SHIFT;
                     * limb_accumulator_2 += w_4;
                     * limb_accumulator_2 *= SUBLIMB_SHIFT;
                     * limb_accumulator_2 += w_3;
                     * limb_accumulator_2 -= w_4_omega;
                     * limb_accumulator_2 *= q_m;
                     */
                    let limb_accumulator_2 := mulmod(
                        mload(W3_OMEGA_EVAL_LOC),
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_2 := addmod(
                        limb_accumulator_2,
                        mload(W2_OMEGA_EVAL_LOC),
                        p
                    )
                    limb_accumulator_2 := mulmod(
                        limb_accumulator_2,
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_2 := addmod(
                        limb_accumulator_2,
                        mload(W1_OMEGA_EVAL_LOC),
                        p
                    )
                    limb_accumulator_2 := mulmod(
                        limb_accumulator_2,
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_2 := addmod(
                        limb_accumulator_2,
                        mload(W4_EVAL_LOC),
                        p
                    )
                    limb_accumulator_2 := mulmod(
                        limb_accumulator_2,
                        SUBLIMB_SHIFT,
                        p
                    )
                    limb_accumulator_2 := addmod(
                        limb_accumulator_2,
                        mload(W3_EVAL_LOC),
                        p
                    )
                    limb_accumulator_2 := addmod(
                        limb_accumulator_2,
                        sub(p, mload(W4_OMEGA_EVAL_LOC)),
                        p
                    )
                    limb_accumulator_2 := mulmod(
                        limb_accumulator_2,
                        mload(QM_EVAL_LOC),
                        p
                    )

                    mstore(
                        AUX_LIMB_ACCUMULATOR_EVALUATION,
                        mulmod(
                            addmod(limb_accumulator_1, limb_accumulator_2, p),
                            mload(Q3_EVAL_LOC),
                            p
                        )
                    )
                }

                {
                    /**
                     * memory_record_check = w_3;
                     * memory_record_check *= eta;
                     * memory_record_check += w_2;
                     * memory_record_check *= eta;
                     * memory_record_check += w_1;
                     * memory_record_check *= eta;
                     * memory_record_check += q_c;
                     *
                     * partial_record_check = memory_record_check;
                     *
                     * memory_record_check -= w_4;
                     */

                    let memory_record_check := mulmod(
                        mload(W3_EVAL_LOC),
                        mload(C_ETA_LOC),
                        p
                    )
                    memory_record_check := addmod(
                        memory_record_check,
                        mload(W2_EVAL_LOC),
                        p
                    )
                    memory_record_check := mulmod(
                        memory_record_check,
                        mload(C_ETA_LOC),
                        p
                    )
                    memory_record_check := addmod(
                        memory_record_check,
                        mload(W1_EVAL_LOC),
                        p
                    )
                    memory_record_check := mulmod(
                        memory_record_check,
                        mload(C_ETA_LOC),
                        p
                    )
                    memory_record_check := addmod(
                        memory_record_check,
                        mload(QC_EVAL_LOC),
                        p
                    )

                    let partial_record_check := memory_record_check
                    memory_record_check := addmod(
                        memory_record_check,
                        sub(p, mload(W4_EVAL_LOC)),
                        p
                    )

                    mstore(AUX_MEMORY_EVALUATION, memory_record_check)

                    // index_delta = w_1_omega - w_1
                    let index_delta := addmod(
                        mload(W1_OMEGA_EVAL_LOC),
                        sub(p, mload(W1_EVAL_LOC)),
                        p
                    )
                    // record_delta = w_4_omega - w_4
                    let record_delta := addmod(
                        mload(W4_OMEGA_EVAL_LOC),
                        sub(p, mload(W4_EVAL_LOC)),
                        p
                    )
                    // index_is_monotonically_increasing = index_delta * (index_delta - 1)
                    let index_is_monotonically_increasing := mulmod(
                        index_delta,
                        addmod(index_delta, sub(p, 1), p),
                        p
                    )

                    // adjacent_values_match_if_adjacent_indices_match = record_delta * (1 - index_delta)
                    let
                        adjacent_values_match_if_adjacent_indices_match
                    := mulmod(
                        record_delta,
                        addmod(1, sub(p, index_delta), p),
                        p
                    )

                    // AUX_ROM_CONSISTENCY_EVALUATION = ((adjacent_values_match_if_adjacent_indices_match * alpha) + index_is_monotonically_increasing) * alpha + partial_record_check
                    mstore(
                        AUX_ROM_CONSISTENCY_EVALUATION,
                        addmod(
                            mulmod(
                                addmod(
                                    mulmod(
                                        adjacent_values_match_if_adjacent_indices_match,
                                        mload(C_ALPHA_LOC),
                                        p
                                    ),
                                    index_is_monotonically_increasing,
                                    p
                                ),
                                mload(C_ALPHA_LOC),
                                p
                            ),
                            memory_record_check,
                            p
                        )
                    )

                    {
                        /**
                         * next_gate_access_type = w_3_omega;
                         * next_gate_access_type *= eta;
                         * next_gate_access_type += w_2_omega;
                         * next_gate_access_type *= eta;
                         * next_gate_access_type += w_1_omega;
                         * next_gate_access_type *= eta;
                         * next_gate_access_type = w_4_omega - next_gate_access_type;
                         */
                        let next_gate_access_type := mulmod(
                            mload(W3_OMEGA_EVAL_LOC),
                            mload(C_ETA_LOC),
                            p
                        )
                        next_gate_access_type := addmod(
                            next_gate_access_type,
                            mload(W2_OMEGA_EVAL_LOC),
                            p
                        )
                        next_gate_access_type := mulmod(
                            next_gate_access_type,
                            mload(C_ETA_LOC),
                            p
                        )
                        next_gate_access_type := addmod(
                            next_gate_access_type,
                            mload(W1_OMEGA_EVAL_LOC),
                            p
                        )
                        next_gate_access_type := mulmod(
                            next_gate_access_type,
                            mload(C_ETA_LOC),
                            p
                        )
                        next_gate_access_type := addmod(
                            mload(W4_OMEGA_EVAL_LOC),
                            sub(p, next_gate_access_type),
                            p
                        )

                        // value_delta = w_3_omega - w_3
                        let value_delta := addmod(
                            mload(W3_OMEGA_EVAL_LOC),
                            sub(p, mload(W3_EVAL_LOC)),
                            p
                        )
                        //  adjacent_values_match_if_adjacent_indices_match_and_next_access_is_a_read_operation = (1 - index_delta) * value_delta * (1 - next_gate_access_type);

                        let
                            adjacent_values_match_if_adjacent_indices_match_and_next_access_is_a_read_operation
                        := mulmod(
                            addmod(1, sub(p, index_delta), p),
                            mulmod(
                                value_delta,
                                addmod(1, sub(p, next_gate_access_type), p),
                                p
                            ),
                            p
                        )

                        // AUX_RAM_CONSISTENCY_EVALUATION

                        /**
                         * access_type = w_4 - partial_record_check
                         * access_check = access_type^2 - access_type
                         * next_gate_access_type_is_boolean = next_gate_access_type^2 - next_gate_access_type
                         * RAM_consistency_check_identity = adjacent_values_match_if_adjacent_indices_match_and_next_access_is_a_read_operation;
                         * RAM_consistency_check_identity *= alpha;
                         * RAM_consistency_check_identity += index_is_monotonically_increasing;
                         * RAM_consistency_check_identity *= alpha;
                         * RAM_consistency_check_identity += next_gate_access_type_is_boolean;
                         * RAM_consistency_check_identity *= alpha;
                         * RAM_consistency_check_identity += access_check;
                         */

                        let access_type := addmod(
                            mload(W4_EVAL_LOC),
                            sub(p, partial_record_check),
                            p
                        )
                        let access_check := mulmod(
                            access_type,
                            addmod(access_type, sub(p, 1), p),
                            p
                        )
                        let next_gate_access_type_is_boolean := mulmod(
                            next_gate_access_type,
                            addmod(next_gate_access_type, sub(p, 1), p),
                            p
                        )
                        let RAM_cci := mulmod(
                            adjacent_values_match_if_adjacent_indices_match_and_next_access_is_a_read_operation,
                            mload(C_ALPHA_LOC),
                            p
                        )
                        RAM_cci := addmod(
                            RAM_cci,
                            index_is_monotonically_increasing,
                            p
                        )
                        RAM_cci := mulmod(RAM_cci, mload(C_ALPHA_LOC), p)
                        RAM_cci := addmod(
                            RAM_cci,
                            next_gate_access_type_is_boolean,
                            p
                        )
                        RAM_cci := mulmod(RAM_cci, mload(C_ALPHA_LOC), p)
                        RAM_cci := addmod(RAM_cci, access_check, p)

                        mstore(AUX_RAM_CONSISTENCY_EVALUATION, RAM_cci)
                    }

                    {
                        // timestamp_delta = w_2_omega - w_2
                        let timestamp_delta := addmod(
                            mload(W2_OMEGA_EVAL_LOC),
                            sub(p, mload(W2_EVAL_LOC)),
                            p
                        )

                        // RAM_timestamp_check_identity = (1 - index_delta) * timestamp_delta - w_3
                        let RAM_timestamp_check_identity := addmod(
                            mulmod(
                                timestamp_delta,
                                addmod(1, sub(p, index_delta), p),
                                p
                            ),
                            sub(p, mload(W3_EVAL_LOC)),
                            p
                        )

                        /**
                         * memory_identity = ROM_consistency_check_identity * q_2;
                         * memory_identity += RAM_timestamp_check_identity * q_4;
                         * memory_identity += memory_record_check * q_m;
                         * memory_identity *= q_1;
                         * memory_identity += (RAM_consistency_check_identity * q_arith);
                         *
                         * auxiliary_identity = memory_identity + non_native_field_identity + limb_accumulator_identity;
                         * auxiliary_identity *= q_aux;
                         * auxiliary_identity *= alpha_base;
                         */
                        let memory_identity := mulmod(
                            mload(AUX_ROM_CONSISTENCY_EVALUATION),
                            mload(Q2_EVAL_LOC),
                            p
                        )
                        memory_identity := addmod(
                            memory_identity,
                            mulmod(
                                RAM_timestamp_check_identity,
                                mload(Q4_EVAL_LOC),
                                p
                            ),
                            p
                        )
                        memory_identity := addmod(
                            memory_identity,
                            mulmod(
                                mload(AUX_MEMORY_EVALUATION),
                                mload(QM_EVAL_LOC),
                                p
                            ),
                            p
                        )
                        memory_identity := mulmod(
                            memory_identity,
                            mload(Q1_EVAL_LOC),
                            p
                        )
                        memory_identity := addmod(
                            memory_identity,
                            mulmod(
                                mload(AUX_RAM_CONSISTENCY_EVALUATION),
                                mload(QARITH_EVAL_LOC),
                                p
                            ),
                            p
                        )

                        let auxiliary_identity := addmod(
                            memory_identity,
                            mload(AUX_NON_NATIVE_FIELD_EVALUATION),
                            p
                        )
                        auxiliary_identity := addmod(
                            auxiliary_identity,
                            mload(AUX_LIMB_ACCUMULATOR_EVALUATION),
                            p
                        )
                        auxiliary_identity := mulmod(
                            auxiliary_identity,
                            mload(QAUX_EVAL_LOC),
                            p
                        )
                        auxiliary_identity := mulmod(
                            auxiliary_identity,
                            mload(C_ALPHA_BASE_LOC),
                            p
                        )

                        mstore(AUX_IDENTITY, auxiliary_identity)

                        // update alpha
                        mstore(
                            C_ALPHA_BASE_LOC,
                            mulmod(
                                mload(C_ALPHA_BASE_LOC),
                                mload(C_ALPHA_CUBE_LOC),
                                p
                            )
                        )
                    }
                }
            }

            {
                /**
                 * quotient = ARITHMETIC_IDENTITY
                 * quotient += PERMUTATION_IDENTITY
                 * quotient += PLOOKUP_IDENTITY
                 * quotient += SORT_IDENTITY
                 * quotient += ELLIPTIC_IDENTITY
                 * quotient += AUX_IDENTITY
                 * quotient *= ZERO_POLY_INVERSE
                 */
                mstore(
                    QUOTIENT_EVAL_LOC,
                    mulmod(
                        addmod(
                            addmod(
                                addmod(
                                    addmod(
                                        addmod(
                                            mload(PERMUTATION_IDENTITY),
                                            mload(PLOOKUP_IDENTITY),
                                            p
                                        ),
                                        mload(ARITHMETIC_IDENTITY),
                                        p
                                    ),
                                    mload(SORT_IDENTITY),
                                    p
                                ),
                                mload(ELLIPTIC_IDENTITY),
                                p
                            ),
                            mload(AUX_IDENTITY),
                            p
                        ),
                        mload(ZERO_POLY_INVERSE_LOC),
                        p
                    )
                )
            }

            /**
             * GENERATE NU AND SEPARATOR CHALLENGES
             */
            {
                let current_challenge := mload(C_CURRENT_LOC)
                // get a calldata pointer that points to the start of the data we want to copy
                let calldata_ptr := add(calldataload(0x04), 0x24)

                calldata_ptr := add(calldata_ptr, NU_CALLDATA_SKIP_LENGTH)

                mstore(NU_CHALLENGE_INPUT_LOC_A, current_challenge)
                mstore(NU_CHALLENGE_INPUT_LOC_B, mload(QUOTIENT_EVAL_LOC))
                calldatacopy(
                    NU_CHALLENGE_INPUT_LOC_C,
                    calldata_ptr,
                    NU_INPUT_LENGTH
                )

                // hash length = (0x20 + num field elements), we include the previous challenge in the hash
                let challenge := keccak256(
                    NU_CHALLENGE_INPUT_LOC_A,
                    add(NU_INPUT_LENGTH, 0x40)
                )

                mstore(C_V0_LOC, mod(challenge, p))
                // We need THIRTY-ONE independent nu challenges!
                mstore(0x00, challenge)
                mstore8(0x20, 0x01)
                mstore(C_V1_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x02)
                mstore(C_V2_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x03)
                mstore(C_V3_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x04)
                mstore(C_V4_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x05)
                mstore(C_V5_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x06)
                mstore(C_V6_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x07)
                mstore(C_V7_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x08)
                mstore(C_V8_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x09)
                mstore(C_V9_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x0a)
                mstore(C_V10_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x0b)
                mstore(C_V11_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x0c)
                mstore(C_V12_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x0d)
                mstore(C_V13_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x0e)
                mstore(C_V14_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x0f)
                mstore(C_V15_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x10)
                mstore(C_V16_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x11)
                mstore(C_V17_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x12)
                mstore(C_V18_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x13)
                mstore(C_V19_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x14)
                mstore(C_V20_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x15)
                mstore(C_V21_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x16)
                mstore(C_V22_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x17)
                mstore(C_V23_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x18)
                mstore(C_V24_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x19)
                mstore(C_V25_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x1a)
                mstore(C_V26_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x1b)
                mstore(C_V27_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x1c)
                mstore(C_V28_LOC, mod(keccak256(0x00, 0x21), p))
                mstore8(0x20, 0x1d)
                mstore(C_V29_LOC, mod(keccak256(0x00, 0x21), p))

                // @follow-up - Why are both v29 and v30 using appending 0x1d to the prior challenge and hashing, should it not change?
                mstore8(0x20, 0x1d)
                challenge := keccak256(0x00, 0x21)
                mstore(C_V30_LOC, mod(challenge, p))

                // separator
                mstore(0x00, challenge)
                mstore(0x20, mload(PI_Z_Y_LOC))
                mstore(0x40, mload(PI_Z_X_LOC))
                mstore(0x60, mload(PI_Z_OMEGA_Y_LOC))
                mstore(0x80, mload(PI_Z_OMEGA_X_LOC))

                mstore(C_U_LOC, mod(keccak256(0x00, 0xa0), p))
            }

            let success := 0
            // VALIDATE T1
            {
                let x := mload(T1_X_LOC)
                let y := mload(T1_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                mstore(ACCUMULATOR_X_LOC, x)
                mstore(add(ACCUMULATOR_X_LOC, 0x20), y)
            }
            // VALIDATE T2
            {
                let x := mload(T2_X_LOC) // 0x1400
                let y := mload(T2_Y_LOC) // 0x1420
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(ZETA_POW_N_LOC))
            // accumulator_2 = [T2].zeta^n
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = [T1] + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE T3
            {
                let x := mload(T3_X_LOC)
                let y := mload(T3_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(mload(ZETA_POW_N_LOC), mload(ZETA_POW_N_LOC), p)
            )
            // accumulator_2 = [T3].zeta^{2n}
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE T4
            {
                let x := mload(T4_X_LOC)
                let y := mload(T4_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(
                    mulmod(mload(ZETA_POW_N_LOC), mload(ZETA_POW_N_LOC), p),
                    mload(ZETA_POW_N_LOC),
                    p
                )
            )
            // accumulator_2 = [T4].zeta^{3n}
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE W1
            {
                let x := mload(W1_X_LOC)
                let y := mload(W1_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V0_LOC), p)
            )
            // accumulator_2 = v0.(u + 1).[W1]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE W2
            {
                let x := mload(W2_X_LOC)
                let y := mload(W2_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V1_LOC), p)
            )
            // accumulator_2 = v1.(u + 1).[W2]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE W3
            {
                let x := mload(W3_X_LOC)
                let y := mload(W3_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V2_LOC), p)
            )
            // accumulator_2 = v2.(u + 1).[W3]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE W4
            {
                let x := mload(W4_X_LOC)
                let y := mload(W4_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V3_LOC), p)
            )
            // accumulator_2 = v3.(u + 1).[W4]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE S
            {
                let x := mload(S_X_LOC)
                let y := mload(S_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V4_LOC), p)
            )
            // accumulator_2 = v4.(u + 1).[S]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE Z
            {
                let x := mload(Z_X_LOC)
                let y := mload(Z_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V5_LOC), p)
            )
            // accumulator_2 = v5.(u + 1).[Z]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE Z_LOOKUP
            {
                let x := mload(Z_LOOKUP_X_LOC)
                let y := mload(Z_LOOKUP_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V6_LOC), p)
            )
            // accumulator_2 = v6.(u + 1).[Z_LOOKUP]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE Q1
            {
                let x := mload(Q1_X_LOC)
                let y := mload(Q1_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V7_LOC))
            // accumulator_2 = v7.[Q1]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE Q2
            {
                let x := mload(Q2_X_LOC)
                let y := mload(Q2_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V8_LOC))
            // accumulator_2 = v8.[Q2]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE Q3
            {
                let x := mload(Q3_X_LOC)
                let y := mload(Q3_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V9_LOC))
            // accumulator_2 = v9.[Q3]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE Q4
            {
                let x := mload(Q4_X_LOC)
                let y := mload(Q4_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V10_LOC))
            // accumulator_2 = v10.[Q4]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE QM
            {
                let x := mload(QM_X_LOC)
                let y := mload(QM_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V11_LOC))
            // accumulator_2 = v11.[Q;]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE QC
            {
                let x := mload(QC_X_LOC)
                let y := mload(QC_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V12_LOC))
            // accumulator_2 = v12.[QC]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE QARITH
            {
                let x := mload(QARITH_X_LOC)
                let y := mload(QARITH_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V13_LOC))
            // accumulator_2 = v13.[QARITH]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE QSORT
            {
                let x := mload(QSORT_X_LOC)
                let y := mload(QSORT_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V14_LOC))
            // accumulator_2 = v14.[QSORT]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE QELLIPTIC
            {
                let x := mload(QELLIPTIC_X_LOC)
                let y := mload(QELLIPTIC_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V15_LOC))
            // accumulator_2 = v15.[QELLIPTIC]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE QAUX
            {
                let x := mload(QAUX_X_LOC)
                let y := mload(QAUX_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V16_LOC))
            // accumulator_2 = v15.[Q_AUX]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE SIGMA1
            {
                let x := mload(SIGMA1_X_LOC)
                let y := mload(SIGMA1_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V17_LOC))
            // accumulator_2 = v17.[sigma1]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE SIGMA2
            {
                let x := mload(SIGMA2_X_LOC)
                let y := mload(SIGMA2_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V18_LOC))
            // accumulator_2 = v18.[sigma2]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE SIGMA3
            {
                let x := mload(SIGMA3_X_LOC)
                let y := mload(SIGMA3_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V19_LOC))
            // accumulator_2 = v19.[sigma3]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE SIGMA4
            {
                let x := mload(SIGMA4_X_LOC)
                let y := mload(SIGMA4_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V20_LOC))
            // accumulator_2 = v20.[sigma4]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE TABLE1
            {
                let x := mload(TABLE1_X_LOC)
                let y := mload(TABLE1_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V21_LOC), p)
            )
            // accumulator_2 = u.[table1]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE TABLE2
            {
                let x := mload(TABLE2_X_LOC)
                let y := mload(TABLE2_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V22_LOC), p)
            )
            // accumulator_2 = u.[table2]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE TABLE3
            {
                let x := mload(TABLE3_X_LOC)
                let y := mload(TABLE3_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V23_LOC), p)
            )
            // accumulator_2 = u.[table3]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE TABLE4
            {
                let x := mload(TABLE4_X_LOC)
                let y := mload(TABLE4_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(
                0x40,
                mulmod(addmod(mload(C_U_LOC), 0x1, p), mload(C_V24_LOC), p)
            )
            // accumulator_2 = u.[table4]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE TABLE_TYPE
            {
                let x := mload(TABLE_TYPE_X_LOC)
                let y := mload(TABLE_TYPE_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V25_LOC))
            // accumulator_2 = v25.[TableType]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE ID1
            {
                let x := mload(ID1_X_LOC)
                let y := mload(ID1_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V26_LOC))
            // accumulator_2 = v26.[ID1]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE ID2
            {
                let x := mload(ID2_X_LOC)
                let y := mload(ID2_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V27_LOC))
            // accumulator_2 = v27.[ID2]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE ID3
            {
                let x := mload(ID3_X_LOC)
                let y := mload(ID3_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V28_LOC))
            // accumulator_2 = v28.[ID3]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            // VALIDATE ID4
            {
                let x := mload(ID4_X_LOC)
                let y := mload(ID4_Y_LOC)
                let xx := mulmod(x, x, q)
                // validate on curve
                success := and(
                    success,
                    eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                )
                mstore(0x00, x)
                mstore(0x20, y)
            }
            mstore(0x40, mload(C_V29_LOC))
            // accumulator_2 = v29.[ID4]
            success := and(
                success,
                staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
            )
            // accumulator = accumulator + accumulator_2
            success := and(
                success,
                staticcall(
                    gas(),
                    6,
                    ACCUMULATOR_X_LOC,
                    0x80,
                    ACCUMULATOR_X_LOC,
                    0x40
                )
            )

            /**
             * COMPUTE BATCH EVALUATION SCALAR MULTIPLIER
             */
            {
                /**
                 * batch_evaluation = v0 * (w_1_omega * u + w_1_eval)
                 * batch_evaluation += v1 * (w_2_omega * u + w_2_eval)
                 * batch_evaluation += v2 * (w_3_omega * u + w_3_eval)
                 * batch_evaluation += v3 * (w_4_omega * u + w_4_eval)
                 * batch_evaluation += v4 * (s_omega_eval * u + s_eval)
                 * batch_evaluation += v5 * (z_omega_eval * u + z_eval)
                 * batch_evaluation += v6 * (z_lookup_omega_eval * u + z_lookup_eval)
                 */
                let batch_evaluation := mulmod(
                    mload(C_V0_LOC),
                    addmod(
                        mulmod(mload(W1_OMEGA_EVAL_LOC), mload(C_U_LOC), p),
                        mload(W1_EVAL_LOC),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V1_LOC),
                        addmod(
                            mulmod(mload(W2_OMEGA_EVAL_LOC), mload(C_U_LOC), p),
                            mload(W2_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V2_LOC),
                        addmod(
                            mulmod(mload(W3_OMEGA_EVAL_LOC), mload(C_U_LOC), p),
                            mload(W3_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V3_LOC),
                        addmod(
                            mulmod(mload(W4_OMEGA_EVAL_LOC), mload(C_U_LOC), p),
                            mload(W4_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V4_LOC),
                        addmod(
                            mulmod(mload(S_OMEGA_EVAL_LOC), mload(C_U_LOC), p),
                            mload(S_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V5_LOC),
                        addmod(
                            mulmod(mload(Z_OMEGA_EVAL_LOC), mload(C_U_LOC), p),
                            mload(Z_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V6_LOC),
                        addmod(
                            mulmod(
                                mload(Z_LOOKUP_OMEGA_EVAL_LOC),
                                mload(C_U_LOC),
                                p
                            ),
                            mload(Z_LOOKUP_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )

                /**
                 * batch_evaluation += v7 * Q1_EVAL
                 * batch_evaluation += v8 * Q2_EVAL
                 * batch_evaluation += v9 * Q3_EVAL
                 * batch_evaluation += v10 * Q4_EVAL
                 * batch_evaluation += v11 * QM_EVAL
                 * batch_evaluation += v12 * QC_EVAL
                 * batch_evaluation += v13 * QARITH_EVAL
                 * batch_evaluation += v14 * QSORT_EVAL_LOC
                 * batch_evaluation += v15 * QELLIPTIC_EVAL_LOC
                 * batch_evaluation += v16 * QAUX_EVAL_LOC
                 * batch_evaluation += v17 * SIGMA1_EVAL_LOC
                 * batch_evaluation += v18 * SIGMA2_EVAL_LOC
                 * batch_evaluation += v19 * SIGMA3_EVAL_LOC
                 * batch_evaluation += v20 * SIGMA4_EVAL_LOC
                 */
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V7_LOC), mload(Q1_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V8_LOC), mload(Q2_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V9_LOC), mload(Q3_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V10_LOC), mload(Q4_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V11_LOC), mload(QM_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V12_LOC), mload(QC_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V13_LOC), mload(QARITH_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V14_LOC), mload(QSORT_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V15_LOC), mload(QELLIPTIC_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V16_LOC), mload(QAUX_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V17_LOC), mload(SIGMA1_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V18_LOC), mload(SIGMA2_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V19_LOC), mload(SIGMA3_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V20_LOC), mload(SIGMA4_EVAL_LOC), p),
                    p
                )

                /**
                 * batch_evaluation += v21 * (table1(zw) * u + table1(z))
                 * batch_evaluation += v22 * (table2(zw) * u + table2(z))
                 * batch_evaluation += v23 * (table3(zw) * u + table3(z))
                 * batch_evaluation += v24 * (table4(zw) * u + table4(z))
                 * batch_evaluation += v25 * table_type_eval
                 * batch_evaluation += v26 * id1_eval
                 * batch_evaluation += v27 * id2_eval
                 * batch_evaluation += v28 * id3_eval
                 * batch_evaluation += v29 * id4_eval
                 * batch_evaluation += quotient_eval
                 */
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V21_LOC),
                        addmod(
                            mulmod(
                                mload(TABLE1_OMEGA_EVAL_LOC),
                                mload(C_U_LOC),
                                p
                            ),
                            mload(TABLE1_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V22_LOC),
                        addmod(
                            mulmod(
                                mload(TABLE2_OMEGA_EVAL_LOC),
                                mload(C_U_LOC),
                                p
                            ),
                            mload(TABLE2_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V23_LOC),
                        addmod(
                            mulmod(
                                mload(TABLE3_OMEGA_EVAL_LOC),
                                mload(C_U_LOC),
                                p
                            ),
                            mload(TABLE3_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(
                        mload(C_V24_LOC),
                        addmod(
                            mulmod(
                                mload(TABLE4_OMEGA_EVAL_LOC),
                                mload(C_U_LOC),
                                p
                            ),
                            mload(TABLE4_EVAL_LOC),
                            p
                        ),
                        p
                    ),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V25_LOC), mload(TABLE_TYPE_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V26_LOC), mload(ID1_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V27_LOC), mload(ID2_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V28_LOC), mload(ID3_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mulmod(mload(C_V29_LOC), mload(ID4_EVAL_LOC), p),
                    p
                )
                batch_evaluation := addmod(
                    batch_evaluation,
                    mload(QUOTIENT_EVAL_LOC),
                    p
                )

                mstore(0x00, 0x01) // [1].x
                mstore(0x20, 0x02) // [1].y
                mstore(0x40, sub(p, batch_evaluation))
                // accumulator_2 = -[1].(batch_evaluation)
                success := and(
                    success,
                    staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
                )
                // accumulator = accumulator + accumulator_2
                success := and(
                    success,
                    staticcall(
                        gas(),
                        6,
                        ACCUMULATOR_X_LOC,
                        0x80,
                        ACCUMULATOR_X_LOC,
                        0x40
                    )
                )

                mstore(OPENING_COMMITMENT_SUCCESS_FLAG, success)
            }

            /**
             * PERFORM PAIRING PREAMBLE
             */
            {
                let u := mload(C_U_LOC)
                let zeta := mload(C_ZETA_LOC)
                // VALIDATE PI_Z
                {
                    let x := mload(PI_Z_X_LOC)
                    let y := mload(PI_Z_Y_LOC)
                    let xx := mulmod(x, x, q)
                    // validate on curve
                    success := eq(
                        mulmod(y, y, q),
                        addmod(mulmod(x, xx, q), 3, q)
                    )
                    mstore(0x00, x)
                    mstore(0x20, y)
                }
                // compute zeta.[PI_Z] and add into accumulator
                mstore(0x40, zeta)
                success := and(
                    success,
                    staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
                )
                // accumulator = accumulator + accumulator_2
                success := and(
                    success,
                    staticcall(
                        gas(),
                        6,
                        ACCUMULATOR_X_LOC,
                        0x80,
                        ACCUMULATOR_X_LOC,
                        0x40
                    )
                )

                // VALIDATE PI_Z_OMEGA
                {
                    let x := mload(PI_Z_OMEGA_X_LOC)
                    let y := mload(PI_Z_OMEGA_Y_LOC)
                    let xx := mulmod(x, x, q)
                    // validate on curve
                    success := and(
                        success,
                        eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                    )
                    mstore(0x00, x)
                    mstore(0x20, y)
                }
                mstore(0x40, mulmod(mulmod(u, zeta, p), mload(OMEGA_LOC), p))
                // accumulator_2 = u.zeta.omega.[PI_Z_OMEGA]
                success := and(
                    success,
                    staticcall(gas(), 7, 0x00, 0x60, ACCUMULATOR2_X_LOC, 0x40)
                )
                // PAIRING_RHS = accumulator + accumulator_2
                success := and(
                    success,
                    staticcall(
                        gas(),
                        6,
                        ACCUMULATOR_X_LOC,
                        0x80,
                        PAIRING_RHS_X_LOC,
                        0x40
                    )
                )

                mstore(0x00, mload(PI_Z_X_LOC))
                mstore(0x20, mload(PI_Z_Y_LOC))
                mstore(0x40, mload(PI_Z_OMEGA_X_LOC))
                mstore(0x60, mload(PI_Z_OMEGA_Y_LOC))
                mstore(0x80, u)
                success := and(
                    success,
                    staticcall(gas(), 7, 0x40, 0x60, 0x40, 0x40)
                )
                // PAIRING_LHS = [PI_Z] + [PI_Z_OMEGA] * u
                success := and(
                    success,
                    staticcall(gas(), 6, 0x00, 0x80, PAIRING_LHS_X_LOC, 0x40)
                )
                // negate lhs y-coordinate
                mstore(PAIRING_LHS_Y_LOC, sub(q, mload(PAIRING_LHS_Y_LOC)))

                if mload(CONTAINS_RECURSIVE_PROOF_LOC) {
                    // VALIDATE RECURSIVE P1
                    {
                        let x := mload(RECURSIVE_P1_X_LOC)
                        let y := mload(RECURSIVE_P1_Y_LOC)
                        let xx := mulmod(x, x, q)
                        // validate on curve
                        success := and(
                            success,
                            eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                        )
                        mstore(0x00, x)
                        mstore(0x20, y)
                    }

                    // compute u.u.[recursive_p1] and write into 0x60
                    mstore(0x40, mulmod(u, u, p))
                    success := and(
                        success,
                        staticcall(gas(), 7, 0x00, 0x60, 0x60, 0x40)
                    )
                    // VALIDATE RECURSIVE P2
                    {
                        let x := mload(RECURSIVE_P2_X_LOC)
                        let y := mload(RECURSIVE_P2_Y_LOC)
                        let xx := mulmod(x, x, q)
                        // validate on curve
                        success := and(
                            success,
                            eq(mulmod(y, y, q), addmod(mulmod(x, xx, q), 3, q))
                        )
                        mstore(0x00, x)
                        mstore(0x20, y)
                    }
                    // compute u.u.[recursive_p2] and write into 0x00
                    // 0x40 still contains u*u
                    success := and(
                        success,
                        staticcall(gas(), 7, 0x00, 0x60, 0x00, 0x40)
                    )

                    // compute u.u.[recursiveP1] + rhs and write into rhs
                    mstore(0xa0, mload(PAIRING_RHS_X_LOC))
                    mstore(0xc0, mload(PAIRING_RHS_Y_LOC))
                    success := and(
                        success,
                        staticcall(
                            gas(),
                            6,
                            0x60,
                            0x80,
                            PAIRING_RHS_X_LOC,
                            0x40
                        )
                    )

                    // compute u.u.[recursiveP2] + lhs and write into lhs
                    mstore(0x40, mload(PAIRING_LHS_X_LOC))
                    mstore(0x60, mload(PAIRING_LHS_Y_LOC))
                    success := and(
                        success,
                        staticcall(
                            gas(),
                            6,
                            0x00,
                            0x80,
                            PAIRING_LHS_X_LOC,
                            0x40
                        )
                    )
                }

                if iszero(success) {
                    mstore(0x0, EC_SCALAR_MUL_FAILURE_SELECTOR)
                    revert(0x00, 0x04)
                }
                mstore(PAIRING_PREAMBLE_SUCCESS_FLAG, success)
            }

            /**
             * PERFORM PAIRING
             */
            {
                // rhs paired with [1]_2
                // lhs paired with [x]_2

                mstore(0x00, mload(PAIRING_RHS_X_LOC))
                mstore(0x20, mload(PAIRING_RHS_Y_LOC))
                mstore(
                    0x40,
                    0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2
                ) // this is [1]_2
                mstore(
                    0x60,
                    0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed
                )
                mstore(
                    0x80,
                    0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b
                )
                mstore(
                    0xa0,
                    0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa
                )

                mstore(0xc0, mload(PAIRING_LHS_X_LOC))
                mstore(0xe0, mload(PAIRING_LHS_Y_LOC))
                mstore(0x100, mload(G2X_X0_LOC))
                mstore(0x120, mload(G2X_X1_LOC))
                mstore(0x140, mload(G2X_Y0_LOC))
                mstore(0x160, mload(G2X_Y1_LOC))

                success := staticcall(gas(), 8, 0x00, 0x180, 0x00, 0x20)
                mstore(PAIRING_SUCCESS_FLAG, success)
                mstore(RESULT_FLAG, mload(0x00))
            }
            if iszero(
                and(
                    and(
                        and(mload(PAIRING_SUCCESS_FLAG), mload(RESULT_FLAG)),
                        mload(PAIRING_PREAMBLE_SUCCESS_FLAG)
                    ),
                    mload(OPENING_COMMITMENT_SUCCESS_FLAG)
                )
            ) {
                mstore(0x0, PROOF_FAILURE_SELECTOR)
                revert(0x00, 0x04)
            }
            {
                mstore(0x00, 0x01)
                return(0x00, 0x20) // Proof succeeded!
            }
        }
    }
}

contract UltraVerifier is BaseUltraVerifier {
    function getVerificationKeyHash()
        public
        pure
        override(BaseUltraVerifier)
        returns (bytes32)
    {
        return UltraVerificationKey.verificationKeyHash();
    }

    function loadVerificationKey(
        uint256 vk,
        uint256 _omegaInverseLoc
    ) internal pure virtual override(BaseUltraVerifier) {
        UltraVerificationKey.loadVerificationKey(vk, _omegaInverseLoc);
    }
}
