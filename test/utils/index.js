const BigNumber = require("bignumber.js");
const { MerkleTree } = require('merkletreejs');
const { isAddress, toChecksumAddress } = require('web3-utils');
const keccak256 = require('keccak256');
const { ethers } = require("hardhat");

const getGasCost = tx => {
    return new BigNumber(tx.receipt.gasUsed).times(tx.receipt.effectiveGasPrice);
}


const processAddress = (address) => {
    address = toChecksumAddress(address)

    if (isAddress(address)) {
        return address
    }
    // TODO: parse ens domains

    return null
}

const getAirdropTree = (addresses) => {

    const leaves = addresses
        .map(x => processAddress(x))
        .filter(x => !!x)
        .map(x => keccak256(x))

    const tree = new MerkleTree(leaves, keccak256, { sort: true })

    const root = tree.getHexRoot()

    return {
        tree,
        root,
    }

}


const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const calculateCosts = async (tx) => {
  const receipt = await tx.wait();

  const cost = receipt.gasUsed.mul(tx.gasPrice || 0);

  // print table of: gas used, gas limit, gas price in gwei, cost in eth, projected cost at 30 gwei, cost in usd at eth = 1800
  console.log(`\t====================\t`);
  console.log(`\tGas used:\t${receipt.gasUsed.toString()}`);
  console.log(`\tGas limit:\t${tx.gasLimit.toString()}`);

  const gasPrice = tx.gasPrice;

  console.log(`\tGas price:\t${gasPrice.div(1e9).toString()} gwei`);

  const costInEth = ethers.utils.formatEther(cost);

  console.log(`\tCost in ETH:\t${costInEth} ETH`);

  const costInUsd = ethers.utils.formatEther(
    cost.mul(ethers.utils.parseEther("1800")).div("" + 1e18)
  );

  console.log(`\tCost in USD:\t${costInUsd} USD`);

  // calculate cost as if gas price is 30 gwei

  const costAt30Gwei = ethers.utils.formatEther(cost.mul(30e9).div(gasPrice));

  console.log(`\tCost at 30 gwei:\t${costAt30Gwei} ETH`);

  const costAt30GweiInUsd = ethers.utils.formatEther(
    cost
      .mul(30e9)
      .div(gasPrice)
      .mul(ethers.utils.parseEther("1800"))
      .div("" + 1e18)
  );

  console.log(`\tCost at 30 gwei:\t${costAt30GweiInUsd} USD`);

  console.log(`\t====================\t`);
};


// struct MintConfig {
//     uint256 publicPrice;
//     uint256 maxTokensPerMint;
//     uint256 maxTokensPerWallet;
//     uint256 royaltyFee;
//     address payoutReceiver;
//     bool shouldLockPayoutReceiver;
//     uint256 startTimestamp;
//     uint256 endTimestamp;
// }
const getMintConfig = () => ({
    publicPrice: new BigNumber(1e18).times(0.1).toString(),
    maxTokensPerMint: 10,
    maxTokensPerWallet: 0,

    royaltyFee: 500,
    payoutReceiver: "0x0000000000000000000000000000000000000000",
    shouldLockPayoutReceiver: false,

    startTimestamp: 0,
    endTimestamp: 0,
})

const createNFTSale = (ERC721CommunityBase) => {
    return ERC721CommunityBase.new(
        "NFT", "NFT",
        1000, 10,
        false,
        "ipfs://avatar-nft/",
        getMintConfig()
    )
}

async function mineBlock() {
    return rpc({ method: 'evm_mine' });
}

async function minerStart() {
    return rpc({ method: 'miner_start' });
}

async function minerStop() {
    return rpc({ method: 'miner_stop' });
}

async function rpc(request) {
    return new Promise((okay, fail) => web3.currentProvider.send(request, (err, res) => err ? fail(err) : okay(res)));
}


module.exports = { getGasCost, getMintConfig, calculateCosts, getAirdropTree, processAddress, createNFTSale, delay, mineBlock, rpc }
