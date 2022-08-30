const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ERC721CommunityImplementation = await hre.ethers.getContractFactory("ERC721CommunityImplementation");
  const metaverseNFT = await ERC721CommunityImplementation.deploy();

  await metaverseNFT.deployed();

  console.log("ERC721CommunityImplementation deployed to:", metaverseNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
