import { PublicClient, WalletClient } from "viem";
export declare class ProcessDepositCoordinator {
    private relayFeeRecipient;
    private proof;
    private to;
    private newBalance;
    private txsToProcess;
    private zeroBalance;
    private encryptedAmount;
    private totalAmount;
    private startingAmount;
    private minFeeToProcess;
    private privateTokenAddress;
    private walletClient;
    private publicClient;
    constructor(to: `0x${string}`, relayFeeRecipient: `0x${string}`, minFeeToProcess: number | undefined, privateTokenAddress: `0x${string}`, publicClient: PublicClient, walletClient: WalletClient);
    init(): Promise<void>;
    generateProof(): Promise<void>;
    sendProcessDeposit(): Promise<`0x${string}`>;
}
