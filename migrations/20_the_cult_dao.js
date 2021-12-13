const TheCultDAO = artifacts.require("TheCultDAO");

const yan = "0xe493d64DC68EDae2A14fa67c6fC34E2A1566313B";

module.exports = async function(deployer) {
  await deployer.deploy(TheCultDAO);

  const dao = await TheCultDAO.deployed();

  await dao.setBeneficiary(yan);
  // await dao.transferOwnership(yan);

};
