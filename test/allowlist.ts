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
        const [owner, user1] = await ethers.getSigners();

        const nftAddress = user1.address;

        const tx = await factory.createAllowlist(
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

        expect(await contract.owner()).to.equal(owner.address);
        expect(await contract.nft()).to.equal(nftAddress);

        expect(await contract.saleStarted()).to.equal(true);

        await contract.startSale();


        expect(await contract.saleStarted()).to.equal(true);
    });

});