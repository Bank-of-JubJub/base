import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData, saveDeploymentData } from "./saveDeploy";
import { delay } from "../utils/utils";
dotenv.config({ path: "../.env" });

async function main() {
  const publicClient = await hre.viem.getPublicClient();
  const [deployer] = await hre.viem.getWalletClients();

  console.log(
    "Deploying contracts with the account:",
    deployer!.account.address
  );

  try {
    let token = await deployAndSave("FunToken", []);

    const pendingDepositVerifier = await deployAndSave(
      "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier",
      []
    );

    const pendingTransferVerifier = await deployAndSave(
      "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier",
      []
    );

    const transferVerifier = await deployAndSave(
      "contracts/transfer/plonk_vk.sol:UltraVerifier",
      []
    );

    const transfer4337Verifier = await deployAndSave(
      "contracts/transfer_4337/plonk_vk.sol:UltraVerifier",
      []
    );

    const transferEthSignerVerifier = await deployAndSave(
      "contracts/transfer_eth_signer/plonk_vk.sol:UltraVerifier",
      []
    );

    const transferMultisigVerifier = await deployAndSave(
      "contracts/transfer_multisig/plonk_vk.sol:UltraVerifier",
      []
    );

    const withdrawVerifier = await deployAndSave(
      "contracts/withdraw/plonk_vk.sol:UltraVerifier",
      []
    );

    const withdraw4337Verifier = await deployAndSave(
      "contracts/withdraw_4337/plonk_vk.sol:UltraVerifier",
      []
    );

    const withdrawEthSignerVerifier = await deployAndSave(
      "contracts/withdraw_eth_signer/plonk_vk.sol:UltraVerifier",
      []
    );

    const withdrawMultisigVerifier = await deployAndSave(
      "contracts/withdraw_multisig/plonk_vk.sol:UltraVerifier",
      []
    );

    const lockVerifier = await deployAndSave(
      "contracts/lock/plonk_vk.sol:UltraVerifier",
      []
    );

    const addEthSigners = await deployAndSave(
      "contracts/add_eth_signers/plonk_vk.sol:UltraVerifier",
      []
    );

    const changeEthSigner = await deployAndSave(
      "contracts/change_eth_signer/plonk_vk.sol:UltraVerifier",
      []
    );

    const changeMultiEthSigners = await deployAndSave(
      "contracts/change_multi_eth_signers/plonk_vk.sol:UltraVerifier",
      []
    );

    const privateTokenFactory = await deployAndSave("PrivateTokenFactory", [
      pendingDepositVerifier.address,
      pendingTransferVerifier.address,
      transferVerifier.address,
      withdrawVerifier.address,
      lockVerifier.address,
      addEthSigners.address,
      changeEthSigner.address,
      changeMultiEthSigners.address,
    ]);

    const txHash = await privateTokenFactory.write.deploy([token.address]);
    await delay(10000);

    const receipt = await publicClient.getTransactionReceipt({
      hash: txHash,
    });

    const logs = await publicClient.getContractEvents({
      address: privateTokenFactory.address,
      abi: privateTokenFactory.abi,
      blockHash: receipt.blockHash,
    });

    // @ts-ignore
    let privateTokenAddress = logs[0].args.token;

    saveDeploymentData("PrivateToken", {
      address: privateTokenAddress as `0x${string}`,
      abi: (await hre.artifacts.readArtifact("PrivateToken")).abi,
      network: hre.network.name,
      chainId: hre.network.config.chainId,
      bytecode: (await hre.artifacts.readArtifact("PrivateToken")).bytecode,
      receipt,
    });

    const privateToken = await hre.viem.getContractAt(
      "PrivateToken",
      privateTokenAddress
    );
    privateToken.write.initOtherVerifiers([
      transfer4337Verifier.address,
      transferEthSignerVerifier.address,
      transferMultisigVerifier.address,
      withdraw4337Verifier.address,
      withdrawEthSignerVerifier.address,
      withdrawMultisigVerifier.address,
    ]);

    console.log(
      "Deployment succeeded. Private token contract at: ",
      privateToken.address
    );
  } catch (e) {
    console.log(e);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

async function deployAndSave(name: string, constructorArgs: any[]) {
  const publicClient = await hre.viem.getPublicClient();
  const [deployer] = await hre.viem.getWalletClients();

  let contractName = name;
  if (name.startsWith("contracts/")) {
    const regex = /\/([^\/]+)\//;
    contractName = name.match(regex)![1];
  }
  const { data } = readDeploymentData(contractName);

  let artifact = await hre.artifacts.readArtifact(name);

  // If the saved bytecode matches the current, don't deploy, just return
  if (
    hre.network.name != "hardhat" &&
    data[hre.network.name] &&
    data[hre.network.name].bytecode == artifact.bytecode
  ) {
    console.log(`${name} contract found, skipping deployment.`);
    return await hre.viem.getContractAt(name, data[hre.network.name].address);
  }

  const hash = await deployer.deployContract({
    abi: artifact.abi,
    account: (await deployer.getAddresses())[0],
    args: constructorArgs,
    bytecode: artifact.bytecode as `0x${string}`,
  });

  console.log(`${name} contract deployed`);

  await delay(10000);

  const receipt = await publicClient.getTransactionReceipt({ hash });

  saveDeploymentData(contractName, {
    address: receipt.contractAddress as `0x${string}`,
    abi: artifact.abi,
    network: hre.network.name,
    chainId: hre.network.config.chainId,
    bytecode: artifact.bytecode,
    receipt,
  });

  return await hre.viem.getContractAt(name, receipt.contractAddress!);
}
