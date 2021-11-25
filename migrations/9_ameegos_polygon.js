const AmeegosNFTv2 = artifacts.require("AmeegosNFTv2");
const AmeegosMintPassv2 = artifacts.require("AmeegosMintPassv2");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";

const { assert } = require('chai');
const NFT_HOLDERS = require('../scripts/ameegos/holders.json');
const MINTPASS_HOLDERS = require('../scripts/ameegos/mintpass_holders.json');

module.exports = async function(deployer, network) {
    if (network !== "polygon" && network !== "polygon-fork" && network !== "mumbai" && network !== "rinkeby" && network !== "development") {
        return
    }

    return;

    await deployer.deploy(AmeegosNFTv2);
    const nft = await AmeegosNFTv2.at("0xf033e4593056f91d43770e01d59449c987ba2e68");

    await deployer.deploy(AmeegosMintPassv2, nft.address);
    const mint = await AmeegosMintPassv2.at("0x63420e1bf75079688dca30c9e866b1d3ed6ec083");

    // await nft.transferOwnership("0x44244acacd0b008004f308216f791f2ebe4c4c50");
    // await mint.transferOwnership("0x44244acacd0b008004f308216f791f2ebe4c4c50");
    // return;

    await nft.setMinter(mint.address);
    await nft.setBeneficiary(AMEEGOS_ADMIN);

    // if not polygon, setPrice to 0.01 ether = 1e16
    if (network !== "polygon") {
        await nft.setPrice(1e16.toString());
    }

    if (network === "development") {
        return
    }

    // mint NFTs by claimReserved(tokenIds[], address[]) in batches of 20
    for (let i = 0; i < NFT_HOLDERS.length; i += 50) {
        const batch = NFT_HOLDERS.slice(i, i + 50);
        const tokenIds = batch.map(h => h.tokenId);
        const holders = batch.map(h => h.holder);
        console.log("Minting batch", i, "of", NFT_HOLDERS.length, "with", tokenIds.length, "tokenIds\n", tokenIds);

        const tx = await nft.claimBatch(tokenIds, holders);
    }

    // distribute mint pass to MINTPASS_HOLDERS using .issue(number, address)
    Promise.all(MINTPASS_HOLDERS.map(async ({ holder, amount }) => {
        console.log("Minting for", holder, ":", amount, "mintpass");
        await mint.issue(amount, holder);
    }));

    // open sale for MintPass
    await mint.flipSaleStarted();

};
