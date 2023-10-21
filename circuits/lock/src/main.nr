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

        public_key: pub Gaffine, 
        value: pub u40, 
        relay_fee: pub u40,
        balance_old_encrypted_1: pub Gaffine, 
        balance_old_encrypted_2: pub Gaffine,
        balance_new_encrypted_1: pub Gaffine, 
        balance_new_encrypted_2: pub Gaffine) 
    { 
    let bjj_affine: AffineCurve = AffineCurve::new(bjj_a, bjj_d, Gaffine::new(bjj_generator_x, bjj_generator_y));
    let base_pt: Gaffine = Gaffine::new(bjj_basept_x, bjj_basept_y);
    let embedded_balance_old_me_clear = bjj_affine.mul(balance_old_clear as Field, base_pt);
    let decoded_value = bjj::exp_elgamal_decrypt(private_key, (balance_old_encrypted_1,balance_old_encrypted_2));
    // check that unencrypted balance of withdrawer really corresponds to his encrypted balance
    assert((decoded_value.x == embedded_balance_old_me_clear.x) & (decoded_value.y == embedded_balance_old_me_clear.y)); 
    // we encrypt the minted value with the minter's public key
    let new_balance_encrypted_computed = bjj::exp_elgamal_encrypt(public_key, balance_old_clear - value - relay_fee, randomness);
    assert((new_balance_encrypted_computed.0.x == balance_new_encrypted_1.x) & 
            (new_balance_encrypted_computed.0.y == balance_new_encrypted_1.y) & 
            (new_balance_encrypted_computed.1.x == balance_new_encrypted_2.x) & 
            (new_balance_encrypted_computed.1.y == balance_new_encrypted_2.y)); 
}

#[test]
fn test_main() {
}


// fn bjj_priv_to_pub_key(private_key: Field) -> Gaffine
// {
//  // Define Baby Jubjub (ERC-2494) parameters in affine representation
//  let bjj_affine: AffineCurve = AffineCurve::new(bjj_a, bjj_d, Gaffine::new(bjj_generator_x, bjj_generator_y));
//  let base_pt: Gaffine = Gaffine::new(bjj_basept_x, bjj_basept_y);
//  bjj_affine.mul(private_key, base_pt)
// }

// fn bjj_exp_elgamal_encrypt(public_key: Gaffine, plaintext: Field, randomness: Field) -> (Gaffine,Gaffine) // same notations as in https://en.wikipedia.org/wiki/ElGamal_encryption 
// {
//  let bjj_affine: AffineCurve = AffineCurve::new(bjj_a, bjj_d, Gaffine::new(bjj_generator_x, bjj_generator_y));
//  let base_pt: Gaffine = Gaffine::new(bjj_basept_x, bjj_basept_y);
//  let C1: Gaffine = bjj_affine.mul(randomness, base_pt);
//  let plain_embedded: Gaffine = bjj_affine.mul(plaintext, base_pt);
//  let shared_secret: Gaffine = bjj_affine.mul(randomness, public_key);
//  let C2: Gaffine = bjj_affine.add(shared_secret, plain_embedded);
//  (C1,C2)
// }
// fn bjj_exp_elgamal_decrypt(private_key : Field, ciphertext: (Gaffine,Gaffine)) -> Gaffine
// {
//  let bjj_affine: AffineCurve = AffineCurve::new(bjj_a, bjj_d, Gaffine::new(bjj_generator_x,bjj_generator_y));
//  let shared_secret = bjj_affine.mul(private_key,ciphertext.0);
//  let plain_embedded = bjj_affine.subtract(ciphertext.1,shared_secret);
//  plain_embedded
// }