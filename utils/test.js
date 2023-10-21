import * as babyjubjubUtils from './babyjubjub_utils.js';

async function main() {

    const priv_key = "0x0510bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4"
    const pub_key = babyjubjubUtils.privateToPublicKey(priv_key);
    console.log(pub_key)
    let packedPublicKey = babyjubjubUtils.packPublicKey(pub_key)
    // console.log('packed public key.', Buffer.from(packedPublicKey).toString('hex'));
    let unpacked = babyjubjubUtils.unpackPoint(packedPublicKey);
    console.log('unpacked public key', BigInt("0x" + Buffer.from(unpacked[0]).toString('hex')))
    console.log('oiriginal == unpacked', pub_key == unpacked)
}

main();