
import { BigNumber, ContractReceipt } from "ethers";
import { expect } from "chai";
import { ethers } from "hardhat";

const getGasCost = (receipt: ContractReceipt) => {
    // const gasUsed = receipt.gasUsed;
    // const gasPrice = tx.gasPrice;

    return receipt.effectiveGasPrice.mul(receipt.cumulativeGasUsed);
}

const ether = BigNumber.from(10).pow(18);

describe("MetaverseNFTFactory Gas Costs", function () {

    it("should spent less than 500k gas at createNFT", async function () {
        const [owner] = await ethers.getSigners();

        const MetaverseNFTFactory = await ethers.getContractFactory("MetaverseNFTFactory");

        const factory = await MetaverseNFTFactory.deploy("0x0000000000000000000000000000000000000000");

        const tx = await factory.createNFT(
            "100000", 10000, 10, 10, 500,
            // { price: "100000", maxSupply: 10000, nReserved: 10, maxPerMint: 10, royaltyFee: 500, extra: "0x000000000000" },
            "ipfs://", "NFT", "NFT"
        );

        const receipt = await tx.wait();
        const gasCost = getGasCost(receipt);

        // print table with gas cost and gas price
        console.log(`Gas used (short URI): ${receipt.cumulativeGasUsed.toString()}`);
        // console.log(`Gas used: ${receipt.gasUsed.toString()}`);

        expect(receipt.gasUsed).to.be.lt(500000);

    });

    // it should not grow too much when bigger uri is provided
    it("should spent less than 500k gas at createNFT", async function () {
        const [owner] = await ethers.getSigners();

        const MetaverseNFTFactory = await ethers.getContractFactory("MetaverseNFTFactory");

        const factory = await MetaverseNFTFactory.deploy("0x0000000000000000000000000000000000000000");

        const tx = await factory.createNFT(
            "100000", 10000, 10, 10, 500,
            // { price: "100000", maxSupply: 10000, nReserved: 10, maxPerMint: 10, royaltyFee: 500, extra: "0x000000000000" },
            "ipfs://bafybeihxrfhgxfy6h2qg46dsj4cp7uzqbb2eyu226viop4pdyjkosxqbri/", "NFT", "NFT"
        );

        const receipt = await tx.wait();

        // print table with gas cost and gas price
        console.log(`Gas used (long URI): ${receipt.cumulativeGasUsed.toString()}`);
        // console.log(`Gas used: ${receipt.gasUsed.toString()}`);

    });

    // it should not grow too much when bigger uri is provided
    it("should spent less than 500k gas at createNFT", async function () {
        const [owner] = await ethers.getSigners();

        const MetaverseNFTFactory = await ethers.getContractFactory("MetaverseNFTFactory");

        const factory = await MetaverseNFTFactory.deploy("0x0000000000000000000000000000000000000000");

        const tx = await factory.createNFT(
            "100000", 10000, 10, 10, 500,
            "https://metadata.buildship.xyz/api/dummy-metadata-for/bafybeicbwe5sa6vjlve4sl7kgjo6cvvjjdgf3shndx4xtbjc6lzblnvogm/", "NFT", "NFT"
        );

        const receipt = await tx.wait();

        // print table with gas cost and gas price
        console.log(`Gas used (pretty long URI): ${receipt.cumulativeGasUsed.toString()}`);
        // console.log(`Gas used: ${receipt.gasUsed.toString()}`);

    });

    // it should launch all three different uris and measure gas for each
    it("should launch all three different uris and measure gas for each", async function () {
        const [ owner ] = await ethers.getSigners();

        const MetaverseNFTFactory = await ethers.getContractFactory("MetaverseNFTFactory");
        const factory = await MetaverseNFTFactory.deploy("0x0000000000000000000000000000000000000000");

        const tx1 = await factory.createNFT(
            "100000", 10000, 10, 10, 500,
            "ipfs://", "NFT", "NFT"
        );

        const tx2 = await factory.createNFT(
            "100000", 10000, 10, 10, 500,
            "ipfs://bafybeihxrfhgxfy6h2qg46dsj4cp7uzqbb2eyu226viop4pdyjkosxqbri/", "NFT", "NFT"
        );

        const tx3 = await factory.createNFT(
            "100000", 10000, 10, 10, 500,
            "https://metadata.buildship.xyz/api/dummy-metadata-for/bafybeicbwe5sa6vjlve4sl7kgjo6cvvjjdgf3shndx4xtbjc6lzblnvogm/", "NFT", "NFT"
        );

        const receipt1 = await tx1.wait();
        const receipt2 = await tx2.wait();
        const receipt3 = await tx3.wait();

        // print table with gas cost and gas price in this format:

        // MetaverseNFTFactory Gas Costs
        // Gas used (short URI): 251716
        // Gas used (long URI): 319434
        // Gas used (pretty long URI): 342397

        console.log(`MetaverseNFTFactory Gas Costs`);
        console.log(`Gas used (short URI): ${receipt1.cumulativeGasUsed.toString()}`);
        console.log(`Gas used (long URI): ${receipt2.cumulativeGasUsed.toString()}`);
        console.log(`Gas used (pretty long URI): ${receipt3.cumulativeGasUsed.toString()}`);

    });

});
