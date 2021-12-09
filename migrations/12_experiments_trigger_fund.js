
const Equation = artifacts.require("Equation");
const TriggerFund = artifacts.require("TriggerFund");

module.exports = async function (deployer, network, accounts) {
    const eq = await deployer.deploy(Equation);

    // link Equation to TriggerFund
    await deployer.link(Equation, TriggerFund);

    await deployer.deploy(TriggerFund);
    const NFTFactory = artifacts.require("NFTFactory");
};
