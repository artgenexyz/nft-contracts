const BigNumber = require("bignumber.js");
const delay = require("delay");
const { assert } = require("chai");
const { expectRevert } = require("@openzeppelin/test-helpers");

const { getGasCost } = require("../utils");

const NFTFactory = artifacts.require("ArtNFTFactory");
const ArtNFT = artifacts.require("ArtNFT");
const NFTExtension = artifacts.require("NFTExtension");
const WhitelistMerkleTreeExtension = artifacts.require("WhitelistMerkleTreeExtension");
const MockTokenURIExtension = artifacts.require("MockTokenURIExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");

const ether = new BigNumber(1e18);

contract("ArtNFT – Implementation", accounts => {
    let factory, nft;
    const [owner, user1, user2] = accounts;
    const beneficiary = owner;

    beforeEach(async () => {
        factory = factory || (await NFTFactory.new());

        tx = await factory.createNFT(
            10, // total supply
            500, // 5%
            "ipfs://art-factory-test/",
            "I am Art",
            "ART",
            { value: ether },
        );

        const { deployedAddress } = tx.logs.find(l => l.event === "NFTCreated").args;

        nft = await ArtNFT.at(deployedAddress);
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(nft.address);
    });

    // price should equal 0.03 ether
    it("should have a price of 0.03 ether for tokenid = 1", async () => {
        await nft.sell(1, ether.times(0.03));
        const price = await nft.prices(1);
        assert.equal(price, ether.times(0.03).toString());
    });

    // it should fail to mint when sale is not started
    it("should fail to mint when sale is not started", async () => {

        try {
            await nft.mint(999, { from: accounts[1], value: ether.times(0.03) });
        } catch (error) {
            // check that error message has expected substring 'Token is not for sale'
            assert.include(error.message, "Token is not for sale");
        }
    });
    // it should not be able to start sale when beneficiary is not set
    xit("should fail to start sale when beneficiary is not set", async () => {

        // start sale
        try {
            await nft.startSale({ from: owner });
        } catch (error) {
            // check that error message has expected substring 'Beneficiary not set'
            assert.include(error.message, "Beneficiary not set");
        }
    });

    // it should be able to start sale when beneficiary is set
    it("should be able to start sale when beneficiary is set", async () => {

        // set beneficiary
        // await nft.setBeneficiary(beneficiary, { from: owner });
        // start sale
        await nft.startSale({ from: owner });

        // await delay(100);
        // skip block

        // await mineBlock();

        // check that sale is started
        const isSaleStarted = await nft.saleStarted();
        assert.equal(isSaleStarted, true);
    });

    // it should mint successfully
    it("should mint successfully when sale is started", async () => {
        await nft.startSale({ from: owner });

        await nft.sell(1, ether.times(0.03));
        const price = await nft.prices(1);
        assert.equal(price, ether.times(0.03).toString());

        // mint
        const tx = await nft.mint(1, { from: owner, value: ether.times(0.03) });
        assert.ok(tx);
    });

    // it should withdraw to beneficiary after contract balance is not zero
    it("should withdraw to beneficiary after contract balance is not zero", async () => {
        await nft.startSale({ from: owner });

        await nft.sell(1, ether.times(0.03));
        await nft.sell(2, ether.times(0.03).times(2));

        await nft.mint(1, { from: user2, value: ether });
        await nft.mint(2, { from: user1, value: ether });

        const saleBalance = await web3.eth.getBalance(nft.address);

        assert(new BigNumber(saleBalance).gte(0), "NFT Sale Balance should be non-zero after mint");

        // check beneficiary balance before withdraw
        const beneficiaryBalanceBefore = await web3.eth.getBalance(beneficiary);
        // withdraw
        const tx = await nft.withdraw({ from: owner });
        assert.ok(tx, "Withdraw failed");
        // check beneficiary balance after withdraw
        const beneficiaryBalanceAfter = await web3.eth.getBalance(beneficiary);

        const gasCost = getGasCost(tx);

        const beneficiaryDelta = new BigNumber(beneficiaryBalanceAfter)
            .minus(new BigNumber(beneficiaryBalanceBefore))
            .plus(gasCost)

        // console.log('beneficiaryDelta', beneficiaryBalanceAfter)
        // console.log('beneficiaryDelta', beneficiaryBalanceBefore)
        // console.log('gasCost', gasCost)

        // TODO: turn on this check
        // assert.equal(
        //     beneficiaryDelta.toString(),
        //     saleBalance,
        //     "Beneficiary didn't get money from sales"
        // );

        assert.equal(
            await web3.eth.getBalance(nft.address),
            0,
            "NFT Sale Balance should be zero after withdraw"
        )
    });

    // it should be able to mint 10 tokens in one transaction
    it("should be able to mint different in one transaction", async () => {

        // startSale
        await nft.startSale();

        await nft.sell(1337, ether.times(0.03));

        const tx = await nft.mint(1337, { from: owner, value: ether.times(0.03) });

        assert.ok(tx);
    });

    // it should fail trying to mint more than 20 tokens
    xit("should fail trying to mint more than 20 tokens", async () => {

        // // startSale
        // await nft.startSale();

        // // mint
        // try {
        //     await nft.mint(21, { from: owner, value: 0.03 * 21 * ether });
        // } catch (error) {
        //     // check that error message has expected substring 'You cannot mint more than'
        //     assert.include(error.message, "You cannot mint more than");
        // }
    });

    // it should be able to mint when you send more ether than needed
    it("should be able to mint when you send more ether than needed", async () => {
        // start sale
        await nft.startSale();

        await nft.sell(1, ether.times(0.3));

        // mint
        const tx = await nft.mint(1, { from: owner, value: ether.times(0.5) });
        assert.ok(tx);
    });

    // it should be able to change baseURI from owner account, and _baseURI() value would change
    it("should be able to change baseURI from owner account, and _baseURI() value would change", async () => {

        const baseURI = "https://avatar.com/";
        await nft.setBaseURI(baseURI, { from: owner });
        // mint token
        await nft.startSale();

        await nft.sell(0, ether.times(0.03));

        await nft.mint(0, { from: user1, value: ether.times(0.03).toString() });

        // check tokenURI
        const tokenURI = await nft.tokenURI(0);
        assert.equal(tokenURI, baseURI + "0");

        // check contractURI equals to baseURI
        const contractURI = await nft.contractURI();
        assert.equal(contractURI, baseURI);
    });

    // it is possible to use extension to change tokenURI
    it("is possible to use extension to change tokenURI", async () => {
        const extension = await MockTokenURIExtension.new(nft.address);

        await nft.setExtensionTokenURI(extension.address, { from: owner });

        // mint token
        await nft.startSale();

        await nft.sell(1, ether.times(0.03));
        await nft.mint(1, { from: owner, value: ether.times(0.03) });

        // check tokenURI
        const tokenURI = await nft.tokenURI(0);

        assert.equal(tokenURI, "<svg></svg>");

    });

    // it should be able to mint via LimitSaleExtension
    it("should be able to mint via LimitAmountSaleExtension", async () => {
        const extension = await LimitAmountSaleExtension.new(
            nft.address,
            ether.times(0.001),
            10,
            1000,
            { from: owner }
        );

        await nft.addExtension(extension.address, { from: owner });

        // mint token
        await extension.startSale();
        await extension.mint(2, { from: owner, value: ether });

        // check tokenURI
        const tokenURI = await nft.tokenURI(2);
        assert.equal(tokenURI, "ipfs://art-factory-test/2");

    });

    // it should output royaltyInfo
    it("should output royaltyInfo", async () => {

        const info = await nft.royaltyInfo(0, 10000);

        // info.royaltyReceiver is nft address
        // info.royaltyFee is 5%

        assert.equal(info.receiver, nft.address);
        assert.equal(info.royaltyAmount, 500);

        // it can change 

        await nft.setRoyaltyFee(100);

        const { royaltyAmount } = await nft.royaltyInfo(0, 10000);

        assert.equal(royaltyAmount, 100);

        // it can't change royaltyReceiver
        await expectRevert(
            nft.setRoyaltyReceiver(owner),
            "Only after 6 months of contract creation can the royalty receiver be changed."
        );
    });

    // it should be able to receive royalty
    it("should be able to receive royalty payout", async () => {
        // send ether to nft.address
        await web3.eth.sendTransaction({ from: owner, to: nft.address, value: ether });

        // check balance
        const balance = await web3.eth.getBalance(nft.address);
        assert.equal(balance, ether);
    });

    // it should be able to mint reserved from owner account
    it("should be able to mint reserved from owner account", async () => {

        // mint
        const tx = await nft.claim(3, user2, "0x0", { from: owner });
        assert.ok(tx);

    });

    // it should not be able to mint reserved from accounts other that owner
    it("should not be able to mint reserved from accounts other that owner", async () => {


        // mint
        try {
            await nft.claim(3, accounts[1], "0x0", { from: accounts[1] });
        } catch (error) {
            // check that error message has expected substring Ownable: caller is not the owner
            assert.include(error.message, "Ownable: caller is not the owner");
        }
    });

    // it should not be able to call withdraw from user1
    it("should not be able to call withdraw from user1", async () => {


        await expectRevert(
            nft.withdraw({ from: user1 }),
            "Ownable: caller is not the owner"
        )
    });

    // it should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner
    it("should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner", async () => {
        await nft.startSale({ from: owner });

        // sell
        await nft.sell(1, ether.times(0.03));
        await nft.sell(3, ether.times(0.03));
        await nft.sell(2, ether.times(0.03));

        await nft.mint(1, { from: user2, value: ether.times(0.03) });
        await nft.mint(3, { from: user1, value: ether.times(0.03) });
        await nft.mint(2, { from: user1, value: ether.times(0.03) });

        await delay(500);

        const saleBalance = await web3.eth.getBalance(nft.address);
        const beneficiaryBalance = await web3.eth.getBalance(beneficiary);

        // withdraw
        const tx = await nft.withdraw({ from: owner });
        assert.ok(tx);

        const gasCost = getGasCost(tx);

        const beneficiaryBalanceNow = await web3.eth.getBalance(beneficiary);

        assert.equal(
            new BigNumber(beneficiaryBalanceNow)
                .minus(beneficiaryBalance)
                .plus(gasCost).toString(),

            // without buildship fee
            new BigNumber(saleBalance).times(95).div(100).toString(),
            "Owner should get money from sales, but only 95%"
        );

    });


    xit("should not be able to mint more than 200 tokens, when 200 tokens are minted, it should fail", async () => {
        const tx = await factory.createNFT(
            // "1000000000000000",
            200,
            // 40,
            // 20,
            500, // royalty
            "https://metadata.buildship.dev/",
            "Art Collection NFT", "NFT",
            { value: ether },
        );

        const { deployedAddress } = tx.logs.find(l => l.event === "NFTCreated").args;

        const nft = await ArtNFT.at(deployedAddress);

        await nft.startSale();

        // set price to 0.0001 ether
        await nft.sell(0, ether.times(0.0001));

        // try minting 20 * 20 tokens, which is more than the max allowed (200)
        try {
            await Promise.all(Array(20).fill().map(() =>
                nft.mint(20, { from: owner, value: ether.times(0.0001).times(20) })
            ));
        } catch (error) {
            assert.include(error.message, "Not enough Tokens left");
        }
    })

    // it should be able to add and remove extension
    it("should be able to add and remove extension", async () => {
        const extension = await NFTExtension.new(nft.address);

        await nft.addExtension(extension.address);
        assert.equal(
            await nft.isExtensionAdded(extension.address),
            true,
        );
        // check that extensions(0) is extension address
        assert.equal(await nft.extensions(0), extension.address);

        await nft.revokeExtension(extension.address);

        assert.equal(
            await nft.isExtensionAdded(extension.address),
            false,
        );

    });
})