// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const GreetModule = buildModule("GreetModule", (m) => {
  const lock = m.contract("Greet");
  return { lock };
});

export default GreetModule;
