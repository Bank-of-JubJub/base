import { BojAccount, EncryptedBalance } from "../utils/types";
import { isAddress, toBytes, toHex } from "viem";
import {
  encryptedBalanceArrayToEncryptedBalance,
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getDecryptedValue,
  getEncryptedValue,
  getNonce,
} from "../utils/utils";
import { createAndWriteToml } from "../../createToml";
import { runNargoProve } from "../utils/generateNargoProof";
import { getWithdrawProof } from "../utils/config";

export class WithdrawCoordinator {
  private proof: string | null;
  private privateToken: any;
  private from: BojAccount;
  private to: `0x${string}`;
  private relayFee: bigint;
  private relayFeeRecipient: `0x${string}`;
  private amount: bigint;
  private isTest: boolean;
  private randomness: bigint;
  private clearOldBalance: bigint;
  private encNewBalance: EncryptedBalance;
  private encOldBalance: EncryptedBalance;

  constructor(
    privateToken: any,
    to: `0x${string}`,
    from: BojAccount,
    amount: bigint,
    relayFee: bigint,
    relayFeeRecipient: `0x${string}`,
    isTest: boolean = false
  ) {
    if (!isAddress(to)) {
      throw new Error("Invalid address");
    }
    if (!isAddress(relayFeeRecipient)) {
      throw new Error("Invalid address");
    }
    this.to = to;
    this.from = from;
    this.relayFee = relayFee;
    this.relayFeeRecipient = relayFeeRecipient;
    this.privateToken = privateToken;
    this.proof = null;
    this.isTest = isTest;
    this.randomness = BigInt(0);
    this.clearOldBalance = BigInt(0);
    this.amount = amount;
    this.encNewBalance = {
      C1x: BigInt(0),
      C1y: BigInt(0),
      C2x: BigInt(0),
      C2y: BigInt(0),
    };
    this.encOldBalance = {
      C1x: BigInt(0),
      C1y: BigInt(0),
      C2x: BigInt(0),
      C2y: BigInt(0),
    };
  }

  public async init() {
    const unfmtEncOldBalance = await this.privateToken.read.balances([
      this.from.packedPublicKey,
    ]);
    this.encOldBalance =
      encryptedBalanceArrayToEncryptedBalance(unfmtEncOldBalance);

    this.clearOldBalance = (await getDecryptedValue(
      this.from,
      unfmtEncOldBalance
    )) as bigint;
    const newBalanceClear = this.clearOldBalance - this.relayFee - this.amount;

    const unfmtEncNewBalance = getEncryptedValue(
      this.from.packedPublicKey,
      Number(newBalanceClear),
      this.isTest
    );
    this.randomness = unfmtEncNewBalance.randomness;
    this.encNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);
  }

  public async generateProof() {
    const proofInputs = {
      private_key: this.from.privateKey,
      randomness: toHex(this.randomness, { size: 32 }),
      balance_old_clear: toHex(this.clearOldBalance, { size: 32 }),
      packed_public_key: Array.from(toBytes(this.from.packedPublicKey)),
      packed_public_key_modulus: fromRprLe(this.from.packedPublicKey),
      nonce_private: toHex(getNonce(this.encNewBalance), { size: 32 }),
      nonce: toHex(getNonce(this.encNewBalance), { size: 32 }),
      value: toHex(this.amount, { size: 32 }),
      relay_fee: toHex(this.relayFee, { size: 32 }),
      balance_old_encrypted_1: {
        x: toHex(this.encOldBalance.C1x, { size: 32 }),
        y: toHex(this.encOldBalance.C1y, { size: 32 }),
      },
      balance_old_encrypted_2: {
        x: toHex(this.encOldBalance.C2x, { size: 32 }),
        y: toHex(this.encOldBalance.C2y, { size: 32 }),
      },
      balance_new_encrypted_1: {
        x: toHex(this.encNewBalance.C1x, { size: 32 }),
        y: toHex(this.encNewBalance.C1y, { size: 32 }),
      },
      balance_new_encrypted_2: {
        x: toHex(this.encNewBalance.C2x, { size: 32 }),
        y: toHex(this.encNewBalance.C2y, { size: 32 }),
      },
    };
    createAndWriteToml("withdraw", proofInputs);
    await runNargoProve("withdraw", "Test.toml");
    this.proof = await getWithdrawProof();
  }

  public async sendWithdraw() {
    const hash = await this.privateToken.write.withdraw([
      this.from.packedPublicKey,
      this.to,
      this.amount,
      this.relayFee,
      this.relayFeeRecipient,
      this.proof,
      this.encNewBalance,
    ]);

    return hash;
  }
}
