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
    } else if (network == "mainnet" || network == "mainnet-fork") {
        // AGOS token from mainnet
        // https://etherscan.io/address/0x5e2c6385e2b663a2f460bfb3a9d18c76c4739ff5
        agos = { address: "0x5e2C6385e2b663A2F460BFB3a9d18C76c4739ff5" };
    } else {
        // agos = { address: "0x5e2C6385e2b663A2F460BFB3a9d18C76c4739ff5" };
        console.error("Unknown network: " + network);
        return;
    }

    console.log('Using AGOS', agos.address);

    await deployer.deploy(AmeegosMarketplace, agos.address);
    const extras = await AmeegosMarketplace.deployed();

    if (network == "development" || network == "soliditycoverage") {

    } else if (network == "rinkeby") {
        await extras.addItem("Test Item", "https://uri", 1e15.toString(), 100, 0, true);

        await extras.buyItem(0, 1, { value: 1e15.toString() });

        await extras.withdraw();

        // await extras.transferOwnership("0x44244acacd0b008004f308216f791f2ebe4c4c50");

    } else {
        await extras.transferOwnership("0x44244acaCD0B008004F308216f791F2EBE4C4C50");


    }
};
