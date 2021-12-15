const CypherPunkNFT = artifacts.require("CypherPunkNFT");
const WhitelistMerkleTreeExtension = artifacts.require("WhitelistMerkleTreeExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");

const admin = "0xffE06cb4807917bd79382981f23d16A70C102c3B";

module.exports = async function(deployer) {
  await deployer.deploy(CypherPunkNFT);

  const punk = await CypherPunkNFT.deployed();

  await deployer.deploy(
    WhitelistMerkleTreeExtension,
    punk.address,
    "0x7af37785565a963182c7a305241e758f2d90fff2fd43be1493faad89e2fc54f0", // 1000 address
    1e17.toString(),
    1
  );

  const ext = await WhitelistMerkleTreeExtension.deployed();

  await punk.addExtension(ext.address);

  await deployer.deploy(
    WhitelistMerkleTreeExtension,
    punk.address,
    "0x67fce051b45b62d635c2a9279cb0eb31b640ad276c31c8736764c4fd52802d7a", // 1000 address
    1.5e17.toString(),
    1
  );

  const ext2 = await WhitelistMerkleTreeExtension.deployed();

  await punk.addExtension(ext2.address);

  await deployer.deploy(
    WhitelistMerkleTreeExtension,
    punk.address,
    "0x209b31601ef86c6209f3df8667cee856d11e4f2943d853f7290cd2b81b2863b8", // 293 address
    2e17.toString(),
    1
  );

  const ext3 = await WhitelistMerkleTreeExtension.deployed();

  await punk.addExtension(ext3.address);

  await deployer.deploy(
    LimitAmountSaleExtension,
    punk.address,
    2e17.toString(),
    3,
    500,
  );

  const ext5 = await LimitAmountSaleExtension.deployed();

  await punk.addExtension(ext5.address);

  // await punk.setBeneficiary(admin);
  // await punk.transferOwnership(admin);
  // await ext.transferOwnership(admin);
  // await ext2.transferOwnership(admin);
  // await ext3.transferOwnership(admin);
  // await ext5.transferOwnership(admin);

};
