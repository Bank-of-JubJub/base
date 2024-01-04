use dep::std::option::Option;
use dep::std;
use dep::std::hash::poseidon::bn254::hash_2;
use dep::std::hash::poseidon::bn254::hash_4;
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
    creation_timestamp: u32,
    commitment_path: [Field; TREE_DEPTH],
    randomness: Field,
    recipient_pub_key: [u8; 32],
    eth_pub_key_x: [u8; 32],
    eth_pub_key_y: [u8; 32],
    signature: [u8; 64],
    // public inputs
    relay_fee: pub u40,
    recipient_pub_key_modulus: pub Field,
    blacklist_root: pub Field,
    commitments_root: pub Field,
    nullifier: pub Field,
    encrypted_amount_1: pub Gaffine,
    encrypted_amount_2: pub Gaffine,
    process_fee: pub u40,
    output_commitment: pub Field,
    timestamp: pub Field
) {
    let hashed_message_calculated = compute_message_hash(recipient_pub_key, encrypted_amount_1, encrypted_amount_2);
    let address = ecrecover::ecrecover(
        eth_pub_key_x,
        eth_pub_key_y,
        signature,
        hashed_message_calculated
    );
    // verify that the nullifier corresponds to a leaf in the commitments tree
    let commitment = hash_4([address, input_amount as Field, timestamp as Field, secret]);
    let computed_commitment_root = compute_merkle_root(commitment, index, commitment_path);
    assert(computed_commitment_root == commitments_root);

    // verify that 24 hours have passed between commitment creation and nullification
    // this ensures that the commitment has time to be flagged and added to the blacklist
    let time_delay = creation_timestamp + 60 * 60 * 24;
    assert(timestamp as u32 >= time_delay);

    let output_commitment_computed = hash_4([new_eth_address, remaining_balance as Field, timestamp as Field, new_secret]);
    assert(output_commitment_computed == output_commitment);
    assert(remaining_balance + amount == input_amount);

    // check that the commitment matches the entry: [key, value] pair
    assert(entry[0] == index);
    assert(entry[1] == 0); // 0 if not on blacklist, 1 if on blacklist

    // check that the nullifier is correct
    assert(nullifier == hash_2([index, secret]));

    // verifies non-membership of the entry in the provided root to a SMT
    smt::verify(entry, matching_entry, smt_siblings, blacklist_root);

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

fn compute_message_hash(
    public_key: [u8;32],
    encrypted_amount_1: Gaffine,
    encrypted_amount_2: Gaffine
) -> [u8;32] {
    // TODO: need to convert the inputs into a string representation bc the string version
    // is what is hashed when signing

    // message is the concatenation of the recipient public key and the encrypted amount
    let mut message: [u8; 349] = [0; 349];

    let mut prefix_message = "Ethereum Signed Message:\n320";

    let mut prefix: [u8;29] = [0; 29];
    prefix[0] = 25.to_be_bytes(1)[0]; // this is \x19
    for i in 1..prefix.len() {
        prefix[i] = prefix_message.as_bytes()[i - 1];
    }
    let prefix_length = prefix.len();

    for i in 0..prefix_length {
        message[i] = prefix[i];
    }
    // let message_length: Field = 320;
    // TODO: add prefix to message
    // prefixedMessage = toBytes(`\x19Ethereum Signed Message:\n${message.length}${message}`)

    for i in 0..public_key.len() {
        message[i + prefix_length] = public_key[i];
    }

    let C1x = encrypted_amount_1.x.to_be_bytes(64);
    let C1y = encrypted_amount_1.y.to_be_bytes(64);
    let C2x = encrypted_amount_2.x.to_be_bytes(64);
    let C2y = encrypted_amount_2.y.to_be_bytes(64);

    let length = C1x.len();

    for i in 0..length {
        message[i + prefix_length + length] = C1x[i];
    }
    for i in 0..length {
        message[i + prefix_length + length * 2] = C1y[i];
    }
    for i in 0..length {
        message[i + prefix_length + length * 3] = C2x[i];
    }
    for i in 0..length {
        message[i + prefix_length + length * 4] = C2y[i];
    }
    std::println(message);

    std::hash::keccak256(message, 349)
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

    let signature = [
        228, 186, 97, 91, 219, 107, 135, 161, 33, 126, 124, 76, 15, 225, 175, 244, 156, 40, 54, 211, 47, 160, 66, 205, 94, 104, 183, 117, 152, 244, 225, 72, 41, 230, 44, 65, 236, 105, 114, 144, 68, 247, 69, 132, 48, 34, 245, 11, 17, 186, 216, 56, 83, 225, 129, 200, 152, 12, 222, 177, 71, 15, 79, 54, 28
    ];

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

    let timestamp: Field = 1704333451;

    let secret = 168986485046885582825082387270879151100288537211746581237924789162159767777;
    let new_secret = 168986485046885582825082387270879151100288537211746581237924789162159767778;
    let address = 0x844Aa7aE2DB9bEb52f0613E5742EC5Ce9E1371a6;
    let new_eth_address = 0x844Aa7aE2DB9bEb52f0613E5742EC5Ce9E1371a6;
    let nullifier = hash_2([0, secret]);
    let input_commitment = hash_4([address, input_amount as Field, timestamp, secret]);
    let output_commitment = hash_4([new_eth_address, remaining_balance as Field, timestamp, new_secret]);

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
    //     relay_fee,
    //     pub_key_modulus,
    //     blacklist_root,
    //     commitments_root,
    //     nullifier,
    //     encrypted_amount.0,
    //     encrypted_amount.1,
    //     process_fee,
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

#[test]
fn test_compute_message_hash() {
    let public_key: [u8;32] = [
        0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49, 0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15, 0x6b, 0xaa
    ];

    // let mut public_key_string: [u8; 64] = [0; 64];
    for i in 0..public_key.len() {
        let val = public_key[i] as Field;
        let bytes = val.to_le_bits(4);

        std::println(bytes);
    }

    // let asbytes = public_key_1.as_bytes();

    let encrypted_amount = (Gaffine {
        x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
        y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
    }, Gaffine {
        x: 0x20a08bc68201d32688f1ba415b168f1b78dfcb0af4c5c8741b8674d9aea97147,
        y: 0x137c478ed936487f6b0a7b850a256c8286c993a43f808ade344aa1dcccd2e126
    });

    // message is the concatenation of the public key and the encrypted amount
    let message_hash_computed = compute_message_hash(public_key, encrypted_amount.0, encrypted_amount.1);
    let message_hash = [
        226, 67, 35, 208, 253, 52, 103, 173, 60, 94, 95, 240, 146, 210, 105, 21, 146, 37, 214, 232, 77, 34, 156, 107, 112, 90, 60, 90, 189, 34, 253, 139
    ];
    for i in 0..message_hash.len() {
        assert(message_hash[i] == message_hash_computed[i]);
    }
    // assert(message_hash == message_hash_computed);
}
