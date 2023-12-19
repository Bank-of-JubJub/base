/* Note: Exponential ElGamal only supports plaintexts constrained to 40 bits, 
because solving the Discrete Log is needed during decryption
It is the responsiblity of the smart contract developer to ensure 
that all plaintexts are in the u40 range before encryption
*/
use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::utils;
use dep::bjj;

/* Code of the circuit used at each transfer of the token to prove the validity of transfer (sender 
has enough balance) and correctness of encrypted new balances of sender.
*/
fn main(
    private_key: Field,
    randomness1: Field,
    randomness2: Field,
    value: u40,
    /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
    balance_old_me_clear: u40,
    nonce_private: Field,
    sender_pub_key: [u8; 32],
    recipient_pub_key: [u8; 32],
    // Public inputs
    sender_pub_key_modulus: pub Field,
    recipient_pub_key_modulus: pub Field,
    // account_address: pub Field, // can be removed with packed public keys
    process_fee: pub u40,
    relay_fee: pub u40,
    nonce: pub Field,
    old_balance_encrypted_1: pub Gaffine,
    old_balance_encrypted_2: pub Gaffine,
    encrypted_amount_1: pub Gaffine,
    encrypted_amount_2: pub Gaffine,
    new_balance_encrypted_1: pub Gaffine,
    new_balance_encrypted_2: pub Gaffine
) {
    assert(nonce == nonce_private);

    let unpacked_sender_pub_key = utils::assert_private_key_matches_packed(private_key, sender_pub_key);

    assert(sender_pub_key_modulus == bjj::from_rpr_le(sender_pub_key));
    assert(recipient_pub_key_modulus == bjj::from_rpr_le(recipient_pub_key));

    // the sender must have sufficient balance
    assert(value + relay_fee + process_fee <= balance_old_me_clear);

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
    utils::assert_correct_new_balance_transfer(
        unpacked_sender_pub_key,
        balance_old_me_clear,
        new_balance_encrypted_1,
        new_balance_encrypted_2,
        value,
        relay_fee,
        process_fee,
        randomness1
    );
    utils::assert_correct_recipient_balance(
        recipient_pub_key,
        value,
        randomness2,
        encrypted_amount_1,
        encrypted_amount_2
    );
}

// Because of a bug in Noir 10.3, this test will cause a stack overflow error, but you can check that it passes via `nargo prove` instead of `nargo test`: the values inside Prover.toml are strictly equivalent to this test
#[test]
fn test_transfer() {
    // private values
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852;
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775;
    let value: u40 = 5;
    let old_balance = 999;

    // public values
    let packed_sender_pub_key = [
        0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49,
        0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15,
        0x6b, 0xaa
    ];
    let sender_pub_key_modulus = bjj::from_rpr_le(packed_sender_pub_key);

    let packed_recipient_pub_key = [
        10, 243, 98, 149, 194, 177, 136, 53, 218, 142, 43, 58, 102, 53, 57, 248, 57, 104, 43, 122, 60, 215, 98, 173, 234, 220, 249, 31, 61, 4, 96, 154
    ];
    let recipient_pub_key_modulus = bjj::from_rpr_le(packed_recipient_pub_key);

    let process_fee: u40 = 1;
    let relay_fee: u40 = 2;

    // let encrypted_amount = bjj::exp_elgamal_encrypt(recipient_unpacked, value, randomness);
    let encrypted_amount: (Gaffine, Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x0a7408fe2fb42871d459d1931021c11491a98aa9c8a075f8f3c8ba2a331d8cb7,
            0x2c2caa69447987232133fec94c85ed8859bf70789741c53ab5fa7e86039e2f22
        ));

    let nonce = 21791187112363609100120894565844832280298519926030489354388467102708178882956;

    // let old_encrypted_balance = bjj::exp_elgamal_encrypt(sender_unpacked, old_balance, randomness);
    let old_encrypted_balance: (Gaffine, Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x1a71ea2eae3ddac2aac76373cbb880c5c6cc76e9d29807d82d05f3c85b5beabb,
            0x2a179ce3f5cbeec397a3d14154d38fae55ffc6163f89ff324171ead91f110ff5
        ));
    // let new_balance_encrypted = bjj::exp_elgamal_encrypt(sender_unpacked, old_balance - process_fee - relay_fee - value, randomness);

    let new_balance_encrypted: (Gaffine, Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x2795109cf233e0d54d88f75d6c8b28b37ea224b6083e2f76efed55710e1fd425,
            0x3006aa76f9499aeee9080237f3c24005be7ca83627f6600f7b278dff77a37df5
        ));

    //    std::println( encrypted_amount.0);
    // std::println(encrypted_amount.1);
    main(
        private_key,
        randomness,
        randomness,
        value,
        old_balance,
        nonce,
        packed_sender_pub_key,
        packed_recipient_pub_key,
        sender_pub_key_modulus,
        recipient_pub_key_modulus,
        process_fee,
        relay_fee,
        nonce,
        old_encrypted_balance.0,
        old_encrypted_balance.1,
        encrypted_amount.0,
        encrypted_amount.1,
        new_balance_encrypted.0,
        new_balance_encrypted.1
    );
}
