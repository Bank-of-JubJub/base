import hre from "hardhat";
import dotenv from "dotenv";
import { delay } from "../utils/utils";
import BabyJubJubUtils from "../utils/babyJubJubUtils";
import { ProcessTransferCoordinator } from "../coordinators/ProcessTransferCoordinator";
import { account2 } from "../utils/constants";
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

  const coordinator = new ProcessTransferCoordinator(
    params.to,
    sender.account.address,
    0
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
