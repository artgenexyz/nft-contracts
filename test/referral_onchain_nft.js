const { assert } = require("chai");

const ReferralOnchainNFT = artifacts.require("ReferralOnchainNFT");

const BN = web3.utils.BN;
const MINT_REFERRAL = 'mint(uint256,address)'

contract("ReferralOnchainNFT", accounts => {
    // it should deploy successfully
    it("should deploy successfully", async () => {
        const nft = await ReferralOnchainNFT.deployed();
        assert.ok(nft.address);

    });

    // it should fail selling if beneficiary is not set
    it("should fail selling if beneficiary is not set", async () => {
        const nft = await ReferralOnchainNFT.deployed();

        try {
            await nft.flipSaleStarted();
            assert.fail("Sale started without beneficiary");
        } catch (error) {
            assert.ok(error.message.includes("Beneficiary not set"));
        }
    });

    // it should start sale after setting beneficiary
    it("should start sale after setting beneficiary", async () => {
        const nft = await ReferralOnchainNFT.deployed();

        await nft.setBeneficiary(accounts[1]);

        await nft.flipSaleStarted();

        assert.equal(await nft.saleStarted(), true, "Sale not started after flipping sale");
    });

    /**
     * Mint tokens with referral info
     *
     * function mintReferral(uint256 nTokens, address payable referral) public payable {
     * 
     */

    it("should mint token with referral info", async () => {
        const nft = await ReferralOnchainNFT.deployed();
        const referral = accounts[1];
        const nTokens = 1;
        const price = await nft.getPrice();

        const tx = await nft.methods[MINT_REFERRAL](nTokens, referral, { value: price.muln(nTokens) });

        const { tokenId } = tx.logs[0].args;

        const token = await nft.tokenOfOwnerByIndex(accounts[0], 0);

        assert(token.eq(tokenId), "Token ID doesnt match");
        // expect(token).to.be(tokenId);
        // expect(token).to.be.bignumber.equal(tokenId);

    });

    // it should update referral balance in pendingWithdrawals when someone mints token
    it("should update referral balance in pendingWithdrawals when someone mints token", async () => {
        const nft = await ReferralOnchainNFT.deployed();
        const referral = accounts[1];
        const nTokens = 2;
        const price = await nft.getPrice();
        const REFERRAL_PERCENT = await nft.REFERRAL_PERCENT();

        await nft.methods[MINT_REFERRAL](nTokens, referral, { value: price.muln(nTokens) });

        const pendingBalance = await nft.pendingWithdrawals(referral);
        const referralReward = price.mul(REFERRAL_PERCENT).divn(10000).muln(nTokens);

        console.log('pending balance', pendingBalance.toString());
        console.log('predicted reward', referralReward.toString());

        // assert pendingBalance more or equal to price * nTokens * REFERRAL_PERCENT / 10000
        assert(pendingBalance.sub(referralReward).gte(0), "Pending balance is less than expected");
        // expect(pendingBalance).to.be.bignumber.gte(referralReward);

    });

    it("should allow referral to withdraw his pendingBalance", async () => {
        const nft = await ReferralOnchainNFT.deployed();
        const referral = accounts[1];

        // save referral balance withdraw
        const balanceBefore = new BN(await web3.eth.getBalance(referral));

        const pendingBalance = await nft.pendingWithdrawals(referral);

        const tx = await nft.claimReferralRewards({ from: referral });

        const balanceAfter = new BN(await web3.eth.getBalance(referral));

        // assert balanceAfter - balanceBefore >= pendingBalance - gasSpent
        const gasPrice = await web3.eth.getGasPrice();
        console.log('tx', tx.receipt.gasUsed, gasPrice);
        const gasSpent = new BN(gasPrice).muln(tx.receipt.gasUsed); //.mul(gasPrice);

        // check that pendingBalance is 0
        const pendingBalanceAfter = await nft.pendingWithdrawals(referral);

        assert.equal(pendingBalanceAfter.toNumber(), 0, "Pending balance is not zero");

    });


    xit("should mint tokens with referral info", async () => {
        const nft = await ReferralOnchainNFT.deployed();

        const buyer = accounts[2];
        const referral = accounts[1];
        const amount = 2;

        const price = await nft.getPrice();

        const balanceBefore = await nft.balanceOf(buyer);
        const totalSupplyBefore = await nft.totalSupply();

        await nft.methods[MINT_REFERRAL](amount, referral, { from: buyer, value: price.muln(amount) });

        const balanceAfter = await nft.balanceOf(buyer);
        const totalSupplyAfter = await nft.totalSupply();

        // assert.equal(balanceAfter.toNumber(), balanceBefore.toNumber() + amount);
        // assert.equal(totalSupplyAfter.toNumber(), totalSupplyBefore.toNumber() + amount);

        // replace with expect and use BigNumber
        expect(balanceAfter).to.be.bignumber.equal(balanceBefore.add(amount))
        expect(totalSupplyAfter).to.be.bignumber.equal(totalSupplyBefore.add(amount))

        // check that pendingWithdrawals for this referral isn't zero now
        const pendingWithdrawals = await nft.pendingWithdrawals(referral);
        const referralPercent = await nft.REFERRAL_PERCENT();

        expect(pendingWithdrawals).to.be.bignumber.not.equal(0);
        // expect(pendingWithdrawals).to.be.bignumber.equal(price.muln(amount).mul(referralPercent).divn(10000));

        // check that referral is able to withdraw his balance
        const referralBalanceBefore = await web3.eth.getBalance(referral);

        await nft.claimReferralRewards({ from: referral });

        const referralBalanceAfter = await web3.eth.getBalance(referral);

        expect(
            referralBalanceAfter
        ).to.be.bignumber.equal(
            referralBalanceBefore.add(price.muln(amount).mul(referralPercent).divn(10000))
        );

        // check that pendingWithdrawals for this referral is zero now
        const pendingWithdrawalsAfter = await nft.pendingWithdrawals(referral);

        expect(pendingWithdrawalsAfter).to.be.bignumber.eq(0);

    });

})