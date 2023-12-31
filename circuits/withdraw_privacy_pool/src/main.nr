use dep::std::option::Option;
use dep::std;
use dep::std::hash::poseidon::bn254::hash_2;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::bjj;
use dep::utils;

mod smt;
global TREE_DEPTH: u32 = 20;

fn main(
    // private inputs
    private_key: Field,
    entry: [Field; 2],
    matching_entry: [Option<Field>; 2],
    smt_siblings: [Field; TREE_DEPTH],
    secret: Field,
    amount: u40,
    // the index of the commitment in the commitment tree
    index: Field,
    commitment_path: [Field; TREE_DEPTH],
    randomness: Field,
    recipient_pub_key: [u8; 32],
    // public inputs
    relay_fee: pub u40,
    recipient_pub_key_modulus: pub Field,
    blacklist_root: pub Field,
    commitments_root: pub Field,
    nullifier: pub Field,
    balance_old_clear: pub u40,
    balance_old_encrypted_1: pub Gaffine,
    balance_old_encrypted_2: pub Gaffine,
    balance_new_encrypted_1: pub Gaffine,
    balance_new_encrypted_2: pub Gaffine // TODO: need to add new balance for withdraw account and compute it in the circuit
) {
    // verify that the nullifier corresponds to a leaf in the commitments tree
    let commitment = hash_2([secret, amount as Field]);
    let computed_commitment_root = std::merkle::compute_merkle_root(commitment, index, commitment_path);
    assert(computed_commitment_root == commitments_root);

    // check that the commitment matches the entry: [key, value] pair
    assert(entry[0] == index);
    assert(entry[1] == 0); // 0 if not on blacklist, 1 if on blacklist

    // check that the nullifier is correct
    assert(nullifier == hash_2([secret, index]));

    // if there is no blacklist root, do not check membership
    if (blacklist_root != 0) {
        // verifies non-membership of the entry in the provided root to a SMT
        smt::verify(entry, matching_entry, smt_siblings, blacklist_root);
    }

    utils::assert_correct_clear_balance(
        private_key,
        balance_old_clear,
        balance_old_encrypted_1,
        balance_old_encrypted_2
    );

    assert(recipient_pub_key_modulus == bjj::from_rpr_le(recipient_pub_key));

    let new_balance = balance_old_clear + amount - relay_fee;
    utils::assert_correct_recipient_balance(
        recipient_pub_key,
        new_balance,
        randomness,
        balance_new_encrypted_1,
        balance_new_encrypted_2
    );
}

#[test]
fn test_verify_smt() {
    // check /hardhat/scripts/buildSmt.ts to see how inputs were generated
    let entry = [6, 0];
    let matching_entry = [Option::some(12), Option::some(1)];
    let mut siblings : [Field; TREE_DEPTH] = [0; TREE_DEPTH];
    siblings[0] = 10156843431765632938234799028080865273583905746116765084187298821282584587626;
    let root = 19092112316297991684143646062628200623803555545749222745894317610913627992357;

    smt::verify(entry, matching_entry, siblings, root);
}
