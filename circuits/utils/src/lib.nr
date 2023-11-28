use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::std::ec;
use dep::bjj;
use dep::ecrecover;

pub fn assert_valid_multisig<N>(pub_key_x: [[u8;32];N],
        pub_key_y: [[u8;32];N],
        signatures: [[u8; 64];N],
        hashed_message: [u8;32],
        threshold: u8,
        eth_signers: [Field;N],
        hashed_message_modulus: Field
        ){
    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
    let mut count = 0 as u8;
    for i in 0..N {
        let address = ecrecover::ecrecover(pub_key_x[i], pub_key_y[i], signatures[i], hashed_message);
        if (eth_signers[i] != 0) {
            assert(address == eth_signers[i]);
            count += 1;
        }
    }
    assert(count >= threshold);
} 

// #[test]
// fn test_main() {
//     main(1, 2);

//     // Uncomment to make test fail
//     // main(1, 1);
// }
