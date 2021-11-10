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

    console.log(`Deploying ${contractName}`);
    // console.log(`Contract`, contract);

    const contractInfo = {
      name: contractName,
      abi: contract.abi,
      bytecode: contract.bytecode,
      // ? constructor arguments, compiler version, source code, optimizer enabled, runs, license
      extra: contract,
    };

    const cid = await client.storeBlob([JSON.stringify(contractInfo)]);

    console.log(
      `Metadata uploaded to https://cloudflare-ipfs.com/ipfs/${cid}\n`
    );

    console.log(`Deploy here:`);

    return callback(`https://app.buildship.dev/deploy?ipfs=${cid}`);
  } catch (err) {
    return callback(err);
  }
}
