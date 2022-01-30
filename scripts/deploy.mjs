const contract = require("@truffle/contract");
const argv = require('minimist')(process.argv.slice(2));

/**
 * Uploads a compiled contract to IPFS
 * @param {string} contractName - The address of the contract.
 */
module.exports = async function (callback) {
    try {

        // if process.argv elements contain "help"
        if (argv.help || argv.h || argv._.find(arg => arg === "help" || arg === "h")) {
            console.log(`Usage: truffle exec scripts/deploy.mjs [contract]`);
            return callback();
        }

        // extract contract name from config arguments
        const [ ,, contractName, ...args ] = argv._;

        console.log("Using contract", contractName);

        if (!contractName) {
            console.log(`Usage: truffle exec scripts/deploy.mjs [contract]`);
            return callback();
        }

        const contractInfo = artifacts.require(contractName);

        const compiledContract = contract(contractInfo.abi);

        const deployedContract = await contractInfo.new(...args);

        const contractAddress = deployedContract.address;

        return callback(`Contract ${contractName} deployed at ${contractAddress}`);
    } catch (err) {
        return callback(err);
    }
}
