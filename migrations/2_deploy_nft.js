const GaslessNFT = artifacts.require("GaslessNFT");
const AvatarNFT = artifacts.require("AvatarNFT");
const AvatarNFTWithMintPass = artifacts.require("AvatarNFTWithMintPass");
const BurnNFT = artifacts.require("BurnNFT");
const TemplateNFT = artifacts.require("TemplateNFT");

module.exports = function (deployer) {
  deployer.deploy(AvatarNFT, "30000000000000000", 200, 500, 20, "https://metadata.buildship.dev/", "Avatar Collection NFT", "NFT");

  deployer.deploy(GaslessNFT);
  deployer.deploy(BurnNFT);

  deployer.deploy(AvatarNFTWithMintPass);
  deployer.deploy(TemplateNFT);
};
