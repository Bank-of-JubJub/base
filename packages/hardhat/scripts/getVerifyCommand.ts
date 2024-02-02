import dotenv from "dotenv";
dotenv.config({ path: "../.env" });
import hre from "hardhat";
import { readDeploymentData } from "./saveDeploy.js";

const params = {
  account: {
    packedPublicKey: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
    privateKey: process.env.BOJ_PRIVATE_KEY as `0x${string}`,
  },
};

async function main() {
  const getContractAt = hre.viem.getContractAt
  const { data: privateTokenData } = readDeploymentData("PrivateToken");
  const { data: transferVerifyData } = readDeploymentData("TransferVerify");
  const { data: withdrawVerifyData } = readDeploymentData("WithdrawVerify");
  const { data: lockData } = readDeploymentData("contracts/lock/plonk_vk.sol:UltraVerifier");
  const { data: funTokenData } = readDeploymentData("FunToken");
  const { data: processTransferData } = readDeploymentData("contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier");
  const { data: processDepositData } = readDeploymentData("contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier");

  const network = hre.network.name;

  let privateToken = await getContractAt(
    "PrivateToken",
    privateTokenData[network].address
  );
  const allTransferVerifier = await getContractAt("TransferVerify", transferVerifyData[network].address);
  const allWithdrawVerifier = await getContractAt("WithdrawVerify", withdrawVerifyData[network].address);
  const lockVerifier = await getContractAt(
    "contracts/lock/plonk_vk.sol:UltraVerifier", lockData[network].address
  );
  const token = await getContractAt("FunToken", funTokenData[network].address);
  const processDepositVerifier = await getContractAt(
    "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier", processDepositData[network].address
  );
  const processTransferVerifier = await getContractAt(
    "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier", processTransferData[network].address
  );

  const decimals = await token.read.decimals();

  console.log("Network ", hre.network.name);

  console.log(
    `npx hardhat verify --network ${hre.network.name} ${privateToken.address} ${processDepositVerifier.address} ${processTransferVerifier.address} ${allTransferVerifier.address} ${allWithdrawVerifier.address} ${lockVerifier.address} ${token.address} ${decimals}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
