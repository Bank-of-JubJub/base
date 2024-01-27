import { buildBabyjub, Point } from "circomlibjs";
import crypto from "crypto";

/*
TODO: debug and use for tests

Pack and unpack functions arent working properly for some reason.

*/

export type BigNumberish = string | bigint | number | Uint8Array;
export type PointObject = { x: bigint; y: bigint };

export class BabyJubJubUtils {
  private babyJub: any;

  constructor() {
    this.init();
  }

  async init() {
    this.babyJub = await buildBabyjub();
  }

  getP() {
    return this.babyJub.p;
  }

  getPm1d2() {
    return this.babyJub.pm1d2;
  }

  getF() {
    return this.babyJub.F;
  }

  private _uint8ArrayToBigInt(bytes: Uint8Array): bigint {
    let hex = [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
    return BigInt("0x" + hex);
  }

  private _getRandomBigInt(maxBigInt: bigint): bigint {
    // Calculate the byte length
    const byteLength = (maxBigInt.toString(16).length + 1) >> 1;
    while (true) {
      const buf = crypto.randomBytes(byteLength);
      let num = BigInt("0x" + buf.toString("hex"));

      if (num <= maxBigInt) {
        return num;
      }
    }
  }

  public _bigIntToUint8Array(bigInt: bigint): Uint8Array {
    let hex = bigInt.toString(16);

    // Ensure even number of characters
    if (hex.length % 2 !== 0) {
      hex = "0" + hex;
    }

    const bytes = new Uint8Array(32);
    const hexLength = hex.length;

    // Start from the end of the hex string and assign byte values to the end of the Uint8Array
    for (let i = hexLength, byteIndex = 31; i > 0; i -= 2, byteIndex--) {
      const byteStr = i >= 2 ? hex.slice(i - 2, i) : hex.slice(0, 1); // Handle the scenario where hex has an odd length
      bytes[byteIndex] = parseInt(byteStr, 16);
    }
    return bytes;
  }

  public privateToPublicKey(privateKey: BigNumberish): PointObject {
    const publicKeyPoint = this.babyJub.mulPointEscalar(
      this.babyJub.Base8,
      privateKey
    ); // A point on Baby Jubjub : C = (CX, Cy)
    return {
      x: this._uint8ArrayToBigInt(
        this.babyJub.F.fromMontgomery(
          this.babyJub.F.e(publicKeyPoint[0])
        ).reverse()
      ), // fromMontgomery because circomlibjs uses the Montgomery form by default, but we need the Twisted Edwards form in Noir
      y: this._uint8ArrayToBigInt(
        this.babyJub.F.fromMontgomery(
          this.babyJub.F.e(publicKeyPoint[1])
        ).reverse()
      ),
    };
  }

  public generatePrivateAndPublicKey() {
    const max_value = BigInt(
      "2736030358979909402780800718157159386076813972158567259200215660948447373041"
    ); // max value should be l (https://eips.ethereum.org/EIPS/eip-2494), the order of the big subgroup to avoid modulo bias
    const privateKey = this._getRandomBigInt(max_value);
    const publicKey = this.privateToPublicKey(privateKey);
    return { privateKey: privateKey, publicKey: publicKey };
  }

  public exp_elgamal_encrypt(
    public_key: PointObject,
    plaintext: BigNumberish,
    isTest: boolean = false
  ) {
    // same notations as in https://en.wikipedia.org/wiki/ElGamal_encryption
    // Check if it's a number and an integer in uint40 range
    if (
      typeof plaintext === "number" &&
      Number.isInteger(plaintext) &&
      plaintext >= 0 &&
      plaintext <= 1099511627775
    ) {
      const max_value = BigInt(
        "2736030358979909402780800718157159386076813972158567259200215660948447373041"
      ); // max value should be l (https://eips.ethereum.org/EIPS/eip-2494), the order of the big subgroup to avoid modulo bias
      // fixed randomness so the output is always the same for testing

      let randomness = isTest
        ? 168986485046885582825082387270879151100288537211746581237924789162159767775n
        : this._getRandomBigInt(max_value);
      // const randomness = this._getRandomBigInt(max_value); // this._getRandomBigInt(max_value);
      // console.log(randomness.toString(16).length);
      const C1P = this.babyJub.mulPointEscalar(this.babyJub.Base8, randomness);
      const plain_embedded = this.babyJub.mulPointEscalar(
        this.babyJub.Base8,
        plaintext
      );
      const shared_secret = this.babyJub.mulPointEscalar(
        [
          this.babyJub.F.toMontgomery(
            this._bigIntToUint8Array(public_key.x).reverse()
          ),
          this.babyJub.F.toMontgomery(
            this._bigIntToUint8Array(public_key.y).reverse()
          ),
        ],
        randomness
      );
      const C2P = this.babyJub.addPoint(plain_embedded, shared_secret);
      const C1 = {
        x: this._uint8ArrayToBigInt(
          this.babyJub.F.fromMontgomery(this.babyJub.F.e(C1P[0])).reverse()
        ),
        y: this._uint8ArrayToBigInt(
          this.babyJub.F.fromMontgomery(this.babyJub.F.e(C1P[1])).reverse()
        ),
      };
      const C2 = {
        x: this._uint8ArrayToBigInt(
          this.babyJub.F.fromMontgomery(this.babyJub.F.e(C2P[0])).reverse()
        ),
        y: this._uint8ArrayToBigInt(
          this.babyJub.F.fromMontgomery(this.babyJub.F.e(C2P[1])).reverse()
        ),
      };
      return { C1: C1, C2: C2, randomness: randomness }; // randomness should stay private, but we need it as private inputs in the circuit
    } else {
      throw new Error("Plain value most be an integer in uint40 range");
    }
  }

  public exp_elgamal_decrypt_embedded(
    private_key: BigNumberish,
    C1: PointObject,
    C2: PointObject
  ) {
    const shared_secret = this.babyJub.mulPointEscalar(
      [
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(C1.x).reverse()),
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(C1.y).reverse()),
      ],
      private_key
    );
    const shared_secret_inverse = this.babyJub.mulPointEscalar(
      shared_secret,
      2736030358979909402780800718157159386076813972158567259200215660948447373040n
    ); // Note : this BigInt is equal to l-1, this equivalent here to -1, to take the inverse of shared_secret, because mulPointEscalar only supports positive values for the second argument
    const plain_embedded = this.babyJub.addPoint(
      [
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(C2.x).reverse()),
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(C2.y).reverse()),
      ],
      shared_secret_inverse
    );
    return {
      x: this._uint8ArrayToBigInt(
        this.babyJub.F.fromMontgomery(
          this.babyJub.F.e(plain_embedded[0])
        ).reverse()
      ),
      y: this._uint8ArrayToBigInt(
        this.babyJub.F.fromMontgomery(
          this.babyJub.F.e(plain_embedded[1])
        ).reverse()
      ),
    };
  }

  public add_points(P1: PointObject, P2: PointObject): PointObject {
    // Used for (homomorphic) addition of baby jubjub (encrypted) points
    const Psum = this.babyJub.addPoint(
      [
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(P1.x).reverse()),
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(P1.y).reverse()),
      ],
      [
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(P2.x).reverse()),
        this.babyJub.F.toMontgomery(this._bigIntToUint8Array(P2.y).reverse()),
      ]
    );
    return {
      x: this._uint8ArrayToBigInt(
        this.babyJub.F.fromMontgomery(this.babyJub.F.e(Psum[0])).reverse()
      ),
      y: this._uint8ArrayToBigInt(
        this.babyJub.F.fromMontgomery(this.babyJub.F.e(Psum[1])).reverse()
      ),
    };
  }

  public intToLittleEndianHex(n: bigint): string {
    // should take a BigInt and returns a string in little endian hexadecimal, of size 64, to give as input as the Rust script computing the Discrete Log with baby-step giant-step algo
    // Ensure input is a BigInt
    if (typeof n !== "bigint") {
      throw new Error("Input must be a BigInt.");
    }

    let hexValue = n.toString(16);

    if (hexValue.length % 2 !== 0) {
      hexValue = "0" + hexValue;
    }

    const pairs = [];
    for (let i = 0; i < hexValue.length; i += 2) {
      pairs.push(hexValue.substring(i, i + 2));
    }
    const littleEndian = pairs.reverse().join("");

    return littleEndian.padEnd(64, "0");
  }

  public packPublicKey(P1: Point): Uint8Array {
    const montgomeryForm: [Uint8Array, Uint8Array] = [
      this.babyJub.F.toMontgomery(P1[0].reverse()),
      this.babyJub.F.toMontgomery(P1[1].reverse()),
    ];

    return this.babyJub.packPoint(montgomeryForm);
  }

  public unpackPoint(point: Uint8Array): Point {
    let p = this.babyJub.unpackPoint(point);

    return [
      this.babyJub.F.fromMontgomery(this.babyJub.F.e(p[0])).reverse(),
      this.babyJub.F.fromMontgomery(this.babyJub.F.e(p[1])).reverse(),
    ];
  }
}

// Usage example:
// (async () => {
//   const utils = new BabyJubJubUtils();
//   await utils.init();
//   const { privateKey, publicKey } = utils.generatePrivateAndPublicKey();
// })();
