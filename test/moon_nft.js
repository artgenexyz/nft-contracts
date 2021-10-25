const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert } = require("chai");

const MoonNFT = artifacts.require("MoonNFT");
const BN = web3.utils.BN;

const ether = 1e18;

const MINT = 'mint(uint256)'
const MINT_TIER = 'mint(uint8,uint256)'
const MINT_REFERRAL = 'mint(uint256,address)'
const MINT_TIER_REFERRAL = 'mint(uint8,uint256,address)'

contract("MoonNFT", accounts => {
    const [ owner, user1, user2, beneficiary ] = accounts;

    let nft;

    // it should deploy successfully
    it("should deploy successfully and start sale", async () => {
        nft = await MoonNFT.new();

        assert.ok(nft.address);

        await nft.setBeneficiary(beneficiary);
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

        assert.equal(price.toString(), 0.08 * ether);

        await nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price, from: buyer });
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

        await nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price, from: buyer });
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

        assert.equal(price, 0.3 * ether);

        await nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price, from: buyer });
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

        assert.equal(price, 0.7 * ether);

        await nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price, from: buyer });
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

        assert.equal(price, 1.2 * ether);

        await nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price, from: buyer });
        const balance = await nft.balanceOf(buyer);

        assert.equal(balance, 5);

        // check getSupply for this tier is now 1
        const supply = await nft.getSupply(tier);

        assert.equal(supply, 1);
    });

    // it should not be able to sell tier = 5 because only reserved tokens are present
    it("should not be able to sell tier = 5 because only reserved tokens are present", async () => {
        const [ owner, buyer, referral, anotherBuyer ] = accounts;
        // using anotherBuyer, because buyer already doesn't have 100 ether

        const tier = 5; // Genesis
        const price = await nft.getPrice(tier);

        assert.equal(price, 100 * ether);

        await expectRevert(
            nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price, from: anotherBuyer }),
            "Not enough Tokens left."
        );
    });

    // it should fail if the tier is not valid
    it("should fail if the tier is not valid", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        const tier = 6; // Invalid Tier id

        await expectRevert(
            nft.getPrice(tier),
            "Invalid tier."
        );

        await expectRevert(
            nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: 0.08 * ether, from: buyer }),
            "Invalid tier."
        );
    });

    // it should fail if calling mint
    it("should fail if calling mint", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        await expectRevert(
            nft.methods[MINT](1, { value: 0.08 * ether, from: buyer }),
            "Not implemented"
        );
    });

    // it should fail if calling mint
    it("should fail if calling mint with tier", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        await expectRevert(
            nft.methods[MINT_TIER](0, 1, { value: 0.08 * ether, from: buyer }),
            "Not implemented"
        );
    });

    // it should fail if calling methods[MINT_REFERRAL]
    it("should fail if calling mint with referral']", async () => {
        // const nft = await MoonNFT.deployed();
        const [ owner, buyer, referral ] = accounts;

        await expectRevert(
            nft.methods[MINT_REFERRAL](1, referral, { value: 0.08 * ether, from: buyer }),
            "Not implemented"
        );
    });

    // it should be able to mint multiple tokens
    it("should be able to mint multiple tokens", async () => {
        const [ owner, buyer, referral, anotherBuyer ] = accounts;

        const tier = 0;
        const amount = 2;
        const price = await nft.getPrice(tier);

        assert.equal(price, 0.08 * ether);

        const balanceBefore = await nft.balanceOf(anotherBuyer);

        await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: anotherBuyer });

        const balance = await nft.balanceOf(anotherBuyer);

        assert.equal(balance.toNumber(), balanceBefore.toNumber() + 2);

    });

    // it should be able to mint max of tier = 4
    it("should be able to create contract, mint max of tier = 4", async () => {
        const [ owner, buyer, referral, anotherBuyer, beneficiary ] = accounts;

        const nft = await MoonNFT.new();
        await nft.setBeneficiary(beneficiary);
        await nft.flipSaleStarted();

        const tier = 4; // President

        const price = await nft.getPrice(tier);

        const maxAmount = await nft.MAX_TOKENS_PER_MINT();
        const maxSupply = await nft.getMaxSupply(tier);
        const reserved = await nft.getReservedLeft(tier);

        assert.equal(price, 1.2 * ether);
        assert.equal(maxAmount, 20);
        assert.equal(maxSupply, 10);
        assert.equal(reserved, 3); // for President

        await expectRevert(
            nft.methods[MINT_TIER_REFERRAL](tier, maxAmount, referral, { value: price * maxAmount, from: anotherBuyer }),
            "Not enough Tokens left."
        );

        const balanceBefore = await nft.balanceOf(anotherBuyer);

        // mint 1 tokens per transaction, 10 times in a row
        for (let i = 0; i < maxSupply - reserved; i++) {
            const amount = 1;
            await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: anotherBuyer })
        }

        const balance = await nft.balanceOf(anotherBuyer);

        assert.equal(balance, balanceBefore.toNumber() + maxSupply - reserved);

        // expect revert if trying to mint 1 more

        // check getMaxSupply(tier) - getReservedLeft(tier) equals getSupply(tier)
        const supply = await nft.getSupply(tier);
        assert.equal(supply, maxSupply - reserved);

        // TODO: check not possible to mint more
        // send ether from owner to buyer

        // const amount = 1;
        // await expectRevert(
        //     nft.methods[MINT_TIER_REFERRAL](tier, 1, referral, { value: price * amount, from: anotherBuyer }),
        //     "Not enough Tokens left."
        // );

    });

    // it should return correct number of reserved
    it("should return correct number of reserved", async () => {

        const reservedTotal = await nft.getReservedLeft();

        let reserved = 0

        // fetch reserved by each tier
        for (let i = 0; i <= 5; i++) {
            reserved = reserved + Number(await nft.getReservedLeft(i));
        }

        assert.equal(reserved, reservedTotal.toNumber(), "getReservedLeft has wrong totals");

    });

    // it should update the number of reserved after you claim
    it("should update the number of reserved after you claim", async () => {
        const reservedTotalBefore = await nft.getReservedLeft();

        await nft.claimReserved(0, 2, owner, { from: owner });

        const reservedTotalAfter = await nft.getReservedLeft();

        assert.equal(reservedTotalAfter, reservedTotalBefore.toNumber() - 2);
    });

    // it should fail if you try to claim
    it("should fail if you try to claim", async () => {

        // try claim but has error message "Not implemented"
        await expectRevert(
            nft.methods['claimReserved(uint256,address)'](2, owner, { from: owner }),
            "Not implemented",
        );
    });

    // it should return the same price for getPrice() and getPrice(Tier.Standard)
    it("should return the same price for getPrice() and getPrice(Tier.Standard)", async () => {
        const tier = 0;
        const price = await nft.getPrice(tier);
        const price2 = await nft.getPrice();

        assert.equal(price.toString(), price2.toString(), "getPrice() should return value for Tier.Standard");
    });

    // it should update referrer balance and userTotalReferrals if minting with referral info
    it("should update referrer balance and userTotalReferrals if minting with referral info", async () => {

        const [ owner, buyer, referral, anotherBuyer ] = accounts;

        const tier = 0;
        const amount = 2;
        const price = await nft.getPrice(tier);

        const balanceBefore = await nft.pendingWithdrawals(referral);
        const userTotalReferralsBefore = await nft.userTotalReferrals(referral);

        await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: anotherBuyer });

        const balance = await nft.pendingWithdrawals(referral);
        const userTotalReferrals = await nft.userTotalReferrals(referral);

        const fee = price * amount * 0.3; // 30%

        assert.equal(balance - balanceBefore, fee);
        assert.equal(userTotalReferrals.toNumber(), userTotalReferralsBefore.toNumber() + amount);

    });

    // it should not update referrer balance if user provides their address
    it("should not update referrer balance if user provides their address", async () => {

        const [ owner, buyer, referral ] = accounts;

        const tier = 0;
        const amount = 2;
        const price = await nft.getPrice(tier);

        const balanceBefore = await nft.pendingWithdrawals(referral);

        await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: referral });

        const balance = await nft.pendingWithdrawals(referral);

        assert.equal(balance.toString(), balanceBefore.toString());

    });

    // it should check that getTier(tokenId) returns correct tier for each token
    it("should check that getTier(tokenId) returns correct tier for each token", async () => {

        const [ owner, buyer, referral, anotherBuyer ] = accounts;

        // skip Genesis
        for (let tier = 0; tier <= 4; tier++) {

            const amount = 1;
            const price = await nft.getPrice(tier);

            const tx = await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: anotherBuyer });

            const { tokenId } = tx.logs[0].args;

            const tier2 = await nft.getTier(tokenId);

            assert.equal(tier, tier2);
        }

        const genesisTier = await nft.getTier(0); // tokenId = 0 should be Genesis

        assert.equal(genesisTier, 5);

    });

    // it should check that getTier(tokenId) fails for non-existent token
    it("should check that getTier(tokenId) fails for non-existent token", async () => {

        const range = await nft.getRange(0); // 0 is Standard, 3111-9999

        const lastTokenId = range[1];

        await expectRevert(
            nft.getTier(lastTokenId.addn(1).toNumber()),
            "TokenId not found in any tier"
        );

    });

    // it should be able to mint all tokens from tier Prestige and President (3,4) and check that tokenIds not interfere
    it("should be able to mint all tokens from tier Prestige and President (3,4) and check that tokenIds not interfere", async () => {

        const [ owner, buyer, referral, anotherBuyer ] = accounts;

        let tx;
        let tier = 3; // Prestige
        let price = await nft.getPrice(tier);
        let mintSupply = await nft.getMaxSupply(tier) - await nft.getSupply(tier) - await nft.getReservedLeft(tier);

        // const balanceBefore = await nft.balanceOf(anotherBuyer);

        // // mint 1 tokens per transaction, 10 times in a row
        // for (let i = 0; i < mintSupply; i++) {
        //     const amount = 1;
        //     tx = await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: anotherBuyer })
        // }


        tier = 4; // President
        price = await nft.getPrice(tier);
        mintSupply = await nft.getMaxSupply(tier) - await nft.getSupply(tier) - await nft.getReservedLeft(tier);

        // claim all President tokens
        const reserved = await nft.getReservedLeft(tier);

        tx = await nft.claimReserved(tier, reserved, owner, { from: owner });

        // const { tokenId } = tx.logs[0].args;

        // mint 1 tokens per transaction, 10 times in a row
        for (let i = 0; i < mintSupply; i++) {
            const amount = 1;
            tx = await nft.methods[MINT_TIER_REFERRAL](tier, amount, referral, { value: price * amount, from: anotherBuyer })
        }

        // const balanceAfter = await nft.balanceOf(anotherBuyer);

        // check that last minted token is equal to the start of the Prestige range
        const lastTokenId = tx.receipt.logs[0].args.tokenId;
        const range = await nft.getRange(3);

        assert.equal(lastTokenId.toNumber() + 1, range[0].toNumber());

    });




})