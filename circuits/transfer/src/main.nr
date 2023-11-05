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

/* Code of the circuit used at each transfer of the token to prove the validity of transfer (sender 
has enough balance) and correctness of encrypted new balances of sender.
*/

fn main(private_key: Field, 
        randomness: Field, 
        value: u40, 
        /* Balance_old_me_clear is the clear (i.e decrypted) balance of sender 
        this is computed offchain by solving the DLP with babygiant algorithm, 
        after calling bjj_exp_elgamal_decrypt with his private key */
        balance_old_me_clear: u40,

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
    ){ 
    let computed_public_key = bjj::priv_to_pub_key(private_key);
    let mut sender_pub_key_u8: [u8;32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; // for some reason nargo 0.17 and 0.18 is not able to verify the circuit without this type conversion
    for i in 0..32 {
        sender_pub_key_u8[i] = sender_pub_key[i] as u8;
    }

    let unpacked_sender_pub_key = bjj::unpack_point(sender_pub_key_u8);
    assert(computed_public_key.x == unpacked_sender_pub_key.x);
    assert(computed_public_key.y == unpacked_sender_pub_key.y);

    let mut recipient_pub_key_u8: [u8;32] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; // for some reason nargo 0.17 and 0.18 is not able to verify the circuit without this type conversion
    for i in 0..32 {
        recipient_pub_key_u8[i] = recipient_pub_key[i] as u8;
    }
    let unpacked_recipient_pub_key = bjj::unpack_point(recipient_pub_key_u8);

    // the sender must have sufficient balance
    assert(value<=balance_old_me_clear); 
    /* this is to deter potential front-running issue: ref https://crypto.stanford.edu/~buenz/papers/zether.pdf §3.1. 
    Here we adopt a simpler approach than the multistep approach proposed in the Zether paper, for a better UX: 
    an attacker who tries to DOS the sender should at least pay 1 token to either original sender or receiver. 
    The "1" threshold could be changed to ensure correct economic incentives, typically this should be at least 
    a multiple of the average gas price of a transfer transaction. another more straightforward solution to 
    front-running would be simply to do the homomorphic addition in the smart contract rather than the circuit, 
    but this is too expensive today on Ethereum, according to the Zeestar paper §III : 
    https://files.sri.inf.ethz.ch/website/papers/sp22-zeestar.pdf
    */
    assert(value>=1); 

    let bjj_affine = bjj::get_affine_curve();
    let base_pt = bjj::get_base_point();
    let embedded_balance_old_me_clear = bjj_affine.mul(balance_old_me_clear as Field, base_pt);
    let decoded_value = bjj::exp_elgamal_decrypt(private_key, (old_balance_encrypted_1,old_balance_encrypted_2));
    // check that unencrypted balance of sender really corresponds to his encrypted balance
    assert((decoded_value.x == embedded_balance_old_me_clear.x) & (decoded_value.y == embedded_balance_old_me_clear.y)); 
 
    let balance_new_me_encrypted_computed = bjj::exp_elgamal_encrypt(unpacked_sender_pub_key, balance_old_me_clear - value - process_fee - relay_fee, randomness);
    // // checks that the new encrypted balance of sender is correct
    assert((balance_new_me_encrypted_computed.0.x==new_balance_encrypted_1.x) & 
            (balance_new_me_encrypted_computed.0.y==new_balance_encrypted_1.y) & 
            (balance_new_me_encrypted_computed.1.x==new_balance_encrypted_2.x) & 
            (balance_new_me_encrypted_computed.1.y==new_balance_encrypted_2.y)); 
    // // check that the amount being transferred is correctly encrypted
    let encrypted_amount_computed = bjj::exp_elgamal_encrypt(unpacked_recipient_pub_key, value, randomness);
    assert((encrypted_amount_computed.0.x == encrypted_amount_1.x) &
            (encrypted_amount_computed.0.y == encrypted_amount_1.y) &
            (encrypted_amount_computed.1.x == encrypted_amount_2.x) &
            (encrypted_amount_computed.1.y == encrypted_amount_2.y));
    }

// Because of a bug in Noir 10.3, this test will cause a stack overflow error, but you can check that it passes via `nargo prove` instead of `nargo test`: the values inside Prover.toml are strictly equivalent to this test
#[test]
fn test_transfer() {
    // private values
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852; // see debug notebook for an example on how to compute those
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775; // see debug notebook for an example on how to compute those
    let value: u40 = 5;
    let old_balance = 999;

    // public values
    // let sender_pub_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_sender_pub_key = [0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49, 0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15, 0x6b, 0xaa];//generated via circomlibjs

    // let recipient_pub_key: Gaffine = bjj::priv_to_pub_key(2397698694665525209403000085013646741088197704326090841842743616643093564368); // bjj_priv_to_pub_key(private_key_to)
    let packed_recipient_pub_key = [0x0c, 0x07, 0x99, 0x9c, 0x15, 0xd4, 0x06, 0xbc, 0x08, 0xd7, 0xf3, 0xf3, 0x1f, 0x62, 0xce, 0xdb, 0xc8, 0x9e, 0xbf, 0x3a, 0x53, 0xff, 0x4d, 0x3b, 0xf7, 0xe2, 0xd0, 0xdd, 0xa9, 0x31, 0x49, 0x04];

    let process_fee: u40 = 1;
    let relay_fee: u40 = 2;
    

    // let encrypted_amount = bjj::exp_elgamal_encrypt(recipient_pub_key, value - relay_fee - process_fee, randomness);

// 5, ecrypted with recipient_pub_key 
        let encrypted_amount : (Gaffine,Gaffine) = 
    (Gaffine::new(0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368, 
    0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f), 
    Gaffine::new(0x25bd68ade5a08a4a012250cff52bd6e92752413aacb5a01ef8157e7c65b1b1c6, 
    0x22ce61a67a4ee826534fca1d6276fd1c80ff05a5831f90ce1c9f5963a6393e5f));
    
    let nonce = 21791187112363609100120894565844832280298519926030489354388467102708178882956;

 // 999, encrypted with sender_pub_key 
    let old_encrypted_balance : (Gaffine,Gaffine) = 
    (Gaffine::new(0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368, 
    0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f), 
    Gaffine::new(0x1a71ea2eae3ddac2aac76373cbb880c5c6cc76e9d29807d82d05f3c85b5beabb, 
    0x2a179ce3f5cbeec397a3d14154d38fae55ffc6163f89ff324171ead91f110ff5)) ; //bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, randomness);

// 991,  encrypted with sender_pub_key 
    let new_balance_encrypted : (Gaffine,Gaffine) = 
    (Gaffine::new(0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368, 
    0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f), 
    Gaffine::new(0x0e1e666f8f0b88b8f95cf51f00175a83a338557351c4c34da8cf4049a5adc77c, 
    0x2271fba8cd2dc38d663006ae7ca0c3ab9a5cdc842d98ac39878e271208827b5d)) ; //bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, randomness);


    // let old_encrypted_balance : (Gaffine,Gaffine) = bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, randomness);
    // let new_balance_encrypted : (Gaffine,Gaffine) = bjj::exp_elgamal_encrypt(sender_pub_key, old_balance - process_fee - relay_fee - value, randomness);


    // std::println(encrypted_amount.0);
    // std::println(encrypted_amount.1);
    // std::println(new_balance_encrypted.0);
    // std::println(new_balance_encrypted.1);

    main(private_key,randomness, 
        value, 
        old_balance, 
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
        new_balance_encrypted.1); 
}
