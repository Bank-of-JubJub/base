import dotenv from "dotenv";
import { getDecryptedValue } from "boj-utils";
import { EncryptedBalanceArray } from "boj-types";

import hre from 'hardhat'
import { readDeploymentData } from "./saveDeploy.js";
dotenv.config({ path: "../.env" });

const params = {
  account: {
    packedPublicKey: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
    privateKey: process.env.BOJ_PRIVATE_KEY as `0x${string}`,
  },
};

async function main() {
  const { data: privateTokenData } = readDeploymentData("PrivateToken");
  const network = hre.network.name;

  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );
  const balance = (await privateToken.read.balances([
    params.account.packedPublicKey,
  ])) as EncryptedBalanceArray;

  const clearBalance = Number(await getDecryptedValue(params.account, balance));

  console.log(
    `Account: ${params.account.packedPublicKey}, balance: `,
    clearBalance
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
