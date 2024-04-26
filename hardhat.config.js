require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.24",
        settings: {
          viaIR: false,
          optimizer: {
            enabled: true,
            runs: 1000000,
          },
        },
      },
    ],
  },
  networks: {
    sepolia: {
      url: process.env.API_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    // mainnet: {
    //   url: process.env.URL_MAIN,
    //   accounts: [process.env.PRIVATE_KEY_MAIN],
    //   chainId: 1,
    // },
  },
  etherscan: {
    apiKey: process.env.API_KEY,
  },
};
// npx hardhat ignition deploy ignition / modules / Lock.js--network sepolia