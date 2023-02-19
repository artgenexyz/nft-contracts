import { expect } from "chai";
import { ethers } from "hardhat";
import { LimitedSupplyExtensionFactory } from "../typechain-types";

const { parseEther } = ethers.utils;

describe("LimitedSupplyExtension Factory", () => {
    let factory: LimitedSupplyExtensionFactory;

    beforeEach(async () => {
        const f = await ethers.getContractFactory("LimitedSupplyExtensionFactory")

        factory = await f.deploy();
    });

    it("should deploy factory", async () => {
        expect(factory.address).to.be.a("string");
    })

    it("should deploy contract", async function () {
        const [owner, user1, user2] = await ethers.getSigners();

        const nftAddress = user1.address; // not real nft

        const tx = await factory.connect(user2).createExtension(
            "Test List",
            nftAddress,
            parseEther("0.1"),
            10, // max per mint
            10, // max per wallet
            100, // series size
            true, // start sale
        );

        const res = await tx.wait();

        const event = res.events?.find(e => e.event === "ContractDeployed")

        expect(event).to.exist;

        expect(event?.args?.nft).to.equal(nftAddress);

        const contract = await ethers.getContractAt(
            "LimitedSupplyExtension",
            event?.args?.deployedAddress,
        );

        expect(event?.args?.title).to.equal("Test List");
        expect(contract.address).to.equal(event?.args?.deployedAddress);

        expect(await contract.owner()).to.equal(user2.address);
        expect(await contract.nft()).to.equal(nftAddress);

        expect(await contract.saleStarted()).to.equal(true);

        await contract.connect(user2).startSale();

        expect(await contract.saleStarted()).to.equal(true);
    });

    // it should mint successfully
    xit("should check proof validity", async function () {

        const [owner, user1, user2] = await ethers.getSigners();

        const nftAddress = user1.address;

        const tx = await factory.createExtension(
            "Test List",
            nftAddress,
            parseEther("0"),
            10, // max per mint
            10, // max per wallet
            100, // series size
            false,
        );

        const res = await tx.wait();

        const event = res.events?.find(e => e.event === "ContractDeployed")

        const contract = await ethers.getContractAt(
            "LimitedSupplyExtension",
            event?.args?.deployedAddress,
        );

    });

    it("should have title for each allowlist", async function () {
        const [owner, user1, user2] = await ethers.getSigners();

        const nftAddress = user1.address;
        
        const tx = await factory.createExtension(
            "Test List",
            nftAddress,
            parseEther("0"),
            10, // max per mint
            10, // max per wallet
            100, // series size
            false,
        );

        const res = await tx.wait();

        const event = res.events?.find(e => e.event === "ContractDeployed")

        const contract = await ethers.getContractAt(
            "LimitedSupplyExtension",
            event?.args?.deployedAddress,
        );

        expect(await contract.title()).to.equal("Test List");
    });

    // // it should mint successfully
    it("should mint successfully", async function () {
        const NFT = await ethers.getContractFactory("ERC721CommunityBase");

        const [ minter1, minter2, minter3 ] = await ethers.getSigners();

        const root = "0xfbc2f54de92972c0f2c6bbd5003031662aa9b8240f4375dc03d3157d8651ec45"

        const proof1 = [
            "0x343750465941b29921f50a28e0e43050e5e1c2611a3ea8d7fe1001090d5e1436"
        ]
        const proof2 = [
            "0x8a3552d60a98e0ade765adddad0a2e420ca9b1eef5f326ba7ab860bb4ea72c94",
            "0xe9707d0e6171f728f7473c24cc0432a9b07eaaf1efed6a137a4a8c12c79552d9"
        ]

        const proof3 = [
            "0x00314e565e0574cb412563df634608d76f5c59d9f817e85966100ec1d48005c0",
            "0xe9707d0e6171f728f7473c24cc0432a9b07eaaf1efed6a137a4a8c12c79552d9"
        ]

        const nft1 = await NFT.deploy(
            "Test NFT",
            "TEST",
            100,
            1,
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

        const tx = await factory.createExtension(
            "Test List",
            nft1.address,
            parseEther("0"),
            10, // max per mint
            10, // max per wallet
            100, // series size
            true, // start sale
        );

        const res = await tx.wait();
        const event = res.events?.find(e => e.event === "ContractDeployed")

        const list = await ethers.getContractAt(
            "LimitedSupplyExtension",
            event?.args?.deployedAddress,
        );

        expect(await list.maxSupply()).to.equal(await nft1.maxSupply());

        await nft1.addExtension(list.address);

        await list.connect(minter1).mint(1);

        expect(await nft1.balanceOf(minter1.address)).to.equal(1);

        await list.connect(minter2).mint(1);

        expect(await nft1.balanceOf(minter2.address)).to.equal(1);

        await list.connect(minter3).mint(1);

        expect(await nft1.balanceOf(minter3.address)).to.equal(1);

    });


});
