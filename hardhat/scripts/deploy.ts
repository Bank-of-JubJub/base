import hre from "hardhat";
import dotenv from "dotenv";
import { readDeploymentData, saveDeploymentData } from "./saveDeploy";
import { delay } from "../utils/utils";
import { bytecode as accountControllerBytecode } from "../artifacts/contracts/AccountController.sol/AccountController.json"
import { keccak256 } from "viem";
dotenv.config({ path: "../.env" });

export async function deployContracts(isTest: boolean = false) {
  const [deployer] = await hre.viem.getWalletClients();

  console.log(
    "Deploying contracts with the account:",
    deployer!.account.address
  );

  try {
    let token = await deployAndSave("FunToken", [], isTest);

    const pendingDepositVerifier = await deployAndSave(
      "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier",
      [],
      isTest
    );

    const pendingTransferVerifier = await deployAndSave(
      "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier",
      [],
      isTest
    );

    const transferVerifier = await deployAndSave(
      "contracts/transfer/plonk_vk.sol:UltraVerifier",
      [],
      isTest
    );

    const withdrawVerifier = await deployAndSave(
      "contracts/withdraw/plonk_vk.sol:UltraVerifier",
      [],
      isTest
    );

    const lockVerifier = await deployAndSave(
      "contracts/lock/plonk_vk.sol:UltraVerifier",
      [],
      isTest
    );

    const addEthSigners = await deployAndSave(
      "contracts/add_eth_signers/plonk_vk.sol:UltraVerifier",
      [],
      isTest
    );

    const create2Deployer = await deployAndSave("Create2Deployer", [], isTest)

    const accountController = await deployAndSave(
      "AccountController",
      [addEthSigners.address],
      isTest
    );

    const allTransferVerifier = await deployAndSave(
      "TransferVerify",
      [transferVerifier.address, accountController.address],
      isTest
    );

    const allWithdrawVerifier = await deployAndSave(
      "WithdrawVerify",
      [withdrawVerifier.address, accountController.address],
      isTest
    );

    const privateToken = await deployAndSave(
      "PrivateToken",
      [
        pendingDepositVerifier.address,
        pendingTransferVerifier.address,
        allTransferVerifier.address,
        allWithdrawVerifier.address,
        lockVerifier.address,
        token.address,
        await token.read.decimals(),
      ],
      isTest
    );

    console.log(
      "Deployment succeeded. Private token contract at: ",
      privateToken.address
    );
    return {
      privateToken,
      token,
    };
  } catch (e) {
    console.log(e);
  }
}

deployContracts().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

async function deployAndSave(
  name: string,
  constructorArgs: any[],
  isTest: boolean = false
) {
  const publicClient = await hre.viem.getPublicClient();
  const [deployer] = await hre.viem.getWalletClients();
  // const count = await publicClient.getTransactionCount({
  //   address: deployer.account.address,
  // });

  let contractName = name;
  if (name.startsWith("contracts/")) {
    const regex = /\/([^\/]+)\//;
    contractName = name.match(regex)![1];
  }
  const { data } = readDeploymentData(contractName);

  let artifact = await hre.artifacts.readArtifact(name);

  // If the saved bytecode matches the current, don't deploy, just return
  if (
    // hre.network.name != "hardhat" &&
    data[hre.network.name] &&
    data[hre.network.name].bytecode == artifact.bytecode &&
    !isTest
  ) {
    console.log(`${name} contract found, skipping deployment.`);
    return await hre.viem.getContractAt(name, data[hre.network.name].address);
  }

  console.log("contract name", name)
  // console.log

  let hash;
  let address;
  let receipt;
  // deploy AccountController with CREATE2
  if (name == "AccountController") {
    const { data: create2DeployerData } = readDeploymentData("Create2Deployer");
    const create2Deployer = await hre.viem.getContractAt("Create2Deployer", create2DeployerData[hre.network.name].address)
    const salt = 8008n;

    console.log(create2Deployer)
    hash = await create2Deployer.write.deploy([accountControllerBytecode as `0x${string}`, salt]);
    console.log("account controller deployment from deployer", hash)
    // the address of the AccountController

    address = (keccak256(('0xff' + deployer.account.address + salt + keccak256(accountControllerBytecode as `0x${string}`)) as `0x${string}`)).slice(12)
    receipt = await publicClient.getTransactionReceipt({ hash });
  } else {
    hash = await deployer.deployContract({
      abi: artifact.abi,
      account: (await deployer.getAddresses())[0],
      args: constructorArgs,
      bytecode: artifact.bytecode as `0x${string}`,
    });
    receipt = await publicClient.getTransactionReceipt({ hash });
    // the address of the deployed contract
    address = receipt.contractAddress
  }

  console.log(`${name} contract deployed`);

  if (!isTest) {
    await delay(20000);
  }

  saveDeploymentData(contractName, {
    address: address as `0x${string}`,
    abi: artifact.abi,
    network: hre.network.name,
    chainId: hre.network.config.chainId,
    bytecode: artifact.bytecode,
    receipt,
  });

  return await hre.viem.getContractAt(name, receipt.contractAddress!);
}
