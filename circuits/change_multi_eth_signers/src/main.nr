use dep::std;
use dep::bjj;

fn main(eth_pub_key_x: [[u8;32];10],
        eth_pub_key_y: [[u8;32];10],
        signatures: [Field;10],
        threshold: Field,
        // public inputs
        eth_signers: pub [Field;10],
        message_hash: pub [u8;32]) {
  // ecrecover each signer w/ pub key points, signature and message hash
  // assert it matches eth_signer
  // once threshold is reached, return true
}

#[test]
fn test_main() {

}
