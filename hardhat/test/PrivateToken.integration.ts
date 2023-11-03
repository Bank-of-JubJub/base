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
} from "viem";
import { hardhat } from "viem/chains";
import { Contract } from "hardhat/internal/hardhat-network/stack-traces/model.js";
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
      randomness:
        "168986485046885582825082387270879151100288537211746581237924789162159767775",
      packed_public_key: [
        "dc",
        "9f",
        "9f",
        "db",
        "74",
        "6d",
        "0f",
        "07",
        "b0",
        "04",
        "cc",
        "43",
        "16",
        "e3",
        "49",
        "5a",
        "58",
        "57",
        "0b",
        "90",
        "66",
        "14",
        "99",
        "f8",
        "a6",
        "a6",
        "69",
        "6f",
        "f4",
        "15",
        "6b",
        "aa",
      ],
      amount_sum: 100,
      old_enc_balance_1: {
        x: "0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368",
        y: "0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036f",
      },
      old_enc_balance_2: {
        x: "0x26e2d952913cecf5261ce7caea0ded4a9c46a3a10dda292c565868d5f98aa5db",
        y: "0x1e8449b223a9d7b6215d5976bd0bec814de2115961f71590878e389a1cff5d09",
      },
      new_enc_balance_1: {
        x: "0x0b958e9d5d179fd5cb5ff51738a09adffb9ce39554074dcc8332a2e9775ffcc0",
        y: "0x2afe00f5544394d2ffdefbb9be1e255374c5c9f9c3f89df5e373cfb9148d63a2",
      },
      new_enc_balance_2: {
        x: "0x15f22eb9e5e68af082365afb12c83997d06514835e1a34cf787d3b65831a03a2",
        y: "0x043495e2d574a451ed777f379c85fe3ac5230909f6aace57ff1900ebb74da265",
      },
    };

    const proof =
      "0x0a367523ffac62d7da419c91d73b4154a711ab941c7f935dc93652672f9d3afd225867c274e394580d0e5a84de8f425bac875c10f4d226b624c1e98b88d561961c9e6309795a427be76bff32d33b3a0414d7c241e14e116772d3c026207423b719a40696b98dd26bc117bccdda0ae54be97610b2dcb0275836282bf96705422f183c2720f8e899e00bcd8b20bacd42024951e1fa5747a3ce59b38474178c9de30797a92ff3f17f676d4eca9c2e9c77e70a8695e7980e49c751c9d9c25e252a1207ea6263b074db4c8bae0aa8415a77e364bda68ec0611562a64c218fd2c0af52176cd493ca198b3c90671518f09b3e781c863de62a3dd84f51c710758789c85927edbba6257c876d7df354ccb308dcf6e19470280c0fe3ab2e0e6a71b91a284001cd30e38d4f8ae2e673d0ab93a7948fffe9428b011b82c88c5df024ca7d5578146b74108b7071134a776eeb544df1a3a791dbce08099be640327a7082204bc12e79397e181670cf49cf850b9639fbb978e7e6c0dd6f468f724bdb7cc5bc567d0d55fc749d6760b378c02daf37406b899556bcc4cb634b317e1ecc27f7e54db0293762ac12bf56d7d2a120eb2fe9d4f062793f9a5168c414eaa1832246cdada022c92c2c41236ce07558801e68b0202ad1381ad58410416ef4453d40026ffa082dfaa5a3afceecdd7ec965c28663214beaeb5264c9d2ffcf5832a08f879c90482ca9ab858a55993960b40e6ddd571dabc7d7bce831d4c32ea3b3e1ed9a389af103dca2740124af3a1ca2ea080be74e322a1cb37fcfa705b579599ed1984df4730a4789ad408e524c09b3c71f1396d6e4d40ace455cb4f95959a3cd00ec97376a1d18758e86e3541584791e4bb67793819e14aafcfe4ba3496ba11adaebb563f209da75dcd25def9f6514396e73e18a45c11418baea046894b001b6604d2ac7be101fa5660bb30578b67f29330494f6c4ff9031a8c4f4f2230badd25abefda0ae20611a6b1e3734d7a8220b218457ae57b10aa5f94a1664e686cad0a2493fb05e0cdb0718ffcfefa2a4d9e8da810619a963728b179ddbe32ba987120c1ea7a0462abba3b3be86c5a34104c28d93ac08189da59b4aac815467dbed05b9fb2a8982120567c2d9ba4ea49b1d4cc73c8245a807d0aeb40e46ce48bb0907bba115bd55288ebff1b46742119982df3ca3ec4afd81aa48534b81490f60a71e6a3967b4110a48ead22d0fbb396410ac330adc816d7609e4cb83768866ee60e1129103fbdd14fe8b607cbec803bbdb5e779b4a38cc071f1a1edbd597fa5420a887d8b2fd5a1ebe1b541b768c57d4f8ae224b01a0465a785c984583d8c08ac2d42060b9ddc8071e917e73838633c39c57f95bb00fe3623127ddf85f671488667f7a9161cf1a20e1677017125c125642ecc24beb6e268efe413fb36ffa8edeedf4fcb8ec43e8008d04e51511e75d5eea3ecebe244bbce43cf0eb9b716b272963f46e5327f61a2ed8422e72657cf4b150474621d75e562c1e40b1b4eef36aab64fc2b4e767264085098c81634c5de75e8d6c3d4b878cd45c018985ddebae4e8d6f832458f14e007308ba9e7c79cfc0cb615ea580719358d3ad8fc3ccfc923fcb42e2b2fbd14521e9492ee2a7526d40177a00311fac3d2ec0e572bf39ad192f91846f6d823c37910fc71c295fb5d92287c83ac82e636a783c2480c34cdeae474f0dcb8017116d52b738923fb7c3949ae04275d7bdde2f726d848b6f617e1f29e8633d27e59d29f2e3149641c47ee16a46df16e3ed44dd66761a213db483c0db325bca74c3f556d12206718b53fb8fbe1c0d86443d5324eb88fc42d20b54a19d7bc029a2c71e2621a5c7c5ba2c055957661f5a8477f1c5f430a3c1b122b19982c9513a999f7baf41e2f431409500aa3d770c2804be452bb0fd4b0dc06878780a67f139ec4617db71852fb5ff04459aa66c7ffc41aaeed1acbb63881c8c296b820b7c9b739ce836a29be4f4036d08e7a3e7657620d3d78f416834136bd3a90515a843929d4d16091263afff243f424b56a6addd07bd940dbc5f031cf258ab32a07b3ae2b36312a3a0c2df8c8aee7bbe5b0b4c438045492f82387d55184c40ca1ac461e015d11d0b81650cc9a52c34bab43924187ac5c18d4678927748929a79e47d4510fd96531e2253eb51b413d012278bf56e1c7f8505c6a31cb487c2642a1e89b7b3016386a7e0093680356ddbe5565244b5d01850a1d4c2afa1555bee8e3403dd28241022ecc107f1e4a8caeeea80bd17e5a7385d8b0c09aeeb189ba42ef4e2423fed131972d178b72598d4fd459004c3d286a5de025d0d961312f0855acc4e4355ba757819a00335e20cf9cab4c5d5a016761e875bdef73c1c4f0489fc83e1365df694183c61ea89abfb7b14ec08696e1df83ebc6b0ed29b6f6552154181d8c43600877b79f24eda65694e63bc589d438f0d06df44137283e9f55b7dac4934b47b9f513a6e2060f8dcab38829bab07ccab57676152c11cdd22652b3f6e71585642247c54a0d1f57e27e23cbcf47ea497f26cdd59df55c4de40cd9049b67122a9a542486cc072d0ef1259e385f97e97f85e579bc8bb81aed11eb9cbe146871dfd00bdf951af31f6e9fd5f8c3db8ef39a35775d60bca5e1de342a3453e45d9f8e37bc8aaa3ef81b56bdf2c5fef4769ee6d2f458ed7a51d6c077e3d0869e0f108fb22807ccf8fe17c6408e88c36716b2399b5331b39e8cffc18a1322efa7dbe91f037ffb6e9cca1e3dad7e3298b298b23b2464550c0e85af0e08f49da5a62cea654002c3bbc395259f52461fb86ebad50aeec3fe76e236819675a5f66ac01b56c5ccc2244f1a6f1cdfd2de37d0e116a12cadc24f16ccf2c0f567005834116f6a842e8449c520e004746150cbabe6ba34e630e53b0de90092b64208ba23de29787af1c1cb3d841b2a5ace4525c25bce66ef7ee3315bd4f93117efdb45deb3485b2ffdb2797ee59c173feba08a2c30cdbd7e8cae95fb8615f4a850872e5bb6ac4324b0224312f4e8";

    const txsToProcess = "";
    const newBalance = "";

    privateToken.write.processPendingDeposit([]);
  });

  it("should perform transfers", async function () {
    const { privateToken, token, walletClient0, walletClient1 } = await setup();
    const { recipient, convertedAmount, fee } = await deposit(
      privateToken,
      token,
      walletClient0
    );

    const processFee = 100;
    const relayFee = 50;
    const relayFeeRecipient = walletClient1.account.address;

    // const amountToSend;
    // const newSendeBalance;
    // const proof;

    // privateToken.write.transfer(to, recipient, relayFeeRecipient);
  });
});

async function deposit(privateToken: any, token: any, walletClient0: any) {
  let balance = await token.read.balanceOf([walletClient0.account.address]);
  await token.write.approve([privateToken.address, balance]);

  let tokenDecimals = (await token.read.decimals()) as number;
  let bojDecimals = await privateToken.read.decimals();

  let recipient =
    "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`;

  let depositAmount = (balance as bigint) / 2n;
  let convertedAmount =
    depositAmount / BigInt(10 ** (tokenDecimals - bojDecimals));
  let fee = 100;

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
