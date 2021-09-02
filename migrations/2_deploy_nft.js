const GaslessNFT = artifacts.require("GaslessNFT");

module.exports = function (deployer) {
  deployer.deploy(GaslessNFT);
};
