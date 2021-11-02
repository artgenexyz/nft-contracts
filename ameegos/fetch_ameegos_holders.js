const fs = require('fs');
const delay = require('delay');

const AmeegosNFT = artifacts.require("AmeegosNFT");
const AmeegosMintPass = artifacts.require("AmeegosMintPass");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";
const AMEEGOS_CONTRACT = "0xF522B448DbF8884038c684B5c3De95654007Fd2B";

module.exports = async function(callback) {

    const a = await AmeegosNFT.at(AMEEGOS_CONTRACT);

    // output a.address
    console.log(a.address);

    const totalSupply = await a.totalSupply();
    console.log("totalSupply", totalSupply.toNumber());
    // fetch all NFT holders via ownerOf(tokenId)

    const holders = [];

    const loop = Array(totalSupply.toNumber()).fill(null);

    await Promise.all(loop.map(async (_, index) => {

        const tokenId = index + 1;
        const holder = await a.ownerOf(tokenId);
        holders.push({ tokenId, holder });

        console.log('holder', tokenId, holder);
    }));

    // save holders to holders.json
    fs.writeFileSync('./holders_all.json', JSON.stringify(holders, null, 2));

    callback();
}
