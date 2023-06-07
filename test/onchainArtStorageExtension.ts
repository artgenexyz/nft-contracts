import { ethers } from "hardhat";
import { expect } from "chai";
import { Artgene721Base } from "../typechain-types";

const { getGasCost, getMintConfig } = require("./utils");

describe("OnchainArtStorageExtension", function () {
  let nft: Artgene721Base;

  beforeEach(async () => {
    const Artgene721Base = await ethers.getContractFactory("Artgene721Base");

    nft = await Artgene721Base.deploy(
      "Test", "NFT",
      1000, 3,
      false,
      "ipfs://factory-test/",
      {
        ...getMintConfig(),
      publicPrice: ethers.utils.parseEther("0.03"),
        maxTokensPerMint: 20,
      }
    );
  });

  it("Add tests for the OnchainArtStorageExtension contract", async function () {

    const OnchainArtStorageExtension = await ethers.getContractFactory("OnchainArtStorageExtension");
    const onchainArtStorageExtension = await OnchainArtStorageExtension.deploy(nft.address, "artwork");

    const tokenId = 1;
    const expectedTokenURI = `data:text/html;base64,${Buffer.from("<html><body><h1>Generative Art for Token ID: 1</h1></body></html>").toString("base64")}`;

    const tokenURI = await onchainArtStorageExtension.tokenURI(tokenId);

    const render = await onchainArtStorageExtension.render(tokenId, "0x1234");

    console.log("tokenURI", tokenURI);
    console.log("render", render);

    expect(await onchainArtStorageExtension.tokenURI(tokenId)).to.equal(expectedTokenURI);
    expect(await onchainArtStorageExtension.render(tokenId, "0x1234")).to.equal("<html><body><h1>Generative Art for Token ID: 1</h1></body></html>");


  });
});
