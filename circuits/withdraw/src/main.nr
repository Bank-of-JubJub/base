/* Note: Exponential ElGamal only supports plaintexts constrained to 40 bits, 
because solving the Discrete Log is needed during decryption
It is the responsiblity of the smart contract developer to ensure 
that all plaintexts are in the u40 range before encryption
*/
use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::noir_bigint::BigUint56;
use dep::bjj;

// Code of the circuit used once at construction of the token to prove the correctness of encryption of the minted total supply.
// In this particular case, we are using a zkSNARK only for its succintness property, not the zk property, because total supply is publicly known.
// The alternative would have been to reimplement Baby JubJub encryption in the EVM onchain which is very gas-expensive and complex.
fn main(private_key: Field, 
        randomness: Field, 
        /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
        balance_old_clear: u40,

        // Public Inputs
        nonce: pub Field,
        packed_public_key: pub [u8;32], 
        value: pub u40, 
        relay_fee: pub u40,
        balance_old_encrypted_1: pub Gaffine, 
        balance_old_encrypted_2: pub Gaffine,
        balance_new_encrypted_1: pub Gaffine, 
        balance_new_encrypted_2: pub Gaffine)
    { 
    let bjj_affine = bjj::get_affine_curve();
    let base_pt = bjj::get_base_point();
    let embedded_balance_old_me_clear = bjj_affine.mul(balance_old_clear as Field, base_pt);
    let decoded_value = bjj::exp_elgamal_decrypt(private_key, (balance_old_encrypted_1,balance_old_encrypted_2));
    // check that unencrypted balance of withdrawer really corresponds to his encrypted balance
    assert((decoded_value.x == embedded_balance_old_me_clear.x) & (decoded_value.y == embedded_balance_old_me_clear.y)); 
    let public_key = bjj::unpack_point(packed_public_key);
    // we encrypt the minted value with the minter's public key
    let new_balance_encrypted_computed = bjj::exp_elgamal_encrypt(public_key, balance_old_clear - value - relay_fee, randomness);
    assert((new_balance_encrypted_computed.0.x == balance_new_encrypted_1.x) & 
            (new_balance_encrypted_computed.0.y == balance_new_encrypted_1.y) & 
            (new_balance_encrypted_computed.1.x == balance_new_encrypted_2.x) & 
            (new_balance_encrypted_computed.1.y == balance_new_encrypted_2.y)); 
}

#[test]
fn test_withdraw() {
    // private values
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852; // see debug notebook for an example on how to compute those
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775; // see debug notebook for an example on how to compute those
    let balance : u40 = 1000;

    // // public values
    let public_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_public_key = bjj::pack_point(public_key);
    let value: u40 = 100; // the message being encrypted, should be a u40
    let relay_fee: u40 = 1; // the relay fee, should be a u40

    let old_encrypted_amount = bjj::exp_elgamal_encrypt(public_key, balance, randomness);
    let new_encrypted_amount = bjj::exp_elgamal_encrypt(public_key, balance - value - relay_fee, randomness);
    let nonce = 0; // compute in Solidity, keccak(encryped amt) % p

    main(private_key, randomness, balance, nonce, packed_public_key,value,relay_fee,old_encrypted_amount.0,old_encrypted_amount.1,new_encrypted_amount.0,new_encrypted_amount.1);  
}