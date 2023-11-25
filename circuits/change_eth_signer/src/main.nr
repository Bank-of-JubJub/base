use dep::std;
use dep::bjj;
use dep::ecrecover;
fn main(pub_key_x: [u8;32],
        pub_key_y: [u8;32],
        signature: [u8; 64],
        // public inputs
        eth_signer: pub Field,
        hashed_message: pub [u8;32]) 
{
    let address = ecrecover::ecrecover(pub_key_x, pub_key_y, signature, hashed_message);
    assert(address == eth_signer);
}

#[test]
fn test_main() {
}
