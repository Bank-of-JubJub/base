use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std;
use dep::utils;
use dep::bjj;

fn main(private_key: Field, public_key: pub [u8; 32]) {
    utils::assert_private_key_matches_packed(private_key, public_key);
}

// #[test]
// fn test_main() {
//     main(1, 2);
//     // Uncomment to make test fail
//     // main(1, 1);
// }
