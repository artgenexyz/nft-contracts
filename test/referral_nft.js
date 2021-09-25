const { assert } = require("chai");

const ReferralNFT = artifacts.require("ReferralNFT");

contract("ReferralNFT", accounts => {
    // it should deploy successfully
    it("should deploy successfully", async () => {
        const nft = await ReferralNFT.deployed();
        assert.ok(nft.address);

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
        const nft = await ReferralNFT.deployed();
        const referral = accounts[1];
        const nTokens = 1;
        const price = await nft.getPrice();

        const tx = await nft.mintReferral(nTokens, referral, { value: price.muln(nTokens) });

        const { tokenId } = tx.logs[0].args;

        const token = await nft.tokenOfOwnerByIndex(accounts[0], 0);

        assert(token.eq(tokenId), "Token ID doesnt match");
        // expect(token).to.be(tokenId);
        // expect(token).to.be.bignumber.equal(tokenId);

    });

    // it should update referral balance in pendingWithdrawals when someone mints token
    it("should update referral balance in pendingWithdrawals when someone mints token", async () => {
        const nft = await ReferralNFT.deployed();
        const referral = accounts[1];
        const nTokens = 2;
        const price = await nft.getPrice();
        const REFERRAL_PERCENT = await nft.REFERRAL_PERCENT();

        await nft.mintReferral(nTokens, referral, { value: price.muln(nTokens) });

        const pendingBalance = await nft.pendingWithdrawals(referral);
        const referralReward = price.mul(REFERRAL_PERCENT).divn(10000).muln(nTokens);

        console.log('pending balance', pendingBalance.toString());
        console.log('predicted reward', referralReward.toString());

        // assert pendingBalance more or equal to price * nTokens * REFERRAL_PERCENT / 10000
        assert(pendingBalance.sub(referralReward).toNumber() >= 0);
        // expect(pendingBalance).to.be.bignumber.gte(referralReward);

    });

    xit("should allow referral to withdraw his pendingBalance", async () => {
        const nft = await ReferralNFT.deployed();
        const referral = accounts[1];

        // save referral balance withdraw
        const balanceBefore = new BN(await web3.eth.getBalance(referral));

        const pendingBalance = await nft.pendingWithdrawals(referral);

        const tx = await nft.claimReferralRewards({ from: referral });

        const balanceAfter = new BN(await web3.eth.getBalance(referral));

        // assert balanceAfter - balanceBefore >= pendingBalance - gasSpent
        const gasPrice = await web3.eth.getGasPrice();
        const gasSpent = new BN(tx.receipt.gasUsed).mul(gasPrice);

        console.log('pending balance', pendingBalance);
        console.log('pending balance', pendingBalance.toString());
        console.log('pending balance', new BN(pendingBalance));
        console.log('pending balance', new BN(pendingBalance).toString());
        console.log('gas spent', gasSpent.toString());

        // expect(balanceAfter.sub(balanceBefore)).to.be.bignumber.gte(pendingBalance.sub(gasSpent));

        // check that pendingBalance is 0
        const pendingBalanceAfter = await nft.pendingWithdrawals(referral);

        console.log('pendingBalanceAfter', pendingBalanceAfter)
        console.log('pendingBalanceAfter', pendingBalanceAfter.toString())

        // expect(pendingBalanceAfter).to.be.bignumber.equal(new BN(0));

    });


    xit("should mint tokens with referral info", async () => {
        const nft = await ReferralNFT.deployed();

        const buyer = accounts[2];
        const referral = accounts[1];
        const amount = 2;

        const price = await nft.getPrice();

        const balanceBefore = await nft.balanceOf(buyer);
        const totalSupplyBefore = await nft.totalSupply();

        await nft.mintReferral(amount, referral, { from: buyer, value: price.muln(amount) });

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