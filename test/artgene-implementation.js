const { network } = require("hardhat");

const BigNumber = require("bignumber.js");
const delay = require("delay");
const { assert } = require("chai");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { parseEther } = require("ethers").utils;

const { getGasCost, createNFTSale } = require("./utils");

const Artgene721Implementation = artifacts.require("Artgene721Implementation");
const Artgene721Base = artifacts.require("Artgene721Base");
const NFTExtension = artifacts.require("NFTExtension");
const MockRenderer = artifacts.require("MockRenderer");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");
const Artgene721 = artifacts.require("Artgene721");

const { IMPLEMENTATION_ADDRESS, main: getImplementation } = require("../scripts/deploy-proxy.ts");
const { main: getPlatform } = require("../scripts/deploy-platform.ts");

const ether = new BigNumber(1e18);

contract("Artgene721Implementation – Implementation", accounts => {
    let factory, pass, nft;
    const [owner, user1, user2] = accounts;
    const beneficiary = owner;

    before(async () => {
        // check if there is contract code at IMPLEMENTATION_ADDRESS
        const code = await web3.eth.getCode(IMPLEMENTATION_ADDRESS);

        if (code === "0x") {
            await getPlatform();

            await getImplementation();
        }

        assert.notEqual(await web3.eth.getCode(IMPLEMENTATION_ADDRESS), "0x", "No contract code at " + IMPLEMENTATION_ADDRESS);
    });

    beforeEach(async () => {
        if (!pass) {
            pass = await createNFTSale(Artgene721Base);
            await pass.claim(2, owner);
        }

        nft_ = await Artgene721.new(
            "Test",
            "NFT",
            1000,
            3, // reserved
            false,
            "ipfs://factory-test/",
            { 
                publicPrice: parseEther("0.03"),
                maxTokensPerMint: 20,
                maxTokensPerWallet: 0,
                royaltyFee: 500,
                payoutReceiver: owner,
                shouldLockPayoutReceiver: false,
                shouldStartSale: false,
                shouldUseJsonExtension: false
            }
        );

        // const { deployedAddress } = tx.logs.find(l => l.event === "NFTCreated").args;

        nft = await Artgene721Implementation.at(nft_.address);
    });

    // it should deploy successfully
    it("should deploy successfully", async () => {
        assert.ok(nft.address);
    });

    // price should equal 0.03 ether
    it("should have a price of 0.03 ether", async () => {
        const price = await nft.price();
        assert.equal(price, ether.times(0.03).toString());
    });

    // it should fail to mint when sale is not started
    it("should fail to mint when sale is not started", async () => {

        // try {
        //     await nft.mint(1, { from: accounts[1], value: ether.times(0.03) });
        // } catch (error) {
        //     // check that error message has expected substring 'Sale not started'
        //     assert.include(error.message, "Sale not started");
        // }

        await expectRevert(
            nft.mint(1, { from: accounts[1], value: ether.times(0.03) }),
            "Sale not started",
        );
    });

    // it should allow to change payout receiver
    it("should allow to change payout receiver", async () => {

        const receiver = await nft.getPayoutReceiver();

        assert.equal(receiver, owner);

        await nft.setPayoutReceiver(user1, { from: owner });

        const receiver2 = await nft.getPayoutReceiver();

        assert.equal(receiver2, user1);
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
        // mint
        const tx = await nft.mint(1, { from: owner, value: ether.times(0.03) });
        assert.ok(tx);
    });

    // it should withdraw to beneficiary after contract balance is not zero
    it("should withdraw to beneficiary after contract balance is not zero", async () => {
        await nft.startSale({ from: owner });

        await nft.mint(1, { from: user2, value: ether.times(0.03) });
        await nft.mint(2, { from: user1, value: ether.times(0.03).times(2) });

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

    it("should allow artgene to force withdraw", async () => {
        await nft.startSale({ from: owner });

        await nft.mint(1, { from: user2, value: ether.times(0.03) });
        await nft.mint(2, { from: user1, value: ether.times(0.03).times(2) });

        // check nft balance is not zero
        const nftBalance = await web3.eth.getBalance(nft.address);
        assert.notEqual(nftBalance, 0);

        // it should not allow owner to call forceWithdrawDeveloper
        await expectRevert(
            nft.forceWithdrawDeveloper({ from: owner }),
            "Caller is not developer"
        );

        const artgene = "0x3087c429ed4e7e5Cec78D006fCC772ceeaa67f00";

        // send ether to artgene
        await web3.eth.sendTransaction({
            from: owner,
            to: artgene,
            value: ether.times(0.1)
        });

        await network.provider.request({ method: "hardhat_impersonateAccount", params: [artgene] })

        await nft.forceWithdrawDeveloper({ from: artgene });

        const nftBalanceAfter = await web3.eth.getBalance(nft.address);
        assert.equal(nftBalanceAfter, 0);

    });

    // it should be able to mint 10 tokens in one transaction
    it("should be able to mint 10 tokens in one transaction", async () => {

        // startSale
        await nft.startSale();
        // mint
        const nTokens = 10;
        const tx = await nft.mint(nTokens, { from: owner, value: 0.03 * nTokens * ether });
        assert.ok(tx);
    });

    // it should fail trying to mint more than 20 tokens
    it("should fail trying to mint more than 20 tokens", async () => {

        // startSale
        await nft.startSale();

        // mint
        try {
            await nft.mint(21, { from: owner, value: 0.03 * 21 * ether });
        } catch (error) {
            // check that error message has expected substring 'You cannot mint more than'
            assert.include(error.message, "You cannot mint more than");
        }
    });

    // it should be able to mint when you send more ether than needed
    it("should be able to mint when you send more ether than needed", async () => {
        // start sale
        await nft.startSale();

        // mint
        const tx = await nft.mint(1, { from: owner, value: 0.5 * ether });
        assert.ok(tx);
    });

    // it should be able to change baseURI from owner account, and _baseURI() value would change
    it("should be able to change baseURI from owner account, and _baseURI() value would change", async () => {

        const baseURI = "https://avatar.com/";
        await nft.setBaseURI(baseURI, { from: owner });
        // mint token
        await nft.startSale();
        await nft.mint(1, { from: owner, value: ether.times(0.03) });
        // check tokenURI
        const tokenURI = await nft.tokenURI(0);
        assert.equal(tokenURI, baseURI + "0");

        // check contractURI equals to baseURI
        const contractURI = await nft.contractURI();
        assert.equal(contractURI, baseURI);
    });

    // it is possible to use extension to change tokenURI
    it("is possible to use extension to change tokenURI", async () => {
        const extension = await MockRenderer.new(nft.address);

        await nft.setRenderer(extension.address, { from: owner });

        // mint token
        await nft.startSale();
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
        await extension.mint(2, { from: owner, value: ether.times(0.03) });

        // check tokenURI
        const tokenURI = await nft.tokenURI(0);
        assert.equal(tokenURI, "ipfs://factory-test/0");

    });

    // it should output royaltyInfo
    it("should output royaltyInfo", async () => {

        const info = await nft.royaltyInfo(0, 10000);

        // info.royaltyReceiver is nft address
        // info.royaltyFee is 5%

        assert.equal(info.receiver, await nft.owner());
        assert.equal(info.royaltyAmount, 500);

        // it can change 

        await nft.setRoyaltyFee(100);

        const { royaltyAmount } = await nft.royaltyInfo(0, 10000);

        assert.equal(royaltyAmount, 100);

        // it can change royaltyReceiver
        await nft.setRoyaltyReceiver(owner)

        const { receiver } = await nft.royaltyInfo(0, 10000);
        assert.equal(receiver, owner);

        // TODO: temporarily disabled
        // await expectRevert(
        //     "Only after 6 months of contract creation can the royalty receiver be changed."
        // );
    });

    // it should be able to mint reserved from owner account
    it("should be able to mint reserved from owner account", async () => {

        // mint
        const tx = await nft.claim(3, accounts[1], { from: owner });
        assert.ok(tx);
    });

    // it should not be able to mint reserved from accounts other that owner
    it("should not be able to mint reserved from accounts other that owner", async () => {


        // mint
        try {
            await nft.claim(3, accounts[1], { from: accounts[1] });
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

        await nft.mint(1, { from: user2, value: ether.times(0.03) });
        await nft.mint(3, { from: user1, value: ether.times(0.03).times(3) });
        await nft.mint(2, { from: user1, value: ether.times(0.03).times(2) });

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

            // without artgene fee
            new BigNumber(saleBalance).times(95).div(100).toString(),
            "Owner should get money from sales, but only 95%"
        );

    });


    it("should not be able to mint more than 200 tokens, when 200 tokens are minted, it should fail", async () => {
        const nft_ = await Artgene721.new(
            "Test",
            "NFT",
            200,
            40, // reserved
            false,
            "ipfs://factory-test/",
            {
                publicPrice: parseEther("0.03"),
                maxTokensPerMint: 20,
                maxTokensPerWallet: 0,
                royaltyFee: 500,
                payoutReceiver: owner,
                shouldLockPayoutReceiver: false,
                shouldStartSale: false,
                shouldUseJsonExtension: false
            }
        );

        const nft = await Artgene721Implementation.at(nft_.address);

        await nft.startSale();

        await nft.updateMaxPerWallet(0);

        // set price to 0.0001 ether
        await nft.setPrice(ether.times(0.0001));

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
        const extension2 = await NFTExtension.new(nft.address);
        const extension3 = await NFTExtension.new(nft.address);

        await nft.addExtension(extension.address);
        await nft.addExtension(extension2.address);
        await nft.addExtension(extension3.address);

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

        await nft.revokeExtension(extension3.address);

        assert.equal(
            await nft.isExtensionAdded(extension3.address),
            false,
        );

        assert.equal(
            await nft.isExtensionAdded(extension2.address),
            true,
        );

    });

    // it should be able to reduce supply minting
    it("should be able to reduce supply and then mint doesnt work", async () => {
        await nft.reduceMaxSupply(10);
        await nft.startSale();

        await nft.mint(5, { value: ether });
        await nft.claim(3, user1);

        try {
            await nft.mint(5, { value: ether });

        } catch (error) {
            assert.include(error.message, "Not enough Tokens left.");
        }
    });

    // it should not be able to reduce max supply more than possible
    it("should not be able to reduce max supply more than possible", async () => {
        await nft.claim(3, user2);

        await nft.startSale();
        await nft.mint(10, { from: user2, value: ether });

        await expectRevert(nft.reduceMaxSupply(300), "Sale should not be started");

        await nft.stopSale();

        await expectRevert(nft.reduceMaxSupply(10), "Max supply is too low, already minted more (+ reserved)");

        await expectRevert(nft.reduceMaxSupply(1337), "Cannot set higher than the current maxSupply");

    })

    // it should be able to set maxPerWallet
    it("should be able to set maxPerWallet", async () => {
        await nft.updateMaxPerWallet(10);
        assert.equal(await nft.maxPerWallet(), 10);
    })

    // it should not be able to mint more than maxPerWallet if set
    it("should not be able to mint more than maxPerWallet if set", async () => {
        await nft.updateMaxPerWallet(10);
        await nft.startSale();

        await nft.mint(4, { from: user1, value: ether.times(0.03).times(4) });
        await nft.mint(4, { from: user1, value: ether.times(0.03).times(4) });

        try {
            await nft.mint(4, { from: user1, value: ether.times(0.03).times(4) });
        } catch (error) {
            assert.include(error.message, "You cannot mint more than maxPerWallet tokens for one address!");
        }
    });

    // it should be able to mint more than maxPerWallet if user transfers
    it("cannot trick maxPerWallet if user transfers to second address temporary", async () => {
        await nft.updateMaxPerWallet(10);
        await nft.startSale();

        await nft.mint(4, { from: user1, value: ether.times(0.03).times(4) });
        await nft.mint(4, { from: user1, value: ether.times(0.03).times(4) });

        // temporary transfer token ids 0,1 to second address
        await nft.transferFrom(user1, user2, 0, { from: user1 });
        await nft.transferFrom(user1, user2, 1, { from: user1 });

        // minting 4 + 4 + 4 tokens for user1+user2
        expectRevert(
            nft.mint(4, { from: user1, value: ether.times(0.03).times(4) }),
            "You cannot mint more than maxPerWallet tokens for one address!"
        );

        // transfer back original tokens
        await nft.transferFrom(user2, user1, 0, { from: user2 });
        await nft.transferFrom(user2, user1, 1, { from: user2 });

        assert.notEqual(await nft.balanceOf(user1), 12);
        assert.equal(await nft.balanceOf(user1), 8);
        assert.equal(await nft.balanceOf(user2), 0);
    });

    // it should be able to update maxPerMint, but not more than MAX_PER_MINT_LIMIT
    it("should be able to update maxPerMint, but not more than MAX_PER_MINT_LIMIT", async () => {
        await nft.updateMaxPerMint(10);
        assert.equal(await nft.maxPerMint(), 10);

        expectRevert(
            nft.updateMaxPerMint(100),
            "Too many tokens per mint",
        );
    });

    // it should autoapprove opensea
    it("should autoapprove opensea", async () => {
        const conduit = "0x1E0049783F008A0085193E00003D00cd54003c71";

        // check isApprovedForAll
        assert.equal(await nft.isApprovedForAll(owner, conduit), true);
    });

})
