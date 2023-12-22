import {
  BojAccount,
  EncryptedBalance,
  PointObjects,
  PointObjectsWithRandomness,
} from "../utils/types";
import { toBytes, toHex } from "viem";
import {
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getC1PointFromEncryptedBalance,
  getC2PointFromEncryptedBalance,
  getEncryptedValue,
} from "../utils/utils";
import { createAndWriteToml } from "../../createToml";
import { runNargoProve } from "../utils/generateNargoProof";
import { getProcessDepositProof, getTransferProof } from "../utils/config";
import BabyJubJubUtils from "../utils/babyJubJubUtils";

export class ProcessDepositCoordinator {
  private relayFeeRecipient: `0x${string}` | null;
  private privateToken: any;
  private proof: string | null;
  private to: `0x${string}`;
  private newBalance: EncryptedBalance | null;
  private txsToProcess: number[] | null;
  private zeroBalance: EncryptedBalance | null;
  private amount: PointObjectsWithRandomness | null;
  private totalAmount: number;
  private startingAmount: EncryptedBalance | null;

  constructor(
    privateToken: any,
    to: `0x${string}`,
    relayFeeRecipient: `0x${string}`
  ) {
    this.relayFeeRecipient = relayFeeRecipient;
    this.to = to;
    this.newBalance = null;
    this.privateToken = privateToken;
  }

  public async init() {
    const babyjub = new BabyJubJubUtils();
    babyjub.init();

    this.startingAmount = encryptedValueToEncryptedBalance(
      await this.privateToken.read.balances([this.to])
    );

    for (let i = 0; i < this.txsToProcess!.length; i++) {
      const pendingDeposit =
        (await this.privateToken.read.allPendingDepositsMapping([
          this.to,
          BigInt(this.txsToProcess![i]),
        ])) as [bigint, number]; // [amount, fee]
      this.totalAmount += Number(pendingDeposit[0]);
    }

    this.amount = getEncryptedValue(this.to, this.totalAmount);
    const C1 = babyjub.add_points(
      { x: this.startingAmount!.C1x, y: this.startingAmount!.C1y },
      this.amount!.C1
    );
    const C2 = babyjub.add_points(
      { x: this.startingAmount!.C2x, y: this.startingAmount!.C2y },
      this.amount!.C2
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
      randomness: toHex(this.amount!.randomness, { size: 32 }),
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
    this.proof = await getProcessDepositProof();
  }

  public async sendProcessDeposit() {
    const hash = await this.privateToken.write.processPendingDeposit([
      this.proof,
      this.txsToProcess, // [], // txs to process, a list of ids.
      this.relayFeeRecipient,
      this.zeroBalance,
      this.newBalance,
    ]);

    return hash;
  }
}
