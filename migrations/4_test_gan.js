const OnChainGAN = artifacts.require("../contracts/OnChainGAN.sol");

module.exports = async function(deployer) {
    deployer.deploy(OnChainGAN);
};
