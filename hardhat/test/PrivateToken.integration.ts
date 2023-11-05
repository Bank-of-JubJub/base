import { assert, expect } from "chai";
import * as fs from "fs";
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
  hexToBigInt,
} from "viem";
import { hardhat } from "viem/chains";
import { Contract } from "hardhat/internal/hardhat-network/stack-traces/model.js";
import exp from "constants";
// import * as proofUtils from "../../utils/proof_utils.js";

const viem = hre.viem;
const BJJ_PRIME =
  21888242871839275222246405745257275088548364400416034343698204186575808495617n;

let process_pending_deposits_inputs = {
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

const transfer_inputs = {
  // 5, ecrypted to `to`
  amount: {
    C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
    C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
    C2x: 0x25bd68ade5a08a4a012250cff52bd6e92752413aacb5a01ef8157e7c65b1b1c6n,
    C2y: 0x22ce61a67a4ee826534fca1d6276fd1c80ff05a5831f90ce1c9f5963a6393e5fn,
  },
  // 992, encrypted to `from`
  newSenderBalance: {
    C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
    C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
    C2x: 0x2795109cf233e0d54d88f75d6c8b28b37ea224b6083e2f76efed55710e1fd425n,
    C2y: 0x3006aa76f9499aeee9080237f3c24005be7ca83627f6600f7b278dff77a37df5n,
  },
};

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
    const proof = (await getProof(
      "../proofs/process_pending_deposits.proof"
    )) as `0x${string}`;

    const txsToProcess = [0n];
    const feeRecipient =
      "0xbEa2940f35737EDb9a9Ad2bB938A955F9b7892e3" as `0x${string}`;

    await processPendingDeposit(
      proof,
      privateToken,
      txsToProcess,
      feeRecipient,
      recipient,
      process_pending_deposits_inputs
    );

    let balance = await privateToken.read.balances([recipient]);
    expect(balance[0] == process_pending_deposits_inputs.new_enc_balance_1.C1x);
    expect(balance[1] == process_pending_deposits_inputs.new_enc_balance_1.C1y);
    expect(balance[2] == process_pending_deposits_inputs.new_enc_balance_1.C2x);
    expect(balance[3] == process_pending_deposits_inputs.new_enc_balance_1.C2y);
  });

  it("should perform transfers", async function () {
    const { privateToken, token, walletClient0, walletClient1 } = await setup();
    const { recipient, convertedAmount, fee } = await deposit(
      privateToken,
      token,
      walletClient0
    );

    const processDepositProof = (await getProof(
      "../proofs/process_pending_deposits.proof"
    )) as `0x${string}`;

    const txsToProcess = [0n];
    const feeRecipient =
      "0xbEa2940f35737EDb9a9Ad2bB938A955F9b7892e3" as `0x${string}`;

    await processPendingDeposit(
      processDepositProof,
      privateToken,
      txsToProcess,
      feeRecipient,
      recipient,
      process_pending_deposits_inputs
    );

    const from = recipient;
    const to =
      "0x0c07999c15d406bc08d7f3f31f62cedbc89ebf3a53ff4d3bf7e2d0dda9314904";
    const processFee = 0;
    const relayFee = 2;
    const relayFeeRecipient = walletClient1.account.address as `0x${string}`;

    const amountToSend = 5;
    const filePath = "../proofs/transfer.proof";
    let proof = (await getProof(filePath)) as `0x${string}`;

    let res = await transfer(
      privateToken,
      to,
      from,
      processFee,
      relayFee,
      relayFeeRecipient,
      transfer_inputs,
      proof
    );

    let sender_balance = privateToken.read.balances([from]);
    let recipient_balance = privateToken.read.balances([to]);
  });
});

async function transfer(
  privateToken: any,
  to: string,
  from: string,
  processFee: number,
  relayFee: number,
  relayFeeRecipient: `0x${string}`,
  transfer_inputs: any,
  proof: string
) {
  return await privateToken.write.transfer([
    to,
    from,
    processFee,
    relayFee,
    relayFeeRecipient,
    transfer_inputs.amount,
    transfer_inputs.newSenderBalance,
    proof,
  ]);
}

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
  return (
    BigInt(
      keccak256(
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
            encryptedAmount.C2y,
          ]
        )
      )
    ) % BJJ_PRIME
  );
}

async function getProof(filePath: string) {
  let proof = "";
  try {
    const data = fs.readFileSync(filePath, { encoding: "utf-8" });
    proof = `0x${data}`;
  } catch (error) {
    console.error("Error reading file:", error);
  }
  return proof;
}

async function processPendingDeposit(
  proof: any,
  privateToken: any,
  txsToProcess: any,
  feeRecipient: any,
  recipient: any,
  inputs: any
) {
  await privateToken.write.processPendingDeposit([
    proof,
    txsToProcess,
    feeRecipient,
    recipient,
    inputs.old_enc_balance_1,
    inputs.new_enc_balance_1,
  ]);
}
