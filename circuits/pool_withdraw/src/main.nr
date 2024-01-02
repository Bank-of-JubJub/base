use dep::std::option::Option;
use dep::std;
use dep::std::hash::poseidon::bn254::hash_2;
use dep::std::hash::poseidon::bn254::hash_3;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::bjj;
use dep::utils;
use dep::ecrecover;

mod smt;
global TREE_DEPTH: u32 = 20;

fn main(
    // private inputs
    entry: [Field; 2],
    matching_entry: [Option<Field>; 2],
    smt_siblings: [Field; TREE_DEPTH],
    secret: Field,
    // amount to be withdrawn from the pool. relay and process fee will be taken from this amount
    amount: u40,
    // amount in the original commitment
    input_amount: u40,
    // input_amount - amount, amount remaining in the pool
    remaining_balance: u40,
    new_secret: Field,
    // can associate the new commitment with a new eth_address
    new_eth_address: Field,
    // the index of the commitment in the commitment tree
    index: Field,
    commitment_path: [Field; TREE_DEPTH],
    randomness: Field,
    recipient_pub_key: [u8; 32],
    eth_pub_key_x: [u8; 32],
    eth_pub_key_y: [u8; 32],
    signature: [u8; 64],
    hashed_message: [u8; 32],
    // public inputs
    relay_fee: pub u40,
    recipient_pub_key_modulus: pub Field,
    blacklist_root: pub Field,
    commitments_root: pub Field,
    nullifier: pub Field,
    encrypted_amount_1: pub Gaffine,
    encrypted_amount_2: pub Gaffine,
    process_fee: pub u40,
    // modulus so that hashed message fits in 1 public input element in the contract
    hashed_message_modulus: pub Field,
    output_commitment: pub Field
) {
    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
    let address = ecrecover::ecrecover(eth_pub_key_x, eth_pub_key_y, signature, hashed_message);
    // verify that the nullifier corresponds to a leaf in the commitments tree
    let commitment = hash_3([address, input_amount as Field, secret]);
    let computed_commitment_root = compute_merkle_root(commitment, index, commitment_path);
    assert(computed_commitment_root == commitments_root);

    let output_commitment_computed = hash_3([new_eth_address, remaining_balance as Field, new_secret]);
    assert(output_commitment_computed == output_commitment);
    assert(remaining_balance + amount == input_amount);

    // check that the commitment matches the entry: [key, value] pair
    assert(entry[0] == index);
    assert(entry[1] == 0); // 0 if not on blacklist, 1 if on blacklist

    // check that the nullifier is correct
    assert(nullifier == hash_2([index, secret]));

    // if there is no blacklist root, do not check membership
    if (blacklist_root != 0) {
        // verifies non-membership of the entry in the provided root to a SMT
        smt::verify(entry, matching_entry, smt_siblings, blacklist_root);
    }

    assert(recipient_pub_key_modulus == bjj::from_rpr_le(recipient_pub_key));

    let new_amount = amount - relay_fee - process_fee;
    utils::assert_correct_recipient_balance(
        recipient_pub_key,
        new_amount,
        randomness,
        encrypted_amount_1,
        encrypted_amount_2
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
    let amount: u40 = 10;
    let input_amount: u40 = 10;
    let amount: u40 = 5;
    let remaining_balance: u40 = 5;
    let relay_fee: u40 = 1;
    let process_fee: u40 = 2;

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
    let commitments_root = 6598509457608670666299136503868652005177457995065010418208814398647233618885;

    // balance setup
    let public_key: Gaffine = bjj::priv_to_pub_key(private_key);
    let packed_public_key = bjj::pack_point(public_key);
    let pub_key_modulus = bjj::from_rpr_le(packed_public_key);
    // let old_balance_encrypted = bjj::exp_elgamal_encrypt(public_key, old_balance_clear, randomness);
    let encrypted_amount = bjj::exp_elgamal_encrypt(public_key, amount - relay_fee - process_fee, randomness);

    std::println(encrypted_amount.0.x);
    std::println(encrypted_amount.0.y);
    std::println(encrypted_amount.1.x);
    std::println(encrypted_amount.1.y);

    let secret = 168986485046885582825082387270879151100288537211746581237924789162159767777;
    let new_secret = 168986485046885582825082387270879151100288537211746581237924789162159767778;
    let address = 0x844Aa7aE2DB9bEb52f0613E5742EC5Ce9E1371a6;
    let new_eth_address = 0x844Aa7aE2DB9bEb52f0613E5742EC5Ce9E1371a6;
    let nullifier = hash_2([0, secret]);
    let input_commitment = hash_3([address, input_amount as Field, secret]);
    let output_commitment = hash_3([new_eth_address, remaining_balance as Field, new_secret]);

    // not on a blacklist
    let entry = [0, 0];
    let matching_entry = [Option::some(12), Option::some(1)];
    let mut siblings : [Field; TREE_DEPTH] = [0; TREE_DEPTH];
    siblings[0] = 10156843431765632938234799028080865273583905746116765084187298821282584587626;
    let blacklist_root = 19092112316297991684143646062628200623803555545749222745894317610913627992357;
    // main(
    //     entry,
    //     matching_entry,
    //     siblings,
    //     secret,
    //     amount,
    //     input_amount,
    //     remaining_balance,
    //     new_secret,
    //     new_eth_address,
    //     index,
    //     commitment_path,
    //     randomness,
    //     packed_public_key,
    //     eth_pub_key_x,
    //     eth_pub_key_y,
    //     signature,
    //     hashed_message,
    //     relay_fee,
    //     pub_key_modulus,
    //     blacklist_root,
    //     commitments_root,
    //     nullifier,
    //     encrypted_amount.0,
    //     encrypted_amount.1,
    //     process_fee,
    //     hashed_message_modulus,
    //     output_commitment

    // );
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

