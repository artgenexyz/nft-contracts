const NFTFactory = artifacts.require("NFTFactory");
const SharedImplementationNFT = artifacts.require("SharedImplementationNFT");

const ether = 1e18;
let factory;

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

contract("NFTFactory", accounts => {
    // it should deploy successfully
    it("should deploy successfully", async () => {
        factory = await NFTFactory.deployed();
        assert.ok(factory.address);
    });

    // TODO: test that deployed NFTs have different owners

    // TODO: test factory
})