import { SetMinDstGasEvent } from "./../../typechain-types/lib/solidity-examples/contracts/token/onft/ONFT721Core";
import hre, { ethers } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";

// const contract = process.env.CONTRACT_ADDRESS;
const remoteChainId = process.env.REMOTE_CHAIN_ID;
const remoteAddress = process.env.REMOTE_ADDRESS;
const localAddress = process.env.LOCAL_ADDRESS;

export default async function main(hre: HardhatRuntimeEnvironment) {
  const [admin] = await hre.ethers.getSigners();

  if (!remoteAddress || !localAddress) {
    console.error("REMOTE_ADDRESS and LOCAL_ADDRESS must be set");
    process.exit(1);
  }

  console.log("Sending NFT between chains", remoteAddress, localAddress);

  // uint16 remoteChainId = 10121;

  // // _path = abi.encodePacked(remoteAddress, localAddress)
  // bytes memory path = abi.encodePacked(remoteAddress, localAddress);

  // artgenes.setTrustedRemote(remoteChainId, path);

  const artgenes = await hre.ethers.getContractAt("LzApp", localAddress);

  const packetType = 1;

  const tx = await artgenes.setMinDstGas(remoteChainId, packetType, 200_000);

  console.log("Waiting for tx to be mined", tx.hash, {
    url: "https://goerli.etherscan.io/tx/" + tx.hash + "#eventlog",
  });

  await tx.wait();

  console.log("Done");
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
