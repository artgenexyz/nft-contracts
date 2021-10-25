const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");
const Market = artifacts.require("Market");

const DemoAGOS = artifacts.require("DemoAGOS");
const DemoShiba = artifacts.require("DemoShiba");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";

module.exports = async function(deployer, network) {
    // Second stage of Ameegos deployment

    await deployer.deploy(DemoAGOS, { overwrite: false});
    // await deployer.deploy(DemoShiba);

    const agos = await DemoAGOS.deployed();
    // const shiba = await DemoShiba.deployed();

    await deployer.deploy(AmeegosMarketplace, agos.address);
    const extras = await AmeegosMarketplace.deployed();

    // await deployer.deploy(Market, extras.address);    

};
