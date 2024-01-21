use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::std::ec;
use dep::bjj;
use dep::ecrecover;

pub fn assert_valid_multisig<N>(pub_key_x: [[u8;32];N],
        pub_key_y: [[u8;32];N],
        signatures: [[u8; 64];N],
        hashed_message: [u8;32],
        threshold: u8,
        eth_signers: [Field;N],
        hashed_message_modulus: Field
        ){
    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
    let mut count = 0 as u8;
    for i in 0..N {
        let address = ecrecover::ecrecover(pub_key_x[i], pub_key_y[i], signatures[i], hashed_message);
        if (eth_signers[i] != 0) {
            assert(address == eth_signers[i]);
            count += 1;
        }
    }
    assert(count >= threshold);
} 

pub fn assert_correct_clear_balance(private_key: Field, balance_old_me_clear: u40, old_balance_encrypted_1: Gaffine, old_balance_encrypted_2: Gaffine )
{
    let bjj_affine = bjj::get_affine_curve();
    let base_pt = bjj::get_base_point();
    let embedded_balance_old_me_clear = bjj_affine.mul(balance_old_me_clear as Field, base_pt);
    let decoded_value = bjj::exp_elgamal_decrypt(private_key, (old_balance_encrypted_1, old_balance_encrypted_2));

    // check that unencrypted balance of sender really corresponds to his encrypted balance
    assert((decoded_value.x == embedded_balance_old_me_clear.x) & (decoded_value.y == embedded_balance_old_me_clear.y));
}

pub fn assert_private_key_matches_packed(private_key: Field, packed_key: [u8;32]) -> Gaffine {
    let computed_public_key = bjj::priv_to_pub_key(private_key);
    let unpacked_sender_pub_key = bjj::unpack_point(packed_key);
    assert(computed_public_key.x == unpacked_sender_pub_key.x);
    assert(computed_public_key.y == unpacked_sender_pub_key.y);
    unpacked_sender_pub_key
}

pub fn assert_correct_new_balance_withdraw(public_key: Gaffine, balance_old_clear: u40, balance_new_encrypted_1: Gaffine, balance_new_encrypted_2: Gaffine, value: u40, relay_fee: u40, randomness:Field){
    let new_balance_encrypted_computed = bjj::exp_elgamal_encrypt(public_key, balance_old_clear - value - relay_fee, randomness);
    assert((new_balance_encrypted_computed.0.x == balance_new_encrypted_1.x) & (new_balance_encrypted_computed.0.y == balance_new_encrypted_1.y) & (new_balance_encrypted_computed.1.x == balance_new_encrypted_2.x) & (new_balance_encrypted_computed.1.y == balance_new_encrypted_2.y));
}

pub fn assert_correct_new_balance_transfer(public_key: Gaffine, balance_old_clear: u40, balance_new_encrypted_1: Gaffine, balance_new_encrypted_2: Gaffine, value: u40, relay_fee: u40, process_fee:u40,  randomness:Field){
    let new_balance_encrypted_computed = bjj::exp_elgamal_encrypt(public_key, balance_old_clear - value - process_fee - relay_fee, randomness);
    assert((new_balance_encrypted_computed.0.x == balance_new_encrypted_1.x) & (new_balance_encrypted_computed.0.y == balance_new_encrypted_1.y) & (new_balance_encrypted_computed.1.x == balance_new_encrypted_2.x) & (new_balance_encrypted_computed.1.y == balance_new_encrypted_2.y));
}

pub fn assert_correct_recipient_balance(recipient_pub_key: [u8;32], value: u40, randomness:Field, encrypted_amount_1: Gaffine, encrypted_amount_2:Gaffine){
    let unpacked_recipient_pub_key = bjj::unpack_point(recipient_pub_key);
    // // check that the amount being transferred is correctly encrypted
    let encrypted_amount_computed = bjj::exp_elgamal_encrypt(unpacked_recipient_pub_key, value, randomness);
    assert((encrypted_amount_computed.0.x == encrypted_amount_1.x) & (encrypted_amount_computed.0.y == encrypted_amount_1.y) & (encrypted_amount_computed.1.x == encrypted_amount_2.x) & (encrypted_amount_computed.1.y == encrypted_amount_2.y));
}

// #[test]
// fn test_main() {
//     main(1, 2);

//     // Uncomment to make test fail
//     // main(1, 1);
// }
