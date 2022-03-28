const fs = require("fs");
const { exec } = require("child_process");
const minimist = require("minimist");

const { NFTStorage } = require("nft.storage");

const NFT_STORAGE_API_KEY = process.env.NFT_STORAGE_API_KEY;
const argv = minimist(process.argv.slice(2));

if (!NFT_STORAGE_API_KEY) {
  console.error('Please put NFT_STORAGE_API_KEY in .env');
  process.exit(-1);
}

const client = new NFTStorage({ token: NFT_STORAGE_API_KEY });

/**
 * Uploads a compiled contract to IPFS
 * @param {string} contractName - The address of the contract.
 */
module.exports = async function(callback) {
  try {
    // console.log('process.argv', process.argv)

    // if process.argv elements contain "help"
    if (argv._.find((elem) => elem.includes("help"))) {
      console.log(`Usage: truffle exec upload [contract]`);
      return callback();
    }

    // extract contract name from config arguments
    const contractName = argv._[2] || argv.contractName;

    console.log("Using contract", contractName);

    if (!contractName) {
      console.log(`Usage: truffle exec upload [contract] --args '"arg1","arg2"'`);
      return callback();
    }

    const contract = artifacts.require(contractName);

    let flattened;

    try {
      // try flattening contract
      const { sourcePath } = contract;

      // create dir ./tmp
      if (!fs.existsSync("./tmp")) {
        fs.mkdirSync("./tmp");
      }

      const sh = `npx truffle-flattener ${sourcePath} | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' > ./tmp/Flattened.sol`;

      // run the flattener
      console.log("\nRunning command:", sh);

      await new Promise((resolve, reject) => {
        exec(sh, (err, stdout, stderr) => {
          if (err) {
            console.log("Error flattening contract:", err);
            return reject(err);
          }

          // pipe stdout and stderr to console
          stdout && console.log(`\nOutput: ${stdout.split("\n").join("\n\t")}`);
          stderr && console.log(`\nErrors: ${stderr.split("\n").join("\n\t")}`);

          resolve();
        });
      })

      flattened = fs.readFileSync("./tmp/Flattened.sol", "utf8");

      if (!flattened) {
        throw new Error("No flattened contract");
      }

    } catch (err) {
      // process exit with error message
      return callback(`\nError: ${err.message}\n`);
    } finally {
      // rm flattened file
      !process.env.KEEP && fs.rmSync("./tmp/Flattened.sol");
      // fs.rmdirSync("./tmp");
    }

    console.log(`\nDeploying ${contractName}`);

    const contractInfo = {
      name: contractName,
      abi: contract.abi,
      bytecode: contract.bytecode,
      extra: contract,
      flattened: flattened,
    };

    const cid = await client.storeBlob([JSON.stringify(contractInfo)]);

    console.log(
      `Metadata uploaded to https://cloudflare-ipfs.com/ipfs/${cid}\n`
    );

    console.log(`Deploy here:`);

    const argsString = argv.args ? `?args=%5B${encodeURIComponent(argv.args)}%5D` : "";

    return callback(`https://gate-rinkeby.buildship.dev/deploy/${cid}${argsString}`);

  } catch (err) {
    return callback(err);
  }
}
