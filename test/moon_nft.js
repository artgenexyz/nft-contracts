const { expectRevert } = require("@openzeppelin/test-helpers");
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");
const MoonNFT = artifacts.require("MoonNFT");

const ether = 1e18;

contract("MoonNFT", accounts => {
    let nft;

    // it should deploy successfully
    it("should deploy successfully and start sale", async () => {
        nft = await MoonNFT.new();

        assert.ok(nft.address);

        await nft.flipSaleStarted();

        assert.equal(await nft.saleStarted(), true, "Sale not started after flipping sale");
    });

    // if (tier == Tier.Standard) return 0.05 ether;
    // if (tier == Tier.Elite) return 0.2 ether;
    // if (tier == Tier.VIP) return 0.5 ether;
    // if (tier == Tier.Prestige) return 1 ether;
    // if (tier == Tier.President) return 5 ether;

    // it should be able to mint at each tier
    it("should be able to mint at each tier", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 0;
        const price = await nft.getPrice(tier);

        assert.equal(price.toString(), 0.05 * ether);

        await nft.mintTierReferral(tier, 1, referral, { value: price, from: buyer });
        const balance = await nft.balanceOf(buyer);

        assert.equal(balance, 1);

        // check getSupply for this tier is now 1
        const supply = await nft.getSupply(tier);
        assert.equal(supply, 1);

    });

    // it should be able to mint at each tier
    it("should be able to mint at each tier", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 1;
        const price = await nft.getPrice(tier);

        assert.equal(price, 0.2 * ether);

        await nft.mintTierReferral(tier, 1, referral, { value: price, from: buyer });
        const balance = await nft.balanceOf(buyer);

        assert.equal(balance, 2);

        // check getSupply for this tier is now 1
        const supply = await nft.getSupply(tier);
        assert.equal(supply, 1);
    });

    // it should be able to mint at each tier
    it("should be able to mint at each tier", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 2; // VIP
        const price = await nft.getPrice(tier);

        assert.equal(price, 0.5 * ether);

        await nft.mintTierReferral(tier, 1, referral, { value: price, from: buyer });
        const balance = await nft.balanceOf(buyer);

        assert.equal(balance, 3);

        // check getSupply for this tier is now 1
        const supply = await nft.getSupply(tier);
        assert.equal(supply, 1);
    });

    // it should be able to mint at each tier
    it("should be able to mint at each tier", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 3; // Prestige
        const price = await nft.getPrice(tier);

        assert.equal(price, 1 * ether);

        await nft.mintTierReferral(tier, 1, referral, { value: price, from: buyer });
        const balance = await nft.balanceOf(buyer);

        assert.equal(balance, 4);

        // check getSupply for this tier is now 1
        const supply = await nft.getSupply(tier);
        assert.equal(supply, 1);
    });

    // it should be able to mint at each tier
    it("should be able to mint at each tier", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 4; // President
        const price = await nft.getPrice(tier);

        assert.equal(price, 5 * ether);

        await nft.mintTierReferral(tier, 1, referral, { value: price, from: buyer });
        const balance = await nft.balanceOf(buyer);

        assert.equal(balance, 5);

        // check getSupply for this tier is now 1
        const supply = await nft.getSupply(tier);

        assert.equal(supply, 1);
    });

    // it should fail if the tier is not valid
    it("should fail if the tier is not valid", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 5; // Invalid Tier id

        expectRevert(
            nft.getPrice(tier),
            "revert"
        );

        expectRevert(
            nft.mintTierReferral(tier, 1, referral, { value: 0.05 * ether, from: buyer }),
            "revert"
        );
    });

    // it should fail if calling mint
    it("should fail if calling mint", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const price = await nft.getPrice();

        expectRevert(
            nft.mint(1, { value: price, from: buyer }),
            "Not implemented"
        );
    });

    // it should fail if calling mintTierReferral
    it("should fail if calling mintTierReferral", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const price = await nft.getPrice();

        expectRevert(
            nft.mintReferral(1, referral, { value: price, from: buyer }),
            "Not implemented"
        );
    });

    // it should be able to mint multiple tokens
    it("should be able to mint multiple tokens", async () => {
        const [ owner, buyer, referral, anotherBuyer ] = accounts;

        const tier = 0;
        const amount = 2;
        const price = await nft.getPrice(tier);

        assert.equal(price, 0.05 * ether);

        const balanceBefore = await nft.balanceOf(anotherBuyer);

        await nft.mintTierReferral(tier, amount, referral, { value: price * amount, from: anotherBuyer });

        const balance = await nft.balanceOf(anotherBuyer);

        assert.equal(balance.toNumber(), balanceBefore.toNumber() + 2);

    });

    // it should be able to mint max of tier = 4
    it("should be able to create contract, mint max of tier = 4", async () => {
        const [ owner, buyer, referral, anotherBuyer ] = accounts;

        const nft = await MoonNFT.new();
        await nft.flipSaleStarted();

        const tier = 4; // President

        const price = await nft.getPrice(tier);

        const maxAmount = await nft.MAX_TOKENS_PER_MINT();
        const maxSupply = await nft.getMaxSupply(tier);

        assert.equal(price, 5 * ether);
        assert.equal(maxAmount, 20);
        assert.equal(maxSupply, 10);

        expectRevert(
            nft.mintTierReferral(tier, maxAmount, referral, { value: price * maxAmount, from: anotherBuyer }),
            "Not enough Tokens left."
        );

        const balanceBefore = await nft.balanceOf(anotherBuyer);

        // mint 1 tokens per transaction, 10 times in a row
        for (let i = 0; i < 10; i++) {
            const amount = 1;
            await nft.mintTierReferral(tier, amount, referral, { value: price * amount, from: anotherBuyer })
        }

        const balance = await nft.balanceOf(anotherBuyer);

        assert.equal(balance, balanceBefore.toNumber() + 10);

        // expect revert if trying to mint 1 more

        // check getMaxSupply(tier) equals getSupply(tier)
        const supply = await nft.getSupply(tier);
        assert.equal(supply.toNumber(), maxSupply.toNumber());

        // TODO: check not possible to mint more
        // send ether from owner to buyer

        // const amount = 1;
        // expectRevert(
        //     nft.mintTierReferral(tier, 1, referral, { value: price * amount, from: anotherBuyer }),
        //     "Not enough Tokens left."
        // );

    });




})