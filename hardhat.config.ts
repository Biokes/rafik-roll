import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY");
const config: HardhatUserConfig = {
  solidity: "0.8.30",
   etherscan: {
      apiKey: ETHERSCAN_API_KEY,
    },
  networks: {
    localhost: {
        url: "http://127.0.0.1:8545",
      },
   }
  // networks: {
  //   sepolia: {
  //     url: SEPOLIA_URL,
  //     accounts: [SEPOLIA_PRIVATE_KEY??""]
  //   }
  // }
};

export default config;