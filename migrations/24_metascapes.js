const Metascapes = artifacts.require("Metascapes");
const WhitelistMerkleTreeExtension = artifacts.require("WhitelistMerkleTreeExtension");

/**
 * Steps:
 * - Deploy Metascapes.sol
 * - TEST withdraw(): deposit 1 wei, call withdraw, check balance
 * - Call updateStartTimestamp with 2nd Feb 2022, 9am EST
 * - Deploy whitelist with arguments: 0x0, address of Metascapes, 0.33 ether, 1
 * - Metascapes.addExtension(whitelist address)
 * - Call whitelist.updateStartTimestamp with 31 Jan 2022, 9am EST
 * - Transfer ownership to Ryan (strawhatbackpacker.eth)
 */


module.exports = async function (deployer, network) {
    await deployer.deploy(Metascapes);

    const metascapes = await Metascapes.deployed();
    // const owner = await metascapes.owner();

    console.log("Metascapes address: " + metascapes.address);

    return;

    // Call updateStartTimestamp with 2nd Feb 2022, 9am EST
    const startTimestamp = 1643810400;
    await metascapes.updateStartTimestamp(startTimestamp);

    // Deploy whitelist with arguments: 0x0, address of Metascapes, 0.33 ether, 1
    await deployer.deploy(
        "WhitelistMerkleTreeExtension",
        "0x0",
        metascapes.address,
        web3.utils.toWei("0.33", "ether"),
        1
    );

    const whitelist = await WhitelistMerkleTreeExtension.deployed();

    // Metascapes.addExtension(whitelist address)
    await metascapes.addExtension(whitelist.address);

    // Call whitelist.updateStartTimestamp with 31 Jan 2022, 9am EST
    const whitelistStartTimestamp = 1643637600;
    await whitelist.updateStartTimestamp(whitelistStartTimestamp);

    // Transfer ownership to Ryan (strawhatbackpacker.eth)
    await metascapes.transferOwnership(owner);

};
