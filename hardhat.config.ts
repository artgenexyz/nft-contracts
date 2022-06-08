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

import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";

import "@tenderly/hardhat-tenderly";

import "solidity-coverage";
import "hardhat-gas-reporter";
import "hardhat-deploy";
import "hardhat-contract-sizer";
import "hardhat-tracer";

import "./scripts/upload";

const INFURA_KEY = process.env.INFURA_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY;
const MOONBEAM_API_KEY = process.env.MOONBEAM_API_KEY;
const MOONRIVER_API_KEY = process.env.MOONRIVER_API_KEY;
const MNEMONIC = process.env.MNEMONIC;

const USING_ZKSYNC = !!process.env.ZKSYNC;

stdout.isTTY && console.log('Using env variables', {
    INFURA_KEY: INFURA_KEY ? '✅' : '❌',
    ETHERSCAN_API_KEY: ETHERSCAN_API_KEY ? '✅' : '❌',
    POLYGONSCAN_API_KEY: POLYGONSCAN_API_KEY ? '✅' : '❌',
    BSCSCAN_API_KEY: BSCSCAN_API_KEY ? '✅' : '❌',
    MOONBEAM_API_KEY: MOONBEAM_API_KEY ? '✅' : '❌',
    MOONRIVER_API_KEY: MOONRIVER_API_KEY ? '✅' : '❌',
    MNEMONIC: MNEMONIC ? '✅' + MNEMONIC.slice(0,4) + '...' + MNEMONIC.slice(-4) : '❌',
    USING_ZKSYNC: USING_ZKSYNC ? '✅' : '❌',
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

const config: HardhatUserConfig = {
    networks: {
        hardhat: {
            // To compile with zksolc, this must be the default network.
            zksync: USING_ZKSYNC,
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
            polygon: POLYGONSCAN_API_KEY,
            bsc: BSCSCAN_API_KEY,
            moonbeam: MOONBEAM_API_KEY,
            moonriver: MOONRIVER_API_KEY,
            moonbaseAlpha: MOONRIVER_API_KEY,
        },
    },


    zksolc: {
        version: "0.1.0",
        compilerSource: "docker",
        settings: {
            compilerPath: "zksolc",
            // compilerPath: "docker://zksolc/zksolc:0.1.0",
            optimizer: {
                enabled: true,
            },
            experimental: {
                dockerImage: "matterlabs/zksolc",
            },
        },
    },
    zkSyncDeploy: {
        zkSyncNetwork: "https://zksync2-testnet.zksync.dev",
        ethNetwork: `https://goerli.infura.io/v3/${INFURA_KEY}`,
        // ethNetwork: "goerli", // Can also be the RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
    },
};

export default config