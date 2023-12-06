import { task } from "hardhat/config";
import { sendAllFunds, getVanityDeployer } from "../scripts/helpers";

task(
  "send-all-funds",
  "Sends all funds to an address",
  async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    const vanity = await getVanityDeployer(hre);

    await sendAllFunds(hre, vanity, accounts[0].address);

    console.log("Done sending all funds");
  }
);
