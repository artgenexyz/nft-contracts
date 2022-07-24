const BigNumber = require("bignumber.js");
const delay = require("delay");
const { assert, expect } = require("chai");
const { web3 } = require("hardhat");
const { expectRevert } = require("@openzeppelin/test-helpers");

const MetaverseBaseNFT = artifacts.require("MetaverseBaseNFT_ERC1155");
const Wilderness = artifacts.require("Wilderness");

// const SERIES = [420, 10, 33, 69, 10, 111, 69] //, 69, 420, 33, 420, 420, 69, 69, 33, 33, 33, 69, 69, 111, 111, 33, 33, 33, 69, 33, 33, 10, 69, 33, 111, 69, 10, 69, 420, 33, 69, 33, 111, 33, 33, 420, 10, 10, 420, 420, 111, 33, 33, 69, 33, 69, 33, 69, 33, 10, 69, 420, 33, 111, 33, 33, 10, 69, 111, 69, 33, 33, 69, 69, 33, 420, 33, 33, 69, 420, 69, 33, 69, 33, 33, 33, 33, 33, 33, 69, 69, 420];
const SERIES = [420, 10, 33, 69, 10, 111, 69, 69, 420, 33, 420, 420, 69, 69, 33, 33, 33, 69, 69, 111, 111, 33, 33, 33, 69, 33, 33, 10, 69, 33, 111, 69, 10, 69, 420, 33, 69, 33, 111, 33, 33, 420, 10, 10, 420, 420, 111, 33, 33, 69, 33, 69, 33, 69, 33, 10, 69, 420, 33, 111, 33, 33, 10, 69, 111, 69, 33, 33, 69, 69, 33, 420, 33, 33, 69, 420, 69, 33, 69, 33, 33, 33, 33, 33, 33, 69, 69, 420];

const ether = new BigNumber(1e18);

contract("Wilderness to Blockchain - Implementation", (accounts) => {
  let nft;
  const [owner, user1, user2] = accounts;
  const beneficiary = owner;

  beforeEach(async () => {
    nft = await MetaverseBaseNFT.new(
      ether.times(0.01),
      88,
      10, // reserved
      20, // per tx
      500, // 5%
      "ipfs://factory-test/",
      "Buildship NFT",
      "NFT",
      true
    );

    await nft.createTokenSeries(SERIES);

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    await nft.setRandomnessSource(randomSeed);

  });

  // it should deploy successfully
  it("should deploy successfully", async () => {
    assert.ok(nft.address);
  });

  // price should equal 0.01 ether
  it("should have a price of 0.01 ether", async () => {
    const price = await nft.price();
    assert.equal(price, ether.times(0.01).toString());
  });

  // it should deploy Wilderness
  it("should deploy Wilderness", async () => {
    const wilderness = await Wilderness.new();

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    await wilderness.setRandomnessSource(randomSeed);


    const tx = await wilderness.claim(1, user1);

    // logs have Transfer event
    expect(tx.logs[1].event).to.equal("TransferSingle");

    await wilderness.startSale();

    await wilderness.mint(1, { from: user1, value: 0 });
  });

  // it should match series
  it("should match series in wilderness", async () => {
    const wilderness = await Wilderness.new();

    for (let i = 0; i < SERIES.length; i++) {
      const series = await wilderness.maxSeriesSupply(i + 1);

      console.log(`Series ${i + 1} = ${series}`);

      assert.equal(series.toNumber(), SERIES[i]);
    }

    const maxSupply = await wilderness.maxSupplyAll();

    console.log(`Max supply = ${maxSupply}`);

    assert.equal(maxSupply.toNumber(), SERIES.reduce((a, b) => a + b));
    assert.equal(maxSupply.toNumber(), 8888);

  });

  // it should be able to mint 100 tokens
  it("should be able to mint 100 tokens", async () => {
    await nft.startSale();

    const balanceBefore = await nft.balanceOf(user1, 1);

    assert.equal(balanceBefore, 0);

    await nft.mint(20, { from: user1, value: ether.times(0.2) });
    await nft.mint(20, { from: user1, value: ether.times(0.2) });
    await nft.mint(20, { from: user1, value: ether.times(0.2) });
    await nft.mint(20, { from: user1, value: ether.times(0.2) });
    await nft.mint(20, { from: user1, value: ether.times(0.2) });

    const balanceAfter1 = await nft.balanceOf(user1, 1);
    const balanceAfter2 = await nft.balanceOf(user1, 2);

    const minted = await nft.mintedBy(user1);

    console.log('balance after 1', balanceAfter1.toString());
    console.log('balance after 2', balanceAfter2.toString());

    expect(minted.toNumber()).to.equal(100);


  });

  // it should match the series
  it("should match the series", async () => {

    for (let i = 0; i < SERIES.length; i++) {
      const series = await nft.maxSeriesSupply(i + 1);

      assert.equal(series.toNumber(), SERIES[i]);
    }

  })

  // it should be able to mint full 8888 tokens
  // DISABLED TO KEEP TESTS FROM RUNNING TOO LONG
  xit("should be able to mint full 8888 tokens", async () => {
    const startTimestamp = Date.now()

    await nft.startSale();

    const balanceBefore = await nft.balanceOf(user1, 1);

    assert.equal(balanceBefore, 0);

    await nft.updateMaxPerMint(10_000);
    await nft.setPrice(ether.times(0.0001));

    // mint 100 tokens in 88 cycles
    await Promise.all(Array(44).fill(0).map(async (_, i) => {
      await nft.mint(200, { from: user1, value: ether.times(0.1) })
    }));

    console.log('time passed', (Date.now() - startTimestamp) / 1000, 'sec...');

    console.log('total supply all', (await nft.totalSupplyAll()).toString());
    console.log('max supply all', (await nft.maxSupplyAll()).toString());
    console.log('reserved left', (await nft.reserved()).toString());

    await nft.mint(78, { from: user1, value: ether.times(0.1) });

    await nft.claim(10, user1, { from: owner });

    const balanceAfter = await nft.balanceOf(user1, 1);
    const maxSupplyToken1 = await nft.maxSeriesSupply(1);

    console.log('balance after', balanceAfter.toString());
    console.log('max supply token 1', maxSupplyToken1.toString());

    for (let i = 1; i <= 88; i++) {
      const balance = await nft.balanceOf(user1, i);
      console.log('token', i, 'balance', balance.toString());
      assert.equal(balance, SERIES[i - 1]);
    }

    for (let i = 0; i < SERIES.length; i++) {
      const series = await nft.totalSeriesSupply(i + 1);

      assert.equal(series.toNumber(), SERIES[i]);
    }

    // Array(88).fill(0).forEach(async (_, i) => {
    //   console.log('token id', i+1, 'balance', (await nft.balanceOf(user1, i+1)).toString());
    // });

    assert.equal(balanceAfter.toNumber(), maxSupplyToken1.toNumber());

  }).timeout(1_000_000);

});
