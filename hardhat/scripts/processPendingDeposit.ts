import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData } from "./saveDeploy";
import { delay } from "../utils/utils";
import BabyJubJubUtils from "../utils/babyJubJubUtils";
import { ProcessDepositCoordinator } from "../coordinators/ProcessDepositCoordinator";
dotenv.config({ path: "../.env" });
const babyjub = new BabyJubJubUtils();

const params = {
  to: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
  amount: 10 * 10 ** 2,
};

// THIS ONLY WORKS FOR 1 tx right now

async function main() {
  await babyjub.init();
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();
  const network = hre.network.name;
  const { data: privateTokenData } = readDeploymentData("PrivateToken");
  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );

  const coordinator = new ProcessDepositCoordinator(
    privateToken,
    params.to,
    sender.account.address
  );
  await coordinator.init();
  await coordinator.generateProof();
  const hash = await coordinator.sendProcessDeposit();

  await delay(15000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
