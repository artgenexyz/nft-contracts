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


module.exports = { getGasCost, getMintConfig, getAirdropTree, processAddress, createNFTSale, mineBlock, rpc }
