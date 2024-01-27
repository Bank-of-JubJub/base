import { getContract, toHex } from "viem";
import { BabyJubJubUtils, createAndWriteToml, encryptedBalanceArrayToPointObjects, encryptedBalanceToPointObjects, pointObjectsToEncryptedBalance, runNargoProve, getProcessTransfersProof, MAX_TXS_TO_PROCESS } from "boj-utils";
import * as artifact from "../../hardhat/artifacts/contracts/PrivateToken.sol/PrivateToken.json" assert { type: "json" };
export class ProcessTransferCoordinator {
    constructor(to, processFeeRecipient, minFeeToProcess = 0, privateTokenAddress, publicClient, walletClient) {
        this.to = to;
        this.privateTokenAddress = privateTokenAddress;
        this.processFeeRecipient = processFeeRecipient;
        this.minFeeToProcess = minFeeToProcess;
        this.oldBalanceArray = [BigInt(0), BigInt(0), BigInt(0), BigInt(0)];
        this.oldEncryptedBalance = {
            C1: { x: BigInt(0), y: BigInt(0) },
            C2: { x: BigInt(0), y: BigInt(0) },
        };
        this.newBalance = {
            C1x: BigInt(0),
            C1y: BigInt(0),
            C2x: BigInt(0),
            C2y: BigInt(0),
        };
        this.encryptedValues = [];
        this.proof = null;
        this.txIndexes = [];
        this.walletClient = walletClient;
        this.publicClient = publicClient;
    }
    async init() {
        const privateToken = await getContract({
            abi: artifact.default.abi,
            address: this.privateTokenAddress,
            client: {
                public: this.publicClient
            }
        });
        const babyjub = new BabyJubJubUtils();
        await babyjub.init();
        this.oldBalanceArray = (await privateToken.read.balances([
            this.to,
        ]));
        this.oldEncryptedBalance = encryptedBalanceArrayToPointObjects(this.oldBalanceArray);
        const pendingTransferCount = await privateToken.read.pendingTransferCounts([
            this.to,
        ]);
        let balanceAfterProcessTransfer = this.oldEncryptedBalance;
        this.encryptedValues = [];
        // pass indexes to contract to lookup and process
        this.txIndexes = [];
        for (let i = 0; i <= Number(pendingTransferCount) - 1; i++) {
            let pendingTransfer = (await privateToken.read.allPendingTransfersMapping([this.to, BigInt(i)]));
            const amount = encryptedBalanceToPointObjects(pendingTransfer[0]);
            const fee = pendingTransfer[1];
            if (fee > this.minFeeToProcess && pendingTransfer[0].C1x > BigInt(0)) {
                this.txIndexes.push(i);
            }
            if (this.txIndexes.length == MAX_TXS_TO_PROCESS)
                break;
            // value will be 0 if it has been deleted or never set, skip this iteration
            if (pendingTransfer[0].C1x == BigInt(0) &&
                pendingTransfer[0].C1y == BigInt(0) &&
                pendingTransfer[0].C2x == BigInt(0) &&
                pendingTransfer[0].C2y == BigInt(0)) {
                console.log("pending transfer is empty. It has been deleted or never set.");
                continue;
            }
            this.encryptedValues.push({
                x: toHex(amount.C1.x, { size: 32 }),
                y: toHex(amount.C1.y, { size: 32 }),
            });
            this.encryptedValues.push({
                x: toHex(amount.C2.x, { size: 32 }),
                y: toHex(amount.C2.y, { size: 32 }),
            });
            const C1 = babyjub.add_points(balanceAfterProcessTransfer.C1, amount.C1);
            const C2 = babyjub.add_points(balanceAfterProcessTransfer.C2, amount.C2);
            balanceAfterProcessTransfer = { C1, C2 };
        }
        // fill empty values with 0
        for (let i = this.txIndexes.length; i < MAX_TXS_TO_PROCESS; i++) {
            this.encryptedValues.push({
                x: "0x0",
                y: "0x0",
            }, {
                x: "0x0",
                y: "0x0",
            });
        }
        this.newBalance = pointObjectsToEncryptedBalance(balanceAfterProcessTransfer);
    }
    async generateProof() {
        const proofInputs = {
            balance_old_to_encrypted_1: {
                x: toHex(this.oldBalanceArray[0], { size: 32 }),
                y: toHex(this.oldBalanceArray[1], { size: 32 }),
            },
            balance_old_to_encrypted_2: {
                x: toHex(this.oldBalanceArray[2], { size: 32 }),
                y: toHex(this.oldBalanceArray[3], { size: 32 }),
            },
            balance_new_to_encrypted_1: {
                x: toHex(this.newBalance.C1x, { size: 32 }),
                y: toHex(this.newBalance.C1y, { size: 32 }),
            },
            balance_new_to_encrypted_2: {
                x: toHex(this.newBalance.C2x, { size: 32 }),
                y: toHex(this.newBalance.C2y, { size: 32 }),
            },
            encrypted_values: this.encryptedValues,
        };
        createAndWriteToml("process_pending_transfers", proofInputs);
        await runNargoProve("process_pending_transfers", "Test.toml");
        this.proof = await getProcessTransfersProof();
    }
    async sendProcessTransfer() {
        const privateToken = await getContract({
            abi: artifact.default.abi,
            address: this.privateTokenAddress,
            client: {
                wallet: this.walletClient
            }
        });
        const hash = await privateToken.write.processPendingTransfer([
            this.proof,
            this.txIndexes,
            this.processFeeRecipient,
            this.to,
            this.newBalance,
        ]);
        return hash;
    }
}
