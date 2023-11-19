use dep::std;
use dep::bjj;

fn main(eth_pub_key_x: [u8;32],
        eth_pub_key_y: [u8;32],
        signature: Field,
        // public inputs
        eth_signer: pub Field,
        message_hash: pub [u8;32]) {
  // ecrecover w/ pub key points, signature and message hash
  // assert it matches eth_signer
}

#[test]
fn test_main() {
}
