const AmeegosExtras = artifacts.require("AmeegosExtras");
const Market = artifacts.require("Market");
const AvatarNFT = artifacts.require("AvatarNFT");

module.exports = async function(deployer) {
  // deployer.deploy(AvatarNFT, "30000000000000000", 500, 200, 20, "https://metadata.buildship.dev/", "Avatar Collection NFT", "NFT");

  const mintPass = await AvatarNFT.new("3000000000000000", 500, 200, 20, "https://mintpass.io", "Test Mint Pass", "MINTPASS");

  await deployer.deploy(AmeegosExtras, mintPass.address);

  const extras = await AmeegosExtras.deployed();

  await deployer.deploy(Market, extras.address);
};
