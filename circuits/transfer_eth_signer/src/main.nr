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
use dep::ecrecover;
use dep::utils;

/* Code of the circuit used at each transfer of the token to prove the validity of transfer (sender 
has enough balance) and correctness of encrypted new balances of sender.
*/

// TODO: Can remove nonce from the circuit and contract--it can be handled my the signed message
fn main(
    private_key: Field,
    randomness: Field,
    value: u40,
    /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
    balance_old_me_clear: u40,
    pub_key_x: [u8;32],
    pub_key_y: [u8;32],
    signature: [u8; 64],
    hashed_message: [u8;32],
    nonce_private: Field,
    // Public inputs
    sender_pub_key: pub [Field; 32],
    recipient_pub_key: pub [Field; 32],
    // account_address: pub Field, // can be removed with packed public keys
    process_fee: pub u40,
    relay_fee: pub u40,
    nonce: pub Field,
    old_balance_encrypted_1: pub Gaffine,
    old_balance_encrypted_2: pub Gaffine,
    encrypted_amount_1: pub Gaffine,
    encrypted_amount_2: pub Gaffine,
    new_balance_encrypted_1: pub Gaffine,
    new_balance_encrypted_2: pub Gaffine,
    eth_signer: pub Field, // eth Address of the signer
    hashed_message_modulus: pub Field // hash of the message to be signed
) {
    let unpacked_sender_pub_key = utils::assert_private_key_matches_packed(private_key, sender_pub_key);

    // the sender must have sufficient balance
    assert(value + process_fee + relay_fee <= balance_old_me_clear);

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

    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
    let address = ecrecover::ecrecover(pub_key_x, pub_key_y, signature, hashed_message);
    assert(address == eth_signer);

    // check that unencrypted balance of sender really corresponds to his encrypted balance
    utils::assert_correct_clear_balance(
        private_key,
        balance_old_me_clear,
        old_balance_encrypted_1,
        old_balance_encrypted_2
    );

    // checks that the new encrypted balance of sender is correct
    utils::assert_correct_new_balance_transfer(
        unpacked_sender_pub_key,
        balance_old_me_clear,
        new_balance_encrypted_1,
        new_balance_encrypted_2,
        value,
        relay_fee,
        process_fee,
        randomness
    );

    // check that the amount being transferred is correctly encrypted
    utils::assert_correct_recipient_balance(
        recipient_pub_key,
        value,
        randomness,
        encrypted_amount_1,
        encrypted_amount_2
    );
    assert(nonce == nonce_private);
}

// Because of a bug in Noir 10.3, this test will cause a stack overflow error, but you can check that it passes via `nargo prove` instead of `nargo test`: the values inside Prover.toml are strictly equivalent to this test
#[test]
fn test_transfer() {
    // private values
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852;

    // see debug notebook for an example on how to compute those
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775;

    // see debug notebook for an example on how to compute those
    let value: u40 = 5;
    let old_balance = 999;

    // public values
    // let sender_pub_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_sender_pub_key = [
        0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49,
        0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15,
        0x6b, 0xaa
    ];

    //generated via circomlibjs
    // let recipient_pub_key: Gaffine = bjj::priv_to_pub_key(2397698694665525209403000085013646741088197704326090841842743616643093564368); // bjj_priv_to_pub_key(private_key_to)
    let packed_recipient_pub_key = [
        0x0c, 0x07, 0x99, 0x9c, 0x15, 0xd4, 0x06, 0xbc, 0x08, 0xd7, 0xf3, 0xf3, 0x1f, 0x62, 0xce,
        0xdb, 0xc8, 0x9e, 0xbf, 0x3a, 0x53, 0xff, 0x4d, 0x3b, 0xf7, 0xe2, 0xd0, 0xdd, 0xa9, 0x31,
        0x49, 0x04
    ];

    let process_fee: u40 = 0;
    let relay_fee: u40 = 2;

    // let encrypted_amount = bjj::exp_elgamal_encrypt(recipient_pub_key, value - relay_fee - process_fee, randomness);
    // 5, ecrypted with recipient_pub_key
    let encrypted_amount : (Gaffine,Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x25bd68ade5a08a4a012250cff52bd6e92752413aacb5a01ef8157e7c65b1b1c6,
            0x22ce61a67a4ee826534fca1d6276fd1c80ff05a5831f90ce1c9f5963a6393e5f
        ));

    let nonce = 21791187112363609100120894565844832280298519926030489354388467102708178882956;

    // 999, encrypted with sender_pub_key
    let old_encrypted_balance : (Gaffine,Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x1a71ea2eae3ddac2aac76373cbb880c5c6cc76e9d29807d82d05f3c85b5beabb,
            0x2a179ce3f5cbeec397a3d14154d38fae55ffc6163f89ff324171ead91f110ff5
        ));

    //bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, randomness);
    // 992,  encrypted with sender_pub_key
    let new_balance_encrypted : (Gaffine,Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x2795109cf233e0d54d88f75d6c8b28b37ea224b6083e2f76efed55710e1fd425,
            0x3006aa76f9499aeee9080237f3c24005be7ca83627f6600f7b278dff77a37df5
        ));

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

    //bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, randomness);
    // let old_encrypted_balance : (Gaffine,Gaffine) = bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, randomness);
    // let new_balance_encrypted : (Gaffine,Gaffine) = bjj::exp_elgamal_encrypt(sender_pub_key, old_balance - process_fee - relay_fee - value, randomness);
    main(
        private_key,
        randomness,
        value,
        old_balance,
        pub_key_x,
        pub_key_y,
        signature,
        hashed_message,
        nonce,
        packed_sender_pub_key,
        packed_recipient_pub_key,
        process_fee,
        relay_fee,
        nonce,
        old_encrypted_balance.0,
        old_encrypted_balance.1,
        encrypted_amount.0,
        encrypted_amount.1,
        new_balance_encrypted.0,
        new_balance_encrypted.1,
        address,
        modulus
    );
}
