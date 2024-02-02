import { expect } from "chai";
import {
    createPublicClient,
    createWalletClient,
    getContract,
    http,
    toHex
} from "viem";
import hre from "hardhat";
import { deployContracts } from "../scripts/deploy.ts";
import * as bojArtifact from "../artifacts/contracts/PrivateToken.sol/PrivateToken.json"  assert { type: 'json' };
import * as tokenArtifact from "../artifacts/contracts/ERC20.sol/FunToken.json"  assert { type: 'json' };
import * as accountControllerArtifact from "../artifacts/contracts/AccountController.sol/AccountController.json"  assert { type: 'json' };
import {
    account1,
    BabyJubJubUtils,
    createAndWriteToml,
    fromRprLe,
    runNargoProve,
    getAddEthSignerProof
} from "boj-utils";
import { hardhat } from "viem/chains";

const babyjub = new BabyJubJubUtils();

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
        // currently fetches proof from ./proofs
        // pwd is ./packages/hardhat
        const proof = await getAddEthSignerProof();
        const hash = await accountController.write.addEthController([account1.packedPublicKey, sender.account.address, proof])

        let controllerAddress = await accountController.read.ethController([account1.packedPublicKey])
        expect(controllerAddress == sender.account, "controller should be the sender")
    })
})

async function getContracts() {
    const wallet = createWalletClient({
        chain: hardhat,
        transport: http(),
        account: '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'
    })
    const publicClient = createPublicClient({
        chain: hardhat,
        transport: http()
    })
    let privateToken = await getContract({
        abi: bojArtifact.default.abi,
        address: privateTokenAddress,
        client: {
            wallet,
            public: publicClient
        }
    });
    let token = await getContract({ abi: tokenArtifact.default.abi, address: tokenAddress, client: { wallet, public: publicClient } });
    const accountController = await getContract({ abi: accountControllerArtifact.default.abi, address: accountControllerAddress, client: { wallet, public: publicClient } })
    return {
        privateToken,
        token,
        accountController
    };
}