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

    const addresses = fs.readFileSync(filename, "utf8").split("\n").slice(1)

    const whitelist = addresses.filter(x => !!x).map(x => x.replace(/[\s\r]+/ig, ''))

    console.log('First 5 addresses parsed:', whitelist.slice(0, 5))

    const url = `https://metadata.buildship.dev/api/extensions/merkle-tree/create`;

    const body = JSON.stringify({
        // whitelist_address is empty, we probably didn't deploy yet
        token_address: contractAddress,
        creator: contractAddress,
        addresses: whitelist
    })

    const options = {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: body
    };

    console.log('Pushing create merkle-tree', JSON.stringify({
        token_address: contractAddress,
        creator: contractAddress,
        addresses: whitelist }, null, 2).split('\n').slice(0,10).join('\n'), '\n...');

    const response = await fetch(url, options);

    const json = await response.json();

    console.log(json);

    const { id } = json

    // check airdrop info by id
    // GET https://metadata.buildship.dev/api/extensions/merkle-tree/by-id/:id

    const url2 = `https://metadata.buildship.dev/api/extensions/merkle-tree/by-id/${id}`;

    console.log('Checking airdrop at id', id);

    const response2 = await fetch(url2);

    const json2 = await response2.json();

    // print response
    console.log(json2);

    const { error, token, root } = json2;

    if (error) {
        console.log('Error:', error);
        return;
    }

    const price = 0;
    const limitPerAddress = 1;
    const args = encodeURI(JSON.stringify([ token, root, price.toString(), limitPerAddress ]));

    // result of running:
    // truffle exec scripts/upload.mjs WhitelistMerkleTreeExtension --network rinkeby
    const whitelistHash = 'bafkreifr5he5hx2j3mtmpfo7ttygzfcmoycwsql2wpsy6vqdnrht2rtjce'

    const deploy_url = `https://gate.buildship.dev/deploy/${whitelistHash}?args=${args}`

    console.log('\n\tDeploy contract at', deploy_url, '\n');

    console.log('\n\tAFTER DEPLOYMENT, DONT FORGET TO UPDATE whitelist_address in DB! https://app.supabase.io/project/kajjntikyfbnawsvyvao/editor/16886\n')

})();
