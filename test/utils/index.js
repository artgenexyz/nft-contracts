const BigNumber = require("bignumber.js");
const { MerkleTree } = require('merkletreejs');
const { isAddress, toChecksumAddress } = require('web3-utils');
const keccak256 = require('keccak256');
const ether = require("@openzeppelin/test-helpers/src/ether");

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

const createNFTSale = (MetaverseBaseNFT) => {
    return MetaverseBaseNFT.new(ether("0.1"), 1000, 10, 10, 0, "ipfs://avatar-nft/", "NFT", "NFT", false)
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


module.exports = { getGasCost, getAirdropTree, processAddress, createNFTSale, mineBlock, rpc }
