const MoonNFT = artifacts.require("MoonNFT");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(MoonNFT);
};
