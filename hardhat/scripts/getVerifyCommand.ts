import dotenv from "dotenv";
import { delay, getContract, getDecryptedValue } from "../utils/utils";
dotenv.config({ path: "../.env" });
import hre from "hardhat";

const params = {
  account: {
    packedPublicKey: process.env.BOJ_PACKED_PUBLIC_KEY as `0x${string}`,
    privateKey: process.env.BOJ_PRIVATE_KEY as `0x${string}`,
  },
};

async function main() {
  const privateToken = await getContract("PrivateToken");
  const allTransferVerifier = await getContract("TransferVerify");
  const allWithdrawVerifier = await getContract("WithdrawVerify");
  const lockVerifier = await getContract(
    "contracts/lock/plonk_vk.sol:UltraVerifier"
  );
  const token = await getContract("FunToken");
  const processDepositVerifier = await getContract(
    "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier"
  );
  const processTransferVerifier = await getContract(
    "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier"
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
