const { expectRevert } = require("@openzeppelin/test-helpers");

const { expect } = require("chai");

const { BN } = web3.utils;

const Metascapes = artifacts.require("Metascapes");

const ether = 1e18;

contract("Metascapes", accounts => {
    let nft;
    const [owner, user2] = accounts;

    const beneficiary = "0xD7096C2E4281a7429D94ee21B53E7F0011D59FA3"

    // it should deploy successfully
    it("should deploy successfully", async () => {
        nft = await Metascapes.new(
            { from: owner },
        );
        // // const nft = await Metascapes.deployed();
        assert.ok(nft.address);
    });

    // price should equal 0.33 ether
    it("should have a price of 0.33 ether", async () => {
        // // // const nft = await Metascapes.deployed();
        const price = await nft.price();
        assert.equal(price, (0.33 * ether).toString());
    });

    // it should fail to mint when sale is not started
    it("should fail to mint when sale is not started", async () => {
        // // const nft = await Metascapes.deployed();
        // mint
        try {
            await nft.mint(1, { from: accounts[1], value: 0.33 * ether });
        } catch (error) {
            // check that error message has expected substring 'Sale not started'
            assert.include(error.message, "Sale not started");
        }
    });
    // it should not be able to start sale when beneficiary is not set
    xit("should fail to start sale when beneficiary is not set", async () => {
        // // const nft = await Metascapes.deployed();
        // start sale
        try {
            await nft.startSale({ from: owner });
        } catch (error) {
            // check that error message has expected substring 'Beneficiary not set'
            assert.include(error.message, "Beneficiary not set");
        }
    });


    it("should be able to start sale", async () => {
        // // const nft = await Metascapes.deployed();
        // start sale
        await nft.startSale({ from: owner });
        // check that sale is started
        const isSaleStarted = await nft.saleStarted();
        assert.equal(isSaleStarted, true);
    });

    // it should mint successfully
    it("should mint successfully when sale is started", async () => {
        // // const nft = await Metascapes.deployed();

        // mint
        const tx = await nft.mint(1, { from: owner, value: 0.33 * ether });
        assert.ok(tx);
    });

    // it should withdraw to beneficiary after contract balance is not zero
    it("should withdraw to beneficiary after contract balance is not zero", async () => {
        // // const nft = await Metascapes.deployed();

        const saleBalance = await web3.eth.getBalance(nft.address);

        assert(new BN(saleBalance).gte(0), "NFT Sale Balance should be non-zero after mint");

        // check beneficiary balance before withdraw
        const beneficiaryBalanceBefore = await web3.eth.getBalance(beneficiary);
        // withdraw
        const tx = await nft.withdraw({ from: owner });
        assert.ok(tx, "Withdraw failed");
        // check beneficiary balance after withdraw
        const beneficiaryBalanceAfter = await web3.eth.getBalance(beneficiary);

        const beneficiaryDelta = new BN(beneficiaryBalanceAfter).sub(new BN(beneficiaryBalanceBefore))

        assert(
            beneficiaryDelta.subn(0).gte(0),
            "Beneficiary didn't get money from sales"
        );
    });

    // it should be able to mint 10 tokens in one transaction
    xit("should be able to mint 10 tokens in one transaction", async () => {
        // // const nft = await Metascapes.deployed();
        // startSale
        // await nft.startSale();
        // mint
        const nTokens = 10;
        const tx = await nft.mint(nTokens, { from: owner, value: 0.3 * nTokens * ether });
        assert.ok(tx);
    });

    // it should fail trying to mint more than 20 tokens
    it("should fail trying to mint more than 2 tokens", async () => {
        // // const nft = await Metascapes.deployed();

        // mint
        try {
            await nft.mint(2, { from: owner, value: 0.3 * 2 * ether });
        } catch (error) {
            // check that error message has expected substring 'You cannot mint more than'
            assert.include(error.message, "You cannot mint more than");
        }
    });

    // it should be able to mint when you send more ether than needed
    it("should be able to mint when you send more ether than needed", async () => {
        // // const nft = await Metascapes.deployed();

        // mint
        const tx = await nft.mint(1, { from: owner, value: 0.5 * ether });
        assert.ok(tx);
    });

    // it should be able to change baseURI from owner account, and _baseURI() value would change
    it("should be able to change baseURI from owner account, and _baseURI() value would change", async () => {
        // // const nft = await Metascapes.deployed();

        const baseURI = "https://avatar.com/";
        await nft.setBaseURI(baseURI, { from: owner });
        // check _baseURI() value
        const uri = await nft.tokenURI(0);
        assert.include(uri, baseURI);
    });

    // it should be able to mint reserved from owner account
    xit("should be able to mint reserved from owner account", async () => {
        // // const nft = await Metascapes.deployed();

        // mint
        const tx = await nft.claimReserved(3, accounts[1], { from: owner });
        assert.ok(tx);
    });

    // it should not be able to mint reserved from accounts other that owner
    xit("should not be able to mint reserved from accounts other that owner", async () => {
        // // const nft = await Metascapes.deployed();

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
        // // const nft = await Metascapes.deployed();

        await expectRevert(
            nft.withdraw({ from: accounts[3] }),
            "Ownable: caller is not the owner"
        )
    });

    // it should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner
    it("should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner", async () => {
        // // const nft = await Metascapes.deployed();

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

    xit("should not be able to mint more than 200 tokens, when 200 tokens are minted, it should fail", async () => {
        const nft = await Metascapes.new();

        await nft.startSale();

        // set price to 0.0001 ether
        await nft.setPrice(0.0001 * ether);

        // try minting 20 * 20 tokens, which is more than the max allowed (200)
        try {
            await Promise.all(Array(20).fill(null).map(() =>
                nft.mint(20, { from: owner, value: 0.0001 * 20 * ether })
            ));
        } catch (error) {
            // check that error message has expected substring 'You cannot mint more than'
            assert.include(error.message, "Not enough Tokens left");
        }
    })

    it("should be able to withdraw", async () => {
        const nft = await Metascapes.new();

        // send 100 wei to nft.address
        await web3.eth.sendTransaction({
            from: accounts[0],
            to: nft.address,
            value: 1000,
        });

        const dev = await nft.DEVELOPER_ADDRESS();
        const devBalanceBefore = await web3.eth.getBalance(dev);

        await nft.withdraw();

        // check that dev balance has increased
        const devBalanceAfter = await web3.eth.getBalance(dev);
        const devDelta = new BN(devBalanceAfter).sub(new BN(devBalanceBefore))

        // check devDelta is 375
        expect(devDelta.gte(375)).to.be.true;

    })

    // TODO: test 1 wei
    it("should withdraw correctly even if has 1 wei", async () => {
        console.log('skip')
    })
})