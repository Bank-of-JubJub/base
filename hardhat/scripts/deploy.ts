import hre from "hardhat";

async function main() {
  const publicClient = await hre.viem.getPublicClient();
  const [deployer] = await hre.viem.getWalletClients();

  console.log(
    "Deploying contracts with the account:",
    deployer.account.address
  );

  let { contract: token } = await deploy("FunToken", []);
  const { contract: pendingDepositVerifier } = await deploy(
    "contracts/process_pending_deposits/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: pendingTransferVerifier } = await deploy(
    "contracts/process_pending_transfers/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferVerifier } = await deploy(
    "contracts/transfer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transfer4337Verifier } = await deploy(
    "contracts/transfer_4337/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferEthSignerVerifier } = await deploy(
    "contracts/transfer_eth_signer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: transferMultisigVerifier } = await deploy(
    "contracts/transfer_multisig/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawVerifier } = await deploy(
    "contracts/withdraw/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdraw4337Verifier } = await deploy(
    "contracts/withdraw_4337/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawEthSignerVerifier } = await deploy(
    "contracts/withdraw_eth_signer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: withdrawMultisigVerifier } = await deploy(
    "contracts/withdraw_multisig/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: lockVerifier } = await deploy(
    "contracts/lock/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: addEthSigners } = await deploy(
    "contracts/add_eth_signers/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: changeEthSigner } = await deploy(
    "contracts/change_eth_signer/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: changeMultiEthSigners } = await deploy(
    "contracts/change_multi_eth_signers/plonk_vk.sol:UltraVerifier",
    []
  );
  const { contract: privateTokenFactory } = await deploy(
    "PrivateTokenFactory",
    [
      pendingDepositVerifier.address,
      pendingTransferVerifier.address,
      transferVerifier.address,
      withdrawVerifier.address,
      lockVerifier.address,
      addEthSigners.address,
      changeEthSigner.address,
      changeMultiEthSigners.address,
    ]
  );
  await privateTokenFactory.write.deploy([token.address]);
  const logs = await publicClient.getContractEvents({
    address: privateTokenFactory.address,
    abi: privateTokenFactory.abi,
    eventName: "Deployed",
  });
  // @ts-ignore
  let privateTokenAddress = logs[0].args.token;
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
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// A deployment function to set up the initial state
async function deploy(name: string, constructorArgs: any[]) {
  const contract = await hre.viem.deployContract(name, constructorArgs);

  return { contract };
}
