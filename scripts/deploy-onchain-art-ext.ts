import { Base64Converter } from "./../typechain-types/contracts/extensions/OnchainArtStorageExtension.sol/Base64Converter";
import fs from "fs";
import hre, { ethers } from "hardhat";
import { getContractAddress, parseEther } from "ethers/lib/utils";

import readline from "readline";

import { stdin as input, stdout as output } from "process";

const rl = readline.createInterface({ input, output });

const question = (query: string): Promise<string> =>
  new Promise((resolve, reject) => {
    try {
      rl.question(query, (answer) => {
        resolve(answer);
        rl.close();
      });
    } catch (err) {
      reject(err);
    }
  });

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const main = async () => {
  const [admin] = await hre.ethers.getSigners();

  // get values from console input: nft contract address, artwork string
  const nft = await question("Enter NFT contract address: ");
  // const artwork = await question("Enter artwork string: ");

  // print values
  console.log("NFT contract address is", nft);
  // console.log("Artwork string is", artwork);

  // check that nft is a valid address and has contract code
  const code = await hre.ethers.provider.getCode(nft);
  if (code === "0x") {
    throw new Error("NFT contract address is not valid");
  }

//   const lib = await hre.ethers.getContractFactory("Base64Converter");
//   const libDeployed = await lib.deploy();
//   await libDeployed.deployed();
//   console.log("Base64Converter deployed to:", libDeployed.address);

  // deploy OnchainArtStorageExtension.sol
  const OnchainArtStorageExtension = await hre.ethers.getContractFactory(
    "OnchainArtStorageExtension",
    {
      libraries: {
        Base64Converter: '0x65581bfCcbAaD498Dac703c7e4462A6E3f48644b'
      },
    }
  );
  const onchainArtStorageExtension = await OnchainArtStorageExtension.deploy(
    nft,
    ""
  );

  await onchainArtStorageExtension.deployed();

  console.log(
    "OnchainArtStorageExtension deployed to:",
    onchainArtStorageExtension.address
  );

  // verify contract

  await hre.run("verify:verify", {
    address: onchainArtStorageExtension.address,
    constructorArguments: [nft, ""],
  });
};

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
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
