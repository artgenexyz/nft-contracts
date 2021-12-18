const CypherPunkNFT = artifacts.require("CypherPunkNFT");
const WhitelistMerkleTreeExtension = artifacts.require("WhitelistMerkleTreeExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");

const admin = "0xffE06cb4807917bd79382981f23d16A70C102c3B";

module.exports = async function(deployer) {
  // await deployer.deploy(CypherPunkNFT);

  const punk = { address: "0xe7Fdaa4f319D4b1de23cD1b8eA0d6E8e69bf68c9" };

  // CypherPunk: WL6
  const wl6 = await WhitelistMerkleTreeExtension.at("0xc156e7f00f6a8a3a980fbfe5208f0bae37fba6d7");

  // CypherPunk: WL5
  const wl5 = await WhitelistMerkleTreeExtension.at("0x65581bfccbaad498dac703c7e4462a6e3f48644b");

  // CypherPunk: Public Sale
  const lim = await LimitAmountSaleExtension.at("0x2c96802b857ce97c5f41cb9ace0f517ee5d7fa5a");

  // CypherPunk: WL3
  const wl3 = await WhitelistMerkleTreeExtension.at("0x6dbd4dc0588bbfea07407f2d20b6c987f172ac6f");

  // CypherPunk: WL2
  const wl2 = await WhitelistMerkleTreeExtension.at("0xfbf41fec932b3645259d4da50ab8b19e463e99f3");

  // CypherPunk: WL1
  const wl1 = await WhitelistMerkleTreeExtension.at("0xb5eae116cd3f5013e67c283de5d66ba2f85f66b3");

  const txs = await Promise.all([
    wl1.stopSale({ gas: 100_000 }),
    wl2.stopSale({ gas: 100_000 }),
    wl3.stopSale({ gas: 100_000 }),
    lim.stopSale({ gas: 100_000 }),
    wl5.stopSale({ gas: 100_000 }),
    wl6.stopSale({ gas: 100_000 }),
  ]);


  console.log('tx', txs);

  console.log('---- summary ----')
  console.log('tx hashes', '\n', txs.map(tx => tx.tx).join("\n"));
  console.log('tx receipts', '\n', txs.map(tx => tx.receipt.status).join("\n"));


};
