import { Address } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Signer } from "ethers";

export const GAS_PRICE_GWEI = "25";

export const sendAllFunds = async (
  hre: HardhatRuntimeEnvironment,
  account: Signer,
  to: Address
) => {
  const balance = await account.getBalance();

  const gasPrice = hre.ethers.utils.parseUnits(GAS_PRICE_GWEI, "gwei");
  const gasCost = gasPrice.mul(21000);

  console.log(" ==> balance ==>", balance.sub(gasCost).toString());

  return await account.sendTransaction({
    to: to,
    value: balance.sub(gasCost),
    gasLimit: 21000,
    gasPrice: gasPrice,
  });
};

export const getVanityDeployer = async (hre: HardhatRuntimeEnvironment) => {
  // if (hre.network.name === "hardhat") {
  //   // impersonate the vanity deployer
  //   await hre.network.provider.request({
  //     method: "hardhat_impersonateAccount",
  //     params: [IMPLEMENTATION_DEPLOYER_ADDRESS],
  //   });
  //   return await hre.ethers.getSigner(IMPLEMENTATION_DEPLOYER_ADDRESS);
  // }

  // load account from process.env.IMPLEMENTATION_PRIVATE_DEPLOYER
  const vanityKey = process.env.IMPLEMENTATION_PRIVATE_DEPLOYER;

  if (!vanityKey) {
    throw new Error("IMPLEMENTATION_PRIVATE_DEPLOYER is not set");
  }

  return new hre.ethers.Wallet(vanityKey, hre.ethers.provider);
};
