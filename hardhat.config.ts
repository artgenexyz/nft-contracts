import fs from "fs";
import "dotenv/config";
import { stdout } from "process";
import { HardhatUserConfig, task } from "hardhat/config";

import { generateMnemonic } from "bip39";

import "@typechain/hardhat";
import "@nomiclabs/hardhat-ganache";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-solhint";

import "@matterlabs/hardhat-zksync-toolbox";

import "@tenderly/hardhat-tenderly";

import "solidity-coverage";
import "hardhat-gas-reporter";
import "hardhat-deploy";
import "hardhat-contract-sizer";
import "hardhat-tracer";
import "hardhat-nodemon";
import "hardhat-preprocessor";

import "hardhat-output-validator";

import "@buildship/hardhat-ipfs-upload";
import "@primitivefi/hardhat-dodoc";

import { sendAllFunds, getVanityDeployer } from "./scripts/helpers";

const INFURA_KEY = process.env.INFURA_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY;
const MOONBEAM_API_KEY = process.env.MOONBEAM_API_KEY;
const MOONRIVER_API_KEY = process.env.MOONRIVER_API_KEY;
const MNEMONIC = process.env.MNEMONIC;
const ALCHEMY_GOERLI_API = process.env.ALCHEMY_GOERLI_API;
const ALCHEMY_API = process.env.ALCHEMY_API;
const FORK = process.env.FORK;
const ZKSYNC = process.env.ZKSYNC;

stdout.isTTY &&
  console.log("Using env variables", {
    INFURA_KEY: INFURA_KEY ? "✅" : "❌",
    ETHERSCAN_API_KEY: ETHERSCAN_API_KEY ? "✅" : "❌",
    POLYGONSCAN_API_KEY: POLYGONSCAN_API_KEY ? "✅" : "❌",
    BSCSCAN_API_KEY: BSCSCAN_API_KEY ? "✅" : "❌",
    MOONBEAM_API_KEY: MOONBEAM_API_KEY ? "✅" : "❌",
    MOONRIVER_API_KEY: MOONRIVER_API_KEY ? "✅" : "❌",
    ALCHEMY_GOERLI_API: ALCHEMY_GOERLI_API ? "✅" : "❌",
    ALCHEMY_API: ALCHEMY_API ? "✅" : "❌",
    FORK: FORK ? "✅" : "❌",
    ZKSYNC: ZKSYNC ? "✅" : "❌",
    MNEMONIC: MNEMONIC
      ? "✅" + MNEMONIC.slice(0, 4) + "..." + MNEMONIC.slice(-4)
      : "❌",
  });

export const mnemonic = (() => {
  if (MNEMONIC) {
    return MNEMONIC;
  }

  try {
    return fs.readFileSync(".mnemonic").toString().trim();
  } catch (err) {
    return generateMnemonic();
  }
})();

export const getRemappings = () => {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .map((line) => line.trim().split("="));
};

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task(
  "send-all-funds",
  "Sends all funds to an address",
  async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    const vanity = await getVanityDeployer(hre);

    await sendAllFunds(hre, vanity, accounts[0].address);

    console.log("Done sending all funds");
  }
);

task(
  "clean-zksync",
  "Clears the zksync cache and artifacts",
  async (taskArgs, hre) => {
    const { rm } = require("fs/promises");
    const { join } = require("path");

    // dry run:
    console.log("delete", join(hre.config.paths.cache, "..", "cache-zk"));
    console.log(
      "delete",
      join(hre.config.paths.artifacts, "..", "artifacts-zk")
    );

    await rm(join(hre.config.paths.cache, "..", "cache-zk"), {
      recursive: true,
      force: true,
    });

    await rm(join(hre.config.paths.artifacts, "..", "artifacts-zk"), {
      recursive: true,
      force: true,
    });
  }
);

const config: HardhatUserConfig = {
  defaultNetwork: ZKSYNC ? "zksync" : "hardhat",

  networks: {
    hardhat: {
      forking:
        FORK === "mainnet" && ALCHEMY_API
          ? {
              url: ALCHEMY_API,
            }
          : FORK && ALCHEMY_GOERLI_API
          ? {
              url: ALCHEMY_GOERLI_API,
            }
          : undefined,
    },

    zksync: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: `https://goerli.infura.io/v3/${INFURA_KEY}`,

      zksync: true,

      // Verification endpoint for Goerli
      verifyURL:
        "https://zksync2-testnet-explorer.zksync.dev/contract_verification",

      // verifyURL:
      // "https://zksync2-mainnet-explorer.zksync.io/contract_verification",

      accounts: {
        mnemonic,
      },
    },

    zksyncEra: {
      url: "https://mainnet.era.zksync.io",
      ethNetwork: `https://mainnet.infura.io/v3/${INFURA_KEY}`,

      zksync: true,

      // Verification endpoint
      verifyURL:
        "https://zksync2-mainnet-explorer.zksync.io/contract_verification",

      accounts: {
        mnemonic,
      },
    },

    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_KEY}`,
      accounts: {
        mnemonic,
      },
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
      accounts: {
        mnemonic,
      },
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: {
        mnemonic,
      },
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: {
        mnemonic,
      },
    },
  },

  solidity: {
    version: "0.8.18",
    settings: {
      evmVersion: "paris",
      optimizer: {
        enabled: true,
        runs: 10000,
        // runs: 4_294_967_295, // 2**32 - 1
      },
    },
  },

  zksolc: {
    version: "1.3.11",
    compilerSource: "binary",

    settings: {
      optimizer: {
        enabled: true,
        runs: 10000,
      },
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

  etherscan: {
    apiKey: {
      mainnet: ETHERSCAN_API_KEY ?? "",
      rinkeby: ETHERSCAN_API_KEY ?? "",
      goerli: ETHERSCAN_API_KEY ?? "",
      polygon: POLYGONSCAN_API_KEY ?? "",
      bsc: BSCSCAN_API_KEY ?? "",
      moonbeam: MOONBEAM_API_KEY ?? "",
      moonriver: MOONRIVER_API_KEY ?? "",
      moonbaseAlpha: MOONRIVER_API_KEY ?? "",
    },
  },

  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: ZKSYNC
    ? undefined
    : {
        eachLine: (hre) =>
          hre.network.name.includes("zksync")
            ? undefined
            : // ? {
              //     settings: {
              //       cache: false,
              //     },
              //     transform: (line: string) => line,
              //   }
              // (console.log("Using zksync, so turn off preprocess"), undefined)
              {
                settings: {
                  // this is needed so that etherscan verification works
                  cache: false,
                },
                transform: (line: string) => {
                  if (line.match(/^\s*import /i)) {
                    for (const [from, to] of getRemappings()) {
                      if (line.includes(from)) {
                        line = line.replace(from, to);
                        break;
                      }
                    }
                  }
                  return line;
                },
              },
      },

  dodoc: {
    runOnCompile: false,
    outputDir: ".wiki/reference",
    exclude: [
      "forge",
      "utils",
      "foundry",
      "ethier",
      "openzeppelin",
      "interfaces",
      "mocks",
      "chiru-labs",
      "erc721a",
      "hardhat",
    ],
  },
};

export default config;
