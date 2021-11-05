const NFTFactory = artifacts.require("NFTFactory");

module.exports = async function (deployer, network, accounts) {
  return;

  // from https://gist.github.com/caffeinum/2ee879df8e828e04126fc0f72ae12b9e

  const [owner] = accounts;
  const lastNonce = await web3.eth.getTransactionCount(owner);
  // this DOESN'T include pending transactions, so lastNonce + 1 always replaces pending

  console.log("Account \t", owner);
  console.log("Last nonce \t", lastNonce);
  console.log("Using nonce \t", lastNonce + 1);

  const tx = NFTFactory.new({ nonce: lastNonce + 1, gasPrice: 22e9 });

  tx.on("transactionHash", (hash) =>
    console.log("Transaction \t", `https://etherscan.io/tx/${hash}`)
  );
  tx.on("receipt", (receipt) => console.log("Receipt \t", receipt));
  tx.on("receipt", (receipt) =>
    console.log(
      "Gas usage \t",
      receipt.gasUsed,
      "used",
      receipt.gasPrice,
      "wei"
    )
  );

  const factory = await tx;

  console.log("factory", factory.address);
};
