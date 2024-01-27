import hre from "hardhat";
import dotenv from "dotenv";
import { BabyJubJubUtils, delay } from "boj-utils";
import { BojAccount } from "boj-types";
import { hexToBigInt, toBytes, toHex } from "viem";
import { WithdrawCoordinator } from "boj-coordinators";
import { readDeploymentData } from "./saveDeploy.js";
dotenv.config({ path: "../.env" });

const params = {
  amount: 10,
  relayFee: 0,
  relayFeeRecipent:
    "0x7D678b9218aC289e0C9F18c82F546c988BfE3022" as `0x${string}`,
};
const babyjub = new BabyJubJubUtils();

async function main() {
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

  const withdrawCoordinator = new WithdrawCoordinator(
    sender.account.address,
    bojAccount,
    params.amount,
    params.relayFee,
    params.relayFeeRecipent,
    privateToken.address.account.address,
    // @ts-ignore
    publicClient,
    sender
  );

  await withdrawCoordinator.init();
  await withdrawCoordinator.generateProof();
  const hash = await withdrawCoordinator.sendWithdraw();

  await delay(5000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
