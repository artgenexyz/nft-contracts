import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC721CommunityImplementation, ERC721Community__factory, ERC721CommunityBase__factory } from "../typechain-types";

const { parseEther } = ethers.utils;

describe("Multicall Test", () => {
    let impl: ERC721CommunityImplementation;

    beforeEach(async () => {
        const i = await ethers.getContractFactory("ERC721CommunityImplementation")

        impl = await i.deploy();
    });

    it("should allow setting price and starting sale in one tx", async () => {

        const NFT: ERC721CommunityBase__factory = await ethers.getContractFactory("ERC721CommunityBase");

        const nft1 = await NFT.deploy(
            "Test NFT",
            "TEST",
            100,
            3,
            false,
            "https://example.com",
            {
                publicPrice: parseEther("0.1"),
                maxTokensPerMint: 5,
                maxTokensPerWallet: 5,
                royaltyFee: 500,
                payoutReceiver: "0x0000000000000000000000000000000000000000",
                shouldLockPayoutReceiver: false,
                shouldStartSale: false,
                shouldUseJsonExtension: false,
            }
        );

        // test setting price
        await nft1.setPrice(parseEther("0.2"));

        // test starting sale
        await nft1.startSale();

        // check it worked
        expect(await nft1.price()).to.equal(parseEther("0.2"));
        expect(await nft1.saleStarted()).to.equal(true);

        await nft1.stopSale();

        expect(await nft1.saleStarted()).to.equal(false);

        // test setting price and starting sale in one tx
        const setPrice = nft1.interface.encodeFunctionData("setPrice", [parseEther("0.3")]);
        const startSale = nft1.interface.encodeFunctionData("startSale");

        await nft1.multicall([setPrice, startSale]);

        // check it worked
        expect(await nft1.price()).to.equal(parseEther("0.3"));
        expect(await nft1.saleStarted()).to.equal(true);

    });

    it("should work for ERC721Community proxy", async () => {

        const NFT: ERC721Community__factory = await ethers.getContractFactory("ERC721Community");

        const nft_ = await NFT.deploy(
            "Test NFT",
            "TEST",
            100,
            3,
            false,
            "https://example.com",
            {
                publicPrice: parseEther("0.1"),
                maxTokensPerMint: 5,
                maxTokensPerWallet: 5,
                royaltyFee: 500,
                payoutReceiver: "0x0000000000000000000000000000000000000000",
                shouldLockPayoutReceiver: false,
                shouldStartSale: true,
                shouldUseJsonExtension: false,
            }
        );

        // replace ABI with implementation ABI
        const nft = impl.attach(nft_.address);

        // test setting price
        await nft.setPrice(parseEther("0.2"));

        // test stopping sale
        await nft.stopSale();

        // check it worked
        expect(await nft.price()).to.equal(parseEther("0.2"));
        expect(await nft.saleStarted()).to.equal(false);

        // test setting price and starting sale in one tx
        const setPrice = nft.interface.encodeFunctionData("setPrice", [parseEther("0.3")]);
        const startSale = nft.interface.encodeFunctionData("startSale");

        await nft.multicall([setPrice, startSale]);

        // check it worked
        expect(await nft.price()).to.equal(parseEther("0.3"));
        expect(await nft.saleStarted()).to.equal(true);

    });

    xit("should allow claim", async () => {

        const [owner, user1, user2] = await ethers.getSigners();

        const NFT: ERC721CommunityBase__factory = await ethers.getContractFactory("ERC721CommunityBase");

        const nft1 = await NFT.deploy(
            "Test NFT",
            "TEST",
            100,
            3,
            false,
            "https://example.com",
            {
                publicPrice: parseEther("0.1"),
                maxTokensPerMint: 5,
                maxTokensPerWallet: 5,
                royaltyFee: 500,
                payoutReceiver: "0x0000000000000000000000000000000000000000",
                shouldLockPayoutReceiver: false,
                shouldStartSale: false,
                shouldUseJsonExtension: false,
            }
        );

        // try claim for owner
        await nft1.claim(1, owner.address);

        // check owner balance
        expect(await nft1.balanceOf(owner.address)).to.equal(1);

        // const calls = [];

        const claim1 = nft1.interface.encodeFunctionData("claim", [1, user1.address]);
        const claim2 = nft1.interface.encodeFunctionData("claim", [1, user2.address]);

        const calls = [claim1, claim2];

        try {
            const res = await nft1.multicall(calls);

            const r = nft1.interface.decodeFunctionResult("multicall", res.data);

            const results = r.map((r) => nft1.interface.decodeFunctionResult("claim", r));

            console.log('Results:\n\n', results);

            // check if the first call was successful
            expect(results[0].success).to.be.true;

            // check if the second call was successful
            expect(results[1].success).to.be.true;

            // check if user1 and user2 both have a token
            expect(await nft1.balanceOf(user1.address)).to.equal(1);
            expect(await nft1.balanceOf(user2.address)).to.equal(1);
        } catch (err: any) {
            console.log('Error:\n\n', err);

            const r = nft1.interface.decodeFunctionResult("multicall", err.data);

            console.log('Results:\n\n', r);

            const results = r.map((r) => nft1.interface.decodeFunctionResult("claim", r));

            console.log('Parsed Results:\n\n', results);

            throw err;
        }
    })

});
