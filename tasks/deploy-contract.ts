import { task, types } from "hardhat/config";
import { join } from "path";
import { writeFile } from "fs/promises";

import { formatEther } from "ethers/lib/utils";

// arguments: contract name, contract args
task("deploy-contract", "Deploys a contract")
  .addPositionalParam("contractName", "The contract name")
  .addOptionalParam("args", "The contract arguments", "[]", types.json)
  .addOptionalParam("gasPrice", "The gas price in gwei", "", types.string)
  .addOptionalParam("gasLimit", "The gas limit", "", types.string)
  .addOptionalParam("overrideNonce", "Override the nonce", "", types.string)
  .setAction(
    async ({ contractName, args, gasPrice, gasLimit, overrideNonce }, hre) => {
      console.log(
        `Running deploy script for the network ${hre.network.name}`,
        "with args:",
        args
      );

      try {
        const factory = await hre.ethers.getContractFactory(contractName);
        const artifact = await hre.artifacts.readArtifact(contractName);

        const contract = await (factory as any).deploy(...args, {
          maxFeePerGas: gasPrice
            ? hre.ethers.utils.parseUnits(gasPrice, "gwei")
            : undefined,
          maxPriorityFeePerGas: hre.ethers.utils.parseUnits("2", "gwei"),
          gasLimit: gasLimit ? parseInt(gasLimit) : undefined,
          nonce: overrideNonce ? parseInt(overrideNonce) : undefined,
        });

        console.log(`Deployed ${contractName} to: ${contract.address}`);

        // save args to a file
        const argsFile = join(
          hre.config.paths.artifacts,
          "..",
          "args-" + contractName + "@" + contract.address + ".json"
        );

        await writeFile(argsFile, JSON.stringify(args, null, 2));

        console.log("Args saved to:", argsFile);

        const contractFullName = `${artifact.sourceName}:${artifact.contractName}`;

        console.log(`
        Verify using:

            hh verify ${contract.address} --constructor-args ${argsFile} --network ${hre.network.name} --contract ${contractFullName}
      `);

        await contract.deployed();

        const tx = contract.deployTransaction;

        const receipt = await tx.wait();

        const txCost = receipt.gasUsed.mul((tx as any).maxFeePerGas);

        console.log(
          `\n| --------------------- | ----------------------------- |`,
          `\n| gasUsed \t\t| ${receipt.gasUsed.toString()}\t\t\t|`,
          `\n| gasPrice\t\t| ${tx.gasPrice?.toString()} gwei\t\t|`,
          `\n| totalCost\t\t| ${formatEther(txCost)} ETH\t|`,

          `\n| --------------------- | ----------------------------- |`,
          `\n| contractAddress\t| ${contract.address}\t|`,
          `\n| --------------------- | ----------------------------- |`
        );

        const verificationId = await hre.run("verify:verify", {
          address: contract.address,
          contract: `${artifact.sourceName}:${artifact.contractName}`,
          constructorArguments: args,
        });

        console.log(
          "Check the verification status: \n\n\thh verify-status --verification-id",
          verificationId,
          "\n"
        );
      } catch (err: any) {
        console.error(
          err?.error?.error ??
            err?.error?.message ??
            err?.error ??
            err?.message ??
            err
        );

        console.log("Failed to deploy the contract.");

        process.exit(1);
      }
    }
  );
