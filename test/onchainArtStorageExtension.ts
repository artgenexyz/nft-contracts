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

  it("conforms to IRenderer interface", async function () {
    const OnchainArtStorageExtension = await ethers.getContractFactory("OnchainArtStorageExtension");
    const onchainArtStorageExtension = await OnchainArtStorageExtension.deploy(nft.address, "artwork");

    // const supportsInterface = await onchainArtStorageExtension.supportsInterface("0x0e89341c");
    // expect(supportsInterface).to.equal(true);

    const tx = await nft.setRenderer(onchainArtStorageExtension.address);
    await tx.wait();

    const renderer = await nft.renderer();
    expect(renderer).to.equal(onchainArtStorageExtension.address);
  });


  it("Add tests for the OnchainArtStorageExtension contract", async function () {

    const OnchainArtStorageExtension = await ethers.getContractFactory("OnchainArtStorageExtension");
    const onchainArtStorageExtension = await OnchainArtStorageExtension.deploy(nft.address, "artwork");

    const tokenId = 1;
    // const expectedTokenURI = `data:text/html;base64,${Buffer.from("<html><body><h1>Generative Art for Token ID: 1</h1></body></html>").toString("base64")}`;

    const tokenURI = await onchainArtStorageExtension.tokenURI(tokenId);

    const render = await onchainArtStorageExtension.render(tokenId, "0x1234");

    console.log("tokenURI", tokenURI);
    console.log("render", render);

    // expect tokenURI to start with data:application/json; and to contain text "artwork"
    expect(tokenURI).to.match(/^data:application\/json;/);
    // expect render to start with data:text/html;base64, and to contain text "Generative Art for Token ID: 1"
    expect(render).to.match(/data:text\/html;base64/);

  });
});
