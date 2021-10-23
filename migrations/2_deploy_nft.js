const GaslessNFT = artifacts.require("GaslessNFT");
const AvatarNFT = artifacts.require("AvatarNFT");
const AvatarNFTWithMintPass = artifacts.require("AvatarNFTWithMintPass");
const BurnNFT = artifacts.require("BurnNFT");
const TemplateNFT = artifacts.require("TemplateNFT");
const TextApesNFT = artifacts.require("TextApesNFT");
const ReferralNFT = artifacts.require("ReferralNFT");

module.exports = function (deployer, network) {
  if (network === "development") {
    deployer.deploy(AvatarNFT, "30000000000000000", 500, 200, 20, "https://metadata.buildship.dev/", "Avatar Collection NFT", "NFT");

    deployer.deploy(GaslessNFT);
    deployer.deploy(BurnNFT);

    deployer.deploy(AvatarNFTWithMintPass);
    deployer.deploy(TemplateNFT);
    deployer.deploy(TextApesNFT);

    deployer.deploy(ReferralNFT, "20000000000000000", 10000, 200, 20, 200, "https://metadata.buildship.dev/", "Referral Collection NFT", "NFT");
  } else {
    console.log("Skipping deploying test NFTs on production network");
  }
};
