require("@nomiclabs/hardhat-waffle");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    // goerli: {
    //   url: "Alchemy Private Key",
    //   accounts: [privateKey1],
    // }
  },
  solidity: "0.8.17",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 40000 // As per hardhat docs
  }
};
