import hre, { ethers } from "hardhat";
import fs from "fs";
import { getContractAddress, parseEther } from "ethers/lib/utils";
import { Address } from "hardhat-deploy/dist/types";
import { Signer } from "ethers";

const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const GAS_PRICE_GWEI = "35";

export const PLATFORM_ADDRESS = "0xAaaeEee77ED0D0ffCc2813333b796E367f1E12d9";
export const PLATFORM_DEPLOYER_ADDRESS =
  "0xE4A02093339a9a908cF9d897481813Ddb5494d44";

export const sendAllFunds = async (account: Signer, to: Address) => {
  const balance = await account.getBalance();

  const gasPrice = hre.ethers.utils.parseUnits(GAS_PRICE_GWEI, "gwei");
  const gasCost = gasPrice.mul(21000);

  console.log(" ==> balance ==>", balance.sub(gasCost).toString());

  return await account.sendTransaction({
    to: to,
    value: balance.sub(gasCost),
    gasLimit: 21_000,
    gasPrice: gasPrice,
  });
};

export const getVanityDeployer = async () => {
  // if (hre.network.name === "hardhat") {
  //   // impersonate the vanity deployer
  //   await hre.network.provider.request({
  //     method: "hardhat_impersonateAccount",
  //     params: [PLATFORM_DEPLOYER_ADDRESS],
  //   });

  //   return await hre.ethers.getSigner(PLATFORM_DEPLOYER_ADDRESS);
  // }

  // load account from process.env.PLATFORM_PRIVATE_DEPLOYER
  const vanityKey = process.env.PLATFORM_PRIVATE_DEPLOYER;

  if (!vanityKey) {
    throw new Error("PLATFORM_PRIVATE_DEPLOYER is not set");
  }

  return new hre.ethers.Wallet(vanityKey, hre.ethers.provider);
};

export const computeVanityAddress = async () => {
  const vanityDeployer = await getVanityDeployer();

  console.log("vanity deployer address is", vanityDeployer.address);

  const transactionCount = await vanityDeployer.getTransactionCount();

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

  const Artgene721Implementation = await hre.ethers.getContractFactory(
    "Artgene721Implementation"
  );

  if (
    Artgene721Implementation.bytecode.includes(
      PLATFORM_ADDRESS.toLowerCase().slice(7)
    )
  ) {
    console.log(
      "\nBytecode includes platform vanity address",
      PLATFORM_ADDRESS
    );
  } else {
    console.log(
      "Bytecode does not include platform vanity address",
      Artgene721Implementation.bytecode,
      PLATFORM_ADDRESS
    );

    // IGNORE THIS ERROR BECAUSE NOT USING VANITY ANYMORE
    // throw new Error("Artgene721 bytecode does not include vanity address");
  }

  const futureAddress = await computeVanityAddress();
  console.log("Future address:", futureAddress);
  console.log("Vanity address:", PLATFORM_ADDRESS);

  if (futureAddress === PLATFORM_ADDRESS) {
    console.log(
      "Address matches vanity address",
      futureAddress,
      PLATFORM_ADDRESS
    );
  } else {
    console.log(
      "Address does not match vanity address",
      futureAddress,
      PLATFORM_ADDRESS
    );

    throw new Error(
      `Address does not match vanity address: ${futureAddress} != ${PLATFORM_ADDRESS}`
    );
  }

  console.log("\n\nDeploying ArtgenePlatform implementation...");

  const vanity = await getVanityDeployer();

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
        value: hre.ethers.utils.parseEther("0.05"),
      });
    }
  }

  const ArtgenePlatform = await hre.ethers.getContractFactory(
    "ArtgenePlatform"
  );

  // const platform = await ArtgenePlatform.attach(PLATFORM_ADDRESS);

  const platform = await ArtgenePlatform.connect(vanity).deploy({
    maxFeePerGas: ethers.utils.parseUnits(GAS_PRICE_GWEI, "gwei"),
    maxPriorityFeePerGas: ethers.utils.parseUnits("2", "gwei"),
    nonce: vanityNonce,
    ...((hre.network.name == "mainnet" || hre.network.name == "goerli") && {
      gasLimit: 1_000_000,
    }),
  });

  await platform.deployed();

  console.log("ArtgenePlatform implementation deployed to:", platform.address);

  // output gas spent, gas price and gas limit
  const receipt = await platform.deployTransaction.wait();
  console.log("Gas used:", receipt.gasUsed.toString());
  console.log("Gas price:", GAS_PRICE_GWEI);
  console.log(
    "Gas cost (gwei)",
    receipt.gasUsed.mul(ethers.BigNumber.from(GAS_PRICE_GWEI)).toString()
  );

  console.log(
    "Transferring ownership to",
    process.env.TRANSFER_TO ?? admin.address
  );

  await platform.connect(vanity).transferOwnership(
    // admin.address,
    process.env.TRANSFER_TO ?? admin.address,
    {
      maxFeePerGas: ethers.utils.parseUnits(GAS_PRICE_GWEI, "gwei"),
      maxPriorityFeePerGas: ethers.utils.parseUnits("2", "gwei"),
      gasLimit: 1_000_000,
    }
  );

  console.log("Transferred successfully");

  console.log("Sending all funds to", admin.address);

  // send all funds to admin
  await sendAllFunds(vanity, admin.address);

  console.log("Sent successfully");

  // write file to scripts/params.js

  const args: string[] = [];

  fs.writeFileSync(
    "./scripts/params.js",
    `module.exports = ${JSON.stringify(args)}`,
    "utf8"
  );

  // skip waiting if running on hardhat network
  if (hre.network.name == "hardhat") {
    return platform.address;
  }

  // print that we are waiting
  console.log("Waiting 3 seconds...");

  await delay(3000);

  // send verification request
  console.log("Verifying...", JSON.stringify(args));

  // verify contract
  await hre.run("verify", {
    contract: "contracts/ArtgenePlatform.sol:ArtgenePlatform",
    address: platform.address,
    constructorArgs: "./scripts/params.js",
    network: "mainnet",
  });

  return platform.address;
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
