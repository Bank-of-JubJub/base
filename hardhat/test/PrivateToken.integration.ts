import { assert, expect } from "chai";
import hre from "hardhat";
import { spawn } from "child_process";
import * as babyjubjubUtils from "../../utils/babyjubjub_utils.js";
import {
  Address,
  createPublicClient,
  http,
  GetContractReturnType,
  walletActions,
  toBytes,
  keccak256,
  encodeAbiParameters,
} from "viem";
import { hardhat } from "viem/chains";
import { Contract } from "hardhat/internal/hardhat-network/stack-traces/model.js";
import exp from "constants";
// import * as proofUtils from "../../utils/proof_utils.js";

const viem = hre.viem;

describe("Private Token integration testing", async function () {
  it("should add a deposit", async () => {
    const { privateToken, token, walletClient0 } = await setup();
    const { recipient, convertedAmount, fee } = await deposit(
      privateToken,
      token,
      walletClient0
    );

    let pending = await privateToken.read.pendingDepositCounts([recipient]);
    assert(pending == 1n, "Pending deposits should be 1.");

    let pendingDeposit = await privateToken.read.allPendingDepositsMapping([
      recipient,
      0n,
    ]);

    const expectedAmount = convertedAmount - BigInt(fee);
    let totalSupply = await privateToken.read.totalSupply();

    assert(
      pendingDeposit[0] == expectedAmount,
      "pending deposit should match deposit amount"
    );
    assert(pendingDeposit[1] == fee, "pending deposit fee should match input");
    assert(
      totalSupply == Number(expectedAmount),
      "deposit amount should be the total supply"
    );
  });

  it("should process pending deposits", async function () {
    const { privateToken, token, walletClient0, walletClient1 } = await setup();
    const { recipient, convertedAmount, fee } = await deposit(
      privateToken,
      token,
      walletClient0
    );

    let inputs = {
      amount_sum: 999,
      old_enc_balance_1: {
        C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
        C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
        C2x: 0x26e2d952913cecf5261ce7caea0ded4a9c46a3a10dda292c565868d5f98aa5dbn,
        C2y: 0x1e8449b223a9d7b6215d5976bd0bec814de2115961f71590878e389a1cff5d09n,
      },
      new_enc_balance_1: {
        C1x: 0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0n,
        C1y: 0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2n,
        C2x: 0x06deb02e81b49cc0e215e0453b6135d52827629df1a12914da953199d39f333bn,
        C2y: 0x211de3374abedea3113aa1f312173764eb804dab7ead931971a4dbba832baf00n,
      },
    };

    const proof =
      "0x25efb40f44921517e2e15271220a9627000032947f02055b14611d668d0687cc1f8b2ac7dadefef70fb7307789f253bc97089fa845ab0f9ee976214c3681d1be0cc65cdd48bf46b5e3e9593566c9369a50b2f30df0226ec638c80e019b72597800e7529a2416c12f761600b6f18707b6f80dab523f5bc434ec09040cfb1bd3903035370611c635f7afb0c38da0111e6ddfe506bb426e5c98599477c1ba222634161f3b76b4627e867232a07fcdc255f15b55f1efabad645d1789b47dbcf7b83e117049f91993ef8427eb0a59a79c3b07b1bc1f317d6bfd0a285357303dd2e8500998c6e795a12e0dc314915f79d3606d765e93dc61374870a8a051df4b7862b71d23ca41b42ccfc1efa88cc2357c833bda0862ff63ac62f0be05477d6388ba81240836c70adef827a97ff2ae31b2352c98b6f02382a0751f609fbf1e08d45b3708f8b2052573b072b7ad1ccaca6628f9139dbfa339ca5ff9d58b84245b6380042ea5b17c3d49da13b12620c55c2003924d9facae35ff50ad37583fc28361c3fd251ca4e87f62f96deb56559c07a835432bc78df74565970c51084e1a5a942a7d1722aedc1c7402c117116fb3bcce1c296e2d1e2af697eb4f4c60735c6925f4bb25034588eb8bb8bfd2f968b94533fd66e4cb24fa387e800b5fc82947d787093e2e7b05cbad56c5e1474722631aa86fb083d4f20155f8f7a0584d62c4ff65776a2a3b9f4db2e6f203caf7a18b044a70301c4529e26ebb530553b47c3d7940690e28032e8db453ecbef02f94e4320b5d05f81e5cb80dff696a1360260d07daf8b00a1a4e7f3e0c520edbf99f4c55e7022f24e48c84eb0230ad79c6155c3411a5531199599e0f98733bae9fbb35f6f1a694c75202d0a208e149b3803fa8da46c7d61702f9d82184476c1d7333217742d6b454e9b94c0b9456569ab48a957cf868211ef97cb38b2e90cede52df5b3bec52d18b3fdb4b2e97f7dfd2d1011ac115c80206345deb602f863f812e56ed84983fcbfdf46a5e35b8b5efd315053f79e941a82d2b73199506aa93468eeb3051f7cc93a381d8e988aae4670b57e3aafba6cd7c26b9853669adde944c9ddf97567f4df7f0ed2a22d3f40166349ef8742145015f2cd358caa02328d2530e7b0d9491e47fcbcca46e7e7af866e507fb4120a3ef8b11b38d5d2af6c6f5f0c9ed3a395d1f1ec18551b1e27c6a679c16ee04a45c770e1e5cc84d26bf6c24fba931dfdb823f6eff838e535a739f10c65ec58ca9c0938924ca9c5c1b22aaf0b8862cafd9b248566b64fa15690df0a56d15b998faa1833d03d8bcaae786de5a1fcdba3cc9cbfb46d40cddaeaffe971e1c4451aeb3029fd0297930bd9a27335279d05b354807e35625c855c958deb29850a740e7ea63f4701a911f1526e362db9a8ec1ab692e32a6feeb505e78218bfd76c1a40b24f54c69023b689dab87c5062c7d5200556a91774883518532708c8a77065adce2c157d30a7cd679ca78fe1085b8fa2e20b018f9439bda02b00e6a32c0a01c7944907acd07abe3756f1c94912cee4b91f9015509a393887b5abfb09b545aebf7a03d11411b69a052d9c66acb363ee962f13dd008e6298167c7ffea6ce9edfe3c970ef42404b8e070cf092bca9329ca9ed7a6a32fd348e891c945e93050271d13e1da97721f40353f0fb188c3e40086dad9c4bbab00034277c416f7fc1a7355a26f2db9bf1226dac6ff46ac29601bc66f261b1f2bb1e138a41d4452c9a59ccd040dab1f952b2815badbe94360904dfdfec16511204f903a942fb3a9d236f1a07c63c03cd81d803cda8fcbdc3805b839029c9d5dcb764a282039cbfeda5c47fa2051ca16e000bb77ffbc5486866ccec3ad5de1fcd8954224187863006cb1d88af9854b9da81b1534e4024cdea285386ba6c5ae340995bea53e0de8297fba2a5ddbc67a58b01a72d5ce7bb0b2807d9d77f0a3dbb43c95fa007f34bfa8ee67e71323cc1f16d022ba906680efe02bacc694304733f34c6fca4d3f7e1d20843c512e1ac955aecf2ed2c67d2e635f206334965b0b489fc21baaf39f969ceb1624f470d2a434ba9b13d2cf1c8406ce800120b24869f1a8898fe2d3eca0555243542995ac194c35931160c04766ebc9e241643ead3c4a22a47d1ce6ed04c564e89b17880a5b0717ea2eb7e3ec0b614eb9cb53bbd460c9226af1e6c38a5689f3e10e9c4d0894f5ecba2c9e0b9faefdfb214486f4143fdbb6dfdf23e66f2e8e51dc47791b20529980071fe1ffc8b82ec6e50bfe69e9361c37583919efe091b38d0e7f5ae4fe9f49c870113cb0c52a2ab32727aad138c1c90a16e42e7efdab926d674097d08dddd5a6640e9491f4ba63193ea548478c8c440f49acb9be3caf2c7fceb728732bb657b31203fbbf159370e7f70d5d3657ccd1f7d815096e7496919472c86913ae996b94aa085a5ab070ebf69c3f879139c9e4c423b55a936905cd131ed071b90901b639552631a652c40839a0728f93b6d8568d3cbecdb1f5b94ead0ae24577e4603265020ad56034f5c7e3a815ca68a5ba5c271d1000eb23b446beb7d731f13e9d69d2aa24b75371dfb9c4934f6259eb16d4fad61b7f85b19f9dbac7117c9e4422b3796e1c3e2b31fe4eaf96eae5459d4ec0bf7bdf7a7a6b9f4bceea37add5815e8b8d8426118613e7ac60f95318f3ee5be9faed0787f8742ca198998e61c1143b0f9e1f1f6531fffb64b750d723668bc94e42d836c670a8435324dd1d2a8f2ae084ba792782cd15fc660b1cf7dad40400c4ce3edb12ae88e0e3dc242c816e21e4e2759325c597ca8f12911663cd304199ee9c6643d0c70123173dd619ffb6d94f49be7806f080b0af36b7b54199b365430d72dc300a0aac3232238a07598852fe8c6a8c1cb79774099e1d5c3ace410692d07401f4ab64e09b88e51ab5d35e8f82bc18f82e36d2f3d78c0359e4f69dec7bd284141872846328a60c7ffe79801f82064db707ab0402928e58da591e70edef0af15926f6f77b23ed05c651a5314cd22dfaae" as `0x${string}`;

    const txsToProcess = [0n];
    const feeRecipient =
      "0xbEa2940f35737EDb9a9Ad2bB938A955F9b7892e3" as `0x${string}`;

    let pendingDeposit = await privateToken.read.allPendingDepositsMapping([
      recipient,
      0n,
    ]);

    await privateToken.write.processPendingDeposit([
      proof,
      txsToProcess,
      feeRecipient,
      recipient,
      inputs.old_enc_balance_1,
      inputs.new_enc_balance_1,
    ]);

    let balance = await privateToken.read.balances([recipient]);
    expect(balance[0] == inputs.new_enc_balance_1.C1x);
    expect(balance[1] == inputs.new_enc_balance_1.C1y);
    expect(balance[2] == inputs.new_enc_balance_1.C2x);
    expect(balance[3] == inputs.new_enc_balance_1.C2y);
  });

  it("should perform transfers", async function () {
    const { privateToken, token, walletClient0, walletClient1 } = await setup();
    const { recipient, convertedAmount, fee } = await deposit(
      privateToken,
      token,
      walletClient0
    );

    const from = recipient;
    const to =
      "0x0c07999c15d406bc08d7f3f31f62cedbc89ebf3a53ff4d3bf7e2d0dda9314904";
    const processFee = 1;
    const relayFee = 2;
    const relayFeeRecipient = walletClient1.account.address;

    const amountToSend = 5;

    // 5, ecrypted to `to`
    const amount = {
      C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
      C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
      C2x: 0x25bd68ade5a08a4a012250cff52bd6e92752413aacb5a01ef8157e7c65b1b1c6n,
      C2y: 0x22ce61a67a4ee826534fca1d6276fd1c80ff05a5831f90ce1c9f5963a6393e5fn,
    };
    // 991, encrypted to `from`
    const newSenderBalance = {
      C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
      C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
      C2x: 0x0e1e666f8f0b88b8f95cf51f00175a83a338557351c4c34da8cf4049a5adc77cn,
      C2y: 0x2271fba8cd2dc38d663006ae7ca0c3ab9a5cdc842d98ac39878e271208827b5dn,
    };

    const proof =
      "0x2851c33267863eec51887d37f5552b619d9c47d1a4e4a6901d3839f701df6b8a1798337395f2d0a34566fb0a10115047ed6b84637e3298e470a2bf41f96eb25f0a69b039ab0d6ddc8a02f364261f55f8a77932b2408e89948d485bbc0b991163206982e25c5a86729d6d02637a918a1b707ccf4fa6588f40bd7cca0463fbda6529eff6b6859b7000cf3018c31a7130152b9b515a531025b0140329c5a17816ce220965862266d0ba4c18404e7d2ed4fce28958782d4578cf6acee95509fd0c8a1cd756d0780956409f75199bd08e1245c9f28b1cc96731b9548d1e697a7d615305a6065e905c98feb16d65f77210aeec6ae0f3f4d699ea4585eb1e0490b8fe752bd091e3b0f77a602773b5c379ab015825293f5cc854cf0a12f644faf06ef5472ffe58882666dc506e278a37cde8111df3f37a4ef781ffa4b58c4dcd8afe74d109ef6f71a67cf9db11cdc9fab3926e2ed3c1b8a922536b734f14064e53d8920e22c405686098f29329cc228a5af030732287832ee6c40272fd5a5b9e0cf64386101aec69d746fcbbd9878f98a8ac0834cc27a8c179dca49a63b39185d893fca501220d2abf56100a6c9769af6174eea05e6c02c001cfd80f1ab800ea430bed712fea8d4ea0e5aa75ab90c9d1201c8cf0715918f069a7fffdf0cd111f18c91b2b19f500a4f7c1685f7e17f0140020053531873af26e5f80b14141bef518da7e0d2919c0bf7673e9bbd72ceeec0f74ed7388b665c1883aee28cbd84c4831697cf4148f04545b47a576f2637dbbfe136613534682fb849de2761f9af85cc21601011d3e58040dc3ae4aaffdf1ed5859e9cc411f447ebccf265507adfccaf07917070dd7500cd4d1cde6d60716a4d49ff60ef18227b9a7a6f93ee6410eea0310b75f2c93d301f3f6b9caf2d7a25d603c9ca0a8e4afedb134d00d8337e5e3fd404bcb2694a40c72630a18638c8f96e64977cff073c24bf2bd0435b1c3aff4cebe2d441f440c81496fa937deb20d18a6c3677f6b1aa2b8eb62fa5cc036c0ccc6de8c4b2dc885239d1d3176494393d8b873d9cf250fdfdbf7d96dd28187d170b3a7762a01cc86a029f2babf6f4148e910ca76e785c2215d14e55701938d39678f1192ad13e4adacd7c51311f71c86479b71c82cfe045613055a0c58b1bb1b9972d04477227a99ac8131fbac8ed2df293a74254adb3cc7d266249f84c4e619e52d99d80919a876f3b0120b0566c1c8e6f7c8e824324baa9decc218a64b59523119c3d6e92b6683dc4861fd13523a560129aa9a8e9073c07f3a3efa6cfacbeb57f057c1e40c3103adbfa383f9cde0da47a5222d6b757230924bd77de8c712510e17696bae098a114c6155ed335e96986ee00ff77c62a46cbff63ffdb7897d697ee3593aba28d1679f1ef271a8f6d6b340404a078e06c44c38911841b3b36cc716b202e4a115abb4463a0dd3b144db64cdaef55e01cc0da388c8851051a8c3a19556e8b84e15ba342407c1705d5712c7488e77eacf00835206045d07023b30420920d129bf150e8db712742cf86866564fb23621b9d0bce53816f4760f0a2380fead6a58181a70916c9993f331980a70278b62376a36cb028c762337dbc2983bd3c50d876209a9c8bf1399fdf4d7a25dba176788be481db9dd6fc7494f76cd506d8415a7cf2d3ad1e949ebe3c2fdde51cdc2991dfbe691da45dfa945d100401024f5b97d7623b60713ab6981b6069bb6dab3d612d915046c099e789e3ab3bb3eeaddabf50903ceeb9162a78253af15d542eed2c1fd1d6be84f7d7cd1a237be55c293b2b2fc1162aa4287d0573bc827a35930ab95a27f5164c21a1599dc4ba8db4a50ecf4700ddb7aa9b8005f8e7e594484f95d2c70b679a46e2a3ea16ff0310dd17c0a76ef05f2d0b47802182cddb161d902e819b632f14604fee4a604eb587d2095dff6c5117deeea33e676d4621d1d8d0d03b5448efc4c82d90bd8ff2e278afa1ee5aa96043fe6b0c3396dc55703c26ab6b963e5a446b26dd4161f1c89a9e22c0ddc42702f2a084246a0a95db8a8ab013c668fc42c0594a090d4f61c90876669a61ded092b1f298d8fbd66292c3d0487edfe4c65bad07b9978f3d3fb7dd421daf98a7bc4293376f33638f92cc03ca6278399b085e8b4af5fac9706bac9e7928c7e80b2fb0698ef5db1515a1d0d3d1f83963107362576d559d7d072c49b4f4be1edbaa3792c13eb0b2181b94092d82cae9c41523a3ba50c33ac19e0ca0f2428633647500d13ff00239ef45e454a85de5607ceae1629e0d1e5ed5fa53ad53ba95c95a0589e048b2eda445137824b9a5928875115dee9655b741529fb20d5d0ad5cde5f9cb601736cf6a7a8ace4d68c24b56609a327ea9356d7ce1db25bdc386d0cfcd9af182a22de04b61a633d3f4923e52e0275123c44df8461b721ff10a997f82f3e47151b480f4ac9f4ec372dd62686263cc35d7ab44f8010934ce56bc2e02f5907c1700f5de62a51948bc9c26c9673d7a07a84a62b3357d62457d4c2df26eeec9abd83048afcfb142058458bb89d6ccfd5abec9bfe3fa4120222fcd36652ee71dbf4c9066a1670389e18514e90f6b3fc6d4d99b3eb04be7fed34a194d53e8633b6180d200095603e5192ab80036b555dc8ba23ef15df10f8dbd7a2f4df7b9dcd9de9d320c486b668c9600e38edad6aa967c3879e37ea6aa561efbf5bec468e10adc41b18173d997e6457255319c7f8e220fb815484a0af39ef4c5a36ded8dc7f57a8d41a884c4a9cce4bfb48c954e4860febab975ba9a3266104ed80b8b8ae181edc8e0c832826b2f972b339b27b13013c075e819d48db5000a85d1abef9670678f8912959be892628a49dea54cd08aee7af273ddc7939e95b3e0a43f196aef01db99d23d646b7b09aa81eb417e94dfdf234f723c7c7b21dedff463b7b01efa5ba8d7807eacf8fd11b3e10cf81e8f1193562c2dd3e99041dccdf4c5e98ba010584be2d247e9118750687665b038bed77cb84e1e65645bbb7e2dbe7aafbc2f1033affa9" as `0x${string}`;
    const nonce = getNonce(newSenderBalance);
    let res = await privateToken.write.transfer([
      to,
      from,
      processFee,
      relayFee,
      relayFeeRecipient,
      amount,
      newSenderBalance,
      proof,
    ]);

    console.log(res);
  });
});

async function deposit(privateToken: any, token: any, walletClient0: any) {
  let balance = await token.read.balanceOf([walletClient0.account.address]);
  await token.write.approve([privateToken.address, balance]);

  let tokenDecimals = (await token.read.decimals()) as number;
  let bojDecimals = await privateToken.read.decimals();

  let recipient =
    "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`;

  let depositAmount = 10 * 10 ** 18;
  let convertedAmount =
    BigInt(depositAmount) / BigInt(10 ** (tokenDecimals - bojDecimals));
  let fee = 1;

  await privateToken.write.deposit([
    walletClient0.account.address,
    depositAmount,
    recipient,
    fee,
  ]);

  return {
    recipient,
    convertedAmount,
    fee,
  };
}

async function setup() {
  const publicClient = await hre.viem.getPublicClient();
  const [walletClient0, walletClient1] = await hre.viem.getWalletClients();
  const { contract: token } = await deploy("FunToken", []);
  const { contract: pendingDepositVerifier } = await deploy(
    "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: pendingTransferVerifier } = await deploy(
    "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferVerifier } = await deploy(
    "contracts/transfer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawVerifier } = await deploy(
    "contracts/withdraw/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: lockVerifier } = await deploy(
    "contracts/lock/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: privateTokenFactory } = await deploy(
    "PrivateTokenFactory",
    [
      pendingDepositVerifier.address,
      pendingTransferVerifier.address,
      transferVerifier.address,
      withdrawVerifier.address,
      lockVerifier.address,
    ]
  );
  await privateTokenFactory.write.deploy([token.address]);
  const logs = await publicClient.getContractEvents({
    address: privateTokenFactory.address,
    abi: privateTokenFactory.abi,
    eventName: "Deployed",
  });
  let privateTokenAddress = logs[0].args.token;
  const privateToken = await viem.getContractAt(
    "PrivateToken",
    privateTokenAddress
  );
  return {
    publicClient,
    pendingDepositVerifier,
    pendingTransferVerifier,
    transferVerifier,
    withdrawVerifier,
    lockVerifier,
    token,
    privateToken,
    walletClient0,
    walletClient1,
  };
}

function uint8ArrayToHexString(arr: Uint8Array) {
  return (
    "0x" +
    Array.from(arr)
      .map((byte) => byte.toString(16).padStart(2, "0"))
      .join("")
  );
}

function bigIntToHexString(bigIntValue: bigint) {
  let hexString = bigIntValue.toString(16);
  // Ensure it's 64 characters long (32 bytes), padding with leading zeros if necessary
  while (hexString.length < 64) {
    hexString = "0" + hexString;
  }
  return "0x" + hexString;
}

async function runRustScriptBabyGiant(X: any, Y: any) {
  // this is to compute the DLP during decryption of the balances with baby-step giant-step algo in circuits/exponential_elgamal/babygiant_native
  //  inside the browser this should be replaced by the WASM version in circuits/exponential_elgamal/babygiant
  return new Promise((resolve, reject) => {
    const rustProcess = spawn(
      "../circuits/exponential_elgamal/babygiant_native/target/release/babygiant",
      [X, Y]
    );
    let output = "";
    rustProcess.stdout.on("data", (data) => {
      output += data.toString();
    });
    rustProcess.stderr.on("data", (data) => {
      reject(new Error(`Rust Error: ${data}`));
    });
    rustProcess.on("close", (code) => {
      if (code !== 0) {
        reject(new Error(`Child process exited with code ${code}`));
      } else {
        resolve(BigInt(output.slice(0, -1)));
      }
    });
  });
}

// A deployment function to set up the initial state
async function deploy(name: string, constructorArgs: any[]) {
  const contract = await hre.viem.deployContract(name, constructorArgs);

  return { contract };
}

function getNonce(encryptedAmount: {
  C1x: bigint;
  C1y: bigint;
  C2x: bigint;
  C2y: bigint;
}) {
  return keccak256(
    encodeAbiParameters(
      [
        { name: "C1x", type: "uint256" },
        { name: "C1y", type: "uint256" },
        { name: "C2x", type: "uint256" },
        { name: "C1y", type: "uint256" },
      ],
      [
        encryptedAmount.C1x,
        encryptedAmount.C1y,
        encryptedAmount.C2x,
        encryptedAmount.C1y,
      ]
    )
  );
}
