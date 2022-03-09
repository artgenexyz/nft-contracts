const assert = require("assert");
const BigNumber = require("bignumber.js");

const TemplateNFTv2 = artifacts.require("TemplateNFTv2");

const MintPassExtension = artifacts.require("MintPassExtension");


const ether = new BigNumber(1e18);

contract("MintPass – Extension", (accounts) => {
    let nft, mintpass, extension;
    const [owner, user1, user2] = accounts;

    beforeEach(async () => {
        nft = await TemplateNFTv2.new();
        mintpass = await TemplateNFTv2.new();

        extension = await MintPassExtension.new(
            nft.address,
            mintpass.address,
            1e14.toString(), // price
            100, // max per extension
            {from: owner}
        );
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(nft.address);
    });

    // it should deploy extension successfully
    it("should deploy extension successfully", async () => {
        assert.ok(extension.address);
    });

    // it should connect extension
    it("should connect extension", async () => {
        await nft.addExtension(extension.address);

        assert.equal(
            await nft.isExtensionAllowed(extension.address),
            true,
        )
    });

    // should be possible to update price
    it("should be possible to update price", async() => {
        await extension.updatePrice(1e18.toString(), {from: owner});
        let price = await await extension.price.call()

        assert.equal(price, 1e18.toString());
    }) 

    // should be possible to update maxPerToken
    xit("should be possible to update maxPerToken", async() => {
        await extension.updateMaxPerToken('10');
        let maxPerToken = await extension.maxPerToken.call().then(callback => {
            return callback.toString();
        })  
        assert.equal(maxPerToken, '10');     
    }) 

    // should be possible to update mintPassAddress
    it("should be possible to update mintPassAddress", async() => {
        await extension.updateMintPassAddress(user1, {from: owner});
        let mintPassAddress = await extension.mintPassAddress.call()

        assert.equal(mintPassAddress.toString(), user1);
    }) 

    // should be possible to update nRemainingTokens
    xit("should be possible to update nRemainingTokens", async () => {
        await extension.updateRemainingTokens('200', {from: owner});

        let nRemainingTokens = await extension.nRemainingTokens.call()

        assert.equal(nRemainingTokens.toString(), '200');
    })

    // should be possible to increase nRemainingTokens
    xit("should be possible to increase nRemainingTokens", async () => {
        await extension.increaseRemainingTokens('200', {from: owner});

        let nRemainingTokens = await extension.nRemainingTokens.call().then(callback => {
            return callback.toString();
        });

        assert.equal(nRemainingTokens, '300');
    })


    // should be possible to mint
    it("should be possible to mint", async () => {
        await nft.setBeneficiary(owner);

        await nft.flipSaleStarted({from: owner});

        await nft.mint(10, { from: user1, value: ether.times(10).toString() });

        await mintpass.setBeneficiary(owner);

        await mintpass.flipSaleStarted({from: owner});

        await mintpass.mint(10, { from: user1, value: ether.times(10).toString() });

        let balance = await mintpass.balanceOf(user1)

        // should mint 10 token
        assert.equal(balance.toString(), '10');

        // start sale
        await extension.startSale();

        await nft.addExtension(extension.address);

        await extension.mint([0], {from: user1, value: ether.toString()});

        // totalSupply should be equal 11 (10 previous + 1)
        const supply = await nft.totalSupply()

        assert.equal(supply.toString(), '11');

        // nRemainingTokens should be equal 9 (100 - 1 minted)
        const remaining = await extension.nRemainingTokens()

        assert.equal(remaining.toString(), '99');

        try {
            await extension.mint([0], {from: user2, value: ether.toString()});
        } catch {}

        // should not be possible to mint without nft
        const supply_ = await nft.totalSupply()

        assert.equal(supply_.toString(), '11');
    })



});