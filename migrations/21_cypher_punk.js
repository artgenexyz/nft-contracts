const CypherPunkNFT = artifacts.require("CypherPunkNFT");
const PresaleListExtension = artifacts.require("PresaleListExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");

const admin = "0xffE06cb4807917bd79382981f23d16A70C102c3B";

module.exports = async function(deployer) {

  return;

  await deployer.deploy(CypherPunkNFT);
  const punk = { address: "0xe7Fdaa4f319D4b1de23cD1b8eA0d6E8e69bf68c9" };

  await deployer.deploy(
    PresaleListExtension,
    punk.address,
    "0xdd16d918cb59839944264126651650e974d4897d33fe3fd17339175f21446920", // 34 address
    "0",
    1,
  );

  const ext = await PresaleListExtension.deployed();

  // await punk.addExtension(ext.address);
  console.log('extension added', ext.address);

  await deployer.deploy(
    PresaleListExtension,
    punk.address,
    "0x07189d4484edbcf8d1d282c6ba36997b5ae9a7c1bce7bc9f35a546bec422503f", // 3 address
    "0",
    5,
  );

  const ext2 = await PresaleListExtension.deployed();

  // await punk.addExtension(ext2.address);
  console.log('extension added', ext2.address);

  // await deployer.deploy(
  //   PresaleListExtension,
  //   punk.address,
  //   "0x209b31601ef86c6209f3df8667cee856d11e4f2943d853f7290cd2b81b2863b8", // 293 address
  //   2e17.toString(),
  //   1
  // );

  // const ext3 = await PresaleListExtension.deployed();

  // await punk.addExtension(ext3.address);

  // await deployer.deploy(
  //   LimitAmountSaleExtension,
  //   punk.address,
  //   2e17.toString(),
  //   3,
  //   500,
  // );

  // const ext5 = await LimitAmountSaleExtension.deployed();

  // await punk.addExtension(ext5.address);

  // await punk.setBeneficiary(admin);
  // await punk.transferOwnership(admin);
  // await ext.transferOwnership(admin);
  // await ext2.transferOwnership(admin);
  // await ext3.transferOwnership(admin);
  // await ext5.transferOwnership(admin);

};
