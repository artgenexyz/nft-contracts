import hre, { ethers } from "hardhat";
import fs from "fs";
import { parseEther } from "ethers/lib/utils";

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

export async function main() {
  const [ admin ] = await hre.ethers.getSigners();

  // load account from process.env.VANITY_PRIVATE_DEPLOYER
  const vanityKey = process.env.VANITY_PRIVATE_DEPLOYER;

  if (!vanityKey) {
    throw new Error("VANITY_PRIVATE_DEPLOYER is not set");
  }

  // // skip waiting if running on hardhat network
  // if (hre.network.name == "hardhat") {

  //   await hre.network.provider.request({
  //     method: "hardhat_reset"
  //   });

  // }

  const vanity = new hre.ethers.Wallet(vanityKey, hre.ethers.provider);

  // check nonce of vanity account and if > 0, exit
  const vanityNonce = await vanity.getTransactionCount();
  if (vanityNonce > 0) {
    console.log("Vanity account has nonce > 0, exiting");
    return;
  }

  // if balance of vanity account is 0, top it up
  const vanityBalance = await vanity.getBalance();

  console.log('vanity deployer address is', vanity.address);
  console.log('vanity deployer balance is', vanityBalance);

  if (vanityBalance.eq(0)) {
    console.log("Vanity account has balance 0");
    if (false && hre.network.name == "hardhat") {
      // use hardhat_setBalance
      await hre.network.provider.send("hardhat_setBalance", [
        vanity.address,
        parseEther("0.1").toHexString(),
      ]);
    } else {
      // use sendTransaction

      // // top up with Ethereum
      await admin.sendTransaction({
        to: vanity.address,
        value: hre.ethers.utils.parseEther("0.1"),
      });
    }
  }

  const ERC721CommunityImplementation = await hre.ethers.getContractFactory("ERC721CommunityImplementation");
  const implementation = await ERC721CommunityImplementation.connect(vanity).deploy();

  await implementation.deployed();

  console.log("ERC721CommunityImplementation implementation deployed to:", implementation.address);

  // write file to scripts/params.js

  const args: string[] = [];

  fs.writeFileSync(
    "./scripts/params.js",
    `module.exports = ${JSON.stringify(args)}`,
    "utf8"
  );
  
  // skip waiting if running on hardhat network
  if (hre.network.name == "hardhat") {
    return;
  }

  // print that we are waiting
  console.log("Waiting 3 seconds...");
  
  await delay(3000);

  // send verification request
  console.log("Verifying...", JSON.stringify(args));

  // verify contract
  await hre.run("verify", {
    contract: "contracts/ERC721CommunityImplementation.sol:ERC721CommunityImplementation",
    address: implementation.address,
    constructorArgs: "./scripts/params.js",
    network: "rinkeby",
  });

  const nft = ERC721CommunityImplementation.attach(implementation.address);

  // // Call the deployed contract.
  // const tx2 = await implementation.initialize(
  //   // "10000000000000000", // 0.01 ETH
  //   // 20,
  //   // 0, // royalty fee
  //   admin,
  //   0,
  //   // "proxy-test-buy/",
  //   false,
  // );

  // // Wait until the transaction is mined.
  // console.log(`Waiting for transaction to be mined...`, tx2.hash, `/tx/${tx2.hash}`);
  // const receipt2 = await tx2.wait();

  // console.log('receipt', receipt2.transactionHash);


}

// call main only if executed directly
if (process.argv[1] === __filename) {

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}

