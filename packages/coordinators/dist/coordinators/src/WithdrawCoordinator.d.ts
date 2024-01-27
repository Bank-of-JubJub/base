import { BojAccount } from "boj-types";
import { PublicClient, WalletClient } from "viem";
export declare class WithdrawCoordinator {
    private proof;
    private privateTokenAddress;
    private from;
    private to;
    private relayFee;
    private relayFeeRecipient;
    private amount;
    private isTest;
    private randomness;
    private clearOldBalance;
    private encNewBalance;
    private encOldBalance;
    private walletClient;
    private publicClient;
    constructor(to: `0x${string}`, from: BojAccount, amount: number, relayFee: number, relayFeeRecipient: `0x${string}`, privateTokenAddress: `0x${string}`, publicClient: PublicClient, walletClient: WalletClient, isTest?: boolean);
    init(): Promise<void>;
    generateProof(): Promise<void>;
    sendWithdraw(): Promise<`0x${string}`>;
}
