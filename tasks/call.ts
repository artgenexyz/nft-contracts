import { formatEther, parseEther } from "ethers/lib/utils";
import { Event, Transaction } from "ethers";
import { task, types } from "hardhat/config";

// arguments: contract address, contract name, method, args
task("call", "Calls a contract")
  /* TODO: make it optional, fetch from the deployed address? */
  .addPositionalParam("contractName", "The contract name")
  .addPositionalParam("contractAddress", "The contract address")
  .addPositionalParam("method", "The method to call")
  .addParam("args", "The method arguments", [], types.json)
  .addParam("value", "Value sent with message", "0", types.string)
  .addFlag("dryRun", "Don't send the transaction")
  .setAction(async (taskArgs, hre) => {
    const { ethers } = hre;

    const [admin] = await ethers.getSigners();

    const contract = await ethers.getContractAt(
      taskArgs.contractName,
      taskArgs.contractAddress,
      admin
    );

    if (!contract.interface.getFunction(taskArgs.method)) {
      throw new Error(
        `Method ${taskArgs.method} not found on contract ${taskArgs.contractName}`
      );
    }

    // if not view method, send tx

    if (
      contract.interface.getFunction(taskArgs.method).stateMutability === "view"
    ) {
      const result = await (contract.callStatic as any)[
        taskArgs.method as string
      ](...taskArgs.args);

      console.log("Result:", result);

      return;
    }

    const tx = await(contract as any)[taskArgs.method as string](
      ...taskArgs.args,
      { value: parseEther(taskArgs.value) }
    );

    // const tx = result;

    console.log("Tx sent:", tx.hash);

    // await tx.wait();

    // console.log("Tx mined");

    const receipt = await tx.wait();

    // gas spent, eth spent, gas price, value sent, gas limit

    console.log("Gas price:", tx.gasPrice, "wei");
    console.log("Gas used:", receipt.gasUsed.toString());

    const txCost = receipt.gasUsed.mul(tx.gasPrice);

    console.log("Tx cost:", formatEther(txCost), "ETH");

    // // events emitted
    // const events = receipt.events.map((e: Event) => e);

    // console.log("Events emitted:", events);
  });
