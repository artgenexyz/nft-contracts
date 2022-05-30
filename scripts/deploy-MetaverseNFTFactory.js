const hre = require("hardhat");

async function main() {
  const MetaverseNFTFactory = await hre.ethers.getContractFactory(
    "MetaverseNFTFactory"
  );
  const metaverseNFTFactory = await MetaverseNFTFactory.deploy(
    "0x0000000000000000000000000000000000000000"
  );

  await metaverseNFTFactory.deployed();

  console.log("MetaverseNFTFactory deployed to:", metaverseNFTFactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
