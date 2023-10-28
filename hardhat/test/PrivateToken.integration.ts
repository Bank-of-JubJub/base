import { expect } from "chai";
import hre from "hardhat";
import "@nomicfoundation/hardhat-ethers";
import { spawn } from "child_process";
import * as babyjubjubUtils from "../../utils/babyjubjub_utils.js";
import * as proofUtils from "../../utils/proof_utils.js";

import { UltraVerifier } from "../types/index.js";

const ethers = hre.ethers;

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

describe("Private Token integration testing", function () {
  let pendingDepositVerifier;
  let transferVerifier;
  let pendingTransferVerifier;
  let withdrawVerifier;
  let lockVerifier;
  let accounts;
  let userA;
  let userB;
  let privateKeyDeployer;
  let publicKeyDeployer;
  let privateKeyUserA;
  let publicKeyUserA;
  let privateKeyUserB;
  let publicKeyUserB;
  let totalSupply;

  -beforeAll(async () => {
    //Setup phase with initial deployments
    accounts = await hre.ethers.getSigners();
    let deployer = accounts[0];
    userA = accounts[1];
    userB = accounts[2];

    console.log(
      "Deploying the verification contracts - these could be deployed only once and used for all the instances of private tokens"
    );

    pendingDepositVerifier = await ethers.deployContract(
      "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier"
    );
    pendingTransferVerifier = await ethers.deployContract(
      "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier"
    );

    transferVerifier = await ethers.deployContract(
      "contracts/transfer/plonk_vk.sol:UltraVerifier"
    );

    withdrawVerifier = await ethers.deployContract(
      "contracts/withdraw/plonk_vk.sol:UltraVerifier"
    );
    lockVerifier = await ethers.deployContract(
      "contracts/lock/plonk_vk.sol:UltraVerifier"
    );


    const privateTokenFactoryFactory = await hre.ethers.deployContract(
      "contracts/PrivateTokenFactory"
    );

    console.log("verifiers deployed");
    const privateTokenFactory = await privateTokenFactoryFactory.deploy(
      pendingDepositVerifier,
      pendingTransferVerifier,
      transferVerifier,
      withdrawVerifier,
      lockVerifier
    );

    // const erc20 = await hre.ethers.


  });
});
