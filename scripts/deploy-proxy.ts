import hre, { ethers } from "hardhat";
import fs from "fs";
import { getContractAddress, parseEther } from "ethers/lib/utils";
import { getVanityDeployer, sendAllFunds } from "./helpers";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const GAS_PRICE_GWEI = "35";

export const IMPLEMENTATION_ADDRESS =
  "0x00000721bEb748401E0390Bb1c635131cDe1Fae8";
export const IMPLEMENTATION_DEPLOYER_ADDRESS =
  "0x156deFdb1c699B48506FfBC97d37612189de788D";

export const computeVanityAddress = async (hre: HardhatRuntimeEnvironment) => {
  const vanityDeployer = await getVanityDeployer(hre);

  console.log("vanity deployer address is", vanityDeployer.address);

  const transactionCount = await vanityDeployer.getTransactionCount();

  console.log("transaction count is", transactionCount);

  const vanityAddress = getContractAddress({
    from: vanityDeployer.address,
    nonce: transactionCount,
  });

  return vanityAddress;
};

export async function main() {
  const [admin] = await hre.ethers.getSigners();

  // // skip waiting if running on hardhat network
  // if (hre.network.name == "hardhat") {

  //   await hre.network.provider.request({
  //     method: "hardhat_reset"
  //   });

  // }

  const Artgene721 = await hre.ethers.getContractFactory("Artgene721");

  if (
    Artgene721.bytecode.includes(IMPLEMENTATION_ADDRESS.toLowerCase().slice(7))
  ) {
    console.log("Bytecode includes vanity address", IMPLEMENTATION_ADDRESS);
  } else {
    console.log(
      "Bytecode does not include vanity address",
      Artgene721.bytecode,
      IMPLEMENTATION_ADDRESS
    );

    // IGNORE THIS ERROR BECAUSE NOT USING VANITY ANYMORE
    // throw new Error("Artgene721 bytecode does not include vanity address");
  }

  const futureAddress = await computeVanityAddress(hre);
  console.log("Future address:", futureAddress);
  console.log("Vanity address:", IMPLEMENTATION_ADDRESS);

  if (futureAddress === IMPLEMENTATION_ADDRESS) {
    console.log(
      "Address matches vanity address",
      futureAddress,
      IMPLEMENTATION_ADDRESS
    );
  } else {
    console.log(
      "Address does not match vanity address",
      futureAddress,
      IMPLEMENTATION_ADDRESS
    );

    throw new Error(
      `Address does not match vanity address: ${futureAddress} != ${IMPLEMENTATION_ADDRESS}`
    );
  }

  const vanity = await getVanityDeployer(hre);

  // check nonce of vanity account and if > 0, exit
  const vanityNonce = await vanity.getTransactionCount();
  if (vanityNonce > 0) {
    console.log("Vanity account has nonce > 0, exiting");
    return;
  }

  // if balance of vanity account is 0, top it up
  const vanityBalance = await vanity.getBalance();

  console.log("vanity deployer address is", vanity.address);
  console.log("vanity deployer balance is", vanityBalance);

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
        value: hre.ethers.utils.parseEther("0.5"),
      });
    }
  }

  const Artgene721Implementation = await hre.ethers.getContractFactory(
    "Artgene721Implementation"
  );

  // deploy with gas = 15 gwei
  const implementation = await Artgene721Implementation.connect(vanity).deploy({
    maxFeePerGas: ethers.utils.parseUnits(GAS_PRICE_GWEI, "gwei"),
    maxPriorityFeePerGas: ethers.utils.parseUnits("1", "gwei"),
    nonce: vanityNonce,
    // ...((hre.network.name == "mainnet" || hre.network.name == "goerli") && {
    //   gasLimit: 8_000_000,
    // }),
  });

  const tx = await implementation.deployed();

  // print gas used

  const receipt = await tx.deployTransaction.wait();
  console.log("Gas used:", receipt.gasUsed.toString());

  console.log(
    "Artgene721Implementation implementation deployed to:",
    implementation.address
  );

  // DO THIS MANUALLY INSTEAD
  // send all funds to admin
  // await sendAllFunds(hre, vanity, admin.address);

  // write file to scripts/params.js

  const args: string[] = [];

  fs.writeFileSync(
    "./scripts/params.js",
    `module.exports = ${JSON.stringify(args)}`,
    "utf8"
  );

  // skip waiting if running on hardhat network
  if (hre.network.name == "hardhat") {
    console.log("Skipping verification on hardhat network");
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
