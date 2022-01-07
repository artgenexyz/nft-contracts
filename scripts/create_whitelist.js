const { isAddress, toChecksumAddress } = require('web3-utils')
const fs = require('fs')
const path = require('path')
const fetch = require('node-fetch')
// const { NFTStorage } = require('nft.storage')

const processAddress = (address) => {
    address = toChecksumAddress(address)

    if (isAddress(address)) {
        return address
    }
    // TODO: parse ens domains

    return null
}

// extract contract name from config arguments
const [ ,, filename, contractAddress ] = process.argv;

console.log("Using contract", contractAddress);
console.log("With list of addresses from", filename);
console.log("");

(async () => {

    // parse filename and contract_address from process.argv
    // read csv file from filename, removing first row

    const addresses = fs.readFileSync(path.join(__dirname, filename), "utf8").split("\n").slice(1)

    const whitelist = addresses.filter(x => !!x).map((address) => processAddress(address)).filter(x => !!x)

    // save the list to db by pushing to API
    // POST https://metadata.buildship.dev/api/extensions/merkle-tree/create
    // JSON = { creator, addresses }

    const url = `https://metadata.buildship.dev/api/extensions/merkle-tree/create`;

    const options = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            _creator: contractAddress,
            addresses: whitelist
        })
    };

    const response = await fetch(url, options);

    const json = await response.json();

    // print response
    console.log('saved', json);

    const { id } = json

    // check airdrop info by id
    // GET https://metadata.buildship.dev/api/extensions/merkle-tree/by-id/:id

    const url2 = `https://metadata.buildship.dev/api/extensions/merkle-tree/by-id/${id}`;

    const response2 = await fetch(url2);

    const json2 = await response2.json();

    // print response
    console.log('loaded', json2);

    // get price from whitelist extensions getPrice
    // const price = await WhitelistMerkleTreeExtension.at(contractAddress).price().call()

    // create JSON for whitelist with structure { wallets, price, contract }
    const whitelistInfo = { wallets: whitelist, contract: contractAddress, price: 0 }

    // print JSON to console
    console.log('')
    console.log({ 1: whitelistInfo })

    // TODO: save to IPFS using nft.storage

})();



// const { isAddress, toChecksumAddress } = require('web3-utils')

// const processAddress = (address) => {
//     address = toChecksumAddress(address)

//     if (isAddress(address)) {
//         return address
//     }
//     // TODO: parse ens domains

//     return null
// }

// module.exports = async function (callback) {
//     try {
//         // if process.argv elements contain "help"
//         if (process.argv.find((elem) => elem.includes("help"))) {
//             console.log(`Usage: truffle exec scripts/create_whitelist.mjs [contract] [address.csv]`);
//             return callback();
//         }

//         // extract contract name from config arguments
//         const [, , , , contractName, filename ] = process.argv;

//         console.log("Using contract", contractName);
//         console.log("With list of addresses from", filename);
//         console.log("");

//         if (!contractName) {
//             console.log(`Usage: truffle exec scripts/create_whitelist.mjs [contract] [address.csv]`);
//             return callback();
//         }

//         const contract = artifacts.require(contractName);

//         console.log(`Loading ${contractName}`);

//         const contractInstance = await contract.deployed();

//         // const contractAddress = contractInstance.address
//         const contractAddress = contract.address

//         // parse filename and contract_address from process.argv
//         // read csv file from filename, removing first row

//         const addresses = await fs.readFileSync(filename, "utf8").split("\n").slice(1)

//         const whitelist = addresses.map((address) => processAddress(address))

//         // save the list to db by pushing to API
//         // POST https://metadata.buildship.dev/api/extensions/merkle-tree/create
//         // JSON = { creator, addresses }

//         const url = `https://metadata.buildship.dev/api/extensions/merkle-tree/create`;

//         const options = {
//             method: "POST",
//             headers: {
//                 "Content-Type": "application/json"
//             },
//             body: JSON.stringify({
//                 creator: contractAddress,
//                 addresses: whitelist
//             })
//         };

//         const response = await fetch(url, options);

//         const json = await response.json();

//         // print response
//         console.log('saved', json);

//         const { id } = json

//         // check airdrop info by id
//         // GET https://metadata.buildship.dev/api/extensions/merkle-tree/by-id/:id

//         const url2 = `https://metadata.buildship.dev/api/extensions/merkle-tree/by-id/${id}`;

//         const response2 = await fetch(url2);

//         const json2 = await response2.json();

//         // print response
//         console.log('loaded', json2);

//         // get price from whitelist extensions getPrice
//         const price = await contractInstance.price().call()

//         // create JSON for whitelist with structure { wallets, price, contract }
//         const whitelistInfo = { wallets: whitelist, contract: contractAddress, price }

//         // save to IPFS using nft.storage
//         // print JSON to console

//         console.log('whitelist json', whitelistInfo)

//     } catch (err) {
//         console.log('Error', err.message);
//     } finally {
//         callback();
//     }

// };

