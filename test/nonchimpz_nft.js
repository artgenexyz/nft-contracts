const { expectRevert } = require("@openzeppelin/test-helpers");
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");

const { expect } = require("chai");

const { BN } = web3.utils;

const AvatarNFT = artifacts.require("AvatarNFT");
const NonChimpzNFT = artifacts.require("NonChimpzNFT");

const ether = 1e18;

contract("NonChimpzNFT", accounts => {
    let nft;
    const [ owner, beneficiary, user2 ] = accounts;

    // it should deploy successfully
    it("should deploy successfully", async () => {
        // const nft = await AvatarNFT.deployed();
        nft = await NonChimpzNFT.new();
        assert.ok(nft.address);
    });

    // price should equal 0.0555 ether
    it("should have a price of 0.0555 ether", async () => {
        // const nft = await AvatarNFT.deployed();
        const price = await nft.getPrice();
        assert.equal(price, (0.0555 * ether).toString());
    });

    // it should fail to mint when sale is not started
    it("should fail to mint when sale is not started", async () => {
        // const nft = await AvatarNFT.deployed();
        // mint
        try {
            await nft.mint(1, { from: accounts[1], value: 0.0555* ether });
        } catch (error) {
            // check that error message has expected substring 'Sale not started'
            assert.include(error.message, "Sale not started");
        }
    });
    // it should not be able to start sale when beneficiary is not set
    it("should fail to start sale when beneficiary is not set", async () => {
        // const nft = await AvatarNFT.deployed();
        // start sale
        try {
            await nft.flipSaleStarted({ from: owner });
        } catch (error) {
            // check that error message has expected substring 'Beneficiary not set'
            assert.include(error.message, "Beneficiary not set");
        }
    });

    // it should be able to start sale when beneficiary is set
    it("should be able to start sale when beneficiary is set", async () => {
        // const nft = await AvatarNFT.deployed();
        // set beneficiary
        await nft.setBeneficiary(beneficiary, { from: owner });
        // start sale
        await nft.flipSaleStarted({ from: owner });
        // check that sale is started
        const isSaleStarted = await nft.saleStarted();
        assert.equal(isSaleStarted, true);
    });

    // it can change beneficiary
    it("can change beneficiary", async () => {

        // change back
        await nft.setBeneficiary(user2, { from: owner });

        // change back
        await nft.setBeneficiary(beneficiary, { from: owner });

    });

    // it should mint successfully
    it("should mint successfully when sale is started", async () => {
        // const nft = await AvatarNFT.deployed();

        // mint
        const tx = await nft.mint(1, { from: owner, value: 0.0555* ether });
        assert.ok(tx);
    });

    // it should withdraw partial amount (0.01) to beneficiary
    it("should withdraw partial amount (0.01) to beneficiary", async () => {
        // const nft = await AvatarNFT.deployed();

        const saleBalance = await web3.eth.getBalance(nft.address);
        const buildship = await nft.DEVELOPER_ADDRESS();

        assert(
            new BN(saleBalance).gte(0),
            "NFT Sale Balance should be non-zero after mint"
        );

        // check beneficiary balance before withdraw
        const beneficiaryBalanceBefore = await web3.eth.getBalance(beneficiary);
        const buildshipBalanceBefore = await web3.eth.getBalance(buildship);

        // withdraw
        const tx = await nft.withdrawAmount((1e16).toString(), { from: owner });

        assert.ok(tx, "Withdraw failed");
        // check beneficiary balance after withdraw
        const beneficiaryBalanceAfter = await web3.eth.getBalance(beneficiary);
        const buildshipBalanceAfter = await web3.eth.getBalance(buildship);

        const beneficiaryDelta = new BN(beneficiaryBalanceAfter)
          .sub(new BN(beneficiaryBalanceBefore))

        const buildshipDelta = new BN(buildshipBalanceAfter)
          .sub(new BN(buildshipBalanceBefore))

        // assert.isAbove(
        //   beneficiaryDelta.toString(),
        //   0,
        //   "Beneficiary didn't get money from sales"
        // );

        assert.equal(
          beneficiaryDelta.toString(),
          new BN((1e16).toString()).muln(95).divn(100).toString(),
          "Beneficiary didn't get his cut"
        );

        assert.equal(
          buildshipDelta.toString(),
          new BN((1e16).toString()).muln(5).divn(100).toString(),
          "Buildship didn't get his cut"
        );

    });

    // it should withdraw to beneficiary after contract balance is not zero
    it("should withdraw to beneficiary after contract balance is not zero", async () => {
        // const nft = await AvatarNFT.deployed();

        const saleBalance = await web3.eth.getBalance(nft.address);
        const buildship = await nft.DEVELOPER_ADDRESS();

        assert(new BN(saleBalance).gte(0), "NFT Sale Balance should be non-zero after mint");

        // check beneficiary balance before withdraw
        const beneficiaryBalanceBefore = await web3.eth.getBalance(beneficiary);
        const buildshipBalanceBefore = await web3.eth.getBalance(buildship);

        // withdraw
        const tx = await nft.withdraw({ from: owner });
        assert.ok(tx, "Withdraw failed");
        // check beneficiary balance after withdraw
        const beneficiaryBalanceAfter = await web3.eth.getBalance(beneficiary);
        const buildshipBalanceAfter = await web3.eth.getBalance(buildship);

        const beneficiaryDelta = new BN(beneficiaryBalanceAfter).sub(new BN(beneficiaryBalanceBefore)).toString()
        const buildshipDelta = new BN(buildshipBalanceAfter).sub(new BN(buildshipBalanceBefore)).toString()

        // assert.isAbove(
        //     beneficiaryDelta,
        //     0,
        //     "Beneficiary didn't get money from sales"
        // );

        assert.equal(
          beneficiaryDelta,
          new BN(saleBalance).muln(95).divn(100),
          "Beneficiary didn't get his cut"
        );

        assert.equal(
          buildshipDelta,
          new BN(saleBalance).muln(5).divn(100),
          "Buildship didn't get his cut"
        );

    });

    // it should be able to mint 10 tokens in one transaction
    it("should be able to mint 10 tokens in one transaction", async () => {
        // const nft = await AvatarNFT.deployed();
        // flipSaleStarted
        // await nft.flipSaleStarted();
        // mint
        const nTokens = 10;
        const tx = await nft.mint(nTokens, { from: owner, value: 0.0555 * nTokens * ether });
        assert.ok(tx);
    });

    // it should fail trying to mint more than 20 tokens
    it("should fail trying to mint more than 20 tokens", async () => {
        // const nft = await AvatarNFT.deployed();

        // mint
        try {
            await nft.mint(21, { from: owner, value: 0.0555 * 21 * ether });
        } catch (error) {
            // check that error message has expected substring 'You cannot mint more than'
            assert.include(error.message, "You cannot mint more than");
        }
    });

    // it should be able to mint when you send more ether than needed
    it("should be able to mint when you send more ether than needed", async () => {
        // const nft = await AvatarNFT.deployed();

        // mint
        const tx = await nft.mint(1, { from: owner, value: 0.5 * ether });
        assert.ok(tx);
    });

    // it should be able to change baseURI from owner account, and _baseURI() value would change
    it("should be able to change baseURI from owner account, and _baseURI() value would change", async () => {
        // const nft = await AvatarNFT.deployed();

        const baseURI = "https://avatar.com/";
        await nft.setBaseURI(baseURI, { from: owner });
        // check _baseURI() value
        const _baseURI = await nft.baseURI();
        assert.equal(_baseURI, baseURI);
    });

    // it should be able to mint reserved from owner account
    // NonChimpz doesn't have any reserved
    xit("should be able to mint reserved from owner account", async () => {
        // const nft = await AvatarNFT.deployed();

        // mint
        const tx = await nft.claimReserved(3, accounts[1], { from: owner });
        assert.ok(tx);
    });

    // it should not be able to mint reserved from accounts other that owner
    it("should not be able to mint reserved from accounts other that owner", async () => {
        // const nft = await AvatarNFT.deployed();

        // mint
        try {
            await nft.claimReserved(3, accounts[1], { from: accounts[1] });
        } catch (error) {
            // check that error message has expected substring Ownable: caller is not the owner
            assert.include(error.message, "Ownable: caller is not the owner");
        }
    });

    // it should not be able to call withdraw from beneficiary
    it("should not be able to call withdraw from beneficiary", async () => {
        // const nft = await AvatarNFT.deployed();

        await expectRevert(
            nft.withdraw({ from: beneficiary }),
            "Ownable: caller is not the owner"
        )
    });

    // it should revert if you try to withdraw 2% more than balance
    it("should revert if you try to withdraw 2% more than balance", async () => {

        const saleBalance = await web3.eth.getBalance(nft.address);

        // print saleBalance, amount, and amount * 95% with labels

        const amount = new BN(saleBalance).muln(102).divn(100);

        // we try to withdraw amount, so that amount * 95% < saleBalance, but amount > saleBalance
        // this checks whether buildship gets his share FOR SURE

        console.log("saleBalance:", saleBalance);
        console.log("amount:", amount.toString());
        console.log("amount * 95%:", amount.muln(95).divn(100).toString());

        // withdraw
        await expectRevert(
          nft.withdrawAmount(amount, { from: owner }),
          "Failed to send funds to developer"
        );

    });



    // it should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner
    it("should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner", async () => {
        // const nft = await AvatarNFT.deployed();

        // save owner's balance and beneficiary's balance before withdraw
        const ownerBalance = await web3.eth.getBalance(owner);
        const beneficiaryBalance = await web3.eth.getBalance(beneficiary);

        // we have already setBeneficiary in the start

        // withdraw
        const tx = await nft.withdraw({ from: owner });
        assert.ok(tx);

        const ownerBalanceNow = await web3.eth.getBalance(owner);

        // check that owner balance has not increased (but he paid for gas)
        expect(
            new BN(ownerBalanceNow).sub(new BN(ownerBalance)).toNumber()
        ).to.be.below(0, "Owner shouldnt get money from sales");

        // check that beneficiary balance has increased
        const beneficiaryBalanceNow = await web3.eth.getBalance(beneficiary);
        const beneficiaryDelta = new BN(beneficiaryBalanceNow).sub(new BN(beneficiaryBalance))

        expect(beneficiaryDelta.gte(0)).to.be.true; // (0, "Beneficiary should get money from sales");

    });

    xit("should not be able to mint all 17777 tokens, when 17777 tokens are minted, it should fail", async () => {
        // set price to 0.00001 ether
        await nft.setPrice(0.00001 * ether);

        // try minting 3 * 3000 tokens, which is allowed (10_000)
        await Promise.all(Array(3).fill().map(() =>
            nft.mint(3000, { from: user2, value: 0.00001 * 3000 * ether })
        ));

        // try minting again 3 * 3000 tokens, which is more than the max allowed (9_000 + 9_000 > 17_777)
        try {
            await Promise.all(Array(3).fill().map(() =>
                nft.mint(3000, { from: user2, value: 0.00001 * 3000 * ether })
            ));
        } catch (error) {
            // check that error message has expected substring 'You cannot mint more than'
            assert.include(error.message, "Not enough Tokens left");
        }
    })
})