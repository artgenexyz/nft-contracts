import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const contractName = process.env.CONTRACT || "DemoCollection";
const args = process.env.ARGS ? JSON.parse(process.env.ARGS) : [];

export const func: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  // const [admin] = await hre.ethers.getSigners();

  //   const { getNamedAccounts, deployments, network } = hre;
  //   const { deploy } = deployments;

  //   // Get some important accounts
  //   const { deployer } = await getNamedAccounts();

  //   const artifact = await deployments.getArtifact(contractName);

  try {
    const factory = await hre.ethers.getContractFactory(contractName);
    const contract = await factory.deploy(...args, { gasLimit: 5_000_000 });

    console.log(`Deployed ${contractName} to: ${contract.address}`);

    await contract.deployed();

    await hre.run("verify:verify", {
      address: contract.address,
      contract: `${contractName}`,
      constructorArguments: args,
    });

    // const verificationId = await verifyContract(hre, artifact, deployed, args);

    // console.log(
    //   "Check the verification status: \n\n\thh verify-status --verification-id",
    //   verificationId,
    //   "\n"
    // );
  } catch (err) {
    console.error(
      // err?.error?.error ??
      //   err?.error?.message ??
      //   err?.error ??
      //   err?.message ??
      err
    );

    console.log("Failed to deploy the contract.");

    process.exit(1);
  }
  // code here
};

export default func;
