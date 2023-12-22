import { BojAccount, EncryptedAmount, EncryptedBalance } from "./types";
import { GetContractReturnType } from "@nomicfoundation/hardhat-viem/types";
import { Abi, toBytes, toHex } from "viem";
import { encryptedValueToEncryptedBalance, fromRprLe, getC1PointFromEncryptedBalance, getC2PointFromEncryptedBalance, getDecryptedValue, getEncryptedValue, getNonce } from "./utils";
import { createAndWriteToml } from "../../createToml";
import { runNargoProve } from "./generateNargoProof";
import { getTransferProof } from "./config";

export class TransferCoordinator {
    private isTest: boolean;
    private to: `0x${string}`;
    private from: BojAccount;
    private processFee: number;
    private relayFee: number;
    private relayFeeRecipient: `0x${string}` | null
    private encryptedOldBalance: [bigint, bigint, bigint, bigint] | null
    private clearOldBalance: number | null
    private recipientBalance: [bigint, bigint, bigint, bigint] | null
    private privateToken: any
    private amount: number
    private encryptedAmount: EncryptedBalance | null
    private encryptedAmountRandomness: bigint | null
    private encryptedNewBalance: EncryptedBalance | null
    private encryptedNewBalanceRandomness: bigint | null
    private proof: string | null

    constructor(amount: number,
        privateToken: any,
        to: `0x${string}`,
        from: BojAccount,
        processFee: number,
        relayFee: number,
        relayFeeRecipient: `0x${string}`,
        isTest: boolean = false) {
        this.processFee = processFee
        this.relayFee = relayFee
        this.relayFeeRecipient = relayFeeRecipient
        this.to = to
        this.from = from
        this.encryptedOldBalance = null
        this.clearOldBalance = null;
        this.recipientBalance = null
        this.privateToken = privateToken
        this.amount = amount
        this.encryptedAmount = null
        this.encryptedAmountRandomness = null
        this.encryptedNewBalance = null
        this.encryptedNewBalanceRandomness = null
        this.proof = null
        this.isTest = isTest
    }

    public async init() {
        this.encryptedOldBalance = await this.privateToken.read.balances([
            this.from.packedPublicKey,
        ]) as [bigint, bigint, bigint, bigint];
        this.recipientBalance = await this.privateToken.read.balances([
            this.to,
        ]) as [bigint, bigint, bigint, bigint];

        if (
            this.recipientBalance[0] == 0n &&
            this.recipientBalance[1] == 0n &&
            this.recipientBalance[2] == 0n &&
            this.recipientBalance[3] == 0n
        ) {
            this.processFee = 0;
        }
        this.clearOldBalance = Number(await getDecryptedValue(this.from, this.encryptedOldBalance))
        const unfmtEncryptedAmount = await getEncryptedValue(this.to, this.amount, this.isTest)
        this.encryptedAmount = encryptedValueToEncryptedBalance(unfmtEncryptedAmount)
        this.encryptedAmountRandomness = unfmtEncryptedAmount.randomness

        const clearNewBalance =
            Number(this.clearOldBalance) - this.relayFee - this.amount - this.processFee;

        const unfmtEncNewBalance = getEncryptedValue(
            this.from.packedPublicKey,
            clearNewBalance,
            this.isTest
        );
        this.encryptedNewBalanceRandomness = unfmtEncNewBalance.randomness
        this.encryptedNewBalance = encryptedValueToEncryptedBalance(unfmtEncNewBalance);
    }

    public async generateProof() {
        const proofInputs = {
            balance_old_me_clear: this.clearOldBalance!,
            private_key: this.from.privateKey,
            value: this.amount,
            randomness1: toHex(this.encryptedAmountRandomness!, { size: 32 }),
            randomness2: toHex(this.encryptedNewBalanceRandomness!, { size: 32 }),
            sender_pub_key: Array.from(toBytes(this.from.packedPublicKey)),
            recipient_pub_key: Array.from(toBytes(this.to)),
            sender_pub_key_modulus: fromRprLe(this.from.packedPublicKey),
            recipient_pub_key_modulus: fromRprLe(this.to),
            process_fee: this.processFee,
            relay_fee: this.relayFee,
            nonce_private: toHex(getNonce(this.encryptedNewBalance!), { size: 32 }),
            nonce: toHex(getNonce(this.encryptedNewBalance!), { size: 32 }),
            old_balance_encrypted_1: {
                x: toHex(this.encryptedOldBalance![0], { size: 32 }),
                y: toHex(this.encryptedOldBalance![1], { size: 32 }),
            },
            old_balance_encrypted_2: {
                x: toHex(this.encryptedOldBalance![2], { size: 32 }),
                y: toHex(this.encryptedOldBalance![3], { size: 32 }),
            },
            encrypted_amount_1: getC1PointFromEncryptedBalance(this.encryptedAmount!),
            encrypted_amount_2: getC2PointFromEncryptedBalance(this.encryptedAmount!),
            new_balance_encrypted_1: getC1PointFromEncryptedBalance(this.encryptedNewBalance!),
            new_balance_encrypted_2: getC2PointFromEncryptedBalance(this.encryptedNewBalance!),
        };

        createAndWriteToml("transfer", proofInputs);
        await runNargoProve("transfer", "Test.toml");
        this.proof = await getTransferProof();
    }

    public async sendTransfer() {
        console.log("Sending transfer tx")

        console.log(this.to)
        console.log(this.from.packedPublicKey)
        console.log(this.processFee)
        console.log(this.relayFee)
        console.log(this.relayFeeRecipient)
        console.log(this.encryptedAmount)
        console.log(this.encryptedNewBalance)
        console.log(this.proof)


        const hash = await this.privateToken.write.transfer([
            this.to,
            this.from.packedPublicKey,
            this.processFee,
            this.relayFee,
            this.relayFeeRecipient,
            this.encryptedAmount,
            this.encryptedNewBalance,
            this.proof,
        ]);

        console.log(`Transfer tx sent: ${hash}`)
    }
}