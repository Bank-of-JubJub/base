use dep::std;
use dep::bjj;

fn main(
    private_key: Field,
    // public inputs
    packed_public_key_modulus: pub Field,
    nonce: pub Field
) {
    let computed_public_key = bjj::priv_to_pub_key(private_key);
    let computed_packed = bjj::pack_point(computed_public_key);
    assert(nonce == nonce);
    // let computed_packed_int = from_rpr_le(computed_packed);
    assert(bjj::from_rpr_le(computed_packed) == packed_public_key_modulus);
}

#[test]
fn test_main() {
    let private_key = 2291123624948246627368989940774052753470489062495018070576418670157516550852;
    let packed_sender_pub_key = [
        0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49,
        0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15,
        0x6b, 0xaa
    ];

    let modulus = bjj::from_rpr_le(packed_sender_pub_key);

    //generated via circomlibjs
    let nonce = 1;

    main(private_key, modulus, nonce);
}
