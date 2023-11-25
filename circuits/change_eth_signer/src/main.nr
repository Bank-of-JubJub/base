use dep::std;
use dep::bjj;
use dep::ecrecover;
fn main(pub_key_x: [u8;32],
        pub_key_y: [u8;32],
        signature: [u8; 64],
        hashed_message: pub [u8;32],
        // public inputs
        eth_signer: pub Field,
        hashed_message_modulus: pub Field,
        )
{
    let address = ecrecover::ecrecover(pub_key_x, pub_key_y, signature, hashed_message);
    assert(address == eth_signer);
    assert(hashed_message_modulus == bjj::from_rpr_le(hashed_message));
}

#[test]
fn test_main() {}

/// translated from here: https://github.com/iden3/ffjavascript/blob/d1cd4ae32170aedd000865f0828b78a15df6f06f/src/scalar.js#L215
/// and inspired by this: https://gist.github.com/signorecello/dad41f8b90ae48c7355bfd1f34f8885b
fn from_rpr_le(public_key: [u8;32]) -> Field {
  let mut y : Field = 0;
  let mut v : Field = 1;
  for i in 0..32 {
      y += public_key[i] as Field * v;
      v *= 256;
  }
  y
}