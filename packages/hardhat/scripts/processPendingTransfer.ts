import hre from "hardhat";
import dotenv from "dotenv";
import { account2, BabyJubJubUtils, delay } from "boj-utils";
import { ProcessTransferCoordinator } from "boj-coordinators";
import { readDeploymentData } from "./saveDeploy.js";
dotenv.config({ path: "../.env" });
const babyjub = new BabyJubJubUtils();

const params = {
  to: account2.packedPublicKey,
};

// THIS ONLY WORKS FOR 1 tx right now

async function main() {
  await babyjub.init();
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();

  const { data: contractData } = readDeploymentData("PrivateToken");
  const network = hre.network.name;
  const privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    contractData[network].address
  );

  const coordinator = new ProcessTransferCoordinator(
    params.to,
    sender.account.address,
    0,
    privateToken.address.account.address,
    // @ts-ignore
    publicClient,
    sender
  );
  await coordinator.init();
  await coordinator.generateProof();
  const hash = await coordinator.sendProcessTransfer();

  await delay(15000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
