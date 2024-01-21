import { assert, expect } from "chai";
import { getContract } from "viem";
import hre from "hardhat";
import BabyJubJubUtils from "../utils/babyJubJubUtils.ts";
import { EncryptedBalanceArray } from "../utils/types.ts";
import {
    account1,
    account2,
    transferProcessFee,
    transferRelayFee,
    depositAmount,
    depositProcessFee,
    transferAmount,
} from "../utils/constants.ts";
import { TransferCoordinator } from "../../coordinators/TransferCoordinator.ts";
import { ProcessDepositCoordinator } from "../../coordinators/ProcessDepositCoordinator.ts";
import { ProcessTransferCoordinator } from "../../coordinators/ProcessTransferCoordinator.ts";
import { WithdrawCoordinator } from "../../coordinators/WithdrawCoordinator.ts";
import { getDecryptedValue } from "../utils/utils.ts";
import { deployContracts } from "../scripts/deploy.ts";
import { abi as privateTokenAbi } from "../artifacts/contracts/PrivateToken.sol/PrivateToken.json"
import { abi as tokenAbi } from "../artifacts/contracts/ERC20.sol/FunToken.json"
import { abi as accountControllerAbi } from "../artifacts/contracts/AccountController.sol/AccountController.json"

// const viem = hre.viem;
const babyjub = new BabyJubJubUtils();
let convertedAmount: bigint;

let privateTokenAddress: `0x${string}`;
let tokenAddress: `0x${string}`;
let accountControllerAddress: `0x${string}`

describe("Private Token integration testing", async function () {
    this.beforeAll(async () => {
        const contracts = await deployContracts(true);
        // @ts-ignore
        accountControllerAddress = contracts!.accountController.address;
        await babyjub.init();
    });


    it("should add an eth controller", async () => {
        const { accountController } = await getContracts();
        accountController.read /
    })
})

async function getContracts() {
    const [wallet] = await hre.viem.getWalletClients();
    const publicClient = await hre.viem.getPublicClient();
    let privateToken = await getContract({
        abi: privateTokenAbi,
        address: privateTokenAddress,
        client: {
            wallet,
            public: publicClient
        }
    });
    let token = await getContract({ abi: tokenAbi, address: tokenAddress, client: { wallet, public: publicClient } });
    const accountController = await getContract({ abi: accountControllerAbi, address: accountControllerAddress, client: { wallet, public: publicClient } })
    return {
        privateToken,
        token,
        accountController
    };
}