use dep::std::option::Option;
use dep::std;
use dep::std::hash::poseidon::bn254::hash_3;
mod smt;
global TREE_DEPTH: u32 = 256;

fn main(
    // private inputs
    entry: [Field; 2],
    matching_entry: [Option<Field>; 2],
    smt_siblings: [Field; TREE_DEPTH],
    secret1: Field,
    secret2: Field,
    amount: Field,
    index: Field,
    commitment_path: [Field; TREE_DEPTH],
    // public inputs
    blacklist_root: pub Field,
    commitments_root: pub Field // nullifier_hash: pub Field
) {
    // verify that the nullifier corresponds to a leaf in the commitments tree
    let commitment = hash_3([secret1, secret2, amount]);
    let computed_commitment_root = std::merkle::compute_merkle_root(commitment, index, commitment_path);
    assert(computed_commitment_root == commitments_root);

    // check that the commitment matches the entry: [key, value] pair
    assert(entry[0] == index);
    assert(entry[1] == 0); // 0 if not on blacklist, 1 if on blacklist

    if (blacklist_root != 0) {
        // verifies non-membership of the entry in the provided root to a SMT
        smt::verify(entry, matching_entry, smt_siblings, blacklist_root);
    }
}

#[test]
fn test_main() {
    // check /hardhat/scripts/buildSmt.ts to see how inputs were generated
    let entry = [6, 0];
    let matching_entry = [Option::some(12), Option::some(1)];
    let mut siblings : [Field; TREE_DEPTH] = [0; TREE_DEPTH];
    siblings[19] = 10156843431765632938234799028080865273583905746116765084187298821282584587626;
    let root = 19092112316297991684143646062628200623803555545749222745894317610913627992357;

    main(entry, matching_entry, siblings, root);
}
