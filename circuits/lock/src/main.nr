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
    lock_to_address_private: Field,
    // Public Inputs
    packed_public_key: pub [Field;32],
    lock_to_address: pub Field,
    relay_fee: pub u40,
    balance_old_encrypted_1: pub Gaffine,
    balance_old_encrypted_2: pub Gaffine,
    balance_new_encrypted_1: pub Gaffine,
    balance_new_encrypted_2: pub Gaffine
) {
    let bjj_affine = bjj::get_affine_curve();
    let base_pt = bjj::get_base_point();
    let mut packed_public_key_u8: [u8;32] = [0; 32];

    // for some reason nargo 0.17 and 0.18 is not able to verify the circuit without this type conversion
    for i in 0..32 {
        packed_public_key_u8[i] = packed_public_key[i] as u8;
    }
    let public_key = bjj::unpack_point(packed_public_key_u8);
    let embedded_balance_old_me_clear = bjj_affine.mul(balance_old_clear as Field, base_pt);
    let decoded_value = bjj::exp_elgamal_decrypt(
        private_key,
        (balance_old_encrypted_1, balance_old_encrypted_2)
    );

    // check that unencrypted balance of withdrawer really corresponds to his encrypted balance
    assert(
        (decoded_value.x == embedded_balance_old_me_clear.x)
        & (decoded_value.y == embedded_balance_old_me_clear.y)
    );

    // we encrypt the minted value with the minter's public key
    let new_balance_encrypted_computed = bjj::exp_elgamal_encrypt(public_key, balance_old_clear - relay_fee, randomness);
    assert(
        (new_balance_encrypted_computed.0.x == balance_new_encrypted_1.x)
        & (new_balance_encrypted_computed.0.y == balance_new_encrypted_1.y)
        & (new_balance_encrypted_computed.1.x == balance_new_encrypted_2.x)
        & (new_balance_encrypted_computed.1.y == balance_new_encrypted_2.y)
    );
    assert(lock_to_address_private == lock_to_address); // for clarity and to remove the unused variable warning
}

#[test]
fn test_lock() {
    let private_key: Field = 0x0510bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4;

    // see debug notebook for an example on how to compute those
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775;

    // see debug notebook for an example on how to compute those
    let public_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_public_key = bjj::pack_point(public_key);
    let mut packed_public_key_Field: [Field;32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    for i in 0..32 {
        packed_public_key_Field[i] = packed_public_key[i] as Field;
    }
    let balance: u40 = 1000;

    // let bjj_affine = bjj::get_affine_curve();
    let lock_to_address = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92265;
    let relay_fee: u40 = 1;

    let old_balance = bjj::exp_elgamal_encrypt(public_key, balance, randomness);
    let new_balance = bjj::exp_elgamal_encrypt(public_key, balance - relay_fee, randomness);

    std::println(new_balance.0);
    main(
        private_key,
        randomness,
        balance,
        lock_to_address,
        packed_public_key_Field,
        lock_to_address,
        relay_fee,
        old_balance.0,
        old_balance.1,
        new_balance.0,
        new_balance.1
    );
}
