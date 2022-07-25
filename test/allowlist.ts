import { expect } from "chai";
import { ethers } from "hardhat";
import { AllowlistFactory } from "../typechain-types";

const { parseEther } = ethers.utils;

describe("Allowlist Factory", () => {
    let factory: AllowlistFactory;

    beforeEach(async () => {
        const f = await ethers.getContractFactory("AllowlistFactory")

        factory = await f.deploy();
    });

    it("should deploy factory", async () => {
        expect(factory.address).to.be.a("string");
    })

    it("should deploy contract", async function () {
        const [owner, user1, user2] = await ethers.getSigners();

        const nftAddress = user1.address;

        const tx = await factory.connect(user2).createAllowlist(
            "Test List",
            nftAddress,
            "0xbd204967d5ef69fe133d1e2e9509f68bf3ee681006804e37b0bd51a64aea0116",
            parseEther("0.1"),
            1,
            true,
        );

        const res = await tx.wait();

        const event = res.events?.find(e => e.event === "ContractDeployed")

        expect(event).to.exist;

        expect(event?.args?.nft).to.equal(nftAddress);

        const contract = await ethers.getContractAt(
            "Allowlist",
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
    it("should check proof validity", async function () {
        const address = "0xffe06cb4807917bd79382981f23d16a70c102c3b"
        const root = "0x01a190633cf36eb0a207f16c11b88f873b92aa9c248482ed87bae56fe75c6871"
        const proof = [
            "0x8b37442083367ac89eaf201381abfda29d6f9761782890715d67e7945771a467"
        ]

        const [owner, user1, user2] = await ethers.getSigners();

        const nftAddress = user1.address;

        const tx = await factory.createAllowlist(
            "Test List",
            nftAddress,
            root,
            parseEther("0"),
            1,
            false,
        );

        const res = await tx.wait();

        const event = res.events?.find(e => e.event === "ContractDeployed")

        const contract = await ethers.getContractAt(
            "Allowlist",
            event?.args?.deployedAddress,
        );

        expect(await contract.whitelistRoot()).to.equal(root);
        expect(await contract.isWhitelisted(root, address, proof)).to.equal(true);

        expect(await contract.isWhitelisted(root, user2.address, proof)).to.equal(false);

    });

    // // it should mint successfully
    it("should mint successfully", async function () {
        const NFT = await ethers.getContractFactory("MetaverseBaseNFT");

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
            parseEther("0.01"),
            100,
            1,
            1,
            100, // 1%
            "Test NFT",
            "TEST",
            "https://example.com",
            false,
        );

        const tx = await factory.createAllowlist(
            "Test List",
            nft1.address,
            root,
            parseEther("0"),
            1, // max per address
            true, // start sale
        );

        const res = await tx.wait();
        const event = res.events?.find(e => e.event === "ContractDeployed")

        const list = await ethers.getContractAt(
            "Allowlist",
            event?.args?.deployedAddress,
        );

        expect(await list.whitelistRoot()).to.equal(root);
        expect(await list.isWhitelisted(root, minter1.address, proof1)).to.equal(true);

        await nft1.addExtension(list.address);

        await list.connect(minter1).mint(1, proof1);

        expect(await nft1.balanceOf(minter1.address)).to.equal(1);

        await list.connect(minter2).mint(1, proof2);

        expect(await nft1.balanceOf(minter2.address)).to.equal(1);

        await list.connect(minter3).mint(1, proof3);

        expect(await nft1.balanceOf(minter3.address)).to.equal(1);

    });


});