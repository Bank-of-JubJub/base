import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData } from "./saveDeploy.js";
import { delay } from "boj-utils";
dotenv.config({ path: "../.env" });

const params = {
  to: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
  amount: BigInt(10 * 10 ** 18),
};

async function main() {
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();

  const network = hre.network.name;

  const { data: erc20data } = readDeploymentData("FunToken");
  const { data: privateTokenData } = readDeploymentData("PrivateToken");

  let erc20 = await hre.viem.getContractAt(
    "FunToken",
    erc20data[network].address
  );
  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );

  await erc20.write.approve([privateTokenData[network].address, params.amount], { account: sender.account });

  await delay(5000);

  const hash = await privateToken.write.deposit([
    params.amount,
    params.to,
    0,
  ], {
    account: sender.account
  });

  await delay(5000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
