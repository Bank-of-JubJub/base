import { assert, expect } from "chai";
import * as fs from "fs";
import hre from "hardhat";
import { spawn } from "child_process";
import BabyJubJubUtils from "../utils/babyJubJubUtils.ts";
// import * as proofUtils from "../../utils/proof_utils.js";
import { EncryptedBalanceArray, EncryptedBalance } from "../utils/types.ts";

import {
  account1,
  account2,
  processFeeRecipient,
  getTransferProof,
  getProcessDepositProof,
  getProcessTransfersProof,
  getWithdrawProof,
  transferProcessFee,
  transferRelayFee,
  depositProcessFee,
  getProcessDepositInputs,
  getTransferInputs,
  getProcessTransferInputs,
} from "../utils/config.ts";

const viem = hre.viem;

const babyjub = new BabyJubJubUtils();

let processDepositInputs = {
  oldBalance: {} as EncryptedBalance,
  newBalance: {} as EncryptedBalance,
};

let transferInputs = {
  encryptedAmount: {} as EncryptedBalance,
  encryptedNewBalance: {} as EncryptedBalance,
};
let processTransferInputs = {
  encryptedNewBalance: {} as EncryptedBalance,
};

describe("Private Token integration testing", async function () {
  this.beforeAll(async () => {
    processDepositInputs = getProcessDepositInputs(account1, 0, 999);
    transferInputs = getTransferInputs(account2, account1, 5, 992);
  });

  it("should add a deposit", async () => {
    await babyjub.init();

    const { privateToken, account1, convertedAmount, fee } = await deposit();

    let pending = await privateToken.read.pendingDepositCounts([account1]);
    assert(pending == 1n, "Pending deposits should be 1.");

    let pendingDeposit = (await privateToken.read.allPendingDepositsMapping([
      account1,
      0n,
    ])) as [bigint, number];

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
      [0n], // txs (indexes) to process
      processDepositInputs
    );

    let balance = (await privateToken.read.balances([
      account1,
    ])) as EncryptedBalanceArray;
    expect(balance[0] == processDepositInputs.newBalance.C1x);
    expect(balance[1] == processDepositInputs.newBalance.C1y);
    expect(balance[2] == processDepositInputs.newBalance.C2x);
    expect(balance[3] == processDepositInputs.newBalance.C2y);
  });

  it("should perform transfers", async function () {
    const { privateToken } = await transfer(
      account2, // to
      account1 // from
    );

    let sender_balance = privateToken.read.balances([account1]);
    let recipient_balance = privateToken.read.balances([account2]);

    console.log();
  });

  it("should process pending transfers", async () => {
    await processPendingTransfer();
    console.log("TODO: implement test");
  });

  it("should do withdrawals", async () => {
    console.log("TODO: finish withdraw test");
  });
});

async function processPendingTransfer() {
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    fee,
    relayFeeRecipient,
  } = await transfer(account2, account1);

  // need to do another transfer since the first transfer from an account doesnt need to be processed
  // await privateToken.write.transfer([
  //   account2,
  //   account1,
  //   transferProcessFee,
  //   transferRelayFee,
  //   relayFeeRecipient,
  //   transferInputs.encryptedAmount,
  //   transferInputs.encryptedNewBalance,
  //   proof,
  // ]);

  // let proof = await getProcessTransfersProof();

  let oldBalance = await privateToken.read.balances([account2]);
  let count = await privateToken.read.pendingTransferCounts([account2]);
  let pendingTransfer = await privateToken.read.allPendingTransfersMapping([
    account2,
    0n,
  ]);

  console.log(count);
  //let processTransferInputs = getProcessTransferInputs(account2, oldBalance);

  // await privateToken.write.processPendingTransfer([
  //   proof,
  //   [0],
  //   processFeeRecipient,
  //   account2,
  //   //processTransferInputs.newSenderBalance,
  //   //getEncryptedValue(account1, 992),
  // ]);
}

async function transfer(to: `0x${string}`, from: `0x${string}`) {
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    fee,
  } = await processPendingDeposit([0], processDepositInputs);
  let proof = await getTransferProof();
  const relayFeeRecipient = walletClient1.account.address as `0x${string}`;

  await privateToken.write.transfer([
    to,
    from,
    transferProcessFee,
    transferRelayFee,
    relayFeeRecipient,
    transferInputs.encryptedAmount,
    transferInputs.encryptedNewBalance,
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
  let bojDecimals = (await privateToken.read.decimals()) as number;

  let depositAmount = BigInt(10 * 10 ** 18);
  let convertedAmount =
    BigInt(depositAmount) / BigInt(10 ** (tokenDecimals - bojDecimals));
  let fee = 1;

  await privateToken.write.deposit([
    walletClient0.account.address,
    depositAmount,
    account1,
    depositProcessFee,
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
  // @ts-ignore
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

async function processPendingDeposit(txsToProcess: any, inputs: any) {
  const proof = await getProcessDepositProof();
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
    processDepositInputs.oldBalance,
    processDepositInputs.newBalance,
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
