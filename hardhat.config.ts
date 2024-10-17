import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";
import "solidity-coverage";
import * as dotenv from "dotenv";

dotenv.config();

const privateKey = process.env.PRIVATE_KEY;
const PolyApi = process.env.POLYGONSCAN_API_KEY;
const baseSepoliaRpcUrl = process.env.NEXT_PUBLIC_BASE_TESTNET_RPC_URL;

if (!privateKey) {
  throw new Error("Please set your PRIVATE_KEY in the .env file");
}

if (!baseSepoliaRpcUrl) {
  throw new Error(
    "Please set your NEXT_PUBLIC_BASE_TESTNET_RPC_URL in the .env file"
  );
}

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com/",
      accounts: [privateKey],
    },
    baseSepolia: {
      url: baseSepoliaRpcUrl,
      accounts: [privateKey],
    },
  },
  etherscan: {
    apiKey: PolyApi,
  },
};

export default config;
