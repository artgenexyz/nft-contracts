const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert } = require("chai");

// const { assert } = require("chai");

const AmeegosMintPass = artifacts.require("AmeegosMintPass");
const AmeegosNFT = artifacts.require("AmeegosNFT");

const AMEEGOS_ADMIN = "0x44244acaCD0B008004F308216f791F2EBE4C4C50";
const AMEEGOS_CONTRACT = "0xF522B448DbF8884038c684B5c3De95654007Fd2B";

const help = `
Before running this test, make sure you have a ganache-cli instance running on port 8545.

It needs to be unlocked with the address 0x44244acaCD0B008004f308216f791f2ebe4c4c50, and run in the mainnet fork.

You can do this by running:

    npx ganache-cli --fork https://mainnet.infura.io/v3/${process.env.INFURA_KEY} --unlock ${AMEEGOS_ADMIN}

`

contract("Ameegos Mint Pass – mainnet fork", function (accounts) {
    const [ owner, user1, user2, user3, user4, hector ] = accounts;

    let nft, pass, unlocked;

    it("should be on mainnet fork", async function () {
        const networkType = await web3.eth.net.getNetworkType();

        console.log('Running on', networkType);
        console.log(help);

        // assert.equal(networkType, "main", "should run on mainnet fork");
    });

    // it should attach to AmeegosNFT on mainnet
    it("should attach to AmeegosNFT on mainnet", async function () {
        const networkType = await web3.eth.net.getNetworkType();

        if (networkType === "main") {
            nft = await AmeegosNFT.at(AMEEGOS_CONTRACT);
            assert.equal(nft.address, AMEEGOS_CONTRACT, "should attach to AmeegosNFT on mainnet");

            unlocked = AMEEGOS_ADMIN;

            const owner = await nft.owner();
            assert.equal(owner, unlocked, "owner should be 0x4424");
        }
    });

    it("should create new AmeegosNFT on testnet", async function () {
        const networkType = await web3.eth.net.getNetworkType();

        if (networkType === "private") {
            nft = await AmeegosNFT.new("Ameegos Metaverse", "AMEEGOS", "uri://test", "uri://test");

            unlocked = hector;

            await nft.transferOwnership(unlocked);
        }
    });

    // it should control AmeegosNFT from owner account
    it("should control AmeegosNFT from owner account", async function () {
        // try pause(true) / pause(false) from unlocked, and .paused should change accordingly
        await nft.pause(true, { from: unlocked });

        const paused = await nft.paused();
        assert.equal(paused, true, "should be paused");

        await nft.pause(false, { from: unlocked });

        const paused2 = await nft.paused();
        assert.equal(paused2, false, "should not be paused");

        await nft.withdraw({ from: unlocked });
    });

    // it should deploy mint pass
    it("should deploy mint pass", async function () {
        pass = await AmeegosMintPass.new(nft.address);

        await pass.flipSaleStarted();

        await pass.claim(1, { from: user2 });

    });

    // it should be able to start sale for mint pass
    it("should be able to start sale for mint pass", async function () {
        // THIS IS THE MOST IMPORTANT PART:
        // Run these on mainnet:

        await nft.whitelistUsers([pass.address], { from: unlocked });
        await nft.setOnlyWhitelisted(true, { from: unlocked });
        await nft.setNftPerAddressLimit(6000, { from: unlocked }); // because MintPass needs to be able to mint from their address
        await nft.setmaxMintAmount(10, { from: unlocked }); // because MintPass needs to be able to mint from their address
        await nft.pause(false, { from: unlocked });

        // await nft.setmaxMintAmount(3, { from: unlocked });

        const user2NFTBefore = await nft.balanceOf(user2);

        const cost = await nft.cost();

        // truffle debug https://www.trufflesuite.com/docs/truffle/getting-started/debugging-your-contracts#in-test-debugging
        await pass.redeem(1, { from: user2, value: cost });

        const balance = await nft.balanceOf(pass.address);
        // assert.equal(balance, 1, "should mint 1 token");

        console.log('balance', balance.toString());

        const tokenIds = [];

        for (let i = 0; i < balance; i++) {
            const tokenId = await nft.tokenOfOwnerByIndex(pass.address, i)

            console.log('tokenId', i, tokenId.toString());

            tokenIds.push(tokenId);

        }

        console.log('tokenIds', tokenIds.map(x => x.toString()));

        // check that user2 has NFT now
        // check that pass contract doesn't have any tokens

        // await pass.emergencyWithdraw(user2);

        const passNFTbalance = await nft.balanceOf(pass.address);
        assert.equal(passNFTbalance, 0, "pass should have 0 NFT");

        const user2NFT = await nft.balanceOf(user2);
        assert.equal(user2NFT - user2NFTBefore, 1, "user2 should have 1 new NFT");


    });

    // it shouldn't be able to mint from user2 directly on nft
    it("shouldn't be able to mint from user2 directly on nft", async function () {
        await expectRevert(
            nft.mint(1, { from: user2 }),
            "user is not whitelisted"
        );
    });

    // it should allow user1, user2, user3, user4 to use mint pass and mint up to 3 nft each, but more than 10 in total
    it("should allow user1, user2, user3, user4 to use mint pass and mint up to 3 nft each", async function () {
        const cost = await nft.cost();

        const user1NFTBefore = await nft.balanceOf(user1);

        await pass.claim(10, { from: user1 });
        await pass.redeem(3, { from: user1, value: cost * 3 });

        const user1NFT = await nft.balanceOf(user1);
        assert.equal(user1NFT - user1NFTBefore, 3, "user1 should have 3 new NFT");

        const user2NFTBefore = await nft.balanceOf(user2);

        await pass.claim(10 - 1, { from: user2 }); // because user2 already had 1 mint pass used
        await pass.redeem(3, { from: user2, value: cost * 3 });

        const user2NFT = await nft.balanceOf(user2);
        assert.equal(user2NFT - user2NFTBefore, 3, "user2 should have 3 new NFT");

        const user3NFTBefore = await nft.balanceOf(user3);

        await pass.claim(10, { from: user3 });
        await pass.redeem(3, { from: user3, value: cost * 3 });

        const user3NFT = await nft.balanceOf(user3);
        assert.equal(user3NFT - user3NFTBefore, 3, "user3 should have 3 new NFT");

        const user4NFTBefore = await nft.balanceOf(user4);

        await pass.claim(10, { from: user4 });
        await pass.redeem(3, { from: user4, value: cost * 3 });

        const user4NFT = await nft.balanceOf(user4);
        assert.equal(user4NFT - user4NFTBefore, 3, "user4 should have 3 new NFT");

        const passNFTbalance = await nft.balanceOf(pass.address);
        assert.equal(passNFTbalance, 0, "pass should have 0 NFT");
    });

    // it should fail if you try to mint more than 3 
    it("should fail if you try to mint more than 3", async function () {
        const cost = await nft.cost();

        await nft.setmaxMintAmount(3, { from: unlocked }); // because MintPass needs to be able to mint from their address

        // // check that user1 still has at least 4 mint passes, otherwise test will fail due to other error
        // const user1MintPasses = await pass.balanceOf(user1);
        // assert.equal(user1MintPasses, 4, "user1 should have 4 MintPasses");

        await expectRevert(
            pass.redeem(4, { from: user1, value: cost * 4 }),
            "max mint amount per session exceeded"
        );

        await nft.setmaxMintAmount(10, { from: unlocked }); // because MintPass needs to be able to mint from their address

    });

    // it should bring everything back to normal
    it("should bring everything back to normal", async function () {
        await nft.whitelistUsers([], { from: unlocked });
        await nft.setNftPerAddressLimit(10, { from: unlocked });
        await nft.setOnlyWhitelisted(false, { from: unlocked });

        // test that direct sale now works
        const user2NFTBefore = await nft.balanceOf(user2);

        const cost = await nft.cost();
        await nft.mint(1, { from: user2, value: cost });

        const user2NFTAfter = await nft.balanceOf(user2);

        assert.equal(user2NFTAfter - user2NFTBefore, 1, "user2 should have 1 NFT");
    });

});