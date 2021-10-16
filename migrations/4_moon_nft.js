const MoonNFT = artifacts.require("MoonNFT");

const owner = "0x197727Ad2EC7326952843Fbd83A0d57B907afbdF";

module.exports = async function(deployer, network) {
  await deployer.deploy(MoonNFT);

  // not tested yet
  // const moon = await MoonNFT.new();
  const moon = await MoonNFT.deployed();

  if (network !== "development" && network !== "soliditycoverage") {
    const tx_ = await moon.setBeneficiary(owner);
    const tx = await moon.transferOwnership(owner);

    console.log(tx.logs[0].args);
  }

};
