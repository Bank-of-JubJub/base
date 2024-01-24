import { assert, expect } from "chai";
import { getContract, bytesToBigInt, hexToBigInt, toHex } from "viem";
import hre from "hardhat";
import BabyJubJubUtils from "../utils/babyJubJubUtils.ts";
import {
    account1,

} from "../utils/constants.ts";
import { deployContracts } from "../scripts/deploy.ts";
import { abi as privateTokenAbi } from "../artifacts/contracts/PrivateToken.sol/PrivateToken.json"
import { abi as tokenAbi } from "../artifacts/contracts/ERC20.sol/FunToken.json"
import { abi as accountControllerAbi } from "../artifacts/contracts/AccountController.sol/AccountController.json"
import { fromRprLe } from "../utils/utils.ts";
import { createAndWriteToml } from "../../createToml.ts";
import { runNargoProve } from "../utils/generateNargoProof.ts";
import { getAddEthSignerProof } from "../utils/config.ts";


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
        const [sender] = await hre.viem.getWalletClients();

        const nonce = await accountController.read.nonce([account1.packedPublicKey]) as bigint;

        const proofInputs = {
            private_key: account1.privateKey,
            packed_public_key_modulus: fromRprLe(account1.packedPublicKey),
            nonce: toHex(nonce)
        }

        createAndWriteToml("add_eth_signer", proofInputs);
        await runNargoProve("add_eth_signer", "Test.toml");
        const proof = await getAddEthSignerProof();
        const hash = await accountController.write.addEthController([account1.packedPublicKey, sender.account.address, proof])

        let controllerAddress = await accountController.read.ethController([account1.packedPublicKey])
        expect(controllerAddress == sender.account, "controller should be the sender")
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