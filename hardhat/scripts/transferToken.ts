import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData } from "./saveDeploy";
import { delay } from "../utils/utils";
import { BojAccount } from "../utils/types";
import { hexToBigInt, toBytes, toHex } from "viem";
import { TransferCoordinator } from "../coordinators/TransferCoordinator";
import BabyJubJubUtils from "../utils/babyJubJubUtils";
dotenv.config({ path: "../.env" });

const params = {
  to: "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`,
  amount: 2,
  processFee: 1,
  relayFee: 1,
};

async function main() {
  const babyjub = new BabyJubJubUtils();
  await babyjub.init();
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();
  const { data: privateTokenData } = readDeploymentData("PrivateToken");
  const network = hre.network.name;

  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );

  const pubKey = babyjub.privateToPublicKey(
    hexToBigInt(process.env.BOJ_PRIVATE_KEY as `0x${string}`)
  );

  const bojAccount = {
    packedPublicKey: toHex(
      babyjub.packPublicKey([toBytes(pubKey.x), toBytes(pubKey.y)])
    ),
    privateKey: process.env.BOJ_PRIVATE_KEY,
  } as BojAccount;

  const coordinator = new TransferCoordinator(
    params.amount,
    params.to,
    bojAccount,
    params.processFee,
    params.relayFee,
    sender.account.address
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
