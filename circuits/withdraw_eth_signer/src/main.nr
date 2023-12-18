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
use dep::ecrecover;

// Code of the circuit used once at construction of the token to prove the correctness of encryption of the minted total supply.
// In this particular case, we are using a zkSNARK only for its succintness property, not the zk property, because total supply is publicly known.
// The alternative would have been to reimplement Baby JubJub encryption in the EVM onchain which is very gas-expensive and complex.

// TODO: Can remove nonce from the circuit and contract--it can be handled my the signed message

fn main(
    private_key: Field,
    randomness: Field,
    /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
    balance_old_clear: u40,
    pub_key_x: [u8;32],
    pub_key_y: [u8;32],
    signature: [u8; 64],
    hashed_message: pub [u8;32],
    nonce_priv: Field,
    packed_public_key: [u8;32],
    // Public Inputs
    packed_public_key_modulus: pub Field,
    nonce: pub Field,
    value: pub u40,
    relay_fee: pub u40,
    balance_old_encrypted_1: pub Gaffine,
    balance_old_encrypted_2: pub Gaffine,
    balance_new_encrypted_1: pub Gaffine,
    balance_new_encrypted_2: pub Gaffine,
    eth_signer: pub Field, // eth Address of the signer
    hashed_message_modulus: pub Field // hash of the message to be signed
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

    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
    let address = ecrecover::ecrecover(pub_key_x, pub_key_y, signature, hashed_message);
    assert(address == eth_signer);

    assert(nonce_priv == nonce); // for clarity and to remove the unused variable warning
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

    let hashed_message = [
        74, 92, 93, 69, 71, 33, 187, 187, 37, 84, 12, 51, 23, 82, 30, 113, 195, 115, 174, 54, 69,
        143, 150, 13, 42, 212, 110, 240, 136, 17, 14, 149
    ];
    let signature = [
        247, 85, 217, 167, 45, 91, 115, 134, 118, 94, 127, 14, 131, 58, 246, 135, 149, 183, 57, 162,
        103, 18, 45, 174, 147, 63, 65, 183, 129, 181, 174, 208, 98, 108, 227, 38, 51, 8, 235, 212,
        195, 123, 237, 132, 49, 155, 102, 218, 39, 148, 54, 135, 113, 4, 104, 37, 189, 137, 185,
        139, 166, 140, 78, 135
    ];
    let pub_key_x = [
        131, 24, 83, 91, 84, 16, 93, 74, 122, 174, 96, 192, 143, 196, 95, 150, 135, 24, 27, 79, 223,
        198, 37, 189, 26, 117, 63, 167, 57, 127, 237, 117
    ];
    let pub_key_y = [
        53, 71, 241, 28, 168, 105, 102, 70, 242, 243, 172, 176, 142, 49, 1, 106, 250, 194, 62, 99,
        12, 93, 17, 245, 159, 97, 254, 245, 123, 13, 42, 165
    ];
    let modulus = bjj::from_rpr_le(hashed_message);
    let address = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 as Field;

    main(
        private_key,
        randomness,
        balance,
        pub_key_x,
        pub_key_y,
        signature,
        hashed_message,
        nonce,
        packed_public_key,
        packed_public_key_modulus,
        nonce,
        value,
        relay_fee,
        old_encrypted_amount.0,
        old_encrypted_amount.1,
        new_encrypted_amount.0,
        new_encrypted_amount.1,
        address,
        modulus
    );
}
