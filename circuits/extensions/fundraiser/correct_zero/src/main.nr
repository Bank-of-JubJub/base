use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std;
use dep::utils;
use dep::bjj;

// this circuit makes sure that when a fundraiser is created, the recipient's balance is 0. it is embedded in the elliptic curve
// so that contributors can homomophically add to the recipient's balance without knowing the recipient's private key.
fn main(
    randomness: Field,
    public_key: pub [u8; 32],
    encrypted_zero_1: pub Gaffine,
    encrypted_zero_2: pub Gaffine
) {
    utils::assert_correct_recipient_balance(public_key, 0, randomness, encrypted_zero_1, encrypted_zero_2);
}

#[test]
fn test_main() {
    let packed_public_key = [
        10, 243, 98, 149, 194, 177, 136, 53, 218, 142, 43, 58, 102, 53, 57, 248, 57, 104, 43, 122, 60, 215, 98, 173, 234, 220, 249, 31, 61, 4, 96, 154
    ];
    let randomness: Field = 168986485046885582825082387270879151100288537211746581237924789162159767775;

    let public_key = bjj::unpack_point(packed_public_key);
    let encrypted_zero = bjj::exp_elgamal_encrypt(public_key, 0, randomness);

    main(
        randomness,
        packed_public_key,
        encrypted_zero.0,
        encrypted_zero.1
    );
}
