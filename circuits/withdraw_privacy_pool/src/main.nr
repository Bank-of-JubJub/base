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
    let computed_commitment_root = compute_merkle_root(commitment, index, commitment_path);
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

// Returns the merkle root of the tree from the provided leaf, path indices, siblings with poseidon hash.
fn compute_merkle_root(leaf: Field, index: Field, siblings: [Field; TREE_DEPTH]) -> Field {
    let n = siblings.len();
    let index_bits = index.to_le_bits(n as u32);
    let mut current = leaf;
    for i in 0..n {
        let path_bit = index_bits[i] as bool;
        let (hash_left, hash_right) = if path_bit {
            (siblings[i], current)
        } else {
            (current, siblings[i])
        };
        current = std::hash::poseidon::bn254::hash_2([hash_left, hash_right]);
    }
    current
}

#[test]
fn test_main() {
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852;
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775;
    let amount: u40 = 5;
    let relay_fee: u40 = 1;
    let old_balance_clear = 0;

    // commitment
    let index = 0;
    let mut commitment_path : [Field; TREE_DEPTH] = [
        0,
        14744269619966411208579211824598458697587494354926760081771325075741142829156,
        7423237065226347324353380772367382631490014989348495481811164164159255474657,
        11286972368698509976183087595462810875513684078608517520839298933882497716792,
        3607627140608796879659380071776844901612302623152076817094415224584923813162,
        19712377064642672829441595136074946683621277828620209496774504837737984048981,
        20775607673010627194014556968476266066927294572720319469184847051418138353016,
        3396914609616007258851405644437304192397291162432396347162513310381425243293,
        21551820661461729022865262380882070649935529853313286572328683688269863701601,
        6573136701248752079028194407151022595060682063033565181951145966236778420039
, 12413880268183407374852357075976609371175688755676981206018884971008854919922
, 14271763308400718165336499097156975241954733520325982997864342600795471836726
, 20066985985293572387227381049700832219069292839614107140851619262827735677018
, 9394776414966240069580838672673694685292165040808226440647796406499139370960
, 11331146992410411304059858900317123658895005918277453009197229807340014528524
, 15819538789928229930262697811477882737253464456578333862691129291651619515538
, 19217088683336594659449020493828377907203207941212636669271704950158751593251,
        21035245323335827719745544373081896983162834604456827698288649288827293579666,
        6939770416153240137322503476966641397417391950902474480970945462551409848591,
        10941962436777715901943463195175331263348098796018438960955633645115732864202
    ];
    let commitments_root = 528424823345637765233459005028157123611466957747207540865748361023965664665;

    // balance setup
    let public_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_public_key = bjj::pack_point(public_key);
    let pub_key_modulus = bjj::from_rpr_le(packed_public_key);
    let old_balance_encrypted = bjj::exp_elgamal_encrypt(public_key, old_balance_clear, randomness);
    let new_balance_encrypted = bjj::exp_elgamal_encrypt(public_key, amount - relay_fee, randomness);

    let secret = 168986485046885582825082387270879151100288537211746581237924789162159767777;
    let nullifier = hash_2([secret, 0]);
    let commitment = hash_2([secret, amount as Field]);

    std::println("commitment:  ");
    std::println(commitment);

    // not on a blacklist
    let entry = [0, 0];
    let matching_entry = [Option::some(12), Option::some(1)];
    let mut siblings : [Field; TREE_DEPTH] = [0; TREE_DEPTH];
    siblings[0] = 10156843431765632938234799028080865273583905746116765084187298821282584587626;
    let blacklist_root = 19092112316297991684143646062628200623803555545749222745894317610913627992357;

    main(
        private_key,
        entry,
        matching_entry,
        siblings,
        secret,
        amount,
        index,
        commitment_path,
        randomness,
        packed_public_key,
        relay_fee,
        pub_key_modulus,
        blacklist_root,
        commitments_root,
        nullifier,
        old_balance_clear,
        old_balance_encrypted.0,
        old_balance_encrypted.1,
        new_balance_encrypted.0,
        new_balance_encrypted.1
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

