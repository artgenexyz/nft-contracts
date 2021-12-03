const BigNumber = require("bignumber.js");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert } = require("chai");
const { getGasCost } = require("./utils");

const NFTFactory = artifacts.require("NFTFactory");
const SharedImplementationNFT = artifacts.require("SharedImplementationNFT");

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

contract("NFTFactory", (accounts) => {
    let factory;
    const [owner, user1, user2] = accounts;

    beforeEach(async () => {
        factory = await NFTFactory.new();
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(factory.address);
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
            "NFT"
        );

        assert.ok(nft.logs[0].args.deployedAddress);
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
            { from: user1 }
        );

        let deployedNFT = await SharedImplementationNFT.at(
            nft.logs[0].args.deployedAddress
        );

        assert.equal(await deployedNFT.owner(), user1);
        assert.include(await deployedNFT.baseURI(), "factory-test");
        assert.equal(
            await deployedNFT.baseURI(),
            "https://metadata.buildship.dev/api/token/factory-test"
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
            { from: user1 }
        );

        let nft2 = await factory.createNFT(
            ether.times(0.05),
            10000,
            0,
            20,
            "factory-test",
            "Test",
            "NFT",
            { from: user1 }
        );

        let deployedNFT = await SharedImplementationNFT.at(
            nft.logs[0].args.deployedAddress
        );
        let deployedNFT2 = await SharedImplementationNFT.at(
            nft2.logs[0].args.deployedAddress
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
        const original = await SharedImplementationNFT.at(proxyImplementation);

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
            "NFT"
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
            "NFT"
        );

        let deployedNFT = await SharedImplementationNFT.at(
            nft.logs[0].args.deployedAddress
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

        const gasCost = await getGasCost(tx);

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
