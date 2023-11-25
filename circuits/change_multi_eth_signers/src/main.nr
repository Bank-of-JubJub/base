use dep::std;
use dep::bjj;
use dep::ecrecover;

fn main(pub_key_x: [[u8;32];10],
        pub_key_y: [[u8;32];10],
        signatures: [[u8; 64];10],
        threshold: u8,
        // public inputs
        eth_signers: pub [Field;10],
        hashed_message: pub [u8;32])
{
    let mut count = 0 as u8;
    for i in 0..10 {
        let address = ecrecover::ecrecover(pub_key_x[i], pub_key_y[i], signatures[i], hashed_message);
        if(eth_signers[i] != 0) {
            assert(address == eth_signers[i]);
            count += 1;
        }
    }
    assert(count >= threshold);
}

#[test]
fn test_main() {}
