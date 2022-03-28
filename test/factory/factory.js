const BigNumber = require("bignumber.js");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert, expect } = require("chai");
const { getGasCost } = require("../utils");

const NFTFactory = artifacts.require("MetaverseNFTFactory");
const MetaverseNFT = artifacts.require("MetaverseNFT");

const TemplateNFTv2 = artifacts.require("TemplateNFTv2");

const ether = new BigNumber(1e18);

/**
 * Tests for the NFTFactory:
 * - Factory can deploy itself, and then create new NFTs successfully
 * - Deployed shared implementation has all the values set to zero
 * - Deployed NFTs have correct owner and correct values
 * - Updating value in one NFT doesn't change value in other, or in the shared implementation
 * - Shared implementation fails on all transactions
 * - Test simple sale for deployed NFTs
 * - Test that deployed NFTs have different owners
 * -
 */

contract("MetaverseNFTFactory", (accounts) => {
    let factory, pass;
    const [owner, user1, user2, user3] = accounts;

    beforeEach(async () => {
        pass = await TemplateNFTv2.new();
        factory = await NFTFactory.new(pass.address);

        await pass.claimReserved(1, owner, { from: owner });
        await pass.claimReserved(1, user1, { from: owner });
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(factory.address, "Factory not deployed");

        const original = await MetaverseNFT.at(await factory.proxyImplementation());

        assert.equal(
            await original.owner(),
            "0x0000000000000000000000000000000000000000",
            "Owner is not zero"
        );

        // TODO: fix for ganache v7 https://github.com/trufflesuite/ganache/discussions/1075#user-content-v7.0.0-alpha.0-the-big-ones

        await expectRevert(
            original.mint(1, { from: user1, value: ether.times(0.1) }),
            "Sale not started"
        );

        return;

        try {
        } catch (err) {

            // extract transaction hash from error
            const txHash = err.message.match(/Transaction: (0x\w+)/)[1];

            const tx = await web3.eth.getTransactionReceipt(txHash);

            // check if transaction was reverted
            assert.equal(
                await tx.status,
                false,
                "Transaction was not reverted"
            );

            // // check if transaction was reverted with correct reason
            // assert.equal(
            //     await tx.logs[0].data,
            //     "Sale not started",
            //     "Transaction was not reverted with correct reason"
            // );

        }

        // await expectRevert(
        //     original.mint(1, { from: user1, value: ether.times(0.1) }),
        //     "Sale not started",
        //     "Minting not failed"
        // );
    });

    // it should measure gas spent on deployment
    it("should measure gas spent on deployment", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01), // price
            10000, // max tokens
            0, // reserved
            20, // max per mint
            0, // royalty fee
            "factory-test-buy",
            "Test",
            "NFT"
        );

        const gasSpent = nft.receipt.gasUsed;

        assert.isBelow(gasSpent, 500_000, "Gas spent is too high");

    });

    // it should test that NFT Factory can create NFTs
    it("should test that NFT Factory can create NFTs", async () => {
        let nft = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            0, // royalty fee
            "factory-test",
            "Test",
            "NFT",
            // { value: ether.times(0.1) },
        );

        assert.ok(nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress);
    });

    // it should test that deployed NFTs have correct owner and correct values
    it("should test that deployed NFTs have correct owner and correct values", async () => {
        let nft = await factory.createNFT(
            ether.times(0.05),
            10000,
            1,
            20,
            0, // royalty fee
            "factory-test/",
            "Test",
            "NFT",
            { from: user1 }
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        assert.equal(await deployedNFT.owner(), user1);

        await deployedNFT.claim(1, user2, { from: user1 });

        assert.include(await deployedNFT.tokenURI(0), "factory-test");
        assert.equal(
            await deployedNFT.tokenURI(0),
            "factory-test/0"
        );
    });

    // it should allow updating value in one NFT doesn't change value in other, or in the shared implementation
    it("should allow updating value in one NFT doesn't change value in other, or in the shared implementation", async () => {
        let nft = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            0, // royalty fee
            "factory-test",
            "Test",
            "NFT",
            { from: user1 }
        );

        let nft2 = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            0, // royalty fee
            "factory-test",
            "Test",
            "NFT",
            { from: user1 }
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );
        let deployedNFT2 = await MetaverseNFT.at(
            nft2.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        await deployedNFT.setPrice(ether.times(0.1), { from: user1 });

        assert.equal(
            (await deployedNFT.price()).toString(),
            ether.times(0.1).toString()
        );

        assert.equal(
            (await deployedNFT2.price()).toString(),
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
            original.mint(1, { from: user1, value: ether.times(0.1) }),
            "Sale not started"
        )

        return;

        try {
        } catch (err) {

            // extract transaction hash from error
            const txHash = err.message.match(/Transaction: (0x\w+)/)[1];

            const tx = await web3.eth.getTransactionReceipt(txHash);

            // check if transaction was reverted
            assert.equal(
                await tx.status,
                false,
                "Transaction was not reverted"
            );

            // // check if transaction was reverted with correct reason
            // assert.equal(
            //     await tx.logs[0].data,
            //     "Sale not started",
            //     "Transaction was not reverted with correct reason"
            // );
        }
    });

    // it should measure gas spent on deployment
    it("should measure gas spent on deployment", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01),
            10000,
            0,
            20,
            0, // royalty fee
            "factory-test-buy",
            "Test",
            "NFT",
            // { value: ether.times(0.1) },
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
            0, // royalty fee
            "factory-test-buy",
            "Test",
            "NFT",
            // { value: ether.times(0.1) },
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        await deployedNFT.startSale();

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

    // it should create nft and add .json using setPostfixURI
    it("should create nft and add .json using setPostfixURI", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01),
            10000,
            1, // reserved
            20,
            0, // royalty fee
            "factory-test-buy",
            "Test",
            "NFT",
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        await deployedNFT.setPostfixURI(".json");

        await deployedNFT.claim(1, user1);

        assert.include(await deployedNFT.tokenURI(0), "factory-test");
        assert.include(await deployedNFT.tokenURI(0), ".json");
    });

    // it start token ids from 0 when calling normal createNFT
    it("start token ids from 0 when calling normal createNFT", async () => {
        let nft = await factory.createNFT(
            ether.times(0.01),
            10000,
            1, // reserved
            20,
            0, // royalty fee
            "factory-test-buy",
            "Test",
            "NFT",
        );

        let deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        const tx = await deployedNFT.claim(1, user1);

        // check tx events for Transfer
        assert.equal(
            tx.logs.find(l => l.event === "Transfer").args.from,
            "0x0000000000000000000000000000000000000000",
        );

        assert.equal(
            tx.logs.find(l => l.event === "Transfer").args.tokenId,
            "0",
        );

    });

    // it should be able to createNFTwithParams
    it("should be able to createNFTwithParams", async () => {
        const nft = await factory.createNFTwithParams(
            ether.times(0.01),
            10000,
            1, // reserved
            20,
            0, // royalty fee
            "factory-test-buy/",
            "Test",
            "NFT",
            user2, // address payoutReceiver,
            true, // bool shouldUseJSONExtension,
            1 + 4 + 8, // uint16 miscParams is a bitmask of 1,2,4,8
            { from: user1 },
        );

        const deployedNFT = await MetaverseNFT.at(
            nft.logs.find(l => l.event === "NFTCreated").args.deployedAddress
        );

        assert.equal(
            await deployedNFT.owner(),
            user1,
        );

        assert.equal(
            await deployedNFT.getPayoutReceiver(),
            user2,
        );

        // test if miscParams are parsed correctly:
        // bool startTokenIdAtOne = (miscParams & 0x01) == 0x01;
        // bool shouldUseJSONExtension = (miscParams & 0x02) == 0x02;
        // bool shouldStartSale = (miscParams & 0x04) == 0x04;
        // bool shouldLockPayoutChange = (miscParams & 0x08) == 0x08;

        assert.equal(
            await deployedNFT.startTokenId(),
            "1"
        );

        await deployedNFT.claim(1, owner, { from: user1 });

        // TODO: fix for ganache v7 https://github.com/trufflesuite/ganache/discussions/1075#user-content-v7.0.0-alpha.0-the-big-ones

        // expect tokenURI(0) to fail
        expectRevert(deployedNFT.tokenURI(0), "ERC721Metadata: URI query for nonexistent token");

        assert.equal(
            await deployedNFT.tokenURI(1),
            "factory-test-buy/1.json",
        );


        // saleStarted is true
        assert.equal(
            await deployedNFT.saleStarted(),
            true,
        );

        // not possible to change payout receiver
        expectRevert(
            deployedNFT.setPayoutReceiver(user3, { from: user1 }),
            "Payout change is locked"
        );

    })


});
