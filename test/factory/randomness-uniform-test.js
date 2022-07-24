const BigNumber = require("bignumber.js");
const delay = require("delay");
const { assert, expect } = require("chai");
const { ethers, hre, web3 } = require("hardhat");
const { expectRevert } = require("@openzeppelin/test-helpers");

const { getGasCost } = require("../utils");

const MetaverseBaseNFT = artifacts.require("MetaverseBaseNFT_ERC1155");
const NFTExtension = artifacts.require("NFTExtension");
const MockTokenURIExtension = artifacts.require("MockTokenURIExtension");
const LimitAmountSaleExtension = artifacts.require("LimitAmountSaleExtension");
const OffchainAllowListExtension = artifacts.require("OffchainAllowListExtension");

const SERIES = [420, 10, 33, 69, 10, 111, 69, 69, 420, 33, 420, 420, 69, 69, 33, 33, 33, 69, 69, 111, 111, 33, 33, 33, 69, 33, 33, 10, 69, 33, 111, 69, 10, 69, 420, 33, 69, 33, 111, 33, 33, 420, 10, 10, 420, 420, 111, 33, 33, 69, 33, 69, 33, 69, 33, 10, 69, 420, 33, 111, 33, 33, 10, 69, 111, 69, 33, 33, 69, 69, 33, 420, 33, 33, 69, 420, 69, 33, 69, 33, 33, 33, 33, 33, 33, 69, 69, 420];

const ether = new BigNumber(1e18);

const { arrayify, hexZeroPad } = ethers.utils; 

contract("MetaverseBaseNFT_ERC1155 - Implementation", (accounts) => {
  let nft;
  const [owner, user1, user2] = accounts;
  const beneficiary = owner;

  // it should mint 100 tokens one by one and measure gas for each
  it("should mint 100 tokens one by one and measure gas for each", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      10,
      10,
      20,
      500, // royalty
      "https://metadata.buildship.xyz/",
      "Buildship NFT",
      "NFT",
      false
    );

    await nft2.createTokenSeries(Array(10).fill(10));

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    console.log('random seed', randomSeed);

    await nft2.setRandomnessSource(randomSeed);

    await nft2.startSale();

    const gasCost = [];

    // await nft2.claim(beneficiary, 10, { from: owner });

    for (let i = 0; i < 5; i++) {
      const tx = await nft2.mint(10, { from: owner, value: ether.times(0.1) });

      gasCost.push(...Array(10).fill(new BigNumber(tx.receipt.gasUsed).div(10)));
    }

    for (let i = 0; i < 20; i++) {
      const tx = await nft2.mint(2, { from: owner, value: ether.times(0.1) });

      gasCost.push(...Array(2).fill(new BigNumber(tx.receipt.gasUsed).div(2)));
    }

    const gasCostAvg = gasCost.reduce((a, b) => b.plus(a), 0).div(gasCost.length);

    // print gas costs in a table 10x10 for each of the transactions
    // gasCost[i * 10 + j]
    console.log(`
      | ${gasCost[0]} | ${gasCost[1]} | ${gasCost[2]} | ${gasCost[3]} | ${gasCost[4]} | ${gasCost[5]} | ${gasCost[6]} | ${gasCost[7]} | ${gasCost[8]} | ${gasCost[9]} |
      | ${gasCost[10]} | ${gasCost[11]} | ${gasCost[12]} | ${gasCost[13]} | ${gasCost[14]} | ${gasCost[15]} | ${gasCost[16]} | ${gasCost[17]} | ${gasCost[18]} | ${gasCost[19]} |
      | ${gasCost[20]} | ${gasCost[21]} | ${gasCost[22]} | ${gasCost[23]} | ${gasCost[24]} | ${gasCost[25]} | ${gasCost[26]} | ${gasCost[27]} | ${gasCost[28]} | ${gasCost[29]} |
      | ${gasCost[30]} | ${gasCost[31]} | ${gasCost[32]} | ${gasCost[33]} | ${gasCost[34]} | ${gasCost[35]} | ${gasCost[36]} | ${gasCost[37]} | ${gasCost[38]} | ${gasCost[39]} |
      | ${gasCost[40]} | ${gasCost[41]} | ${gasCost[42]} | ${gasCost[43]} | ${gasCost[44]} | ${gasCost[45]} | ${gasCost[46]} | ${gasCost[47]} | ${gasCost[48]} | ${gasCost[49]} |

      Average gas cost: ${gasCostAvg}

      Minting by 2 tokens per tx:

      | ${gasCost[50]} | ${gasCost[51]} | ${gasCost[52]} | ${gasCost[53]} | ${gasCost[54]} | ${gasCost[55]} | ${gasCost[56]} | ${gasCost[57]} | ${gasCost[58]} | ${gasCost[59]} |
      | ${gasCost[60]} | ${gasCost[61]} | ${gasCost[62]} | ${gasCost[63]} | ${gasCost[64]} | ${gasCost[65]} | ${gasCost[66]} | ${gasCost[67]} | ${gasCost[68]} | ${gasCost[69]} |
      | ${gasCost[70]} | ${gasCost[71]} | ${gasCost[72]} | ${gasCost[73]} | ${gasCost[74]}
    `);
  });

  // it should mint 50 out of 100 tokens and token ids should appear according to random distr
  it("should mint 50 out of 100 tokens and token ids should appear according to random distr", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      10,
      10,
      50,
      500, // royalty
      "https://metadata.buildship.xyz/",
      "Buildship NFT",
      "NFT",
      false
    );

    await nft2.createTokenSeries(Array(10).fill(10));

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    console.log('random seed', randomSeed);

    await nft2.setRandomnessSource(randomSeed);

    await nft2.startSale();

    const tx = await nft2.mint(50, { from: owner, value: ether.times(0.1) });

    // const tokenIds = arrayify(tx.logs[0].args.tokenIds);

    const tokenIdsBalances = await Promise.all(Array(10).fill(null).map(async (_, tokenId) => {
      return nft2.balanceOf(owner, tokenId);
    }));

    // count how many balances are 0 and 10
    const zeroBalances = tokenIdsBalances.filter(balance => balance.eq(0));
    const tenBalances = tokenIdsBalances.filter(balance => balance.eq(10));

    // assert.equal(zeroBalances.length, tenBalances.length);

    // token id = 4 balance should not be 10
    // token id = 5 balance should not be 0

    assert.notEqual(tokenIdsBalances[4], 10);
    assert.notEqual(tokenIdsBalances[5], 0);

    // print nice table format tokenIdsBalances
    tokenIdsBalances.forEach((balance, i) => {
      console.log(`~${i}: ${balance}`);
    })

  });

  it("should mint 50 out of 100 tokens and random distr even for broken series", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      10,
      10,
      300,
      500, // royalty
      "https://metadata.buildship.xyz/",
      "Buildship NFT",
      "NFT",
      false
    );

    await nft2.createTokenSeries([100, 20, 100, 20, 100, 20, 100, 20, 100, 20]);

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    console.log('random seed', randomSeed);

    await nft2.setRandomnessSource(randomSeed);

    await nft2.startSale();

    const tx = await nft2.mint(300, { from: owner, value: ether.times(1) });

    // const tokenIds = arrayify(tx.logs[0].args.tokenIds);

    const tokenIdsBalances = await Promise.all(Array(10).fill(null).map(async (_, tokenId) => {
      return nft2.balanceOf(owner, tokenId);
    }));

    // count how many balances are 0 and 10
    const zeroBalances = tokenIdsBalances.filter(balance => balance.eq(0));
    const tenBalances = tokenIdsBalances.filter(balance => balance.eq(10));

    // assert.equal(zeroBalances.length, tenBalances.length);

    // token id = 4 balance should not be 10
    // token id = 5 balance should not be 0

    assert.notEqual(tokenIdsBalances[0], 100);
    assert.notEqual(tokenIdsBalances[1], 20);
    assert.notEqual(tokenIdsBalances[4], 100);
    assert.notEqual(tokenIdsBalances[5], 0);

    // print nice table format tokenIdsBalances
    tokenIdsBalances.forEach((balance, i) => {
      console.log(`~${i}: ${balance}`);
    })

  });

});
