
module.exports = async function (callback) {
    try {
        // if process.argv elements contain "help"
        if (process.argv.find((elem) => elem.includes("help"))) {
            console.log(`Usage: truffle exec upload [contract]`);
            return callback();
        }

        // extract contract name from config arguments
        const [, , , , contractName, newOwner ] = process.argv;

        console.log("Using contract", contractName);
        console.log("Will transferOwnership to", newOwner);
        console.log("");

        if (!contractName) {
            console.log(`Usage: truffle exec scripts/transfer.mjs [contract] [new owner]`);
            return callback();
        }

        const contract = artifacts.require(contractName);

        console.log(`Loading ${contractName}`);

        const contractInstance = await contract.deployed();

        console.log("Found instance at address", contractInstance.address);

        console.log("Transferring ownership to", newOwner);

        tx = await contractInstance.transferOwnership(newOwner, {
            gas: 100_000,
            gasPrice: 150e9,
        });

        receipt = await tx.wait();

        console.log("tx success", receipt.transactionHash);
    } catch (err) {
        console.log('Error', err.message);
    } finally {
        callback();
    }

};
