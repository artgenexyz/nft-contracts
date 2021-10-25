const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");
const Market = artifacts.require("Market");

const AmeegosNFT = artifacts.require("AmeegosNFT");
const AmeegosMintPass = artifacts.require("AmeegosMintPass");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";
const AMEEGOS_CONTRACT = "0xF522B448DbF8884038c684B5c3De95654007Fd2B";

const owner = "0x2195601e1EA42363C85AC7868143b80d20Db978f";

module.exports = async function(deployer, network) {
  let nft;

  if (network === "development" || network === "soliditycoverage" || network === "rinkeby") {
    await deployer.deploy(AmeegosNFT, "Ameegos Metaverse", "AMEEGOS", "uri://test", "uri://test");

    nft = await AmeegosNFT.deployed();
  } else if (network === "mainnet") {
    nft = await AmeegosNFT.at(AMEEGOS_CONTRACT);
  }

  await deployer.deploy(AmeegosMintPass, nft.address);

  const mintPass = await AmeegosMintPass.deployed();

  console.log("mint pass deployed to", mintPass.address);

  if (network === "development" || network === "soliditycoverage") {
    await mintPass.flipSaleStarted();
    await mintPass.transferOwnership(AMEEGOS_ADMIN);

    await nft.whitelistUsers([mintPass.address]);
    await nft.setOnlyWhitelisted(true);
    await nft.setNftPerAddressLimit(6000); // because MintPass needs to be able to mint from their address
    await nft.pause(false);

    await nft.transferOwnership(AMEEGOS_ADMIN);
  }

};
