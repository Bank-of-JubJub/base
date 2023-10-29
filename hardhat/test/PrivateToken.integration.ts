import { expect } from "chai";
import { before, beforeEach } from "mocha";
import hre from "hardhat";
import { spawn } from "child_process";
import * as babyjubjubUtils from "../../utils/babyjubjub_utils.js";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { Address, createPublicClient, http, GetContractReturnType } from "viem";
import { hardhat } from "viem/chains";
import { Contract } from "hardhat/internal/hardhat-network/stack-traces/model.js";
// import * as proofUtils from "../../utils/proof_utils.js";

const viem = hre.viem;

// A deployment function to set up the initial state
const deploy = async (name: string, construtorArgs: any[]) => {
  const returnContract = await viem.deployContract(name, construtorArgs);

  return { returnContract };
};

type Deployment = {
  path: string;
  deployArgs: any[];
  instance: null | GetContractReturnType;
};

type DeploymentDictionary = {
  [key: string]: Deployment;
};
let deployments: DeploymentDictionary = {
  pendingDepositVerifier: {
    path: "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier",
    deployArgs: [],
    instance: null,
  },
  pendingTransferVerifier: {
    path: "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier",
    deployArgs: [],
    instance: null,
  },
  transferVerifier: {
    path: "contracts/transfer/plonk_vk.sol:UltraVerifier",
    deployArgs: [],
    instance: null,
  },
  withdrawVerifier: {
    path: "contracts/withdraw/plonk_vk.sol:UltraVerifier",
    deployArgs: [],
    instance: null,
  },
  lockVerifier: {
    path: "contracts/lock/plonk_vk.sol:UltraVerifier",
    deployArgs: [],
    instance: null,
  },
  erc20: {
    path: "FunToken",
    deployArgs: [],
    instance: null,
  },
};
const deployAll = async () => {
  const publicClient = await hre.viem.getPublicClient();
  const [walletClient0, walletClient1] = await hre.viem.getWalletClients();

  for (const contract in deployments) {
    if (deployments.hasOwnProperty(contract)) {
      let deployment = deployments[contract as keyof DeploymentDictionary];
      const { returnContract: instance } = await deploy(
        deployment.path,
        deployment.deployArgs
      );
      deployment.instance = instance;
    }
  }
  const deployArgs = [
    deployments.pendingDepositVerifier.instance?.address,
    deployments.pendingTransferVerifier.instance?.address,
    deployments.transferVerifier.instance?.address,
    deployments.withdrawVerifier.instance?.address,
    deployments.lockVerifier.instance?.address,
  ];

  const { returnContract: privateTokenFactory } = await deploy(
    "PrivateTokenFactory",
    deployArgs
  );
  let { request } = await publicClient.simulateContract({
    address: privateTokenFactory.address,
    functionName: "deploy",
    abi: privateTokenFactory.abi,
    account: walletClient0.account,
    args: [deployments.erc20.instance?.address],
  });
  const res = await privateTokenFactory.write.deploy([
    deployments.erc20.instance?.address,
  ]);
  console.log(res);
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

describe("Private Token integration testing", async function () {
  it("should deploy a Private token from the factory", async () => {
    await deployAll();
  });
});
