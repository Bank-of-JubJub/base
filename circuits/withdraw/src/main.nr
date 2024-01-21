/* Note: Exponential ElGamal only supports plaintexts constrained to 40 bits, 
because solving the Discrete Log is needed during decryption
It is the responsiblity of the smart contract developer to ensure 
that all plaintexts are in the u40 range before encryption
*/
use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::bjj;
use dep::utils;

// Code of the circuit used once at construction of the token to prove the correctness of encryption of the minted total supply.
// In this particular case, we are using a zkSNARK only for its succintness property, not the zk property, because total supply is publicly known.
// The alternative would have been to reimplement Baby JubJub encryption in the EVM onchain which is very gas-expensive and complex.
fn main(
    private_key: Field,
    randomness: Field,
    /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
    balance_old_clear: u40,
    nonce_private: Field,
    packed_public_key: [u8;32],
    // Public Inputs
    packed_public_key_modulus: pub Field,
    nonce: pub Field,
    value: pub u40,
    relay_fee: pub u40,
    balance_old_encrypted_1: pub Gaffine,
    balance_old_encrypted_2: pub Gaffine,
    balance_new_encrypted_1: pub Gaffine,
    balance_new_encrypted_2: pub Gaffine
) {
    let public_key = utils::assert_private_key_matches_packed(private_key, packed_public_key);
    assert(packed_public_key_modulus == bjj::from_rpr_le(packed_public_key));
    assert(value + relay_fee <= balance_old_clear);
    utils::assert_correct_clear_balance(
        private_key,
        balance_old_clear,
        balance_old_encrypted_1,
        balance_old_encrypted_2
    );
    utils::assert_correct_new_balance_withdraw(
        public_key,
        balance_old_clear,
        balance_new_encrypted_1,
        balance_new_encrypted_2,
        value,
        relay_fee,
        randomness
    );
    assert(nonce == nonce_private);
}

#[test]
fn test_withdraw() {
    // private values
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852;

    // see debug notebook for an example on how to compute those
    let randomness: Field = 0x5fa49918e16a3c3f4d42071a137c8a818964701c63604244ac2746b95e00df;

    // see debug notebook for an example on how to compute those
    let balance : u40 = 1000;

    // // public values
    let public_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_public_key = bjj::pack_point(public_key);
    let packed_public_key_modulus = bjj::from_rpr_le(packed_public_key);

    let value: u40 = 100;

    // the message being encrypted, should be a u40
    let relay_fee: u40 = 1;

    // the relay fee, should be a u40
    let old_encrypted_amount = bjj::exp_elgamal_encrypt(public_key, balance, randomness);
    let new_encrypted_amount = bjj::exp_elgamal_encrypt(public_key, balance - value - relay_fee, randomness);
    let nonce = 2;

    // compute in Solidity, keccak(encryped amt) % p
    main(
        private_key,
        randomness,
        balance,
        nonce,
        packed_public_key,
        packed_public_key_modulus,
        nonce,
        value,
        relay_fee,
        old_encrypted_amount.0,
        old_encrypted_amount.1,
        new_encrypted_amount.0,
        new_encrypted_amount.1
    );
}
