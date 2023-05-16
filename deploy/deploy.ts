import * as ethers from "ethers";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

import { mnemonic } from "./../hardhat.config";

const hdWallet = ethers.Wallet.fromMnemonic(mnemonic);

const CONTRACT_NAME = "ArtgenePlatform";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the network ${hre.network.name}`);

  // derive wallet key from mnemonic

  // Initialize the wallet.
  const wallet = new Wallet(hdWallet.privateKey);

  console.log("Deployer address:", wallet.address);

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact(CONTRACT_NAME);

  // Estimate contract deployment fee
  let deploymentFee;

  try {
    deploymentFee = await deployer.estimateDeployFee(artifact, []);

    const parsedFee = ethers.utils.formatEther(deploymentFee.toString());

    console.log(`The deployment is estimated to cost ${parsedFee} ETH`);
  } catch (err) {
    console.error(
      err?.error?.error ??
        err?.error?.message ??
        err?.error ??
        err?.message ??
        err
    );

    console.log(
      "Failed to estimate the deployment fee. Please make sure you have enough funds on L2."
    );

    process.exit(1);
  }

  // TODO: this doesnt work
  const balance = await deployer.zkWallet.getBalance();

  if (deploymentFee.gt(balance)) {
    console.log(
      "Not enough funds to deploy the contract",
      "Have: ",
      ethers.utils.formatEther(balance.toString()),
      "Need: ",
      ethers.utils.formatEther(deploymentFee.toString()),
      "\nAdding funds to the wallet from L1"
    );

    // OPTIONAL: Deposit funds to L2
    //   Comment this block if you already have funds on zkSync.
    const depositHandle = await deployer.zkWallet.deposit({
      to: deployer.zkWallet.address,
      token: utils.ETH_ADDRESS,
      amount: deploymentFee.mul(2),
    });

    // Wait until the deposit is processed on zkSync
    // console.log(
    //   "Waiting for the deposit from Goerli to zkSync to be committed..."
    // );
    // await depositHandle.wait();

    console.log("Deposit committed");
  }

  let greeterContract;

  try {
    greeterContract = await deployer.deploy(artifact, []);
  } catch (err) {
    console.error(
      err?.error?.error ??
        err?.error?.message ??
        err?.error ??
        err?.message ??
        err
    );
    console.log(
      "Failed to deploy the contract. Please make sure you have enough funds on L2."
    );

    process.exit(1);
  }

  //obtain the Constructor Arguments
  console.log(
    "Deployed with constructor args:",
    greeterContract.interface.encodeDeploy([])
  );

  // Show the contract info.
  const contractAddress = greeterContract.address;
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);

  const url = `https://goerli.explorer.zksync.io/address/${contractAddress}#code`;
  console.log(
    `See the contract code on zkScan: ${url}. Running the verification...`
  );

  const verificationId = await hre.run("verify:verify", {
    address: contractAddress,
    contract: `${artifact.sourceName}:${artifact.contractName}`,
    constructorArguments: [],
  });

  // run yarn hardhat verify-status --verification-id <your verification id>

  //   console.log("Verification ID:", verificationId);

  console.log(
    "Check the verification status: \n\n\thh verify-status --verification-id",
    verificationId,
    "\n"
  );
}
