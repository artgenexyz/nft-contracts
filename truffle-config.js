require('dotenv').config()

const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');

const mnemonic = (() => {
  try {
    return fs.readFileSync(".mnemonic").toString().trim();
  } catch (err) { return null }
})();

const INFURA_KEY = process.env.INFURA_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY;

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },

    // Useful for deploying to a public network.
    // NB: It's important to wrap the provider as a function.
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${INFURA_KEY}`),
      network_id: 4,       // Rinkeby
      gas: 8500000,
      gasPrice: 10e9,
      confirmations: 1,    // # of confs to wait between deployments. (default: 0)
      skipDryRun: true,
      // timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      networkCheckTimeout: 30000, // If you have a slow internet connection, try configuring a longer timeout in your Truffle config.
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/${INFURA_KEY}`),
      network_id: 1,
      gas: 8500000,
      gasPrice: 80e9,
      confirmations: 1,    // # of confs to wait between deployments. (default: 0)
      skipDryRun: false,
      timeoutBlocks: 200,
      networkCheckTimeout: 60000, // If you have a slow internet connection, try configuring a longer timeout in your Truffle config.
    },
    polygon: {
      provider: () => new HDWalletProvider({
        mnemonic,
        providerOrUrl: `https://polygon-mainnet.infura.io/v3/${INFURA_KEY}`,
        // shareNonce: false,
      }),
      network_id: 137,
      gas: 8500000,
      gasPrice: 50e9,
      confirmations: 1,
      skipDryRun: true,
    },
    mumbai: {
      provider: () => new HDWalletProvider(mnemonic, "wss://ws-mumbai.matic.today"),
      network_id: 80001,
      gas: 8500000,
      confirmations: 1,
      skipDryRun: true,
    },
    bsc: {
      provider: () => new HDWalletProvider(mnemonic, "https://bsc-dataseed1.binance.org"),
      network_id: 56,
      gas: 8500000,
      confirmations: 1,
      skipDryRun: true,
    },
    chapel: {
      provider: () => new HDWalletProvider(mnemonic, "https://data-seed-prebsc-1-s1.binance.org:8545"),
      network_id: 97,
      gas: 8500000,
      confirmations: 1,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    timeout: 100000,
    ...(process.env.CIRCLE_BRANCH && {
      reporter: "mocha-junit-reporter",
      reporterOptions: {
        mochaFile: "./test_results/mocha/results.xml",
      },
    }),
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.9",
      settings: {
        optimizer: {
          enabled: true,
          runs: 10000,
          // runs: 4_294_967_295, // 2**32 - 1
        },
      },
    }
  },

  plugins: [
    'truffle-plugin-verify',
    'truffle-contract-size',
    'solidity-coverage',
  ],

  api_keys: {
    etherscan: ETHERSCAN_API_KEY,
    polygonscan: POLYGONSCAN_API_KEY,
    bscscan: BSCSCAN_API_KEY,
  }

};
