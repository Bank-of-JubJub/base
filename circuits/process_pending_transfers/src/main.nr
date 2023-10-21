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
has enough balance) and correctness of encrypted new balances of sender and receiver.
To be sure this is not vulnerable, we added a check in the smart contract to make sure that sender
is different from receiver (a nonce variable is not needed in our case because transfers are 
initiated by from=msg.sender in the contract, so replay attack is impossible)
*/
fn main(// All Public inputs, this can be executed by anyone
        balance_old_to_encrypted_1: pub Gaffine, 
        balance_old_to_encrypted_2: pub Gaffine,
        balance_new_to_encrypted_1: pub Gaffine, 
        balance_new_to_encrypted_2: pub Gaffine,
        encrypted_values: pub [Gaffine; 8],
    ) { 

    // check that new balance = the balance_old_me_clear - fee
    let bjj_affine = bjj::get_affine_curve();
    
    let mut encrypted_value_sum = (encrypted_values[0], encrypted_values[1]);

    for i in 1..3 {
        let mut s = i*2;
        if(encrypted_values[s].x as Field != 0){
            encrypted_value_sum = (bjj_affine.add(encrypted_value_sum.0, encrypted_values[s]),bjj_affine.add(encrypted_value_sum.1, encrypted_values[s+1]));
        }
    }

    // addition of the points on Baby Jubjub : this operation is additevely homomorphic for Exponential ElGamal
    let balance_new_to_encrypted_computed = 
        (bjj_affine.add(balance_old_to_encrypted_1, encrypted_value_sum.0),bjj_affine.add(balance_old_to_encrypted_2, encrypted_value_sum.1)); 
    // checks that the new encrypted balance of receiver is correct
    assert((balance_new_to_encrypted_computed.0.x==balance_new_to_encrypted_1.x) & 
            (balance_new_to_encrypted_computed.0.y==balance_new_to_encrypted_1.y) & 
            (balance_new_to_encrypted_computed.1.x==balance_new_to_encrypted_2.x) & 
            (balance_new_to_encrypted_computed.1.y==balance_new_to_encrypted_2.y)); 
}

// Because of a bug in Noir 10.3, this test will cause a stack overflow error, but you can check that it passes via `nargo prove` instead of `nargo test`: the values inside Prover.toml are strictly equivalent to this test
#[test]
fn test_main() {
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852; // see debug notebook for an example on how to compute those
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775; // see debug notebook for an example on how to compute those
    let public_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let balance: u40 = 1000;
    let old_encrypted_amount = bjj::exp_elgamal_encrypt(public_key, balance, randomness);


    // public values
    let old_balance = bjj::exp_elgamal_encrypt(public_key, balance, randomness);
    let new_balance_encrypted = bjj::exp_elgamal_encrypt(public_key, balance+400, randomness);

    let encryped_value = bjj::exp_elgamal_encrypt(public_key, 100, randomness);
    let encryped_values = [encryped_value.0, encryped_value.1, encryped_value.0, encryped_value.1, encryped_value.0, encryped_value.1, encryped_value.0, encryped_value.1];
    main(old_encrypted_amount.0, old_encrypted_amount.1, new_balance_encrypted.0, new_balance_encrypted.1, encryped_values);
}