const BigNumber = require("bignumber.js");

const getGasCost = tx => {
    return new BigNumber(tx.receipt.gasUsed).times(tx.receipt.effectiveGasPrice);
}

module.exports = { getGasCost }
