use dep::std::ec::tecurve::affine::Curve as AffineCurve;
use dep::std::ec::tecurve::affine::Point as Gaffine;
use dep::std::collections::vec::Vec;
use dep::std;
use dep::biguint::BigUint56;
use dep::std::ec;

global bjj_a = 168700;
global bjj_d = 168696;
global bjj_generator_x = 995203441582195749578291179787384436505546430278305826713579947235728471134;
global bjj_generator_y = 5472060717959818805561601436314318772137091100104008585924551046643952123905;
global bjj_basept_x    = 5299619240641551281634865583518297030282874472190772894086521144482721001553;
global bjj_basept_y    = 16950150798460657717958625567821834550301663161624707787222815936182638968203;
global pm1d2           = 10944121435919637611123202872628637544274182200208017171849102093287904247808;
// from here: https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/babyjub.js#L11C37-L11C114
global p = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

fn get_affine_curve() -> AffineCurve {
  AffineCurve::new(bjj_a, bjj_d, Gaffine::new(bjj_generator_x, bjj_generator_y))
}

fn get_base_point() -> Gaffine {
  Gaffine::new(bjj_basept_x, bjj_basept_y)
}

fn priv_to_pub_key(private_key: Field) -> Gaffine
{
 // Define Baby Jubjub (ERC-2494) parameters in affine representation
 let bjj_affine = get_affine_curve();
 let base_pt = get_base_point();
 bjj_affine.mul(private_key, base_pt)
}

fn exp_elgamal_encrypt(public_key: Gaffine, plaintext: u40, randomness: Field) -> (Gaffine,Gaffine) // same notations as in https://en.wikipedia.org/wiki/ElGamal_encryption 
{
 let bjj_affine = get_affine_curve();
 let base_pt = get_base_point();
 let C1: Gaffine = bjj_affine.mul(randomness, base_pt);
 let plain_embedded: Gaffine = bjj_affine.mul(plaintext as Field, base_pt);
 let shared_secret: Gaffine = bjj_affine.mul(randomness, public_key);
 let C2: Gaffine = bjj_affine.add(shared_secret, plain_embedded);
 (C1,C2)
}

fn exp_elgamal_decrypt(private_key : Field, ciphertext: (Gaffine,Gaffine)) -> Gaffine
{
 let bjj_affine = get_affine_curve();
 let shared_secret = bjj_affine.mul(private_key,ciphertext.0);
 let plain_embedded = bjj_affine.subtract(ciphertext.1,shared_secret);
 plain_embedded
}

// another ref: https://github.com/iden3/go-iden3-crypto/blob/master/babyjub/babyjub.go#L250
pub fn unpack_point(mut public_key: [u8; 32]) -> Gaffine 
{
  let mut point: Gaffine = Gaffine::new(0,0);
  let mut sign = false;
  if((public_key[31] & 0x80) != 0) {
    sign = true;
    public_key[31] &= 0x7f;
  }
  point.y = from_rpr_le(public_key);
  // assert point.y < p
  assert(BigUint56::from_bytes(point.y.to_le_bytes(32))
          .gt(BigUint56::from_bytes(p.to_le_bytes(32))));  
 
  let mut y2 = point.y * point.y;

  let xa = 1-y2;
  let xb = bjj_a - (bjj_d * y2);

  let x2 = xa / xb;
  point.x = ec::sqrt(x2);

  // if(sign) {
  //   point.x = p - point.x;
  // } 
  point
}

// from here: https://github.com/iden3/circomlibjs/blob/4f094c5be05c1f0210924a3ab204d8fd8da69f49/src/babyjub.js#L97
// This matches circomlibjs
fn pack_point(public_key: Gaffine) -> [u8;32] {
  let mut array: [u8;32] = [0;32];
  let mut y = public_key.y.to_le_bytes(32);
  for i in 0..32 {
    array[i] = y[i];
  }

  let pm1d2 = (p - 1) / 2;
  if(BigUint56::from_bytes(public_key.x.to_le_bytes(32))
      .gt(BigUint56::from_bytes(pm1d2.to_le_bytes(32))))
  {
    array[31] = array[31] | 0x80;
  }

  array
}

// translated from here: https://github.com/iden3/ffjavascript/blob/d1cd4ae32170aedd000865f0828b78a15df6f06f/src/scalar.js#L215
// and inspired by this: https://gist.github.com/signorecello/dad41f8b90ae48c7355bfd1f34f8885b
fn from_rpr_le(public_key: [u8;32]) -> Field {
  let mut y : Field = 0;
  let mut v : Field = 1;
  for i in 0..32 {
      y += public_key[i] as Field * v;
      v *= 256;
  }
  y
}

#[test]
fn test_pack_point(){
  let private_key = 0x0510bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4;
  let pub_key: Gaffine = priv_to_pub_key(private_key);
  let packed_pub_key = [0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49, 0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15, 0x6b, 0xaa];
  
  let computed_packed_key = pack_point(pub_key);

  assert(computed_packed_key == packed_pub_key);
}

#[test]
fn test_unpack_point() {
  let private_key: Field = 0x0510bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4; // see debug notebook for an example on how to compute those
  let public_key: Gaffine = priv_to_pub_key(private_key);
  std::println(public_key);
  let packed_pub_key = pack_point(public_key);
  std::println(packed_pub_key);

  let packed_pub_key = [0xdc, 0x9f, 0x9f, 0xdb, 0x74, 0x6d, 0x0f, 0x07, 0xb0, 0x04, 0xcc, 0x43, 0x16, 0xe3, 0x49, 0x5a, 0x58, 0x57, 0x0b, 0x90, 0x66, 0x14, 0x99, 0xf8, 0xa6, 0xa6, 0x69, 0x6f, 0xf4, 0x15, 0x6b, 0xaa];
  let point = unpack_point(packed_pub_key);
  let repacked_point = pack_point(point);
  let reunpacked_point = unpack_point(repacked_point);
  std::println(point);
  std::println(repacked_point);
  std::println(reunpacked_point);
  assert(point.x == reunpacked_point.x);
  assert(point.y == reunpacked_point.y);
  assert(repacked_point == packed_pub_key);
}

#[test]
fn test_encrypt_packed(){
  let x: u40 = 5;
  let bjj_affine = get_affine_curve();
  let base_pt = get_base_point();
  let embedded_x = bjj_affine.mul(x as Field, base_pt);

  let private_key: Field = 0x0510bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4;
  let pub_key: Gaffine = priv_to_pub_key(private_key);

  let encrypted_point = exp_elgamal_encrypt(pub_key, x, 1);
  let decrypted_point = exp_elgamal_decrypt(private_key, encrypted_point);

  assert(decrypted_point.x == embedded_x.x);
  assert(decrypted_point.y == embedded_x.y);

  let packed = pack_point(pub_key);
  let unpacked = unpack_point(packed);

  let encrypted_with_unpacked = exp_elgamal_encrypt(unpacked, x, 1);
  let decrypted_with_unpacked = exp_elgamal_decrypt(private_key, encrypted_with_unpacked);

  assert(decrypted_with_unpacked.x == embedded_x.x);
  assert(decrypted_with_unpacked.y == embedded_x.y);
}
