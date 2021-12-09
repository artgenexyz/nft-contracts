const BigNumber = require("bignumber.js");

const getGasCost = async tx => {
    return new BigNumber(tx.receipt.gasUsed).times(tx.receipt.effectiveGasPrice);
}

module.exports = { getGasCost }
