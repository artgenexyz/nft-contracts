import "dotenv/config";
import "@nomiclabs/hardhat-waffle";
import { task } from "hardhat/config";

import fs from "fs";
import { exec } from "child_process";
import minimist from "minimist";

import { NFTStorage, Blob } from "nft.storage";

import { getLongVersion } from "./solc/version";

const NFT_STORAGE_API_KEY = process.env.NFT_STORAGE_API_KEY;
const argv = minimist(process.argv.slice(2));

// Uploads a compiled contract to IPFS and returns its hash
task("upload", "Uploads a compiled contract to IPFS and returns deploy link")
.addPositionalParam("contract", "Contract to deploy")
.addOptionalParam("args", "Deploy arguments")
.addOptionalParam("ascii", "ASCII art file path (.txt)")
.setAction(async (taskArgs, hre) => {
    try {

        if (!NFT_STORAGE_API_KEY) {
            console.error('Please put NFT_STORAGE_API_KEY in .env');
            process.exit(-1);
        }

        const client = new NFTStorage({ token: NFT_STORAGE_API_KEY });

        await hre.run("compile");

        // console.log('process.argv', process.argv)
        const { contract, args, ascii } = taskArgs;

        console.log("Using contract", contract);

        if (!contract || !fs.existsSync(contract)) {
            console.log(`Usage: npx hardhat upload [contract name] --args '"arg1","arg2"'`);
            return;
        }

        // const factory = await hre.ethers.getContractFactory(contractName);

        // extract filename from contract
        const filename = contract.split("/").pop().replace(".sol", "");

        if (!filename) {
            console.log(`File has no name`);
            return;
        }

        // read dir ./artifacts/${contract} and open the {filename}.json file
        const contractArtifact = JSON.parse(fs.readFileSync(`./artifacts/${contract}/${filename}.json`).toString());

        const { abi, bytecode, ...artifact } = contractArtifact;

        // if process.argv elements contain "help"
        if (argv._.find((elem) => elem.includes("help"))) {
            console.log(`Usage: npx hardhat upload [contract name] --args '"arg1","arg2"'`);
            return;
        }

        let flattened;

        try {
            // try flattening contract
            const sourcePath = contract;

            // create dir ./tmp
            if (!fs.existsSync("./tmp")) {
                fs.mkdirSync("./tmp");
            }

            // await run("flatten", [ sourcePath, "./tmp/Flattened.sol" ]);

            // const sh = `npx truffle-flattener ${sourcePath} | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' > ./tmp/Flattened.sol`;
            const sh = `npx hardhat flatten "${sourcePath}" > ./tmp/Flattened.sol`;

            // run the flattener
            console.log("\nRunning command:", sh);

            await new Promise((resolve, reject) => {
                exec(sh, (err, stdout, stderr) => {
                    if (err || stderr) {
                        console.log("Error flattening contract:", err);
                        return reject(err);
                    }

                    // pipe stdout and stderr to console
                    stdout && console.log(`\nOutput: ${stdout.split("\n").join("\n\t")}`);
                    stderr && console.log(`\nErrors: ${stderr.split("\n").join("\n\t")}`);

                    resolve(true);
                });
            })

            flattened = fs.readFileSync("./tmp/Flattened.sol", "utf8");

            if (!flattened) {
                throw new Error("No flattened contract");
            }

            // from https://github.com/boringcrypto/dictator-dao/blob/a3de9f606d05852eb5cfa811a3f38870ab22800a/hardhat.config.js#L60

            // Remove every line started with "// SPDX-License-Identifier:"
            flattened = flattened.replace(/SPDX-License-Identifier:/gm, "License-Identifier:")

            flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`

            // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
            flattened = flattened.replace(/pragma experimental ABIEncoderV2;\n/gm, ((i) => (m: string) => (!i++ ? m : ""))(0))

            flattened = flattened.trim()

            if (ascii) {
                // read file from ascii and paste in front of flattened
                const art = fs.readFileSync(ascii, "utf8");

                flattened = `${art}\n\n${flattened}`;
            }

            // write it back
            fs.writeFileSync("./tmp/Flattened.sol", flattened);

        } catch (err) {
            // process exit with error message
            console.error(`\nError:`, err);
            return
        } finally {
            // rm flattened file
            !process.env.KEEP && fs.rmSync("./tmp/Flattened.sol");
            // fs.rmdirSync("./tmp");
        }

        console.log(`\nDeploying ${contract}`);

        const longVersion = await getLongVersion(hre.config.solidity.compilers[0].version);

        const longVersionString = longVersion.replace(/^v/, "");

        const contractInfo = {
            name: contractArtifact.contractName,
            filename: filename,
            abi: abi,
            bytecode: bytecode,
            artifact: artifact,
            extra: {
                metadata: JSON.stringify({
                    ...hre.config.solidity.compilers[0],
                    compiler: {
                        ...hre.config.solidity.compilers[0],
                        version: longVersionString,
                    },
                }),
            },
            flattened: flattened,
        };

        const blob = new Blob([JSON.stringify(contractInfo)], { type: "application/json" });
        const cid = await client.storeBlob(blob);

        console.log(
            `Metadata uploaded to https://cloudflare-ipfs.com/ipfs/${cid}\n`
        );

        console.log(`Deploy here:`);

        const argsString = args ? `?args=%5B${encodeURIComponent(args)}%5D` : "?args=%5B%5D";

        console.log(`https://gate-rinkeby.buildship.xyz/deploy/${cid}${argsString}`);

    } catch (err) {
        console.error(err);

    }
});

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
