use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::utils;
use dep::bjj;

fn main(
    private_key: Field,
    randomness: Field,
    value: u40,
    /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
    balance_old_me_clear: u40,
    sender_pub_key: [u8; 32],
    // Public inputs
    sender_pub_key_modulus: pub Field,
    // account_address: pub Field, // can be removed with packed public keys
    relay_fee: pub u40,
    nonce: pub Field,
    old_balance_encrypted_1: pub Gaffine,
    old_balance_encrypted_2: pub Gaffine,
    encrypted_amount_1: pub Gaffine,
    encrypted_amount_2: pub Gaffine,
    new_balance_encrypted_1: pub Gaffine,
    new_balance_encrypted_2: pub Gaffine
) {
    let unpacked_sender_pub_key = utils::assert_private_key_matches_packed(private_key, sender_pub_key);
    assert(sender_pub_key_modulus == bjj::from_rpr_le(sender_pub_key));

    // the sender must have sufficient balance
    assert(value + relay_fee <= balance_old_me_clear);

    /* this is to deter potential front-running issue: ref https://crypto.stanford.edu/~buenz/papers/zether.pdf §3.1. 
    Here we adopt a simpler approach than the multistep approach proposed in the Zether paper, for a better UX: 
    an attacker who tries to DOS the sender should at least pay 1 token to either original sender or receiver. 
    The "1" threshold could be changed to ensure correct economic incentives, typically this should be at least 
    a multiple of the average gas price of a transfer transaction. another more straightforward solution to 
    front-running would be simply to do the homomorphic addition in the smart contract rather than the circuit, 
    but this is too expensive today on Ethereum, according to the Zeestar paper §III : 
    https://files.sri.inf.ethz.ch/website/papers/sp22-zeestar.pdf
    */
    assert(value >= 1);
    utils::assert_correct_clear_balance(
        private_key,
        balance_old_me_clear,
        old_balance_encrypted_1,
        old_balance_encrypted_2
    );

    // check that the encrypted amount is correct
    let encrypted_amount_computed = bjj::exp_elgamal_encrypt(unpacked_sender_pub_key, value - relay_fee, randomness);
    assert(encrypted_amount_computed.0.x == encrypted_amount_1.x);
    assert(encrypted_amount_computed.0.y == encrypted_amount_1.y);
    assert(encrypted_amount_computed.1.x == encrypted_amount_2.x);
    assert(encrypted_amount_computed.1.y == encrypted_amount_2.y);

    utils::assert_correct_new_balance_transfer(
        unpacked_sender_pub_key,
        balance_old_me_clear,
        new_balance_encrypted_1,
        new_balance_encrypted_2,
        value,
        relay_fee,
        0, // process fee is 0
        randomness
    );
}

#[test]
fn test() {
    let x = 1689864850468855828250823872708791511002885372117465812379247895436524654321621597677787;
    std::println(x);
}
