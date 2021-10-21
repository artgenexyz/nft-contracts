const AmeegosExtras = artifacts.require("AmeegosExtras");
const Market = artifacts.require("Market");

const owner = "0x2195601e1EA42363C85AC7868143b80d20Db978f";

module.exports = async function(deployer) {
  // deployer.deploy(AvatarNFT, "30000000000000000", 500, 200, 20, "https://metadata.buildship.dev/", "Avatar Collection NFT", "NFT");

  // const mintPass = await AvatarNFT.new("3000000000000000", 500, 200, 20, "https://mintpass.io", "Test Mint Pass", "MINTPASS");

  await deployer.deploy(AmeegosExtras);

  const extras = await AmeegosExtras.deployed();

  await deployer.deploy(Market, extras.address);

  // price   uint256 :  1000000000000000
  // maxSupply   uint256 :  1000
  // mintedSupply   uint256 :  3
  // name   string :  Dirty Stone Skin
  // imageUrl   string :  https://www.vizpark.com/wp-content/uploads/2018/06/VP-Stone-floor-1-cam-2-870x489.jpg

  await extras.addItem("Dirty Stone Skin", "https://www.vizpark.com/wp-content/uploads/2018/06/VP-Stone-floor-1-cam-2-870x489.jpg", "10000000000000000", 1000, true);

  // price   uint256 :  3000000000000000
  // maxSupply   uint256 :  2000
  // mintedSupply   uint256 :  5
  // name   string :  Pretty Carpet Skin
  // imageUrl   string :  https://i.pinimg.com/originals/23/bc/15/23bc157ee8f708b216a6d386de51460c.jpg

  await extras.addItem("Pretty Carpet Skin", "https://i.pinimg.com/originals/23/bc/15/23bc157ee8f708b216a6d386de51460c.jpg", "3000000000000000", 2000, true);

  await extras.buyItem(0, 1, {value: "10000000000000000"});

  await extras.transferOwnership(owner);

};
