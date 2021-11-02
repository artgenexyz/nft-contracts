
const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert } = require("chai");

const AmeegosMintPass = artifacts.require("AmeegosMintPass");
const AmeegosNFT = artifacts.require("AmeegosNFT");
const AmeegosMintPassv2 = artifacts.require("AmeegosMintPassv2");
const AmeegosNFTv2 = artifacts.require("AmeegosNFTv2");

const HOLDERS = require('../ameegos/holders.json');

// This is hard. We have extracted list of old holders for AmeegosNFT and AmeegosMintPassv2.
// We need to test:
// - we can mint AmeegosNFTv2 to old holders
// - the NFT sale is still stopped
// - tokenURI are correct
// - we can mint AmeegosMintPassv2 to old holders
// - mint pass works with redeem() - it takes your money, gives you NFT, doesn't leave NFT on the MintPass contract
// - we can start the sale on AmeegosNFT and change the price
// - if we are on mainnet fork, we can check if the NFTs have same owners

const HOLDERS_DEMO = HOLDERS.slice(0,20)

const MINTPASS_HOLDERS_DEMO = [

{ "holder": "0x45647bd8fa8b0e6a98fbc6091266d5d519632084", "amount": 3 },
{ "holder": "0x54e6d0af09c10eaba369f78e67ed29e6e8310580", "amount": 2 },
{ "holder": "0x1b30f1f67306f6d0d4c2c3b2dd82cfa270b747a9", "amount": 2 },
{ "holder": "0x399f9eef2582ca5e72ea6a5e8b0da6b62b562704", "amount": 2 },
{ "holder": "0x8373300d7e10466c17711637ae9ff4d00c6b318e", "amount": 2 },
{ "holder": "0x96348847893208c2329e8e4221e7ce8d410c2826", "amount": 2 },
{ "holder": "0xc2ef1173a4b051bbcc4474c407bbb2ac7e02e363", "amount": 2 },
{ "holder": "0xc3804b434332d1ec36ef263d06ab4dce4ed627ff", "amount": 2 },
{ "holder": "0xd81bdcceb77e7c46b358627686f1eaf06d1fcba5", "amount": 2 },
{ "holder": "0xeae2eac6d8d46820bf813fd5033c5d296328bc0d", "amount": 2 },
{ "holder": "0xf9cf9f053409707d2ea83ae736df510e660cf402", "amount": 2 },

{ "holder": "0xebe1125c2bb2676c157a0948af88b9af17f9babe", "amount": 1 },
{ "holder": "0xf16e9dd6b1f360fe597bebc037379820e2abbbc1", "amount": 1 },
{ "holder": "0xf3c0758138a19453f4518baa039dfebb7eb6f0d2", "amount": 1 },
{ "holder": "0xf8a44bd1ceff43ba61eb5fc71a5309e351017e60", "amount": 1 },
{ "holder": "0x18a6a993674262e166c475edfae0858f6d0456e6", "amount": 1 },
{ "holder": "0xfe899c851c20f84e1a4d53600bcab433eefcb966", "amount": 1 },
]

contract("Ameegos NFT – Polygon migration and NFT sale", function (accounts) {
    const [ owner, user1, user2, user3, user4, hector ] = accounts;

    let nft, pass, unlocked;

    it("should be on mainnet fork", async function () {
        const networkType = await web3.eth.net.getNetworkType();

        console.log('Running on', networkType);
        // console.log(help);

        // assert.equal(networkType, "main", "should run on mainnet fork");
    });

    it("should deploy AmeegosNFT and AmeegosMintPass, v2", async function () {
        nft = await AmeegosNFTv2.new();
        pass = await AmeegosMintPassv2.new(nft.address);
    });

    // price should be 115*1e18
    it("should have price equal to 115 MATIC", async function () {
        const price = await nft.getPrice();

        assert.equal(price.toString(), (115 * 1e18).toString(), "price should be 115*1e18");
    });

    // it should change price to 1e17
    it("should change price to 1e17", async function () {
        await nft.setPrice(1e17.toString());
        const price = await nft.getPrice();

        assert.equal(price.toString(), 1e17.toString(), "price should be 1e17");
    });

    // it should be possible to claimReserved for the list of HOLDERS_DEMO
    it("should be possible to claimReserved for the list of HOLDERS_DEMO", async function () {
        // measure gas for each tx
        let gas = 0;

        for (let i = 0; i < HOLDERS_DEMO.length; i++) {
            const { tokenId, holder } = HOLDERS_DEMO[i];
            const tx = await nft.claimReserved(1, holder, { from: owner });
            gas += tx.receipt.gasUsed;
        }

        console.log('claimReserved total gas:', gas, 'gas per tx:', gas / HOLDERS_DEMO.length);

        // assert nft saleStarted is false
        assert.equal(await nft.saleStarted(), false, "nft saleStarted should be false");
    });

    // it should be able to run claimBatch until 1356 are reserved
    it("should be able to run claimBatch a lot", async function () {
        HOLDERS.splice(0, 20); // already added

        for (let i = 0; i < HOLDERS.length; i += 50) {
            const batch = HOLDERS.slice(i, i + 50);
            const tokenIds = batch.map(h => h.tokenId);
            const holders = batch.map(h => h.holder);
            console.log("Minting batch", i, "of", HOLDERS.length, "with", tokenIds.length, "tokenIds\n", tokenIds);

            const tx = await nft.claimBatch(tokenIds, holders);
            console.log('tx', tx.receipt.gasUsed, tx.receipt.hash);
        }

        // check getReservedLeft() is zero
        assert.equal(await nft.getReservedLeft(), 0, "getReservedLeft() should be 0");

        // select random tokenID from HOLDERS and check it's holder is the same as nft.ownerOf(tokenId)
        const { tokenId, holder } = HOLDERS[Math.floor(Math.random() * HOLDERS.length)];
        const owner = await nft.ownerOf(tokenId);

        console.log('tokenId', tokenId, 'holder', holder, 'owner', owner);

        assert.equal(owner, holder, "owner should be the same as holder");
    });

    // it should mint correct tokenURI, check for tokenID = 7
    it("should mint correct tokenURI, check for tokenID = 7", async function () {
        // from https://etherscan.io/address/0xf522b448dbf8884038c684b5c3de95654007fd2b#readContract
        const tokenId = 7;
        const tokenURI = 'ipfs://QmXE9FZkbaXSKcigDdx5d6uZu84xKQwamdjh8mxZLzKpp6/7.json';

        const uri = await nft.tokenURI(tokenId);

        assert.equal(uri, tokenURI, "tokenURI should equal mainnet version");
    });

    // it should mint mintpass to old holders .issue(number, holder)
    it("should mint mintpass to old holders .issue(number, holder)", async function () {
        for (let i = 0; i < MINTPASS_HOLDERS_DEMO.length; i++) {
            const { holder, amount } = MINTPASS_HOLDERS_DEMO[i];
            const tx = await pass.issue(amount, holder, { from: owner });
        }
    });

    // it should be possible to claim mintpass for the user
    it("should be possible to claim mintpass for the user", async function () {
        await pass.flipSaleStarted({ from: owner });

        await pass.claim(1, { from: user1 });
    });

    // it should fail if user try redeem mintpass with error including "MinterAccess"
    it("should fail if user try redeem mintpass with error including 'MinterAccess'", async function () {
        await expectRevert(
            pass.redeem(1, { from: user1 }),
            "MinterAccess: only minter allowed"
        );
    });

    // it should be possible to redeem mintpass for the user
    it("should be possible to redeem mintpass for the user", async function () {
        const price = await nft.getPrice();

        await nft.setMinter(pass.address);

        const balanceBefore = await nft.balanceOf(user1);

        await pass.redeem(1, { from: user1, value: price });

        // assert nft saleStarted is false
        assert.equal(await nft.saleStarted(), false, "nft saleStarted should be false");

        // check that user received nft
        const balance = await nft.balanceOf(user1);

        assert.equal(balance.toNumber(), balanceBefore.toNumber() + 1, "user1 should receive 1 nft");

        // check that user doesn't have mintpass anymore
        const MINT_PASS_ID = 0;
        const mintpass = await pass.balanceOf(user1, MINT_PASS_ID);

        assert.equal(mintpass.toNumber(), 0, "user1 should not have mintpass");
    });

    // it should be possible to start sale on nft
    it("should be possible to start sale on nft", async function () {
        await nft.setBeneficiary(owner, { from: owner });
        await nft.flipSaleStarted({ from: owner });

        // assert nft saleStarted is true
        assert.equal(await nft.saleStarted(), true, "nft saleStarted should be true");

        // it should be possible to mint now
        const price = await nft.getPrice();

        await nft.mint(1, { from: user1, value: price });
    });

    // it should be possible to change beneficiary to user1 and back
    it("should be possible to change beneficiary to user1 and back", async function () {
        await nft.setBeneficiary(user1, { from: owner });

        // // assert nft beneficiary is user1
        // assert.equal(await nft.beneficiary(), user1, "nft beneficiary should be user1");

        await nft.setBeneficiary(owner, { from: owner });

        // // assert nft beneficiary is owner
        // assert.equal(await nft.beneficiary(), owner, "nft beneficiary should be owner");
    });

    // it should be possible to mint multiple nfts
    it("should be possible to mint multiple nfts", async function () {
        const price = await nft.getPrice();

        await nft.mint(2, { from: user1, value: (price * 2).toString() });
    });

    // it should be able to update setBaseURI
    it("should be able to update setBaseURI", async function () {
        const newBaseURI = 'ipfs://QmcXei9Mo46XijLncQuPAmbRAC5QXfREqkb4RisKprUX4Y/';

        await nft.setBaseURI(newBaseURI, { from: owner });

        // assert nft baseURI is newBaseURI
        assert.equal(await nft.baseURI(), newBaseURI, "nft baseURI should be newBaseURI");
    });

    // it should withdraw money
    it("should withdraw money", async function () {

        const balanceBefore = await web3.eth.getBalance(owner);

        await nft.withdraw({ from: owner });

        const balanceAfter = await web3.eth.getBalance(owner);

        assert.isAbove(
            Number(balanceAfter),
            Number(balanceBefore),
            "owner should receive money"
        );
    });

    // it should fail if you try to transfer nft to mintpass address
    it("should fail if you try to transfer nft to mintpass address", async function () {
      const tokenId = await nft.tokenOfOwnerByIndex(user1, 0);

      // approve nft for transfer to pass.address
      await nft.setApprovalForAll(pass.address, { from: user1 });

      await expectRevert(
        nft.safeTransferFrom(user1, pass.address, tokenId, { from: user1 }),
        "ERC721: transfer to non ERC721Receiver implementer"
      );
    });
});