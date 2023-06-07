import { ethers } from "hardhat";
import { expect } from "chai";

describe("OnchainArtStorageExtension", function () {
  it("Should return the token URI and render the generative art for a given token ID", async function () {
    const OnchainArtStorageExtension = await ethers.getContractFactory("OnchainArtStorageExtension");
    const onchainArtStorageExtension = await OnchainArtStorageExtension.deploy();
    await onchainArtStorageExtension.deployed();

    const tokenId = 1;
    const expectedTokenURI = `data:text/html;base64,${Buffer.from("<html><body><h1>Generative Art for Token ID: 1</h1></body></html>").toString("base64")}`;

    expect(await onchainArtStorageExtension.tokenURI(tokenId)).to.equal(expectedTokenURI);
    expect(await onchainArtStorageExtension.render(tokenId)).to.equal("<html><body><h1>Generative Art for Token ID: 1</h1></body></html>");
  });
});