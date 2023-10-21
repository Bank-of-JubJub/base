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

        sender_pub_key: pub [u8; 32], 
        recipient_pub_key: pub [u8; 32], 
        // account_address: pub Field, // can be removed with packed public keys
        process_fee: pub u40,
        relay_fee: pub u40,
        nonce: pub Field,
        balance_old_me_encrypted_1: pub Gaffine, 
        balance_old_me_encrypted_2: pub Gaffine,
        encrypted_amount_1: pub Gaffine,
        encrypted_amount_2: pub Gaffine,
        balance_new_me_encrypted_1: pub Gaffine, 
        balance_new_me_encrypted_2: pub Gaffine, 
    ){ 
    let computed_public_key = bjj::priv_to_pub_key(private_key);
    let unpacked_sender_pub_key = bjj::unpack_point(sender_pub_key);
    assert(computed_public_key.x == unpacked_sender_pub_key.x);
    assert(computed_public_key.y == unpacked_sender_pub_key.y);
    let unpacked_recipient_pub_key = bjj::unpack_point(recipient_pub_key);

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
    let decoded_value = bjj::exp_elgamal_decrypt(private_key, (balance_old_me_encrypted_1,balance_old_me_encrypted_2));
    // check that unencrypted balance of sender really corresponds to his encrypted balance
    assert((decoded_value.x == embedded_balance_old_me_clear.x) & (decoded_value.y == embedded_balance_old_me_clear.y)); 
 
    let balance_new_me_encrypted_computed = bjj::exp_elgamal_encrypt(unpacked_sender_pub_key, balance_old_me_clear - value - process_fee - relay_fee, randomness);
    // // checks that the new encrypted balance of sender is correct
    assert((balance_new_me_encrypted_computed.0.x==balance_new_me_encrypted_1.x) & 
            (balance_new_me_encrypted_computed.0.y==balance_new_me_encrypted_1.y) & 
            (balance_new_me_encrypted_computed.1.x==balance_new_me_encrypted_2.x) & 
            (balance_new_me_encrypted_computed.1.y==balance_new_me_encrypted_2.y)); 
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
    let value: u40 = 100;
    let old_balance = 10000;

    // public values
    let sender_pub_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_sender_pub_key = bjj::pack_point(sender_pub_key);
    let recipient_pub_key: Gaffine = bjj::priv_to_pub_key(2397698694665525209403000085013646741088197704326090841842743616643093564368); // bjj_priv_to_pub_key(private_key_to)
    let packed_recipient_pub_key = bjj::pack_point(recipient_pub_key);
    let process_fee: u40 = 5;
    let relay_fee: u40 = 5;
    
    let encrypted_amount = bjj::exp_elgamal_encrypt(recipient_pub_key, value - process_fee - relay_fee, randomness);
    let nonce = 5;

     let old_encrypted_balance : (Gaffine,Gaffine) = bjj::exp_elgamal_encrypt(sender_pub_key, old_balance, 1223911427385630814994881905088740515414339792865684838215099796087690786721);
     let new_balance_encrypted : (Gaffine,Gaffine) = bjj::exp_elgamal_encrypt(sender_pub_key, 9900, randomness);


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
        new balance_encrypted.0,
        new_balance_encrypted.1); 
}

fn abi_encode_encrypted_amount(first: Gaffine, second: Gaffine) -> [u8; 128]{
    let mut prehashed_nonce: [u8;128] = [0;128];
    for i in 0..128 {
      let first_quarter = first.x.to_le_bytes(32);
      let second_quarter = first.y.to_le_bytes(32);
      let third_quarter = second.x.to_le_bytes(32);
      let fourth_quarter = second.y.to_le_bytes(32);
        if(i as u8<32){
          prehashed_nonce[i] = first_quarter[i];
        } else if i as u8 < 64 {
          prehashed_nonce[i] = second_quarter[i];
        } else if i as u8 < 96 {
          prehashed_nonce[i] = third_quarter[i];
        } else {
          prehashed_nonce[i] = fourth_quarter[i];
        }
      }
      prehashed_nonce
}