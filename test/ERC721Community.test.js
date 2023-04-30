const {expect} = require("chai");
const {ethers} = require("hardhat");
const {utils} = require("ethers");

describe("ERC721Community - Burn function with OpenSea integration", function () {
  let erc721Community;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let tokenURI;
  let tokenId;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    tokenURI = "https://example.com/token/";
    tokenId = 1;

    const ERC721Community = await ethers.getContractFactory("ERC721Community");
    erc721Community = await ERC721Community.deploy("ERC721CommunityExample", "EXM");
    await erc721Community.deployed();

    await erc721Community.connect(addr1).mint(addr1.address, tokenId, tokenURI);
  });

  it("Should decrease maxSupply when a token is burned", async function () {
    const initialMaxSupply = await erc721Community.maxSupply();
    await erc721Community.connect(addr1).burn(tokenId);

    const finalMaxSupply = await erc721Community.maxSupply();
    expect(finalMaxSupply).to.equal(initialMaxSupply.sub(1));
  });

  it("Should decrease totalMinted and totalSupply when a token is burned", async function () {
    const initialTotalMinted = await erc721Community.totalMinted();
    const initialTotalSupply = await erc721Community.totalSupply();
    await erc721Community.connect(addr1).burn(tokenId);

    const finalTotalMinted = await erc721Community.totalMinted();
    const finalTotalSupply = await erc721Community.totalSupply();
    expect(finalTotalMinted).to.equal(initialTotalMinted.sub(1));
    expect(finalTotalSupply).to.equal(initialTotalSupply.sub(1));
  });

  it("Should update token balance when a token is burned", async function () {
    const initialBalance = await erc721Community.balanceOf(addr1.address);
    await erc721Community.connect(addr1).burn(tokenId);

    const finalBalance = await erc721Community.balanceOf(addr1.address);
    expect(finalBalance).to.equal(initialBalance.sub(1));
  });

  it("Should fail if non-token owner tries to burn a token", async function () {
    await expect(erc721Community.connect(addr2).burn(tokenId)).to.be.revertedWith("ERC721: burn caller is not owner nor approved");
  });
});