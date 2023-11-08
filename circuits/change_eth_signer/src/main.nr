use dep::std;
use dep::bjj;

fn main(eth_pub_key_x: ,
        eth_pub_key_y: 
        signature: Field,
        // public inputs
        eth_signer: pub Field,
        message_hash: pub [u8;32]) {
  // ecrecover w/ pub key points, signature and message hash
  // assert it matches eth_signer
}

#[test]
fn test_main() {
    main(1, 2);

    // Uncomment to make test fail
    // main(1, 1);
}
