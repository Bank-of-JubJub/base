import {
  BojAccount,
  EncryptedBalance,
  EncryptedBalanceArray,
} from "boj-types";
import {
  PublicClient,
  WalletClient,
  getContract,
  isAddress,
  toBytes,
  toHex,
} from "viem";
import {
  createAndWriteToml,
  encryptedBalanceArrayToEncryptedBalance,
  encryptedValueToEncryptedBalance,
  fromRprLe,
  getDecryptedValue,
  getEncryptedValue,
  getNonce,
  getWithdrawProof,
  runNargoProve
} from "boj-utils";
import * as artifact from "../../hardhat/artifacts/contracts/PrivateToken.sol/PrivateToken.json" assert { type: "json"};

export class WithdrawCoordinator {
  private proof: `0x${string}` | null;
  private privateTokenAddress: `0x${string}`;
  private from: BojAccount;
  private to: `0x${string}`;
  private relayFee: number;
  private relayFeeRecipient: `0x${string}`;
  private amount: number;
  private isTest: boolean;
  private randomness: bigint;
  private clearOldBalance: number;
  private encNewBalance: EncryptedBalance;
  private encOldBalance: EncryptedBalance;
  private walletClient: WalletClient;
  private publicClient: PublicClient;

  constructor(
    to: `0x${string}`,
    from: BojAccount,
    amount: number,
    relayFee: number,
    relayFeeRecipient: `0x${string}`,
    privateTokenAddress: `0x${string}`,
    publicClient: PublicClient,
    walletClient: WalletClient,
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
    this.privateTokenAddress = privateTokenAddress;
    this.relayFee = relayFee;
    this.relayFeeRecipient = relayFeeRecipient;
    this.proof = null;
    this.isTest = isTest;
    this.randomness = BigInt(0);
    this.clearOldBalance = 0;
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
    this.walletClient = walletClient;
    this.publicClient = publicClient;
  }

  public async init() {
    const privateToken = await getContract({
      abi: artifact.default.abi,
      address: this.privateTokenAddress,
      client: {
        public: this.publicClient
      }
    });

    const unfmtEncOldBalance = (await privateToken.read.balances([
      this.from.packedPublicKey,
    ])) as EncryptedBalanceArray;
    this.encOldBalance =
      encryptedBalanceArrayToEncryptedBalance(unfmtEncOldBalance);

    this.clearOldBalance = Number(
      await getDecryptedValue(this.from, unfmtEncOldBalance)
    );
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
    const privateToken = await getContract({
      abi: artifact.default.abi,
      address: this.privateTokenAddress,
      client: {
        wallet: this.walletClient
      }
    });
    const hash = await privateToken.write.withdraw([
      this.from.packedPublicKey,
      this.to,
      this.amount,
      this.relayFee,
      this.relayFeeRecipient,
      this.proof!,
      this.encNewBalance,
    ]);

    return hash;
  }
}
