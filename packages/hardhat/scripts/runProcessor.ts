import hre from "hardhat";
import { parseAbi } from "viem";
import { readDeploymentData } from "./saveDeploy.js";

async function main() {
  const publicClient = await hre.viem.getPublicClient();

  const { data: contractData } = readDeploymentData("PrivateToken");
  const network = hre.network.name;
  const privateToken = await hre.viem.getContractAt(
    "PrivateToken",
    contractData[network].address
  );

  const unwatch = publicClient.watchEvent({
    address: privateToken.address.account.address,
    events: parseAbi([
      "event Deposit(address from, bytes32 to, uint256 amount, uint256 processFee)",
      "event Transfer(bytes32 indexed to, bytes32 indexed from, EncryptedAmount amount)",
    ]),
    onLogs: (logs) => console.log(logs),
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
