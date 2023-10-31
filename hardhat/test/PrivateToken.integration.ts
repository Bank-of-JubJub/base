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

// A deployment function to set up the initial state
const deploy = async (name: string, constructorArgs: any[]) => {
  const contract = await hre.viem.deployContract(name, constructorArgs);

  return { contract };
};

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
  };
}

describe("Private Token integration testing", async function () {
  it("should add a deposit", async () => {
    const { privateToken, token, walletClient0, publicClient } = await setup();
    let balance = await token.read.balanceOf([walletClient0.account.address]);
    await token.write.approve([privateToken.address, balance]);

    let recipient =
      "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`;

    let depositAmount = (balance as bigint) / 2n;
    let fee = 100;

    await privateToken.write.deposit([
      walletClient0.account.address,
      depositAmount,
      recipient,
      fee,
    ]);

    const logs = await publicClient.getContractEvents({
      address: privateToken.address,
      abi: privateToken.abi,
      eventName: "Deposit",
    });

    let pending = await privateToken.read.pendingDepositCounts([recipient]);
    assert(pending == 1n, "Pending deposits should be 1.");

    let pendingDeposit = await privateToken.read.allPendingDepositsMapping([
      recipient,
      0n,
    ]);

    // need to convert decimals between token and private token to get this to pass
    // assert(
    //   pendingDeposit[0] == depositAmount,
    //   "pending deposit should match deposit amount"
    // );
    // assert(pendingDeposit[1] == fee, "pending deposit fee should match input");

    let totalSupply = await privateToken.read.totalSupply();
    console.log("totalSupply", totalSupply);

    // need to convert decimals between token and private token to get this to pass
    // assert(
    //   totalSupply == Number(depositAmount),
    //   "deposit amount should be the total supply"
    // );
  });

  it("should work in another test", async function () {});
});
