import "@nomicfoundation/hardhat-toolbox";
import { config as dotenvConfig } from "dotenv";
import "hardhat-deploy";
import type { HardhatUserConfig } from "hardhat/config";
import type { NetworkUserConfig } from "hardhat/types";
import { resolve } from "path";
import "hardhat-diamond-abi";
import "@nomiclabs/hardhat-etherscan";
import "./tasks/accounts";
import "./tasks/taskDeploy";

const dotenvConfigPath: string = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

// Ensure that we have all the environment variables we need.
const mnemonic: string | undefined = process.env.MNEMONIC;
if (!mnemonic) {
  throw new Error("Please set your MNEMONIC in a .env file");
}

const privatekey: string | undefined = process.env.PRIVATE_KEY;
if (!privatekey) {
  throw new Error("Please set your private key in a .env file");
}

const chainIds = {
  "arbitrum-mainnet": 42161,
  avalanche: 43114,
  fuji: 43113,
  bsc: 56,
  ganache: 1337,
  hardhat: 31337,
  mainnet: 1,
  "optimism-mainnet": 10,
  "polygon-mainnet": 137,
  "polygon-mumbai": 80001,
  sepolia: 11155111,
};

function getChainConfig(chain: keyof typeof chainIds): NetworkUserConfig {
  let jsonRpcUrl: string;
  switch (chain) {
    case "polygon-mumbai":
      jsonRpcUrl = "https://rpc-mumbai.maticvigil.com";
      break;
    case "arbitrum-mainnet":
      jsonRpcUrl = "https://arbitrum.llamarpc.com";
      break;
    case "polygon-mainnet":
      jsonRpcUrl = "https://rpc-mainnet.maticvigil.com";
      break;
    case "avalanche":
      jsonRpcUrl = "https://api.avax.network/ext/bc/C/rpc";
      break;
    case "bsc":
      jsonRpcUrl = "https://bsc-dataseed.binance.org";
      break;
    case "mainnet":
      jsonRpcUrl = "https://1rpc.io/eth";
      break;
    case "sepolia":
      jsonRpcUrl = "https://sepolia.publicgoods.network";
      break;
    case "fuji":
      jsonRpcUrl = "https://api.avax-test.network/ext/bc/C/rpc";
      break;
    default:
      jsonRpcUrl = "";
      break;
  }
  return {
    accounts: {
      count: 10,
      mnemonic,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[chain],
    url: jsonRpcUrl,
  };
}

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",

  diamondAbi: {
    strict: false,
    name: "DiamondABI",
    include: ["Membership", "Stake", "SettingMembership", "SettingStake"],
    exclude: [],
  },
  etherscan: {
    apiKey: {
      snowtrace: "snowtrace",
      arbitrumOne: process.env.ARBISCAN_API_KEY || "",
      avalanche: process.env.SNOWTRACE_API_KEY || "",
      bsc: process.env.BSCSCAN_API_KEY || "",
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      optimisticEthereum: process.env.OPTIMISM_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY || "",
      sepolia: process.env.ETHERSCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "snowtrace",
        chainId: 43113,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan",
          browserURL: "https://avalanche.testnet.routescan.io",
        },
      },
    ],
  },
  gasReporter: {
    currency: "USD",
    enabled: process.env.REPORT_GAS ? true : false,
    excludeContracts: [],
    src: "./contracts",
  },
  networks: {
    hardhat: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.hardhat,
    },
    snowtrace: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      accounts: [privatekey],
    },
    arb: {
      url: "https://arbitrum.llamarpc.com",
      accounts: [privatekey],
    },
    ganache: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.ganache,
      url: "http://localhost:8545",
    },
    "arbitrum-mainnet": getChainConfig("arbitrum-mainnet"),
    avalanche: getChainConfig("avalanche"),
    bsc: getChainConfig("bsc"),
    mainnet: getChainConfig("mainnet"),
    optimism: getChainConfig("optimism-mainnet"),
    "polygon-mainnet": getChainConfig("polygon-mainnet"),
    "polygon-mumbai": getChainConfig("polygon-mumbai"),
    sepolia: getChainConfig("sepolia"),
    fuji: getChainConfig("fuji"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.20",
    settings: {
      evmVersion: "paris",
      metadata: {
        // Not including the metadata hash
        // https://github.com/paulrberg/hardhat-template/issues/31
        bytecodeHash: "none",
      },
      // Disable the optimizer when debugging
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  typechain: {
    outDir: "types",
    target: "ethers-v5",
  },
};

export default config;
