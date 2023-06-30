import { HardhatRuntimeEnvironment } from "hardhat/types";
import { deployContract, getDeployer, verifyContract } from "../deploy";

const contractName = process.env.CONTRACT || "DemoCollection";
const args = process.env.ARGS ? JSON.parse(process.env.ARGS) : [];

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
