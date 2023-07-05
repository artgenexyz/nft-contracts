import * as ethers from "ethers";
import { formatEther } from "ethers/lib/utils";
import { Wallet, utils } from "zksync-web3";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

import { mnemonic } from "../hardhat.config";
import { ZkSyncArtifact } from "@matterlabs/hardhat-zksync-deploy/dist/types";
import {
  TransactionDetails,
  TransactionReceipt,
  TransactionRequest,
  TransactionResponse,
} from "zksync-web3/build/src/types";

const contractName = process.env.CONTRACT || "DemoCollection";
const args = process.env.ARGS ? JSON.parse(process.env.ARGS) : [];
const newOwner = process.env.NEW_OWNER;

export async function getDeployer(hre: HardhatRuntimeEnvironment) {
  const hdWallet = ethers.Wallet.fromMnemonic(mnemonic);
  const wallet = new Wallet(hdWallet.privateKey);

  console.log("Deployer address:", wallet.address);

  return new Deployer(hre, wallet);
}

export async function deployContract(
  deployer: Deployer,
  artifact: ZkSyncArtifact,
  args = []
) {
  const deploymentFee = await deployer.estimateDeployFee(artifact, args);

  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());

  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

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
    // const depositHandle = await deployer.zkWallet.deposit({
    //   to: deployer.zkWallet.address,
    //   token: utils.ETH_ADDRESS,
    //   amount: deploymentFee.mul(2),
    // });

    // Wait until the deposit is processed on zkSync
    // console.log(
    //   "Waiting for the deposit from Goerli to zkSync to be committed..."
    // );
    // await depositHandle.wait();

    // console.log("Deposit committed");
  }

  const contract = await deployer.deploy(artifact, args);

  const tx = contract.deployTransaction as TransactionRequest &
    TransactionResponse;

  console.log(
    `The contract was deployed.`,
    `\n\tThe tx hash is ${tx.hash}.`,
    `\n\tWaiting for confirmation...`
  );

  // output gas spent
  const receipt = await tx.wait();
  //   console.log(`\tThe contract address is ${contract.address}.`);
  //   console.log(`\tThe gas used is ${receipt.gasUsed.toString()}.`);
  /*
    tx {
        type: 113,
        nonce: 36,
        maxPriorityFeePerGas: BigNumber { _hex: '0x0ee6b280', _isBigNumber: true },
        maxFeePerGas: BigNumber { _hex: '0x0ee6b280', _isBigNumber: true },
        gasLimit: BigNumber { _hex: '0x02cd2967', _isBigNumber: true },
        to: '0x0000000000000000000000000000000000008006',
        value: BigNumber { _hex: '0x00', _isBigNumber: true },
        data: '0x9c4d535b0000000000000000000000000000000000000000000000000000000000000000010000ad2046848d5d8e3e645b539638f7bd783a54a0fae1d1b52e09679a292500000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000',
        chainId: BigNumber { _hex: '0x0118', _isBigNumber: true },
        from: '0xe5cc6F5bbB3Eee408A1C022D235e6903656f2509',
        customData: {
            gasPerPubdata: BigNumber { _hex: '0xc350', _isBigNumber: true },
            ...
        },
    }
    */

  // print a vertical table of gas use, including both fee per gas, gas limit, gas used and gas per pubdata, and then bottom line of the total tx cost in ETH

  //   console.log(
  //     `
  //         | gasPerPubdata | gasLimit | gasUsed | maxPriorityFeePerGas | maxFeePerGas | totalCost |
  //         | ------------- | -------- | ------- | -------------------- | ------------ | --------- |
  //         | ${tx.customData.gasPerPubdata.toString()} | ${tx.gasLimit.toString()} | ${receipt.gasUsed.toString()} | ${tx.maxPriorityFeePerGas.toString()} | ${tx.maxFeePerGas.toString()} | ${receipt.gasUsed
  //       .mul(tx.maxFeePerGas).div(1e18)
  //       .toString()} ETH |
  //         `
  //   );

  console.log(
    `| Key\t\t\t| Value\t\t\t|`,
    `\n| --------------------- | ----------------------------- |`,
    // `\n| txHash\t\t| ${tx.hash}\t|`,
    `\n| gasPerPubdata\t\t| ${tx.customData.gasPerPubdata.toString()}\t\t\t\t|`,
    `\n| gasLimit\t\t| ${tx.gasLimit.toString()}\t\t\t|`,
    `\n| gasUsed\t\t| ${receipt.gasUsed.toString()}\t\t\t|`,
    `\n| maxPriorityFeePerGas\t| ${tx.maxPriorityFeePerGas?.toString()}\t\t\t|`,
    `\n| maxFeePerGas\t\t| ${tx.maxFeePerGas?.toString()}\t\t\t|`,
    `\n| totalCost\t\t| ${formatEther(
      receipt.gasUsed.mul(tx.maxFeePerGas).div((1e18).toString())
    )} ETH\t\t|`,
    // refund
    // `\n| refund\t\t| ${formatEther(receipt.))} ETH\t|`,

    `\n| --------------------- | ----------------------------- |`,
    `\n| contractAddress\t| ${contract.address}\t|`,

    `\n| --------------------- | ----------------------------- |`
  );

  return contract;
}

export async function verifyContract(hre, artifact, contract, args = []) {
  console.log(
    "Deployed with constructor args:",
    contract.interface.encodeDeploy(args)
  );

  const contractAddress = contract.address;
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);

  const url = `https://goerli.explorer.zksync.io/address/${contractAddress}#code`;
  console.log(
    `See the contract code on zkScan: ${url}. Running the verification...`
  );

  const verificationId = await hre.run("verify:verify", {
    address: contractAddress,
    contract: `${artifact.sourceName}:${artifact.contractName}`,
    constructorArguments: args,
  });

  return verificationId;
}

export default async function (hre: HardhatRuntimeEnvironment) {
  console.log(`Running deploy script for the network ${hre.network.name}`);

  if (!hre.network.zksync) {
    console.error("zkSync network is not configured for this network");
    process.exit(1);
  }

  const deployer = await getDeployer(hre);
  const artifact = await deployer.loadArtifact(contractName);

  console.log("Deploying the contract with args:", args);

  try {
    const deployed = await deployContract(deployer, artifact, args);

    const verificationId = await verifyContract(hre, artifact, deployed, args);

    if (newOwner) {
      console.log(`Transferring ownership to ${newOwner}...`);
      // transfer ownership
      const tx = await deployed.transferOwnership(newOwner);
      await tx.wait();
      console.log(`Ownership transferred to ${newOwner}`);
    }

    console.log(
      "Check the verification status: \n\n\thh verify-status --verification-id",
      verificationId,
      "\n"
    );
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
}
