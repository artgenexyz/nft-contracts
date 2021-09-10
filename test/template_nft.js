const TemplateNFT = artifacts.require("TemplateNFT");

const ether = 1e18;

contract("TemplateNFT", accounts => {
    // it should deploy successfully
    it("should deploy successfully", async () => {
        const nft = await TemplateNFT.deployed();
        assert.ok(nft.address);
    });

    // price should equal 1 ether
    it("should have a price of 1 ether", async () => {
        const nft = await TemplateNFT.deployed();
        const price = await nft.getPrice();
        assert.equal(price, (1 * ether).toString());
    });

    // it should fail to mint when sale is not started
    it("should fail to mint when sale is not started", async () => {
        const nft = await TemplateNFT.deployed();
        // mint
        try {
            await nft.mint(1, { from: accounts[1], value: 1 * ether });
        } catch (error) {
            // check that error message has expected substring 'Sale not started'
            assert.include(error.message, "Sale not started");
        }
    });

    // it should mint successfully
    it("should mint successfully when sale is started", async () => {
        const nft = await TemplateNFT.deployed();
        // flipSaleStarted
        await nft.flipSaleStarted();
        // mint
        const tx = await nft.mint(1, { from: accounts[0], value: 1 * ether });
        assert.ok(tx);
    });

    // it should be able to mint 10 tokens in one transaction
    it("should be able to mint 10 tokens in one transaction", async () => {
        const nft = await TemplateNFT.deployed();
        // flipSaleStarted
        // await nft.flipSaleStarted();
        // mint
        const nTokens = 10;
        const tx = await nft.mint(nTokens, { from: accounts[0], value: 1 * nTokens * ether });
        assert.ok(tx);
    });

    // it should fail trying to mint more than 20 tokens
    it("should fail trying to mint more than 20 tokens", async () => {
        const nft = await TemplateNFT.deployed();

        // mint
        try {
            await nft.mint(21, { from: accounts[0], value: 1 * 21 * ether });
        } catch (error) {
            // check that error message has expected substring 'You cannot mint more than'
            assert.include(error.message, "You cannot mint more than");
        }
    });

    // it should be able to mint when you send more ether than needed
    it("should be able to mint when you send more ether than needed", async () => {
        const nft = await TemplateNFT.deployed();

        // mint
        const tx = await nft.mint(1, { from: accounts[0], value: 1.5 * ether });
        assert.ok(tx);
    });

    // it should be able to change baseURI from owner account, and _baseURI() value would change
    it("should be able to change baseURI from owner account, and _baseURI() value would change", async () => {
        const nft = await TemplateNFT.deployed();

        const baseURI = "https://avatar.com/";
        await nft.setBaseURI(baseURI, { from: accounts[0] });
        // check _baseURI() value
        const _baseURI = await nft.baseURI();
        assert.equal(_baseURI, baseURI);
    });

    // it should be able to mint reserved from owner account
    it("should be able to mint reserved from owner account", async () => {
        const nft = await TemplateNFT.deployed();

        // mint
        const tx = await nft.claimReserved(3, accounts[1], { from: accounts[0] });
        assert.ok(tx);
    });

    // it should not be able to mint reserved from accounts other that owner
    it("should not be able to mint reserved from accounts other that owner", async () => {
        const nft = await TemplateNFT.deployed();

        // mint
        try {
            await nft.claimReserved(3, accounts[1], { from: accounts[1] });
        } catch (error) {
            // check that error message has expected substring Ownable: caller is not the owner
            assert.include(error.message, "Ownable: caller is not the owner");
        }
    });

    // // when 10000 tokens are minted, it should fail
    // it("when 10000 tokens are minted, it should fail", async () => {
    //     const nft = await TemplateNFT.deployed();

    //     // mint
    //     try {
    //         // try minting 20000 tokens, which is more than the max allowed
    //         for (let i = 0; i < 1000; i++) {
    //             await nft.mint(20, { from: accounts[0], value: 1 * 20 * ether });
    //         }
    //     } catch (error) {
    //         // check that error message has expected substring 'You cannot mint more than'
    //         assert.include(error.message, "You cannot mint more than");
    //     }
    // })

})