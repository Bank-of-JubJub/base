import hre from "hardhat";
import dotenv from "dotenv";
import { account2, BabyJubJubUtils, delay } from "boj-utils";
import { BojAccount } from "boj-types";
import { hexToBigInt, toBytes, toHex } from "viem";
import { TransferCoordinator } from "boj-coordinators";
import { readDeploymentData } from "./saveDeploy.js";
dotenv.config({ path: "../.env" });

const params = {
  to: account2.packedPublicKey,
  amount: 2,
  processFee: 1,
  relayFee: 1,
};

async function main() {
  const babyjub = new BabyJubJubUtils();
  await babyjub.init();
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();

  const pubKey = babyjub.privateToPublicKey(
    hexToBigInt(process.env.BOJ_PRIVATE_KEY as `0x${string}`)
  );

  const bojAccount = {
    packedPublicKey: toHex(
      babyjub.packPublicKey([toBytes(pubKey.x), toBytes(pubKey.y)])
    ),
    privateKey: process.env.BOJ_PRIVATE_KEY,
  } as BojAccount;

  const { data: contractData } = readDeploymentData("PrivateToken");
  const network = hre.network.name;
  const privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    contractData[network].address
  );

  const coordinator = new TransferCoordinator(
    params.amount,
    params.to,
    bojAccount,
    params.processFee,
    params.relayFee,
    sender.account.address,
    privateToken.address.account.address,
    // @ts-ignore
    publicClient,
    sender
  );

  await coordinator.init();
  await coordinator.generateProof();
  const hash = await coordinator.sendTransfer();

  await delay(5000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
