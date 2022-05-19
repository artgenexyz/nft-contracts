const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const MetaverseNFT = await hre.ethers.getContractFactory("MetaverseNFT");
  const metaverseNFT = await MetaverseNFT.deploy();

  await metaverseNFT.deployed();

  console.log("MetaverseNFT deployed to:", metaverseNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
