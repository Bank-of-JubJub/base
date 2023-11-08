use dep::std;
use dep::bjj;
global p = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

fn main(private_key: Field,
        // public inputs
        packed_public_key_mod: pub Field,
        nonce: pub Field) {
    let computed_public_key = bjj::priv_to_pub_key(private_key);
    let packed = bjj::pack_point(computed_public_key);
    assert(packed_public_key_mod == packed % p);
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}
