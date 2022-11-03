const BigNumber = require("bignumber.js");
const delay = require("delay");
const { assert } = require("chai");
const { ethers, hre, web3 } = require("hardhat");
const { expectRevert } = require("@openzeppelin/test-helpers");

const { getGasCost, getMintConfig } = require("./utils");

const ERC721CommunityBase = artifacts.require("ERC721CommunityBase");
const NFTExtension = artifacts.require("NFTExtension");
const MockTokenURIExtension = artifacts.require("MockTokenURIExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");
const OffchainAllowlistExtension = artifacts.require("OffchainAllowListExtension");

const ether = new BigNumber(1e18);

const { arrayify, hexZeroPad } = ethers.utils; 

contract("ERC721CommunityBase_ERC1155 - Extensions", (accounts) => {
  let nft;
  const [owner, user1, user2] = accounts;
  const beneficiary = owner;

  beforeEach(async () => {
    nft = await ERC721CommunityBase.new(
      "Test", "NFT",
      1000, 3,
      false,
      "ipfs://factory-test/",
      {
        ...getMintConfig(),
        publicPrice: ether.times(0.03).toString(),
        maxTokensPerMint: 20,
      }
    );

    // await nft.createTokenSeries(Array(1000).fill(3));
    // token id = 0: 100 items
    // token id = 1: 20 items
    // token id = 2: 100 items

  });

  // it should be able to use normal extensions to mint erc1155
  it("should be able to use LimitAmountSaleExtension to mint erc1155", async () => {
    const extension = await LimitAmountSaleExtension.new(
      nft.address,
      ether.times(0.001),
      10,
      1000,
      { from: owner }
    );

    await nft.addExtension(extension.address, { from: owner });

    // mint token
    // await nft.setRandomnessSource("0x0");
    await extension.startSale();
    await extension.mint(2, { from: owner, value: ether.times(0.005) });
    await extension.mint(10, { from: owner, value: ether.times(0.01) });

    // check tokenURI
    const tokenURI = await nft.tokenURI(0);
    assert.equal(tokenURI, "ipfs://factory-test/0");
  });

  async function sign(
    addr,
    maxAmount,
    data,
    signer = owner
    // expiry = timestamp + 1000
  ) {
    const a1 = arrayify(addr);
    const a2 = arrayify(hexZeroPad(maxAmount, 32));
    const a3 = arrayify(hexZeroPad(data, 32));

    // hexZeroPad(Buffer.from(data).toHexString(), 32));
    const message = new Uint8Array(a1.length + a2.length + a3.length);
    message.set(a1);
    message.set(a2, a1.length);
    message.set(a3, a2.length + a1.length);
    return await signer.signMessage(message);
  }

  function toEthSignedMessageHash(messageHex) {
    const messageBuffer = Buffer.from(messageHex.substring(2), 'hex');
    const prefix = Buffer.from(`\u0019Ethereum Signed Message:\n${messageBuffer.length}`);
    return web3.utils.sha3(Buffer.concat([prefix, messageBuffer]));
  }

  // it should be able to use normal extensions to mint erc1155
  // TODO: turn back on when we gonna use it
  xit("should be able to use OffchainAllowListExtension to mint", async () => {
    const [ admin ] = await ethers.getSigners();

    const nft = await ERC721CommunityBase.new(
      "Test", "NFT",
      1000, 3,
      false,
      "ipfs://factory-test/",
      {
        ...getMintConfig(),
        publicPrice: ether.times(0.03),
        maxTokensPerMint: 20,
      }
    )

    const extension = await OffchainAllowlistExtension.new(
      nft.address,
      admin.address,
      0, // price
    );

    await nft.addExtension(extension.address, { from: owner });

    // receiver, maxAmount, data (token id)
    const hash = [user1, 999, 12+256] // .map(x => x.toString()));

    // keccak256(abi.encodePacked(receiver, maxAmount, data))

    const hashHex = web3.utils.keccak256(web3.utils.encodePacked(...hash));

    // sign message from owner
    const signature = await web3.eth.sign((hashHex), owner);

    const message = new Uint8Array(Buffer.from(hashHex));

    const sig_ethers = await admin.signMessage(message);

    // output sig
    console.log("JS raw", web3.utils.encodePacked(...hash));
    console.log("JS hash", hashHex);

    console.log("JS sig", sig_ethers);
    console.log("JS sig", signature);
    console.log("");

    await nft.createTokenSeries(Array(1000).fill(1));
    await nft.setRandomnessSource("0x0");
    // mint token
    await extension.startSale();

    await extension.mint(2, 999, web3.utils.encodePacked(12+1+256), signature, { value: ether.times(0.005), from: user1 });

    // check balanceof token id = 12 for user1
    const balance = await nft.balanceOf(user1, 12);
    assert.equal(balance, 2);

    // process.exit(0);

    const sig2 = await (() => {
        // receiver, maxAmount, data (token id)
        const hash = [user1, 999, 10+256] // .map(x => x.toString()));

        // keccak256(abi.encodePacked(receiver, maxAmount, data))

        const hashHex = web3.utils.keccak256(web3.utils.encodePacked(...hash));

        // sign message from owner
        return web3.eth.sign((hashHex), owner);
    })()

    await extension.mint(5, 999, web3.utils.encodePacked(10+256), sig2, { from: user1, value: ether.times(0.005) });
    // check balanceof token id = 10 for user1
    const balance2 = await nft.balanceOf(user1, 10);
    assert.equal(balance2, 5);

  });

});
