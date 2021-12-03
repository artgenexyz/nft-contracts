const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const BigNumber = require("bignumber.js");

const getGasCost = async tx => {
    // TODO: is there way to take real gas price?
    return new BigNumber(tx.receipt.gasUsed).times(await web3.eth.getGasPrice());
}

module.exports = { getGasCost }
