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
    };

    // console.log("contract info", contractInfo);

    const cid = await client.storeBlob([JSON.stringify(contractInfo)]);

    // https://cloudflare-ipfs.com/ipfs/bafkreieigfk556awti66ju6a2ebmtrdhxbobavbpi3rx2mj2hnsmcg2llq

    console.log(
      `Metadata uploaded to https://cloudflare-ipfs.com/ipfs/${cid}\n\n`
    );

    return callback(`Deploy at https://deploy.buildship.dev?ipfs=${cid}`);
    // return callback(`https://cloudflare-ipfs.com/ipfs/${cid}`);
  } catch (err) {
    return callback(err);
  }
}
