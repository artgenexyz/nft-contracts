const GaslessNFT = artifacts.require("GaslessNFT");
const AvatarNFT = artifacts.require("AvatarNFT");
const AvatarNFTWithMintPass = artifacts.require("AvatarNFTWithMintPass");
const BurnNFT = artifacts.require("BurnNFT");

module.exports = function (deployer) {
  deployer.deploy(GaslessNFT);
  deployer.deploy(AvatarNFT);
  deployer.deploy(AvatarNFTWithMintPass);
  deployer.deploy(BurnNFT);
};
