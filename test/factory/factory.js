const BigNumber = require("bignumber.js");
const { expectRevert } = require("@openzeppelin/test-helpers");
const { assert, expect } = require("chai");
const { getGasCost, createNFTSale } = require("../utils");

const NFTFactory = artifacts.require("MetaverseNFTFactory");
const MetaverseNFT = artifacts.require("MetaverseNFT");

const MetaverseBaseNFT = artifacts.require("MetaverseBaseNFT");

const ether = new BigNumber(1e18);

/**
 * Tests for the NFTFactory:
 * - Factory can deploy itself, and then create new NFTs successfully
 * - Deployed shared implementation has all the values set to zero
 * - Deployed NFTs have correct owner and correct values
 * - Updating value in one NFT doesn't change value in other, or in the shared implementation
 * - Shared implementation fails on all transactions
 * - Test simple sale for deployed NFTs
 * - Test that deployed NFTs have different owners
 * -
 */

contract("MetaverseNFTFactory", (accounts) => {
  let factory, pass;
  const [owner, user1, user2, user3] = accounts;

  beforeEach(async () => {
    pass = await createNFTSale(MetaverseBaseNFT);
    factory = await NFTFactory.new(pass.address);

    await pass.claim(1, owner, { from: owner });
    await pass.claim(1, user1, { from: owner });
  });

  // it should deploy successfully
  it("should deploy successfully", async () => {
    assert.ok(factory.address, "Factory not deployed");

    const original = await MetaverseNFT.at(await factory.proxyImplementation());

    assert.equal(
      await original.owner(),
      "0x0000000000000000000000000000000000000000",
      "Owner is not zero"
    );

  });

  // it should measure gas spent on deployment
  it("should measure gas spent on deployment", async () => {
    let nft = await factory.createNFT(
      ether.times(0.01), // price
      10000, // max tokens
      0, // reserved
      20, // max per mint
      0, // royalty fee
      "factory-test-buy",
      "Test",
      "NFT"
    );

    const gasSpent = nft.receipt.gasUsed;

    assert.isBelow(gasSpent, 500_000, "Gas spent is too high");
  });

  // it should test that NFT Factory can create NFTs
  it("should test that NFT Factory can create NFTs", async () => {
    let nft = await factory.createNFT(
      ether.times(0.05),
      10000,
      0,
      20,
      0, // royalty fee
      "factory-test",
      "Test",
      "NFT"
      // { value: ether.times(0.1) },
    );

    assert.ok(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );
  });

  // it should test that deployed NFTs have correct owner and correct values
  it("should test that deployed NFTs have correct owner and correct values", async () => {
    let nft = await factory.createNFT(
      ether.times(0.05),
      10000,
      1,
      20,
      0, // royalty fee
      "factory-test/",
      "Test",
      "NFT",
      { from: user1 }
    );

    let deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    assert.equal(await deployedNFT.owner(), user1);

    await deployedNFT.claim(1, user2, { from: user1 });

    assert.include(await deployedNFT.tokenURI(0), "factory-test");
    assert.equal(await deployedNFT.tokenURI(0), "factory-test/0");
  });

  // it should allow updating value in one NFT doesn't change value in other, or in the shared implementation
  it("should allow updating value in one NFT doesn't change value in other, or in the shared implementation", async () => {
    let nft = await factory.createNFT(
      ether.times(0.05),
      10000,
      0,
      20,
      0, // royalty fee
      "factory-test",
      "Test",
      "NFT",
      { from: user1 }
    );

    let nft2 = await factory.createNFT(
      ether.times(0.05),
      10000,
      0,
      20,
      0, // royalty fee
      "factory-test",
      "Test",
      "NFT",
      { from: user1 }
    );

    let deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );
    let deployedNFT2 = await MetaverseNFT.at(
      nft2.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    await deployedNFT.setPrice(ether.times(0.1), { from: user1 });

    assert.equal(
      (await deployedNFT.price()).toString(),
      ether.times(0.1).toString()
    );

    assert.equal(
      (await deployedNFT2.price()).toString(),
      ether.times(0.05).toString()
    );
  });

  // it should test that shared implementation fails on all transactions
  it("should test that shared implementation fails on all transactions", async () => {
    const proxyImplementation = await factory.proxyImplementation();
    const original = await MetaverseNFT.at(proxyImplementation);

    assert.equal(
      await original.owner(),
      "0x0000000000000000000000000000000000000000"
    );

    assert.equal(
      await original.saleStarted(),
      false
    );

    await expectRevert(
      original.mint(1, { from: user1, value: ether.times(0.1) }),
      "Sale not started"
    );
  });

  // it should measure gas spent on deployment
  it("should measure gas spent on deployment", async () => {
    let nft = await factory.createNFT(
      ether.times(0.01),
      10000,
      0,
      20,
      0, // royalty fee
      "factory-test-buy",
      "Test",
      "NFT"
      // { value: ether.times(0.1) },
    );

    const gasSpent = nft.receipt.gasUsed;

    assert.isBelow(gasSpent, 500_000);
  });

  // it should allow starting sale and buying nft from factory
  // it should test fee split works correctly and developer gets 5% of the balance after owner calls withdraw()
  it("should allow starting sale and buying nft from factory", async () => {
    let nft = await factory.createNFT(
      ether.times(0.01),
      10000,
      0,
      20,
      0, // royalty fee
      "factory-test-buy",
      "Test",
      "NFT"
      // { value: ether.times(0.1) },
    );

    let deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    await deployedNFT.startSale();

    await deployedNFT.mint(5, { from: user1, value: ether.times(0.05) });
    await deployedNFT.mint(5, { from: user2, value: ether.times(0.05) });

    // total is 0.1 eth now

    const dev = await deployedNFT.DEVELOPER_ADDRESS();

    const balance = await web3.eth.getBalance(deployedNFT.address);
    const balanceDeveloperBefore = await web3.eth.getBalance(dev);
    const balanceOwnerBefore = await web3.eth.getBalance(owner);

    assert.equal(balance.toString(), ether.times(0.1).toString());

    const tx = await deployedNFT.withdraw({ from: owner });

    const balanceOwnerAfter = await web3.eth.getBalance(owner);
    const balanceDeveloperAfter = await web3.eth.getBalance(dev);

    const gasCost = getGasCost(tx);

    assert.equal(
      new BigNumber(balanceOwnerAfter)
        .minus(balanceOwnerBefore)
        .plus(gasCost)
        .toString(),
      ether.times(0.1).times(0.95).toString()
    );

    assert.equal(
      new BigNumber(balanceDeveloperAfter)
        .minus(balanceDeveloperBefore)
        .toString(),
      ether.times(0.1).times(0.05).toString()
    );
  });

  // it should create nft and add .json using setPostfixURI
  it("should create nft and add .json using setPostfixURI", async () => {
    let nft = await factory.createNFT(
      ether.times(0.01),
      10000,
      1, // reserved
      20,
      0, // royalty fee
      "factory-test-buy",
      "Test",
      "NFT"
    );

    let deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    await deployedNFT.setPostfixURI(".json");

    await deployedNFT.claim(1, user1);

    assert.include(await deployedNFT.tokenURI(0), "factory-test");
    assert.include(await deployedNFT.tokenURI(0), ".json");
  });

  // it start token ids from 0 when calling normal createNFT
  it("start token ids from 0 when calling normal createNFT", async () => {
    let nft = await factory.createNFT(
      ether.times(0.01),
      10000,
      1, // reserved
      20,
      0, // royalty fee
      "factory-test-buy",
      "Test",
      "NFT"
    );

    let deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    const tx = await deployedNFT.claim(1, user1);

    // check tx events for Transfer
    assert.equal(
      tx.logs.find((l) => l.event === "Transfer").args.from,
      "0x0000000000000000000000000000000000000000"
    );

    assert.equal(tx.logs.find((l) => l.event === "Transfer").args.tokenId, "0");
  });

  // it should be able to createNFTWithSettings
  it("should be able to createNFTWithSettings", async () => {
    const nft = await factory.createNFTWithSettings(
      ether.times(0.01),
      10000,
      1, // reserved
      20,
      0, // royalty fee
      "factory-test-buy/",
      "Test",
      "NFT",
      user2, // address payoutReceiver,
      true, // bool shouldUseJSONExtension,
      2 + 4 + 8, // uint16 miscParams is a bitmask of 1,2,4,8 = 1<<0,1<<1,1<<2,1<<3
      { from: user1 }
    );

    const deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    assert.equal(await deployedNFT.owner(), user1);

    assert.equal(await deployedNFT.getPayoutReceiver(), user2);

    // test if miscParams are parsed correctly:
    // bool startTokenIdAtOne = (miscParams & 0x01) == 0x01;
    // bool shouldUseJSONExtension = (miscParams & 0x02) == 0x02;
    // bool shouldStartSale = (miscParams & 0x04) == 0x04;
    // bool shouldLockPayoutChange = (miscParams & 0x08) == 0x08;

    assert.equal(await deployedNFT.startTokenId(), "1");

    await deployedNFT.claim(1, owner, { from: user1 });

    // TODO: fix for ganache v7 https://github.com/trufflesuite/ganache/discussions/1075#user-content-v7.0.0-alpha.0-the-big-ones

    // expect tokenURI(0) to fail
    expectRevert(
      deployedNFT.tokenURI(0),
      "ERC721Metadata: URI query for nonexistent token"
    );

    assert.equal(await deployedNFT.tokenURI(1), "factory-test-buy/1.json");

    assert.equal(
      await deployedNFT.totalSupply(),
      1,
      "total supply is wrong ≠ 1"
    );

    // saleStarted is true
    assert.equal(await deployedNFT.saleStarted(), true);

    // not possible to change payout receiver
    expectRevert(
      deployedNFT.setPayoutReceiver(user3, { from: user1 }),
      "Payout change is locked"
    );
  });

  // it should not allow createNFT if you dont own earlyPass

  it("should not allow createNFT if you dont own earlyPass", async () => {
    await expectRevert(
      factory.createNFTWithSettings(
        ether.times(0.01),
        10000,
        1, // reserved
        20,
        0, // royalty fee
        "factory-test-buy/",
        "Test",
        "NFT",
        user2, // address payoutReceiver,
        true, // bool shouldUseJSONExtension,
        2 + 4 + 8, // uint16 miscParams is a bitmask of 1,2,4,8
        { from: user3 }
      ),
      "MetaverseNFTFactory: Early Access Pass is required"
    );
  });

  // it should allow to createNFT if you dont own earlyPass if the total amount for sale is less than 50 ether
  it("should allow to createNFT if you dont own earlyPass if the total amount for sale is less than 50 ether", async () => {
    const nft = await factory.createNFTWithoutAccessPass(
      ether.times(0.003),
      10000,
      1, // reserved
      20,
      0, // royalty fee
      "factory-test-buy/",
      "Cheap Test",
      "LOWNFT",
      user2, // address payoutReceiver,
      true, // bool shouldUseJSONExtension,
      2 + 4 + 8, // uint16 miscParams is a bitmask of 1,2,4,8
      { from: user1 }
    );

    const deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    assert.equal(await deployedNFT.owner(), user1);
  });

  // it should not allow to create without access pass if selling 10000 tokens at 0.08 eth
  it("should not allow to create without access pass if selling 10000 tokens at 0.08 eth", async () => {
    await expectRevert(
      factory.createNFTWithoutAccessPass(
        ether.times(0.08),
        10000,
        1, // reserved
        20,
        0, // royalty fee
        "factory-test-buy/",
        "Cheap Test",
        "LOWNFT",
        user2, // address payoutReceiver,
        true, // bool shouldUseJSONExtension,
        2 + 4 + 8, // uint16 miscParams is a bitmask of 1,2,4,8
        { from: user1 }
      ),
      "MetaverseNFTFactory: Collection total amount is too high"
    );
  });

  // it should be able to set early access pass to zero address, and everyone can mint
  it("should be able to set early access pass to zero address, and everyone can mint", async () => {
    await factory.updateEarlyAccessPass(
      "0x0000000000000000000000000000000000000000"
    );

    const nft = await factory.createNFT(
      ether.times(0.01),
      10000,
      1, // reserved
      20,
      0, // royalty fee
      "factory-test-buy/",
      "Test",
      "NFT",
      { from: user2 } // usually doesn't have access
    );

    const deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    await deployedNFT.claim(1, user2, { from: user2 });
  });

  // it should be able to mint 10 tokens and check totalSupply
  it("should be able to mint 10 tokens and check totalSupply", async () => {
    const nft = await factory.createNFT(
      ether.times(0.01),
      10000,
      1, // reserved
      20,
      0, // royalty fee
      "factory-test-buy/",
      "Test",
      "NFT",
      { from: user1 } // usually doesn't have access
    );

    const deployedNFT = await MetaverseNFT.at(
      nft.logs.find((l) => l.event === "NFTCreated").args.deployedAddress
    );

    await deployedNFT.startSale({ from: user1 });

    await deployedNFT.mint(10, { from: user1, value: ether });

    assert.equal(await deployedNFT.totalSupply(), 10);
  });

  // it shouldn't be able to mint more than maxPerMintLimt
  it("should not be able to mint max per mint limit", async () => {
    await expectRevert(
      factory.createNFT(
        ether.times(0.01),
        10000,
        1, // reserved
        60,
        0, // royalty fee
        "factory-test-buy/",
        "Test",
        "NFT",
        { from: user1 } // usually doesn't have access
      ),
      "MetaverseNFTFactory: Overflowed max tokens per mint"
    );
  });

  it("Should not be able to set mint max per mint limit by non-owner", async () => {
    await expectRevert(
      factory.setMaxPerMintLimit(100, { from: user1 }),
      "Ownable: caller is not the owner"
    );
  });

  it("Should be able to set mint max per mint limit", async () => {
    await factory.setMaxPerMintLimit(100, { from: owner });
    await factory.createNFT(
      ether.times(0.01),
      10000,
      1, // reserved
      60,
      0, // royalty fee
      "factory-test-buy/",
      "Test",
      "NFT",
      { from: user1 } // usually doesn't have access
    );
  });
});
