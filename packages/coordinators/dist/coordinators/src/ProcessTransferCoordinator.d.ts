import { PublicClient, WalletClient } from "viem";
export declare class ProcessTransferCoordinator {
    private privateTokenAddress;
    private to;
    private processFeeRecipient;
    private minFeeToProcess;
    private oldBalanceArray;
    private oldEncryptedBalance;
    private newBalance;
    private encryptedValues;
    private proof;
    private txIndexes;
    private walletClient;
    private publicClient;
    constructor(to: `0x${string}`, processFeeRecipient: `0x${string}`, minFeeToProcess: number | undefined, privateTokenAddress: `0x${string}`, publicClient: PublicClient, walletClient: WalletClient);
    init(): Promise<void>;
    generateProof(): Promise<void>;
    sendProcessTransfer(): Promise<`0x${string}`>;
}
