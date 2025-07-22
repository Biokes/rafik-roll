import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const { SEPOLIA_PRIVATE_KEY, SEPOLIA_URL } = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.30",
  networks: {
    sepolia: {
      url: SEPOLIA_URL,
      accounts: [SEPOLIA_PRIVATE_KEY??""]
    }
  }
};

export default config;