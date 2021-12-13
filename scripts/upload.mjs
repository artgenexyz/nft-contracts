const fs = require("fs");
const { exec } = require("child_process");

const { NFTStorage } = require("nft.storage");

const NFT_STORAGE_API_KEY = process.env.NFT_STORAGE_API_KEY;
const client = new NFTStorage({ token: NFT_STORAGE_API_KEY });

/**
 * Uploads a compiled contract to IPFS
 * @param {string} contractName - The address of the contract.
 */
module.exports = async function(callback) {
  try {
    // console.log('process.argv', process.argv)

    // if process.argv elements contain "help"
    if (process.argv.find((elem) => elem.includes("help"))) {
      console.log(`Usage: truffle exec upload [contract]`);
      return callback();
    }

    // extract contract name from config arguments
    const [, , , , contractName] = process.argv;

    console.log("Using contract", contractName);

    if (!contractName) {
      console.log(`Usage: truffle exec upload [contract]`);
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
        exec(sh, (err, stdout) => {
          if (err) {
            console.log("Error flattening contract:", err);
            return reject(err);
          }

          console.log("Flattened contract:", stdout);
          resolve();
        });
      })

      flattened = fs.readFileSync("./tmp/Flattened.sol", "utf8");

    } catch (err) {
      console.log("Error flattening contract, sending empty source code", err);
    } finally {
      // rm flattened file
      fs.rmSync("./tmp/Flattened.sol");
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

    return callback(`https://gate-rinkeby.buildship.dev/deploy/${cid}`);
  } catch (err) {
    return callback(err);
  }
}
