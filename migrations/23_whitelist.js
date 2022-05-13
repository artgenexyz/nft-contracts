const PresaleListExtension = artifacts.require("PresaleListExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");

const admin = "0x31f40bc42cbae2d36aa11623d6d07d94c8339613";

module.exports = async function(deployer, network) {

  return;

  // const ethlandis = { address: "0xad700bae76965f01aa322068ab953082cfd3b9d6" };

  const root = "0x8a615c49449352c94d8bb01562934a4dcbc3ebb4e465f46b3f3f0978348c395d"

  await deployer.deploy(PresaleListExtension, "0x3A6704803fA770b6E765a262Ff476846AD7D0138", root, 8e16.toString(), 1);

  const wl = await PresaleListExtension.deployed();

  // print wl address
  console.log('Whitelist address: ', `https://etherscan.io/address/${wl.address}`)
  // console.log('Whitelist address: ', `https://rinkeby.etherscan.io/address/${wl1.address}`)
  // console.log('---- summary ----')
  // console.log('tx hashes', '\n', txs.map(tx => tx.tx).join("\n"));
  // console.log('tx receipts', '\n', txs.map(tx => tx.receipt.status).join("\n"));

  await wl.transferOwnership(admin)
  // await wl1.transferOwnership(admin)

  console.log('Verify: \n')
  console.log(`truffle run verify PresaleListExtension@${wl.address} --network ${network}`)
  console.log('\n')

};
