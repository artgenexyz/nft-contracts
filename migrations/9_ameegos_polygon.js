const AmeegosNFTv2 = artifacts.require("AmeegosNFTv2");
const AmeegosMintPassv2 = artifacts.require("AmeegosMintPassv2");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";

const { assert } = require('chai');
const NFT_HOLDERS = require('../ameegos/holders.json');
const MINTPASS_HOLDERS = require('../ameegos/mintpass_holders.json');

module.exports = async function(deployer, network) {
    if (network !== "polygon" && network !== "polygon-fork" && network !== "rinkeby") {
        return
    }

    await deployer.deploy(AmeegosNFTv2);
    const nft = await AmeegosNFTv2.deployed();

    await deployer.deploy(AmeegosMintPassv2, nft.address);
    const mint = await AmeegosMintPassv2.deployed();

    await nft.setMinter(mint.address);
    await nft.setBeneficiary(AMEEGOS_ADMIN);

    // if not polygon, setPrice to 0.01 ether = 1e16
    if (network !== "polygon") {
        await nft.setPrice(1e16.toString());
    }

    // sort holders by tokenID – already sorted
    // NFT_HOLDERS.sort((a, b) => {
    //     return a.tokenID - b.tokenID;
    // });

    // mint NFTs by claimReserved(amount, address) using Promise.all
    const mintNFTs = Promise.all(NFT_HOLDERS.map(async ({ holder }) => {
        await nft.claimReserved(1, holder);
    }));

    await mintNFTs;

    // check that tokenID = 7 belongs to 0xc2c2E23dd7d2511cEa79B41310697A87dC8d7a3c
    // assert(await nft.ownerOf(7) === "0xc2c2E23dd7d2511cEa79B41310697A87dC8d7a3c", "tokenID 7 should belong to 0xc2c2E23dd7d2511cEa79B41310697A87dC8d7a3c");


    // distribute mint pass to MINTPASS_HOLDERS using .issue(number, address)
    Promise.all(MINTPASS_HOLDERS.map(async ({ holder, amount }) => {
        await mint.issue(amount, holder);
    }));

    // open sale for MintPass
    await mint.flipSaleStarted();

};
