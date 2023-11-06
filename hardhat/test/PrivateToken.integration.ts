import { assert, expect } from "chai";
import * as fs from "fs";
import hre from "hardhat";
import { spawn } from "child_process";
import { keccak256, encodeAbiParameters } from "viem";
import BabyJubJubUtils from "../utils/babyJubJubUtils.ts";
// import * as proofUtils from "../../utils/proof_utils.js";

import {
  BJJ_PRIME,
  processDepositInputs,
  processTransferInputs,
  account1,
  account2,
  processFeeRecipient,
} from "../utils/config.ts";

const viem = hre.viem;

// let account1 = "" as `0x${string}`;

const babyjub = new BabyJubJubUtils();

describe("Private Token integration testing", async function () {
  it("should add a deposit", async () => {
    const { privateToken, account1, convertedAmount, fee } = await deposit();

    let pending = await privateToken.read.pendingDepositCounts([account1]);
    assert(pending == 1n, "Pending deposits should be 1.");

    let pendingDeposit = await privateToken.read.allPendingDepositsMapping([
      account1,
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
    const { privateToken, account1 } = await processPendingDeposit(
      [0n], // txs (indeexes) to process
      processDepositInputs
    );

    let balance = await privateToken.read.balances([account1]);
    expect(balance[0] == processDepositInputs.new_enc_balance_1.C1x);
    expect(balance[1] == processDepositInputs.new_enc_balance_1.C1y);
    expect(balance[2] == processDepositInputs.new_enc_balance_1.C2x);
    expect(balance[3] == processDepositInputs.new_enc_balance_1.C2y);
  });

  it("should perform transfers", async function () {
    const { privateToken } = await transfer(
      account2, // to
      account1, // from
      0, // process fee
      2, // relay fee
      processTransferInputs
    );

    let sender_balance = privateToken.read.balances([account1]);
    let recipient_balance = privateToken.read.balances([account2]);
  });

  it("should process pending transfers", async () => {});

  it("should do withdrawals", async () => {
    const {
      privateToken,
      token,
      walletClient0,
      walletClient1,
      account1,
      convertedAmount,
      fee,
    } = await deposit();

    const txsToProcess = [0n];
    const {} = await processPendingDeposit(txsToProcess, processDepositInputs);

    const from = account1;
    const processFee = 0;
    const relayFee = 2;

    let proof = (await getProof("../proofs/transfer.proof")) as `0x${string}`;

    await transfer(account2, from, processFee, relayFee, processTransferInputs);

    const amount = 5;
    const withdrawRelayFee = 1;
    const withdrawProof = (await getProof(
      "../proofs/withdraw.proof"
    )) as `0x${string}`;

    const newEncryptedBalance = {
      C1x: 0x034ed15cc9c368232e3926503d285e05f1ebed691e83dd928ca96c9ef0ce7368n,
      C1y: 0x0967e26ca6d6476a92fdf6e3417219351a51c337fb0a43fcfedc50f3009c036fn,
      C2x: 0x24992c487642ad804322be7024633e21857873c6b2f169a4dd3a370985d46678n,
      C2y: 0x25e90aa472ac81af98d86ae821ae2a50808066149b20c76e67a4cb6838054b2en,
    };

    console.log("TODO: finish withdraw test");

    // await privateToken.write.withdraw([
    //   from,
    //   walletClient0.account.address,
    //   amount,
    //   withdrawRelayFee,
    //   relayFeeRecipient,
    //   withdrawProof,
    //   newEncryptedBalance,
    // ]);
  });
});

async function transfer(
  to: `0x${string}`,
  from: `0x${string}`,
  processFee: number,
  relayFee: number
) {
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    fee,
  } = await processPendingDeposit([0], processDepositInputs);
  let proof = (await getProof("../proofs/transfer.proof")) as `0x${string}`;
  const relayFeeRecipient = walletClient1.account.address as `0x${string}`;

  await privateToken.write.transfer([
    to,
    from,
    processFee,
    relayFee,
    relayFeeRecipient,
    processTransferInputs.amount,
    processTransferInputs.newSenderBalance,
    proof,
  ]);

  return {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    fee,
    relayFeeRecipient,
  };
}

async function deposit() {
  const { privateToken, token, walletClient0, walletClient1 } = await setup();
  let balance = await token.read.balanceOf([walletClient0.account.address]);
  await token.write.approve([privateToken.address, balance]);

  let tokenDecimals = (await token.read.decimals()) as number;
  let bojDecimals = await privateToken.read.decimals();

  let depositAmount = BigInt(10 * 10 ** 18);
  let convertedAmount =
    BigInt(depositAmount) / BigInt(10 ** (tokenDecimals - bojDecimals));
  let fee = 1;

  await privateToken.write.deposit([
    walletClient0.account.address,
    depositAmount,
    account1,
    fee,
  ]);

  return {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    account1,
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

function hexToUint8Array(hexString: string): Uint8Array {
  // Ensure the input string length is even
  if (hexString.length % 2 !== 0) {
    throw new Error("Hex string must have an even number of characters");
  }

  const arrayBuffer = new Uint8Array(hexString.length / 2);

  for (let i = 0; i < arrayBuffer.length; i++) {
    const byteValue = parseInt(hexString.substr(i * 2, 2), 16);
    if (Number.isNaN(byteValue)) {
      throw new Error("Invalid hex string");
    }
    arrayBuffer[i] = byteValue;
  }

  console.log(arrayBuffer);

  return arrayBuffer;
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

async function processPendingDeposit(txsToProcess: any, inputs: any) {
  const proof = (await getProof(
    "../proofs/process_pending_deposits.proof"
  )) as `0x${string}`;
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    account1,
    convertedAmount,
    fee,
  } = await deposit();

  await privateToken.write.processPendingDeposit([
    proof,
    txsToProcess,
    processFeeRecipient,
    account1,
    inputs.old_enc_balance_1,
    inputs.new_enc_balance_1,
  ]);
  return {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    account1,
    convertedAmount,
    fee,
  };
}
