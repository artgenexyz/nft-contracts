
const Equation = artifacts.require("Equation");
const TriggerFund = artifacts.require("TriggerFund");
const BadgeNFT = artifacts.require("BadgeNFT");

module.exports = async function (deployer, network, accounts) {

    await deployer.deploy(Equation);

    // link Equation to TriggerFund
    await deployer.link(Equation, TriggerFund);

    await deployer.deploy(TriggerFund);

    return;
    let nft;

    nft = await BadgeNFT.new("ETHGlobal", "ETHG", "Winner of ETHGlobal? Also date, Category ID");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("MixBytes Audit", "MIXB", "MixBytes Audit passed. Date, Result");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("Variant Fund Invested", "VARF", "How much Variant Fund invested? Date");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("a16z Invested", "A16Z", "a16z: No words needed.");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("caffeinum.eth approved", "0xCAFF", "caffeinum.eth had a talk with the team and approves of them");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("Zoom with @sama", "sama", "Sam Altman had a zoom conversation. Notice: Issued automatically");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("Any Fund invested >100k", "FUND100", "Issued by coingecko whenever some team receives funding");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("Gitcoin Grant Received", "GITCO", "Gitcoin: Amount of funds raised, Amount of funds donated");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("On-chain Milestone", "Milestone", "Number of users and a date");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("Binance Listing", "BINALIST", "Binance listed them, and a date");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");
    nft = await BadgeNFT.new("Coindesk Mention", "COINDESK", "Article ID on Coindesk");
    await nft.transferOwnership("0x2CC7faecA2F0dc48732346e8b3117fcb9c7aA2a7");






};
