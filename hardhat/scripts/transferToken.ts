import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData } from "./saveDeploy";
import { delay } from "../utils/utils";
dotenv.config({ path: "../.env" });

// bytes32 _to,
// bytes32 _from,
// uint40 _processFee,
// uint40 _relayFee,
// address _relayFeeRecipient,
// EncryptedAmount calldata _amountToSend,
// EncryptedAmount calldata _senderNewBalance,
// bytes memory _proof_transfer
const params = {
  to: "0xdc9f9fdb746d0f07b004cc4316e3495a58570b90661499f8a6a6696ff4156baa" as `0x${string}`,
  from: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
  amount: 10 * 10 ** 18,
};

async function main() {
  const publicClient = await hre.viem.getPublicClient();
  const [sender] = await hre.viem.getWalletClients();

  const network = hre.network.name;

  const { data: privateTokenData } = readDeploymentData("PrivateToken");

  let privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );

  const hash = await privateToken.write.transfer([]);

  await delay(5000);

  const receipt = await publicClient.getTransactionReceipt({ hash });
  console.log(receipt);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
