import hre, { ethers } from "hardhat";
import fs from "fs";
import { getContractAddress, parseEther } from "ethers/lib/utils";
import { Address } from "hardhat-deploy/dist/types";
import { Signer } from "ethers";


const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

export const IMPLEMENTATION_ADDRESS = "0xf3E07A5cBDFE6a257A7caa4Fcb3187A1C2Ec6a2E";
export const IMPLEMENTATION_DEPLOYER_ADDRESS = "0x9c867BF9F724F29E1B1bf66EB71A35493FC8FCE1";

export const sendAllFunds = async (account: Signer, to: Address) => {
  const balance = await account.getBalance();

  const gasPrice = hre.ethers.utils.parseUnits("10", "gwei");
  const gasCost = gasPrice.mul(21000);

  return await account.sendTransaction({
    to: to,
    value: balance.sub(gasCost),
    gasLimit: 21_000,
    gasPrice: gasPrice,
  });
}

export const getVanityDeployer = async () => {

  if (hre.network.name === "hardhat") {
    // impersonate the vanity deployer
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [IMPLEMENTATION_DEPLOYER_ADDRESS],
    });

    return await hre.ethers.getSigner(IMPLEMENTATION_DEPLOYER_ADDRESS);
  }

  // load account from process.env.IMPLEMENTATION_PRIVATE_DEPLOYER
  const vanityKey = process.env.IMPLEMENTATION_PRIVATE_DEPLOYER;

  if (!vanityKey) {
    throw new Error("IMPLEMENTATION_PRIVATE_DEPLOYER is not set");
  }

  return new hre.ethers.Wallet(vanityKey, hre.ethers.provider);

}

export const computeVanityAddress = async () => {
  const vanityDeployer = await getVanityDeployer();

  const transactionCount = await vanityDeployer.getTransactionCount();

  const vanityAddress = getContractAddress({
    from: vanityDeployer.address,
    nonce: transactionCount
  });

  return vanityAddress;
}

export async function main() {
  const [admin] = await hre.ethers.getSigners();

  // // skip waiting if running on hardhat network
  // if (hre.network.name == "hardhat") {

  //   await hre.network.provider.request({
  //     method: "hardhat_reset"
  //   });

  // }


  const Artgene721 = await hre.ethers.getContractFactory("Artgene721");

  if (Artgene721.bytecode.includes(IMPLEMENTATION_ADDRESS.toLowerCase().slice(2))) {
    
    console.log("Bytecode includes vanity address", IMPLEMENTATION_ADDRESS);

  } else {
    console.log("Bytecode does not include vanity address", Artgene721.bytecode, IMPLEMENTATION_ADDRESS);

    // IGNORE THIS ERROR BECAUSE NOT USING VANITY ANYMORE
    // throw new Error("Artgene721 bytecode does not include vanity address");
  }

  const futureAddress = await computeVanityAddress();
  console.log("Future address:", futureAddress);
  console.log("Vanity address:", IMPLEMENTATION_ADDRESS);

  if (futureAddress === IMPLEMENTATION_ADDRESS) {
    console.log("Address matches vanity address", futureAddress, IMPLEMENTATION_ADDRESS);
  } else {
    console.log("Address does not match vanity address", futureAddress, IMPLEMENTATION_ADDRESS);

    throw new Error(`Address does not match vanity address: ${futureAddress} != ${IMPLEMENTATION_ADDRESS}`);
  }

  const vanity = await getVanityDeployer();

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
        value: hre.ethers.utils.parseEther("0.4"),
      });
    }
  }

  const Artgene721Implementation = await hre.ethers.getContractFactory("Artgene721Implementation");

  // deploy with gas = 15 gwei
  const implementation = await Artgene721Implementation.connect(vanity).deploy({
    gasPrice: ethers.utils.parseUnits("15", "gwei"),
    nonce: vanityNonce,
    ...(hre.network.name == "mainnet" && {
      gasLimit: 6_000_000,
    })
  });

  await implementation.deployed();

  console.log("Artgene721Implementation implementation deployed to:", implementation.address);

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
    contract: "contracts/Artgene721Implementation.sol:Artgene721Implementation",
    address: implementation.address,
    constructorArgs: "./scripts/params.js",
    network: "rinkeby",
  });

  const nft = Artgene721Implementation.attach(implementation.address);

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

