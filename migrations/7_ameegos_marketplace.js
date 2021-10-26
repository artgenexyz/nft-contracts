const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");
const Market = artifacts.require("Market");

const DemoAGOS = artifacts.require("DemoAGOS");
const DemoShiba = artifacts.require("DemoShiba");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";

module.exports = async function(deployer, network) {
    // Second stage of Ameegos deployment

    let agos, shiba;

    if (network == "development" || network == "soliditycoverage") {
        await deployer.deploy(DemoAGOS);
        await deployer.deploy(DemoShiba);
        
        agos = await DemoAGOS.deployed();
        shiba = await DemoShiba.deployed();
    } else if (network == "rinkeby") {
        agos = { address: "0xE09761C663276d8aD44C3F45c7529634056Da856" };
    } else {
        await deployer.deploy(DemoAGOS);
        agos = await DemoAGOS.deployed();
    }
    await deployer.deploy(AmeegosMarketplace, agos.address);
    const extras = await AmeegosMarketplace.deployed();

    if (network == "development" || network == "soliditycoverage") {

    } else {
        extras.transferOwnership("0x44244acacd0b008004f308216f791f2ebe4c4c50");
    }
};
