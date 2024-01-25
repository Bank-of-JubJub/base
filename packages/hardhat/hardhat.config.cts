import "hardhat-deploy";
import "@nomicfoundation/hardhat-viem";
import "solidity-docgen";
import "@nomicfoundation/hardhat-verify";
require("dotenv").config();

import { join } from "path";
import { writeFile } from "fs/promises";
import { subtask } from "hardhat/config";
import { TASK_COMPILE_SOLIDITY } from "hardhat/builtin-tasks/task-names";

subtask(TASK_COMPILE_SOLIDITY).setAction(async (_, { config }, runSuper) => {
  const superRes = await runSuper();

  try {
    await writeFile(
      join(config.paths.artifacts, "package.json"),
      '{ "type": "commonjs" }'
    );
  } catch (error) {
    console.error("Error writing package.json: ", error);
  }

  return superRes;
});

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.8.20",
    settings: {
      // viaIR: true,
      optimizer: {
        enabled: true,
        runs: 50000,
      },
    },
  },
  mocha: {
    timeout: 400000000,
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
  },
  // docgen: {
  //   exclude: ["./contracts/BaseUltraVerifier"],
  // },
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    sepolia: {
      chainId: 11155111,
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: [process.env.PRIVATE_KEY || "0".repeat(64)],
      saveDeployments: true,
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: process.env.ARBITRUM_SEPOLIA_RPC_URL || "",
      accounts: [process.env.PRIVATE_KEY || "0".repeat(64)],
      saveDeployments: true,
    },
    optimismSepolia: {
      chainId: 11155420,
      url: process.env.OPTIMISM_SEPOLIA_RPC_URL || "",
      accounts: [process.env.PRIVATE_KEY || "0".repeat(64)],
      saveDeployments: true,
    },
    chaidochain: {
      chainId: 10200,
      url: "https://rpc.chiadochain.net",
      accounts: [process.env.PRIVATE_KEY || "0".repeat(64)],
    },
    alfajores: {
      chainId: 44787,
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [process.env.PRIVATE_KEY || "0".repeat(64)],
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      optimisticEthereum: "YOUR_OPTIMISTIC_ETHERSCAN_API_KEY",
      arbitrumSepolia: process.env.ETHERSCAN_ARBITRUM_API_KEY,
      alfajores: process.env.ETHERSCAN_CELO_API_KEY
    },
    customChains: [
      {
        network: "arbitrumSepolia",
        chainId: 44787,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia.arbiscan.io/",
        },
      },
      {
        network: "alfajores",
        chainId: 421614,
        urls: {
          apiURL: "https://api-alfajores.celoscan.io/api",
          browserURL: "https://alfajores.celoscan.io/",
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
      sepolia: process.env.TESTING_PUBLIC_KEY || "", //it can also specify a specific netwotk name (specified in hardhat.config.js)
      31337: 0,
    },
  },
};
