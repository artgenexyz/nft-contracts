import hre, { ethers } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const contractName = process.env.CONTRACT || "DemoCollection";
const args = process.env.ARGS ? JSON.parse(process.env.ARGS) : [];

export default async function main(hre: HardhatRuntimeEnvironment) {
  const [admin] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", admin.address);

  const artifact = await hre.artifacts.readArtifact(contractName);

  // deploy contract to goerli

  const Factory = await hre.ethers.getContractFactory(contractName);

  const contract = await Factory.deploy(...args);

  await contract.deployed();

  console.log(contractName, "deployed to:", contract.address);

  console.log("Verifiying contract on etherscan...", {
    address: contract.address,
    contract: `${artifact.sourceName}:${artifact.contractName}`,
    constructorArguments: args,
  });

  // verify contract on etherscan
  await hre.run("verify:verify", {
    address: contract.address,
    contract: `${artifact.sourceName}:${artifact.contractName}`,
    constructorArguments: args,
  });
}

// call main only if executed directly
if (process.argv[1] === __filename) {
  // if --help or -h flag is passed, show help
  // if (process.argv[2] === "--help" || process.argv[2] === "-h" || process.argv.length < 4) {
  //     console.log(
  //         "Usage: npx hardhat run scripts/deploy-onchain-art-storage-extension.ts <nft> <artwork>"
  //     );
  //     process.exit(0);
  // }

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main(hre).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
