import {
  EncryptedBalance,
  EncryptedBalanceArray,
  PointObjectsWithRandomness,
} from "boj-types";
import {
  isAddress,
  toBytes,
  toHex,
  getContract,
  PublicClient,
  WalletClient,
} from "viem";
import {
  BabyJubJubUtils,
  createAndWriteToml,
  encryptedBalanceArrayToEncryptedBalance,
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getC1PointFromEncryptedBalance,
  getC2PointFromEncryptedBalance,
  getEncryptedValue,
  getProcessDepositProof,
  runNargoProve
} from "boj-utils";
import * as artifact from "../../hardhat/artifacts/contracts/PrivateToken.sol/PrivateToken.json" assert { type: "json"};

import { fileURLToPath } from 'url';
import { dirname } from 'path';

export class ProcessDepositCoordinator {
  private relayFeeRecipient: `0x${string}` | null;
  private proof: `0x${string}` | null;
  private to: `0x${string}`;
  private newBalance: EncryptedBalance | null;
  private txsToProcess: bigint[] | null;
  private zeroBalance: EncryptedBalance | null;
  private encryptedAmount: PointObjectsWithRandomness | null;
  private totalAmount: number;
  private startingAmount: EncryptedBalance | null;
  private minFeeToProcess: number;
  private privateTokenAddress: `0x${string}`;
  private walletClient: WalletClient;
  private publicClient: PublicClient;

  constructor(
    to: `0x${string}`,
    relayFeeRecipient: `0x${string}`,
    minFeeToProcess: number = 0,
    privateTokenAddress: `0x${string}`,
    publicClient: PublicClient,
    walletClient: WalletClient
  ) {
    this.relayFeeRecipient = relayFeeRecipient;
    this.privateTokenAddress = privateTokenAddress;
    this.to = to;
    this.newBalance = null;
    this.zeroBalance = null;
    this.txsToProcess = null;
    this.encryptedAmount = null;
    this.totalAmount = 0;
    this.startingAmount = null;
    this.proof = null;
    this.minFeeToProcess = minFeeToProcess;
    this.walletClient = walletClient;
    this.publicClient = publicClient;

    if (!isAddress(relayFeeRecipient)) {
      throw new Error("Invalid address");
    }
  }

  public async init() {
    const privateToken = await getContract({
      abi: artifact.default.abi,
      address: this.privateTokenAddress,
      client: {
        public: this.publicClient
      }
    });
    const babyjub = new BabyJubJubUtils();
    await babyjub.init();

    this.startingAmount = encryptedBalanceArrayToEncryptedBalance(
      (await privateToken.read.balances([this.to])) as EncryptedBalanceArray
    );

    // if balance == 0, set the starting amount to encrypted 0
    if (
      this.startingAmount.C1x == 0n &&
      this.startingAmount.C1y == 0n &&
      this.startingAmount.C2x == 0n &&
      this.startingAmount.C2y == 0n
    ) {
      this.startingAmount = encryptedValueToEncryptedBalance(
        getEncryptedValue(this.to, 0)
      );
      this.zeroBalance = this.startingAmount;
    }

    // stage 4 deposits for processing
    let count = (await privateToken.read.pendingDepositCounts([
      this.to,
    ])) as number;
    this.txsToProcess = [] as bigint[];
    for (let i = 0; i < count; i++) {
      let pending = (await privateToken.read.allPendingDepositsMapping([
        this.to,
        BigInt(i),
      ])) as [bigint, number];
      const processFee = pending[1];
      if (processFee >= this.minFeeToProcess && pending[0] > BigInt(0)) {
        this.txsToProcess.push(BigInt(i));
      }
      if (this.txsToProcess.length == 4) break;
    }

    // process the txs in the array, add them to the total amount
    for (let i = 0; i < this.txsToProcess!.length; i++) {
      const pendingDeposit = (await privateToken.read.allPendingDepositsMapping(
        [this.to, BigInt(this.txsToProcess![i])]
      )) as [bigint, number]; // [amount, fee]
      this.totalAmount += Number(pendingDeposit[0]);
    }

    // encrypt it
    this.encryptedAmount = getEncryptedValue(this.to, this.totalAmount);

    // add the encrypted values
    const C1 = babyjub.add_points(
      { x: this.startingAmount!.C1x, y: this.startingAmount!.C1y },
      this.encryptedAmount!.C1
    );
    const C2 = babyjub.add_points(
      { x: this.startingAmount!.C2x, y: this.startingAmount!.C2y },
      this.encryptedAmount!.C2
    );
    this.newBalance = {
      C1x: C1.x,
      C1y: C1.y,
      C2x: C2.x,
      C2y: C2.y,
    } as EncryptedBalance;
  }

  public async generateProof() {
    const proofInputs = {
      randomness: toHex(this.encryptedAmount!.randomness, { size: 32 }),
      amount_sum: this.totalAmount,
      packed_public_key: Array.from(toBytes(this.to)),
      packed_public_key_modulus: fromRprLe(this.to),
      old_enc_balance_1: getC1PointFromEncryptedBalance(this.startingAmount!),
      old_enc_balance_2: getC2PointFromEncryptedBalance(this.startingAmount!),
      new_enc_balance_1: getC1PointFromEncryptedBalance(this.newBalance!),
      new_enc_balance_2: getC2PointFromEncryptedBalance(this.newBalance!),
    };

    createAndWriteToml("process_pending_deposits", proofInputs);
    await runNargoProve("process_pending_deposits", "Test.toml");

    // Get the current file's directory
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = dirname(__filename);

    console.log("process deposit coordinator dirname", __dirname)

    this.proof = await getProcessDepositProof();
  }

  public async sendProcessDeposit() {
    const privateToken = await getContract({
      abi: artifact.default.abi,
      address: this.privateTokenAddress,
      client: {
        wallet: this.walletClient
      }
    });
    const hash = await privateToken.write.processPendingDeposit([
      this.proof!,
      this.txsToProcess!, // [], // txs to process, a list of ids.
      this.relayFeeRecipient!,
      this.to,
      this.zeroBalance!,
      this.newBalance!,
    ]);

    return hash;
  }
}
