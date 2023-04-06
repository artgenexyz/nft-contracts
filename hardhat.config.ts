import fs from "fs";
import { stdout } from "process";
import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";

import { generateMnemonic } from "bip39";

import "@typechain/hardhat";
import "@nomiclabs/hardhat-ganache";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-solhint";

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

const INFURA_KEY = process.env.INFURA_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY;
const MOONBEAM_API_KEY = process.env.MOONBEAM_API_KEY;
const MOONRIVER_API_KEY = process.env.MOONRIVER_API_KEY;
const MNEMONIC = process.env.MNEMONIC;
const ALCHEMY_RINKEBY_API = process.env.ALCHEMY_RINKEBY_API;
const ALCHEMY_API = process.env.ALCHEMY_API;
const FORK = process.env.FORK;

stdout.isTTY && console.log('Using env variables', {
    INFURA_KEY: INFURA_KEY ? '✅' : '❌',
    ETHERSCAN_API_KEY: ETHERSCAN_API_KEY ? '✅' : '❌',
    POLYGONSCAN_API_KEY: POLYGONSCAN_API_KEY ? '✅' : '❌',
    BSCSCAN_API_KEY: BSCSCAN_API_KEY ? '✅' : '❌',
    MOONBEAM_API_KEY: MOONBEAM_API_KEY ? '✅' : '❌',
    MOONRIVER_API_KEY: MOONRIVER_API_KEY ? '✅' : '❌',
    ALCHEMY_RINKEBY_API: ALCHEMY_RINKEBY_API ? '✅' : '❌',
    ALCHEMY_API: ALCHEMY_API ? '✅' : '❌',
    FORK: FORK ? '✅' : '❌',
    MNEMONIC: MNEMONIC ? '✅' + MNEMONIC.slice(0, 4) + '...' + MNEMONIC.slice(-4) : '❌',
});

const mnemonic = (() => {
    if (MNEMONIC) {
        return MNEMONIC;
    }

    try {
        return fs.readFileSync(".mnemonic").toString().trim();
    } catch (err) {
        return generateMnemonic()
    }
})();

const getRemappings = () => {
    return fs
        .readFileSync("remappings.txt", "utf8")
        .split("\n")
        .filter(Boolean)
        .map((line) => line.trim().split("="));
};

const config: HardhatUserConfig = {
    networks: {
        hardhat: {
            forking: (FORK === "mainnet" && ALCHEMY_API) ? {
                url: ALCHEMY_API
            } : (FORK && ALCHEMY_RINKEBY_API) ? {
                url: ALCHEMY_RINKEBY_API,
            } : undefined,
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
        version: "0.8.9",
        settings: {
            optimizer: {
                enabled: true,
                runs: 10000,
                // runs: 4_294_967_295, // 2**32 - 1
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
            mainnet: ETHERSCAN_API_KEY,
            rinkeby: ETHERSCAN_API_KEY,
            goerli: ETHERSCAN_API_KEY,
            polygon: POLYGONSCAN_API_KEY,
            bsc: BSCSCAN_API_KEY,
            moonbeam: MOONBEAM_API_KEY,
            moonriver: MOONRIVER_API_KEY,
            moonbaseAlpha: MOONRIVER_API_KEY,
        },
    },

    // This fully resolves paths for imports in the ./lib directory for Hardhat
    preprocess: {
        eachLine: (hre) => ({
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
        }),
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
            "hardhat"
        ],
    },

};

export default config
