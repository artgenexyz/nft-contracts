const BigNumber = require("bignumber.js");
const { expectRevert, expectEvent } = require("@openzeppelin/test-helpers");
const { assert, expect } = require("chai");
const keccak256 = require("keccak256");
const delay = require("delay");

const { getGasCost, getAirdropTree, createNFTSale, processAddress } = require("../utils");

const PresaleListExtension = artifacts.require("PresaleListExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");
const LimitedSupplyMintingExtension = artifacts.require("LimitedSupplyMintingExtension");
const MetaverseBaseNFT = artifacts.require("MetaverseBaseNFT");

const MockERC20CurrencyToken = artifacts.require("MockERC20CurrencyToken");
const ERC20SaleExtension = artifacts.require("ERC20SaleExtension");

contract("MetaverseBaseNFT – Extensions", (accounts) => {
    let nft;
    const [owner, user1, user2] = accounts;

    beforeEach(async () => {
        nft = await createNFTSale(MetaverseBaseNFT);
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(nft.address);
    });

    // it should deploy extension successfully
    it("should deploy extension successfully", async () => {
        const extension = await PresaleListExtension.new(
            nft.address,
            "0x0", // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        assert.ok(extension.address);
    });

    // it should connect extension to NFT
    it("should connect extension to NFT", async () => {
        const extension = await PresaleListExtension.new(
            nft.address,
            "0x0", // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        await nft.addExtension(extension.address);

        assert.equal(
            await nft.isExtensionAdded(extension.address),
            true,
        );
    });

    // it creates same tree independent on capital case or address order
    it("creates same tree independent on capital case or address order", async () => {
        const { tree: tree1 } = getAirdropTree([ user1, user2 ])
        const { tree: tree2 } = getAirdropTree([ user2, user1 ])
        const { tree: tree3 } = getAirdropTree([ user1.toUpperCase(), user2.toUpperCase() ])
        const { tree: tree4 } = getAirdropTree([ user2.toUpperCase(), user1.toUpperCase() ])
        const { tree: tree5 } = getAirdropTree([ user1.toLowerCase(), user2.toLowerCase() ])

        // check tree roots are equal via tree.getHexRoot()

        assert.equal(
            tree1.getHexRoot(),
            tree2.getHexRoot(),
            "tree1 and tree2 (reverse order) should have same root"
        );

        assert.equal(
            tree1.getHexRoot(),
            tree3.getHexRoot(),
            "tree1 and tree3 (uppercase) should have same root"
        );

        assert.equal(
            tree1.getHexRoot(),
            tree4.getHexRoot(),
            "tree1 and tree4 (uppercase, reverse order) should have same root"
        );

        assert.equal(
            tree1.getHexRoot(),
            tree5.getHexRoot(),
            "tree1 and tree5 (lowercase) should have same root"
        );

    });


    // it should be able to be whitelisted
    it("should be able to be whitelisted", async () => {
        const addresses = [ user1, user2 ]

        const { tree } = getAirdropTree(addresses)

        const extension = await PresaleListExtension.new(
            nft.address,
            tree.getHexRoot(), // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        console.log('tree', tree.getHexRoot())

        const leaf = keccak256(processAddress(user1)).toString('hex')
        // const leaf = keccak256(Buffer.from(processAddress(user1), 'hex'))
        const root = tree.getHexRoot()
        const proof = tree.getHexProof(leaf)

        assert(proof.length > 0, "Invalid proof");

        // function isWhitelisted(bytes32 root, address receiver, uint256 amount, bytes32[] memory proof) public pure returns (bool) {
        const isWhitelisted = await extension.isWhitelisted(root, user1, proof);

        assert.equal(
            isWhitelisted,
            true,
            "user1 should be whitelisted"
        );
    });

    // it should be able to mint via whitelist
    it("should be able to mint via whitelist", async () => {
        const addresses = [ user1, user2 ]

        const { tree } = getAirdropTree(addresses)

        const extension = await PresaleListExtension.new(
            nft.address,
            tree.getHexRoot(), // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        await nft.addExtension(extension.address);
        await extension.startSale();

        assert(await nft.isExtensionAdded(extension.address), "Extension should be allowed");

        await delay(1000);

        const leaf = keccak256(processAddress(user1)).toString('hex')

        const proof = tree.getHexProof(leaf)

        await extension.mint(1, proof, { from: user1, value: 1e17.toString() });

        const balance = await nft.balanceOf(user1);

        assert.equal(
            balance.toString(),
            "1",
            "user1 should have 1 NFT"
        );
    });

    // it should not allow to mint from original contract, reverts "Sale not started"
    it("should not allow to mint from original contract, reverts 'Sale not started'", async () => {
        await expectRevert(
            nft.mint(1, { from: user1 }),
            "Sale not started"
        );
    });

    // it should allow to mint from ERC20SaleExtension
    it ("it should allow to mint from ERC20SaleExtension", async () => {
        const currency = await MockERC20CurrencyToken.new();
        const pass = await createNFTSale(MetaverseBaseNFT);
        await pass.claim(2, owner);

        const metaverseNFT = nft;

        const ERC20Extension = await ERC20SaleExtension.new(metaverseNFT.address, currency.address, 10, 20);
        await metaverseNFT.addExtension(ERC20Extension.address);

        await currency.transfer(user1, 500);

        await expectRevert(
            ERC20Extension.mint(10, { from: user2 }),
            "Not enough currency to mint"
        );
        await expectRevert(
            ERC20Extension.mint(21, { from: user1 }),
            "Too many tokens to mint"
        );

        await currency.approve(ERC20Extension.address, 500, { from: user1 });

        await ERC20Extension.mint(20, { from: user1 })

        const devAddress = await metaverseNFT.DEVELOPER_ADDRESS();

        assert.equal(
            await currency.balanceOf(metaverseNFT.address),
            "200",
            "Contract should have 200 currency tokens"
        );

        await metaverseNFT.withdrawToken(currency.address);
        assert.equal(
            await currency.balanceOf(devAddress),
            "10",
            "Contract developer should have 10 currency tokens after withdrawal"
        );

        const currency2 = await MockERC20CurrencyToken.new();
        await currency2.transfer(user2, 500);
        await currency2.approve(ERC20Extension.address, 500, { from: user2 });

        await expectRevert(
            ERC20Extension.changeCurrency(currency2.address, 20, { from: user1 }),
            "Ownable: caller is not the owner"
        );

        await expectRevert(
            ERC20Extension.changeCurrency(currency2.address, 0),
            "New price must be bigger then zero"
        );

        expectEvent(
            await ERC20Extension.changeCurrency(currency2.address, "20"),
            "currencyChanged",
            { newCurrency: currency2.address}
        );

        await expectRevert(
            ERC20Extension.mint(10, { from: user1 }),
            "Not enough currency to mint"
        );

        await ERC20Extension.mint(10, { from: user2 });

        assert.equal(
            await currency2.balanceOf(metaverseNFT.address),
            "200",
            "Contract should have 200 new currency tokens"
        );

        await metaverseNFT.withdrawToken(currency2.address);
        assert.equal(
            await currency.balanceOf(devAddress),
            "10",
            "Contract developer should have 10 new currency tokens after withdrawal"
        );

    });

    // it should allow to mint from LimitAmountSaleExtension
    it("should allow to mint from LimitAmountSaleExtension", async () => {
        const extension = await LimitAmountSaleExtension.new(
            nft.address,
            1e16.toString(), // price
            3,
            500,
        );

        await nft.addExtension(extension.address);

        await extension.startSale();
        await delay(1000);

        assert(
            await nft.isExtensionAdded(extension.address),
            "Extension should be allowed"
        );

        await extension.mint(1, { from: user2, value: 1e16.toString() });

        const balance = await nft.balanceOf(user2);

        assert.equal(
            balance.toString(),
            "1",
            "user2 should have 1 NFT"
        );

    });

    // it should allow to mint from LimitedSupplyMintingExtension
    it("should allow to mint from LimitedSupplyMintingExtension", async () => {
        const extension = await LimitedSupplyMintingExtension.new(
            nft.address,
            1e16.toString(), // price
            3,
            6, // max per wallet
            500,
        );

        await nft.addExtension(extension.address);

        await extension.startSale();
        await delay(1000);

        assert(
            await nft.isExtensionAdded(extension.address),
            "Extension should be allowed"
        );

        await extension.mint(1, { from: user2, value: 1e16.toString() });

        const balance = await nft.balanceOf(user2);

        assert.equal(
            balance.toString(),
            "1",
            "user2 should have 1 NFT"
        );

        const mintedSupply = await extension.totalSupply();
        const maxSupply = await extension.maxSupply();
        const nftMaxSupply = await nft.maxSupply();

        // expect mintedSupply < maxSupply
        // expect maxSupply == nftMaxSupply

        assert.isBelow(
            Number(mintedSupply),
            Number(nftMaxSupply),
            "nftSupply should be less than maxSupply"
        );

        assert.equal(
            nftMaxSupply.toString(),
            maxSupply.toString(),
            "nftMaxSupply should be equal to maxSupply"
        );

    });

    // it should allow to mint from LimitedSupplyMintingExtension
    it("should not allow to mint more than maxPerWallet from LimitedSupplyMintingExtension", async () => {
        const extension = await LimitedSupplyMintingExtension.new(
            nft.address,
            1e16.toString(), // price
            3, // max per tx
            1, // max per wallet
            500,
        );

        await nft.addExtension(extension.address);

        await extension.startSale();

        await extension.mint(1, { from: user2, value: 1e16.toString() });

        await expectRevert(
            extension.mint(1, { from: user2, value: 1e16.toString() }),
            "LimitedSupplyMintingExtension: max per wallet reached"
        );

    });
});
