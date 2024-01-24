import dotenv from "dotenv";
import { delay, getContract, getDecryptedValue } from "../utils/utils";
import { EncryptedBalanceArray } from "../utils/types";
dotenv.config({ path: "../.env" });

const params = {
  account: {
    packedPublicKey: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
    privateKey: process.env.BOJ_PRIVATE_KEY as `0x${string}`,
  },
};

async function main() {
  const privateToken = await getContract("PrivateToken");
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
