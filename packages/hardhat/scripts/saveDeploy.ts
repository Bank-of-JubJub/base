import fs from "fs";
import path, { dirname } from "path";
import { TransactionReceipt } from "viem";
import JSONbig from "json-bigint";

import { fileURLToPath } from 'url';
// import { dirname } from 'path';

// Get the current file's directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

interface DeploymentData {
  address: `0x${string}`;
  abi: any;
  network: string;
  chainId: number | undefined;
  bytecode: string;
  receipt: TransactionReceipt;
}

export function saveDeploymentData(
  contractName: string,
  deploymentData: DeploymentData
): void {
  let { data, filePath } = readDeploymentData(contractName);

  // Append new deployment data
  // Assuming 'deploymentData' contains a unique identifier such as a timestamp or network name
  data[deploymentData.network] = deploymentData;

  // Write updated data back to file
  fs.writeFileSync(filePath, JSONbig.stringify(data, null, 2));
}

export function readDeploymentData(contractName: string) {
  const deploymentsDir = path.join(__dirname, "../", "deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }

  const filePath = path.join(deploymentsDir, `${contractName}.json`);
  let data: { [key: string]: DeploymentData } = {};

  // Check if file already exists
  if (fs.existsSync(filePath)) {
    // Read existing data
    const fileData = fs.readFileSync(filePath);
    data = JSONbig.parse(fileData.toString());
  }

  return { data, filePath };
}
