import "hardhat-gas-reporter";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-viem";
import "solidity-docgen";
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.8.20",
    settings: {
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
      verify: {
        etherscan: {
          apiKey: process.env.ETHERSCAN_API_KEY || "",
        },
      },
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
