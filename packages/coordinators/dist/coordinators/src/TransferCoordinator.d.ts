import { BojAccount } from "boj-types";
import { PublicClient, WalletClient } from "viem";
export declare class TransferCoordinator {
    private privateTokenAddress;
    private isTest;
    private to;
    private from;
    private processFee;
    private relayFee;
    private relayFeeRecipient;
    private encryptedOldBalance;
    private clearOldBalance;
    private recipientBalance;
    private amount;
    private encryptedAmount;
    private encryptedAmountRandomness;
    private encryptedNewBalance;
    private encryptedNewBalanceRandomness;
    private proof;
    private walletClient;
    private publicClient;
    constructor(amount: number, to: `0x${string}`, from: BojAccount, processFee: number, relayFee: number, relayFeeRecipient: `0x${string}`, privateTokenAddress: `0x${string}`, publicClient: PublicClient, walletClient: WalletClient, isTest?: boolean);
    init(): Promise<void>;
    generateProof(): Promise<void>;
    sendTransfer(): Promise<`0x${string}`>;
}
