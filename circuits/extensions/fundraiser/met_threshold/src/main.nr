use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std;
use dep::utils;
use dep::bjj;

// this circuit checks that the encrypted amount contributed to the fundraiser has met the threshold, without revealing the specific amount contributed
fn main(
    private_key: Field,
    decrypted_value: u40,
    // public inputs
    encrypted_value_1: pub Gaffine,
    encrypted_value_2: pub Gaffine,
    threshold: pub Field
) {
    utils::assert_correct_clear_balance(
        private_key,
        decrypted_value,
        encrypted_value_1,
        encrypted_value_2
    );
    assert(decrypted_value >= threshold as u40);
}

#[test]
fn test_main() {
    let private_key: Field = 2291123624948246627368989940774052753470489062495018070576418670157516550852;
    let decrypted_value = 999;
    let encrypted_value: (Gaffine, Gaffine) = (Gaffine::new(
            0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368,
            0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f
        ), Gaffine::new(
            0x1a71ea2eae3ddac2aac76373cbb880c5c6cc76e9d29807d82d05f3c85b5beabb,
            0x2a179ce3f5cbeec397a3d14154d38fae55ffc6163f89ff324171ead91f110ff5
        ));
    let threshold = 100;

    main(
        private_key,
        decrypted_value,
        encrypted_value.0,
        encrypted_value.1,
        threshold
    )
}
