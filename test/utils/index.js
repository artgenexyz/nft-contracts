const BigNumber = require("bignumber.js");
const { MerkleTree } = require('merkletreejs');
const { isAddress, toChecksumAddress } = require('web3-utils');
const keccak256 = require('keccak256');

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



module.exports = { getGasCost, getAirdropTree, processAddress }
