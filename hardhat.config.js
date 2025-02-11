require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

const { PrivateKey } = require("./secret.json");

module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      evmVersion: "paris",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    core_testnet: {
      url: "https://rpc.test.btcs.network/",
      accounts: [PrivateKey],
      chainId: 1115
    }
  }
};
