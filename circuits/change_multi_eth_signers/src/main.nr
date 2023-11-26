use dep::std;
use dep::bjj;
use dep::ecrecover;

fn main(pub_key_x: [[u8;32];10],
        pub_key_y: [[u8;32];10],
        signatures: [[u8; 64];10],
        hashed_message: pub [u8;32],

        // public inputs
        threshold: pub u8,
        eth_signers: pub [Field;10],
        hashed_message_modulus: pub Field,
)
{
    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
    let mut count = 0 as u8;
    for i in 0..10 {
        let address = ecrecover::ecrecover(pub_key_x[i], pub_key_y[i], signatures[i], hashed_message);
        if (eth_signers[i] != 0) {
            assert(address == eth_signers[i]);
            count += 1;
        }
    }
    assert(count >= threshold);
}

#[test]
fn test_main() {
        let hashed_message = [74, 92, 93, 69, 71, 33, 187, 187, 37, 84, 12, 51, 23, 82, 30, 113, 195, 115, 174, 54, 69,
        143, 150, 13, 42, 212, 110, 240, 136, 17, 14, 149];
    let signature = [247, 85, 217, 167, 45, 91, 115, 134, 118, 94, 127, 14, 131, 58, 246, 135, 149, 183, 57, 162,
        103, 18, 45, 174, 147, 63, 65, 183, 129, 181, 174, 208, 98, 108, 227, 38, 51, 8, 235, 212,
        195, 123, 237, 132, 49, 155, 102, 218, 39, 148, 54, 135, 113, 4, 104, 37, 189, 137, 185,
        139, 166, 140, 78, 135];
    let pub_key_x = [131, 24, 83, 91, 84, 16, 93, 74, 122, 174, 96, 192, 143, 196, 95, 150, 135, 24, 27, 79, 223,
        198, 37, 189, 26, 117, 63, 167, 57, 127, 237, 117];
    let pub_key_y = [53, 71, 241, 28, 168, 105, 102, 70, 242, 243, 172, 176, 142, 49, 1, 106, 250, 194, 62, 99,
        12, 93, 17, 245, 159, 97, 254, 245, 123, 13, 42, 165];
    let modulus = bjj::from_rpr_le(hashed_message);
    let threshold = 6 as u8;
    let address = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 as Field;


    let mut pub_key_xs = [[0 as u8;32];10];
    let mut pub_key_ys = [[0 as u8;32];10];
    let mut signatures = [[0 as u8;64];10];

    let mut addresses = [0 as Field;10];
    for i in 0..10 {
        addresses[i] = address;
        pub_key_xs[i] = pub_key_x;
        pub_key_ys[i] = pub_key_y;
        signatures[i] = signature;
    }

    main(pub_key_xs, pub_key_ys, signatures,hashed_message, threshold,  addresses, modulus);
}
