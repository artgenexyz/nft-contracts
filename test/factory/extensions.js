const BigNumber = require("bignumber.js");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert, expect } = require("chai");
const keccak256 = require("keccak256");
const delay = require("delay");

const { getGasCost, getAirdropTree, processAddress } = require("../utils");

const MetaverseNFT = artifacts.require("MetaverseNFT");
const NFTExtension = artifacts.require("NFTExtension");
const WhitelistMerkleTreeExtension = artifacts.require("WhitelistMerkleTreeExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");
const AvatarNFTv2 = artifacts.require("AvatarNFTv2");
const TemplateNFTv2 = artifacts.require("TemplateNFTv2");

const ether = new BigNumber(1e18);

contract("AvatarNFTv2 – Extensions", (accounts) => {
    let nft;
    const [owner, user1, user2] = accounts;

    beforeEach(async () => {
        nft = await TemplateNFTv2.new();
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(nft.address);
    });

    // it should deploy extension successfully
    it("should deploy extension successfully", async () => {
        const extension = await WhitelistMerkleTreeExtension.new(
            nft.address,
            "0x0", // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        assert.ok(extension.address);
    });

    // it should connect extension to NFT
    it("should connect extension to NFT", async () => {
        const extension = await WhitelistMerkleTreeExtension.new(
            nft.address,
            "0x0", // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        await nft.addExtension(extension.address);

        assert.equal(
            await nft.isExtensionAllowed(extension.address),
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

        const extension = await WhitelistMerkleTreeExtension.new(
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

        const extension = await WhitelistMerkleTreeExtension.new(
            nft.address,
            tree.getHexRoot(), // mock merkle root
            1e17.toString(), // price
            1, // max per address
        );

        await nft.addExtension(extension.address);
        await extension.startSale();

        assert(await nft.isExtensionAllowed(extension.address), "Extension should be allowed");

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
            await nft.isExtensionAllowed(extension.address),
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

    return ;

    // it should measure gas spent on deployment
    it("should measure gas spent on deployment", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01),
            10000,
            0,
            20,
            "factory-test-buy",
            "Test",
            "NFT",
            { value: ether.times(0.1) },
        );

        const gasSpent = nft.receipt.gasUsed;

        assert.isBelow(gasSpent, 500_000);

    });

    // it should test that NFT Factory can create NFTs
    it("should test that NFT Factory can create NFTs", async () => {
        let nft = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            "factory-test",
            "Test",
            "NFT",
            { value: ether.times(0.1) },
        );

        assert.ok(nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress);
    });

    // it should test that deployed NFTs have correct owner and correct values
    it("should test that deployed NFTs have correct owner and correct values", async () => {
        let nft = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            "factory-test",
            "Test",
            "NFT",
            { from: user1, value: ether.times(0.1) }
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        assert.equal(await deployedNFT.owner(), user1);
        assert.include(await deployedNFT.baseURI(), "factory-test");
        assert.equal(
            await deployedNFT.baseURI(),
            "factory-test"
        );
    });

    // it should allow updating value in one NFT doesn't change value in other, or in the shared implementation
    it("should allow updating value in one NFT doesn't change value in other, or in the shared implementation", async () => {
        let nft = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            "factory-test",
            "Test",
            "NFT",
            { from: user1, value: ether.times(0.1) }
        );

        let nft2 = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            "factory-test",
            "Test",
            "NFT",
            { from: user1, value: ether.times(0.1) }
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );
        let deployedNFT2 = await MetaverseNFT.at(
            nft2.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        await deployedNFT.setPrice(ether.times(0.1), { from: user1 });

        assert.equal(
            (await deployedNFT.getPrice()).toString(),
            ether.times(0.1).toString()
        );

        assert.equal(
            (await deployedNFT2.getPrice()).toString(),
            ether.times(0.05).toString()
        );
    });

    // it should test that shared implementation fails on all transactions
    it("should test that shared implementation fails on all transactions", async () => {
        const proxyImplementation = await factory.proxyImplementation();
        const original = await MetaverseNFT.at(proxyImplementation);

        assert.equal(
            await original.owner(),
            "0x0000000000000000000000000000000000000000"
        );

        await expectRevert(
            original.mint(1, { from: owner, value: ether.times(0.1) }),
            "Sale not started"
        );
    });

    // it should measure gas spent on deployment
    it("should measure gas spent on deployment", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01),
            10000,
            0,
            20,
            "factory-test-buy",
            "Test",
            "NFT",
            { value: ether.times(0.1) },
        );

        const gasSpent = nft.receipt.gasUsed;

        assert.isBelow(gasSpent, 500_000);

    });

    // it should allow starting sale and buying nft from factory
    // it should test fee split works correctly and developer gets 5% of the balance after owner calls withdraw()
    it("should allow starting sale and buying nft from factory", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01),
            10000,
            0,
            20,
            "factory-test-buy",
            "Test",
            "NFT",
            { value: ether.times(0.1) },
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        await deployedNFT.flipSaleStarted();

        await deployedNFT.mint(5, { from: user1, value: ether.times(0.05) });
        await deployedNFT.mint(5, { from: user2, value: ether.times(0.05) });

        // total is 0.1 eth now

        const dev = await deployedNFT.DEVELOPER_ADDRESS();

        const balance = await web3.eth.getBalance(deployedNFT.address);
        const balanceDeveloperBefore = await web3.eth.getBalance(dev);
        const balanceOwnerBefore = await web3.eth.getBalance(owner);

        assert.equal(balance.toString(), ether.times(0.1).toString());

        const tx = await deployedNFT.withdraw({ from: owner });

        const balanceOwnerAfter = await web3.eth.getBalance(owner);
        const balanceDeveloperAfter = await web3.eth.getBalance(dev);

        const gasCost = getGasCost(tx);

        assert.equal(
            new BigNumber(balanceOwnerAfter).minus(balanceOwnerBefore).plus(gasCost).toString(),
            ether.times(0.1).times(0.95).toString(),
        );

        assert.equal(
            new BigNumber(balanceDeveloperAfter).minus(balanceDeveloperBefore).toString(),
            ether.times(0.1).times(0.05).toString(),
        );
    });
});
