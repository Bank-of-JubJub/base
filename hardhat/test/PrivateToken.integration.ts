import { assert, expect } from "chai";
import * as fs from "fs";
import hre from "hardhat";
import { spawn } from "child_process";
import BabyJubJubUtils from "../utils/babyJubJubUtils.ts";
// import * as proofUtils from "../../utils/proof_utils.js";
import { EncryptedBalanceArray, EncryptedBalance } from "../utils/types.ts";
import { runNargoProve } from "../test/generateNargoProof";
import {
  account1,
  account2,
  processFeeRecipient,
  transferProcessFee,
  transferRelayFee,
  depositAmount,
  depositProcessFee,
  random,
  transferAmount,
} from "../utils/constants.ts";

import {
  getTransferProof,
  getProcessDepositProof,
  getProcessTransfersProof,
  getWithdrawProof,
  getProcessDepositInputs,
  getTransferInputs,
  getProcessTransferInputs,
} from "../utils/config.ts";
import { TomlKeyValue, createAndWriteToml } from "../../createToml.ts";
import {
  formatEncryptedValueForToml,
  getC1PointFromEncryptedBalance,
  getEncryptedValue,
  getNonce,
  hexToUint8Array,
} from "../utils/utils.ts";

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

let convertedAmount: bigint;
let processDepositProof: `0x${string}`;
let transferProof: `0x${string}`;

describe("Private Token integration testing", async function () {
  this.beforeAll(async () => {
    processDepositInputs = getProcessDepositInputs(
      account1.packedPublicKey,
      0,
      999
    );
    transferInputs = getTransferInputs(
      account2.packedPublicKey,
      account1.packedPublicKey,
      transferAmount,
      992
    );
  });

  it("should add a deposit", async () => {
    await babyjub.init();

    const { privateToken, account1, convertedAmount, depositProcessFee } =
      await deposit();

    let pending = await privateToken.read.pendingDepositCounts([
      account1.packedPublicKey,
    ]);
    assert(pending == 1n, "Pending deposits should be 1.");

    let pendingDeposit = (await privateToken.read.allPendingDepositsMapping([
      account1.packedPublicKey,
      0n,
    ])) as [bigint, number];

    const expectedAmount = convertedAmount - BigInt(depositProcessFee);
    let totalSupply = await privateToken.read.totalSupply();

    assert(
      pendingDeposit[0] == expectedAmount,
      "pending deposit should match deposit amount"
    );
    assert(
      pendingDeposit[1] == depositProcessFee,
      "pending deposit fee should match input"
    );
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
      account1.packedPublicKey,
    ])) as EncryptedBalanceArray;
    expect(balance[0] == processDepositInputs.newBalance.C1x);
    expect(balance[1] == processDepositInputs.newBalance.C1y);
    expect(balance[2] == processDepositInputs.newBalance.C2x);
    expect(balance[3] == processDepositInputs.newBalance.C2y);
  });

  it("should perform transfers", async function () {
    const { privateToken } = await transfer(
      account2.packedPublicKey, // to
      account1.packedPublicKey // from
    );

    let sender_balance = privateToken.read.balances([account1.packedPublicKey]);
    let recipient_balance = privateToken.read.balances([
      account2.packedPublicKey,
    ]);
  });

  it("should process pending transfers", async () => {
    await processPendingTransfer();
    console.log("TODO: implement test");
  });

  it("should do withdrawals", async () => {
    console.log("TODO: finish withdraw test");
  });
});

async function deposit() {
  const { privateToken, token, walletClient0, walletClient1 } = await setup();
  let balance = await token.read.balanceOf([walletClient0.account.address]);
  await token.write.approve([privateToken.address, balance]);

  let tokenDecimals = (await token.read.decimals()) as number;
  let bojDecimals = (await privateToken.read.decimals()) as number;

  convertedAmount =
    BigInt(depositAmount) / BigInt(10 ** (tokenDecimals - bojDecimals));

  await privateToken.write.deposit([
    walletClient0.account.address,
    depositAmount,
    account1.packedPublicKey,
    depositProcessFee,
  ]);

  return {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    account1,
    convertedAmount,
    depositProcessFee,
  };
}

async function processPendingDeposit(txsToProcess: any, inputs: any) {
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    account1,
    convertedAmount,
    depositProcessFee,
  } = await deposit();

  const proofInputs: Array<TomlKeyValue> = [
    {
      key: "randomness",
      value: random,
    },
    {
      key: "amount_sum",
      value: Number(convertedAmount) - depositProcessFee,
    },
    {
      key: "packed_public_key",
      value: Array.from(hexToUint8Array(account1.packedPublicKey)),
    },
    {
      key: "old_enc_balance_1",
      value: getC1PointFromEncryptedBalance(
        processDepositInputs.oldBalance,
        true
      ),
    },
    {
      key: "old_enc_balance_2",
      value: getC1PointFromEncryptedBalance(
        processDepositInputs.oldBalance,
        false
      ),
    },
    {
      key: "new_enc_balance_1",
      value: getC1PointFromEncryptedBalance(
        processDepositInputs.newBalance,
        true
      ),
    },
    {
      key: "new_enc_balance_2",
      value: getC1PointFromEncryptedBalance(
        processDepositInputs.newBalance,
        false
      ),
    },
  ];

  // TODO: optimize to only call once
  if (processDepositProof == undefined) {
    createAndWriteToml("process_pending_deposits", proofInputs);
    await runNargoProve("process_pending_deposits", "Test.toml");
    processDepositProof = await getProcessDepositProof();
  }

  await privateToken.write.processPendingDeposit([
    processDepositProof,
    txsToProcess,
    processFeeRecipient,
    account1.packedPublicKey,
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
    depositProcessFee,
  };
}

async function transfer(to: `0x${string}`, from: `0x${string}`) {
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    depositProcessFee,
  } = await processPendingDeposit([0], processDepositInputs);

  const encOldBalance = await privateToken.read.balances([
    account1.packedPublicKey,
  ]);

  const encryptedAmount = getEncryptedValue(
    account2.packedPublicKey,
    transferAmount
  );
  const encNewBalance = getEncryptedValue(
    account1.packedPublicKey,
    // 992
    Number(convertedAmount) -
      depositProcessFee -
      transferAmount -
      transferRelayFee
  );

  const proofInputs: Array<TomlKeyValue> = [
    {
      key: "balance_old_me_clear",
      value: Number(convertedAmount) - depositProcessFee,
    },
    {
      key: "private_key",
      value: account1.privateKey,
    },
    {
      key: "value",
      value: transferAmount,
    },
    {
      key: "randomness",
      value: random,
    },
    {
      key: "sender_pub_key",
      value: Array.from(hexToUint8Array(account1.packedPublicKey)),
    },
    {
      key: "recipient_pub_key",
      value: Array.from(hexToUint8Array(account2.packedPublicKey)),
    },
    {
      key: "process_fee",
      value: 0,
    },
    {
      key: "relay_fee",
      value: 2,
    },
    {
      key: "nonce",
      value: "0x" + getNonce(transferInputs.encryptedNewBalance).toString(16),
    },
    {
      key: "old_balance_encrypted_1",
      value: {
        x: "0x" + encOldBalance[0].toString(16),
        y: "0x" + encOldBalance[1].toString(16),
      },
    },
    {
      key: "old_balance_encrypted_2",
      value: {
        x: "0x" + encOldBalance[2].toString(16),
        y: "0x" + encOldBalance[3].toString(16),
      },
    },
    {
      key: "encrypted_amount_1",
      value: formatEncryptedValueForToml(encryptedAmount.C1),
    },
    {
      key: "encrypted_amount_2",
      value: formatEncryptedValueForToml(encryptedAmount.C2),
    },
    {
      key: "new_balance_encrypted_1",
      value: formatEncryptedValueForToml(encNewBalance.C1),
    },
    {
      key: "new_balance_encrypted_2",
      value: formatEncryptedValueForToml(encNewBalance.C2),
    },
  ];
  const relayFeeRecipient = walletClient1.account.address as `0x${string}`;

  try {
    if (transferProof == undefined) {
      createAndWriteToml("transfer", proofInputs);
      await runNargoProve("transfer", "Test.toml");
      transferProof = await getTransferProof();
    }

    await privateToken.write.transfer([
      to,
      from,
      transferProcessFee,
      transferRelayFee,
      relayFeeRecipient,
      transferInputs.encryptedAmount,
      transferInputs.encryptedNewBalance,
      transferProof,
    ]);
  } catch (e) {
    console.log(e);
  }

  return {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    depositProcessFee,
    relayFeeRecipient,
  };
}

async function processPendingTransfer() {
  const {
    privateToken,
    token,
    walletClient0,
    walletClient1,
    convertedAmount,
    depositProcessFee,
    relayFeeRecipient,
  } = await transfer(account2.packedPublicKey, account1.packedPublicKey);

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

  let oldBalance = await privateToken.read.balances([account2.packedPublicKey]);
  let count = await privateToken.read.pendingTransferCounts([
    account2.packedPublicKey,
  ]);
  let pendingTransfer = await privateToken.read.allPendingTransfersMapping([
    account2.packedPublicKey,
    0n,
  ]);

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
