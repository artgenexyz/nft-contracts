const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");
const Market = artifacts.require("Market");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";

module.exports = async function(deployer, network) {
    let nft;

    // Second stage of Ameegos deployment
    await deployer.deploy(AmeegosMarketplace);
    const extras = await AmeegosMarketplace.deployed();
    await deployer.deploy(Market, extras.address);

    // await extras.addItem("Dirty Stone Skin", "https://www.vizpark.com/wp-content/uploads/2018/06/VP-Stone-floor-1-cam-2-870x489.jpg", "10000000000000000", 1000, true);
    // await extras.addItem("Pretty Carpet Skin", "https://i.pinimg.com/originals/23/bc/15/23bc157ee8f708b216a6d386de51460c.jpg", "3000000000000000", 2000, true);

    //   await extras.buyItem(0, 1, {value: "10000000000000000"});
    //   await extras.transferOwnership(AMEEGOS_ADMIN);

};
