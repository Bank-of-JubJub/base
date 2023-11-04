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
    // private key 0x0000bae26a9b59ebad67a4324c944b1910a778e8481d7f08ddba6bcd2b94b2c4
    const to =
      "0x17aeb1361bdada97d8b24aeae439f0643d73f1833a890e67707bb99baafcc38c";
    const processFee = 1;
    const relayFee = 2;
    const relayFeeRecipient = walletClient1.account.address;

    const amountToSend = 3n;
    const amount = {
      C1x: 0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0n,
      C1y: 0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2n,
      C2x: 0x06deb02e81b49cc0e215e0453b6135d52827629df1a12914da953199d39f333bn,
      C2y: 0x211de3374abedea3113aa1f312173764eb804dab7ead931971a4dbba832baf00n,
    };
    const newSenderBalance = {
      C1x: 0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0n,
      C1y: 0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2n,
      C2x: 0x06deb02e81b49cc0e215e0453b6135d52827629df1a12914da953199d39f333bn,
      C2y: 0x211de3374abedea3113aa1f312173764eb804dab7ead931971a4dbba832baf00n,
    };

    const proof = "" as `0x${string}`;
    const nonce = keccak256(
      encodeAbiParameters(
        [
          { name: "C1x", type: "bytes32" },
          { name: "C1y", type: "bytes32" },
          { name: "C2x", type: "bytes32" },
          { name: "C1y", type: "bytes32" },
        ],
        [
          newSenderBalance.C1x.toString(16) as `0x{string}`,
          newSenderBalance.C1y.toString(16) as `0x{string}`,
          newSenderBalance.C2x.toString(16) as `0x{string}`,
          newSenderBalance.C1y.toString(16) as `0x{string}`,
        ]
      )
    );
    console.log(nonce);
    // privateToken.write.transfer([
    //   to,
    //   from,
    //   processFee,
    //   relayFee,
    //   relayFeeRecipient,
    //   amount,
    //   newSenderBalance,
    //   proof,
    // ]);
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
