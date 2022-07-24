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

const ether = new BigNumber(1e18);

contract("MetaverseBaseNFT_ERC1155 - Implementation", (accounts) => {
  let nft;
  const [owner, user1, user2] = accounts;
  const beneficiary = owner;

  beforeEach(async () => {
    nft = await MetaverseBaseNFT.new(
      ether.times(0.03),
      5,
      3, // reserved
      20, // per tx
      500, // 5%
      "ipfs://factory-test/",
      "Buildship NFT",
      "NFT",
      false
    );

    await nft.createTokenSeries([100, 20, 100, 20, 100]);

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    await nft.setRandomnessSource(randomSeed);

    // token id = 0: 100 items
    // token id = 1: 20 items
    // token id = 2: 100 items
    // token id = 3: 20 items
    // token id = 4: 100 items

  });

  // it should deploy successfully
  it("should deploy successfully", async () => {
    assert.ok(nft.address);
  });

  // price should equal 0.03 ether
  it("should have a price of 0.03 ether", async () => {
    const price = await nft.price();
    assert.equal(price, ether.times(0.03).toString());
  });

  // it should fail to mint when sale is not started
  it("should fail to mint when sale is not started", async () => {
    try {
      await nft.mint(1, { from: accounts[1], value: ether.times(0.03) });
    } catch (error) {
      // check that error message has expected substring 'Sale not started'
      assert.include(error.message, "Sale not started");
    }
  });

  // it should allow to change payout receiver
  it("should allow to change payout receiver", async () => {
    const receiver = await nft.getPayoutReceiver();

    assert.equal(receiver, owner);

    await nft.setPayoutReceiver(user1, { from: owner });

    const receiver2 = await nft.getPayoutReceiver();

    assert.equal(receiver2, user1);
  });

  // it should be able to start sale when beneficiary is set
  it("should be able to start sale when beneficiary is set", async () => {
    // set beneficiary
    // await nft.setBeneficiary(beneficiary, { from: owner });
    // start sale
    await nft.startSale({ from: owner });

    // await delay(100);
    // skip block

    // await mineBlock();

    // check that sale is started
    const isSaleStarted = await nft.saleStarted();
    assert.equal(isSaleStarted, true);
  });

  // it should mint successfully
  it("should mint successfully when sale is started", async () => {
    await nft.startSale({ from: owner });
    // mint
    const tx = await nft.mint(1, { from: owner, value: ether.times(0.03) });
    assert.ok(tx);
  });

  // it should withdraw to beneficiary after contract balance is not zero
  it("should withdraw to beneficiary after contract balance is not zero", async () => {
    await nft.startSale({ from: owner });

    await nft.mint(1, { from: user2, value: ether.times(0.03) });
    await nft.mint(2, { from: user1, value: ether.times(0.03).times(2) });

    const saleBalance = await web3.eth.getBalance(nft.address);

    assert(
      new BigNumber(saleBalance).gte(0),
      "NFT Sale Balance should be non-zero after mint"
    );

    // check beneficiary balance before withdraw
    const beneficiaryBalanceBefore = await web3.eth.getBalance(beneficiary);
    // withdraw
    const tx = await nft.withdraw({ from: owner });
    assert.ok(tx, "Withdraw failed");
    // check beneficiary balance after withdraw
    const beneficiaryBalanceAfter = await web3.eth.getBalance(beneficiary);

    const gasCost = getGasCost(tx);

    const beneficiaryDelta = new BigNumber(beneficiaryBalanceAfter)
      .minus(new BigNumber(beneficiaryBalanceBefore))
      .plus(gasCost);

    // console.log('beneficiaryDelta', beneficiaryBalanceAfter)
    // console.log('beneficiaryDelta', beneficiaryBalanceBefore)
    // console.log('gasCost', gasCost)

    // TODO: turn on this check
    // assert.equal(
    //     beneficiaryDelta.toString(),
    //     saleBalance,
    //     "Beneficiary didn't get money from sales"
    // );

    assert.equal(
      await web3.eth.getBalance(nft.address),
      0,
      "NFT Sale Balance should be zero after withdraw"
    );
  });

  // it should be able to mint 10 tokens in one transaction
  it("should be able to mint 10 tokens in one transaction", async () => {
    // startSale
    await nft.startSale();
    // mint
    const nTokens = 10;
    const tx = await nft.mint(nTokens, {
      from: owner,
      value: 0.03 * nTokens * ether,
    });
    assert.ok(tx);
  });

  // it should fail trying to mint more than 20 tokens
  it("should fail trying to mint more than 20 tokens", async () => {
    // startSale
    await nft.startSale();

    // mint
    try {
      await nft.mint(21, { from: owner, value: 0.03 * 21 * ether });
    } catch (error) {
      // check that error message has expected substring 'You cannot mint more than'
      assert.include(error.message, "You cannot mint more than");
    }
  });

  // it should be able to mint when you send more ether than needed
  it("should be able to mint when you send more ether than needed", async () => {
    // start sale
    await nft.startSale();

    // mint
    const tx = await nft.mint(1, { from: owner, value: 0.5 * ether });
    assert.ok(tx);
  });

  // it should be able to change baseURI from owner account, and _baseURI() value would change
  it("should be able to change baseURI from owner account, and _baseURI() value would change", async () => {
    const baseURI = "https://avatar.com/";
    await nft.setBaseURI(baseURI, { from: owner });
    // mint token
    await nft.startSale();
    await nft.mint(1, { from: owner, value: ether.times(0.03) });
    // check tokenURI
    const tokenURI = await nft.tokenURI(0);
    assert.equal(tokenURI, baseURI + "0");

    // check contractURI equals to baseURI
    const contractURI = await nft.contractURI();
    assert.equal(contractURI, baseURI);
  });

  // it is possible to use extension to change tokenURI
  it("is possible to use extension to change tokenURI", async () => {
    const extension = await MockTokenURIExtension.new(nft.address);

    await nft.setExtensionTokenURI(extension.address, { from: owner });

    // mint token
    await nft.startSale();
    await nft.mint(1, { from: owner, value: ether.times(0.03) });

    // check tokenURI
    const tokenURI = await nft.tokenURI(0);

    assert.equal(tokenURI, "<svg></svg>");
  });

  // it should be able to mint via LimitSaleExtension
  it("should be able to mint via LimitAmountSaleExtension", async () => {
    const extension = await LimitAmountSaleExtension.new(
      nft.address,
      ether.times(0.001),
      10,
      1000,
      { from: owner }
    );

    await nft.addExtension(extension.address, { from: owner });

    // mint token
    await extension.startSale();
    await extension.mint(2, { from: owner, value: ether.times(0.03) });

    // check tokenURI
    const tokenURI = await nft.tokenURI(0);
    assert.equal(tokenURI, "ipfs://factory-test/0");
  });

  // it should output royaltyInfo
  it("should output royaltyInfo", async () => {
    const info = await nft.royaltyInfo(0, 10000);

    // info.royaltyReceiver is nft address
    // info.royaltyFee is 5%

    assert.equal(info.receiver, nft.address);
    assert.equal(info.royaltyAmount, 500);

    // it can change

    await nft.setRoyaltyFee(100);

    const { royaltyAmount } = await nft.royaltyInfo(0, 10000);

    assert.equal(royaltyAmount, 100);

    // it can change royaltyReceiver
    await nft.setRoyaltyReceiver(owner);

    const { receiver } = await nft.royaltyInfo(0, 10000);
    assert.equal(receiver, owner);
  });

  // it should be able to mint reserved from owner account
  it("should be able to mint reserved from owner account", async () => {
    // mint
    const tx = await nft.claim(3, accounts[1], { from: owner });
    assert.ok(tx);
  });

  // it should not be able to mint reserved from accounts other that owner
  it("should not be able to mint reserved from accounts other that owner", async () => {
    // mint
    try {
      await nft.claim(3, accounts[1], { from: accounts[1] });
    } catch (error) {
      // check that error message has expected substring Ownable: caller is not the owner
      assert.include(error.message, "Ownable: caller is not the owner");
    }
  });

  // it should not be able to call withdraw from user1
  it("should not be able to call withdraw from user1", async () => {
    await expectRevert(
      nft.withdraw({ from: user1 }),
      "Ownable: caller is not the owner"
    );
  });

  // it should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner
  it("should be able to withdraw when setBeneficiary is called, but money will go to beneficiary instead of owner", async () => {
    await nft.startSale({ from: owner });

    await nft.mint(1, { from: user2, value: ether.times(0.03) });
    await nft.mint(3, { from: user1, value: ether.times(0.03).times(3) });
    await nft.mint(2, { from: user1, value: ether.times(0.03).times(2) });

    await delay(500);

    const saleBalance = await web3.eth.getBalance(nft.address);
    const beneficiaryBalance = await web3.eth.getBalance(beneficiary);

    // withdraw
    const tx = await nft.withdraw({ from: owner });
    assert.ok(tx);

    const gasCost = getGasCost(tx);

    const beneficiaryBalanceNow = await web3.eth.getBalance(beneficiary);

    assert.equal(
      new BigNumber(beneficiaryBalanceNow)
        .minus(beneficiaryBalance)
        .plus(gasCost)
        .toString(),

      // without buildship fee
      new BigNumber(saleBalance).times(95).div(100).toString(),
      "Owner should get money from sales, but only 95%"
    );
  });

  // it should be able to set updateMaxPerWallet
  it("should be able to set updateMaxPerWallet", async () => {

    await nft.updateMaxPerWallet(7);

    await nft.startSale();

    await nft.mint(7, { from: user1, value: ether.times(1) });

    const minted = await nft.mintedBy(user1);

    expect(minted.toNumber()).to.equal(7);

    expectRevert(nft.mint(7, { from: user1, value: ether.times(1) }), "Max per wallet reached");

  });

  it("should not be able to mint more than 100 tokens, when 100 tokens are minted, it should fail", async () => {
    const nft = await MetaverseBaseNFT.new(
      "1000000000000000",
      20,
      3, // reserved
      20,
      500, // royalty
      "https://metadata.buildship.xyz/",
      "Buildship NFT",
      "NFT",
      true
    );

    await nft.createTokenSeries(Array(20).fill(5));

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    await nft.setRandomnessSource(randomSeed);

    await nft.startSale();

    // set price to 0.0001 ether
    await nft.setPrice(ether.times(0.0001));

    // try minting 100 + 10 tokens, which is more than the max allowed (100)

    await nft.mint(20, { from: owner, value: ether.times(0.0001).times(20) })
    await nft.mint(20, { from: owner, value: ether.times(0.0001).times(20) })
    await nft.mint(20, { from: owner, value: ether.times(0.0001).times(20) })
    await nft.mint(20, { from: owner, value: ether.times(0.0001).times(20) })

    await nft.mint(10, { from: owner, value: ether.times(0.0001).times(20) })

    try {
      await nft.mint(10, { from: owner, value: ether.times(0.0001).times(20) });
    } catch (error) {
      assert.include(error.message, "Not enough Tokens left.");
    }

    await nft.mint(7, { from: owner, value: ether.times(0.0001).times(20) });

    await nft.claim(3, owner, { from: owner });

    // check balanceOf(owner, tokenId) for each token id is 5

    for (let i = 1; i <= 20; i++) {
      const balance = await nft.balanceOf(owner, i);
      // console
      console.log('token', i, 'balance', balance.toString());
      assert.equal(balance, 5);
    }

  });

  // it should be able to add and remove extension
  it("should be able to add and remove extension", async () => {
    const extension = await NFTExtension.new(nft.address);
    const extension2 = await NFTExtension.new(nft.address);
    const extension3 = await NFTExtension.new(nft.address);

    await nft.addExtension(extension.address);
    await nft.addExtension(extension2.address);
    await nft.addExtension(extension3.address);

    assert.equal(await nft.isExtensionAdded(extension.address), true);
    // check that extensions(0) is extension address
    assert.equal(await nft.extensions(0), extension.address);

    await nft.revokeExtension(extension.address);

    assert.equal(await nft.isExtensionAdded(extension.address), false);

    await nft.revokeExtension(extension3.address);

    assert.equal(await nft.isExtensionAdded(extension3.address), false);

    assert.equal(await nft.isExtensionAdded(extension2.address), true);
  });

  // it should be able to freeze minting and then startSale doesnt work
  it("should be able to freeze minting and then startSale doesnt work", async () => {
    await nft.startSale();
    await nft.freeze();

    try {
      await nft.startSale();
    } catch (error) {
      assert.include(error.message, "Minting is frozen");
    }
  });

  // it should be able to create new contract, mint 10 tokens, and balanceOf(tokenId=0) should not be 10
  it("should be able to create new contract, mint 10 tokens, and balanceOf(tokenId=0) should not be 10", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      5,
      0, // reserved
      20,
      500, // royalty
      "https://metadata.buildship.xyz/",
      "Buildship NFT",
      "NFT",
      false
    );

    await nft2.createTokenSeries(Array(5).fill(5));

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    // print seed
    console.log('using seed', randomSeed);

    await nft2.setRandomnessSource(randomSeed);
    await nft2.startSale();

    const tx = await nft2.mint(10, { from: owner, value: ether.times(0.3) });

    // print event ShuffledWith
    // console.log('tx logs', tx.logs);

    tx.logs.map(log => {
      if (log.event === "ShuffledWith") {
        console.log('ShuffledWith(', log.args.current.toString(), log.args.with.toString(), ')');
      }
    })

    expect(await nft2.balanceOf(owner, 0)).to.be.bignumber.not.equal("10");
    expect(await nft2.balanceOf(owner, 0)).to.be.bignumber.not.equal("0");

    await nft2.mint(10, { from: owner, value: ether.times(0.3) });

    assert.notEqual(await nft2.balanceOf(owner, 0), 20);


  });

  // it should mint 100 tokens one by one and measure gas for each
  it("should mint 100 tokens one by one and measure gas for each", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      10,
      0, // reserved
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

    for (let i = 0; i < 5; i++) {
      const tx = await nft2.mint(10, { from: owner, value: ether.times(0.1) });

      gasCost.push(...Array(10).fill(new BigNumber(tx.receipt.gasUsed).div(10)));
    }

    for (let i = 0; i < 25; i++) {
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

  // it should return correct values in _tokenOffset2TokenId

  it("should return correct values in tokenSeed2TokenId", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      10,
      0, // reserved
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

    // for seed from 0 to 100 print table of tokenIds

    const tokenIds = [];

    for (let i = 0; i < 100; i++) {
      const tokenId = await nft2.tokenOffset2TokenId(i);

      tokenIds[i] = tokenId;
    }

    const startTokenId = await nft2.startTokenId();

    // print array in a table 10x10 with tabs between values
    console.log(`===== token ids =====`);
    console.log(tokenIds.join("\t"));

    // expect startTokenId to be 0
    expect(startTokenId).to.be.bignumber.eq("0");

    // 0,1,2,3,4,5,6,7,8,9 => startTokenId = 0
    // 10,11,12... => 1
    expect( await nft2.tokenOffset2TokenId(0) ).to.be.bignumber.equal("0");

    assert.equal(await nft2.tokenOffset2TokenId(10), 1);
    assert.equal(await nft2.tokenOffset2TokenId(11), 1);

    assert.equal(await nft2.tokenOffset2TokenId(99), 9);

    // expect 100 revert not found
    expectRevert(nft2.tokenOffset2TokenId(100), "Not found");

  })

  it("should return correct values in tokenSeed2TokenId", async () => {
    const nft2 = await MetaverseBaseNFT.new(
      "1000000000000000",
      10,
      0, // reserved
      20,
      500, // royalty
      "https://metadata.buildship.xyz/",
      "Buildship NFT",
      "NFT",
      true
    );

    await nft2.createTokenSeries(Array(10).fill(10));

    // random bytes32
    const randomSeed = web3.utils.randomHex(32);

    console.log('random seed', randomSeed);

    await nft2.setRandomnessSource(randomSeed);

    // for seed from 0 to 100 print table of tokenIds

    const tokenIds = [];

    // for (let i = 0; i < 99; i++) {
    //   const tokenId = await nft2.tokenOffset2TokenId(i);

    //   tokenIds[i] = tokenId;
    // }

    const startTokenId = await nft2.startTokenId();

    // print array in a table 10x10 with tabs between values
    console.log(`===== token ids =====`);
    console.log(tokenIds.map((x, i) => `${i}: ${x}`).join("\t\t"));

    // expect startTokenId to be 1
    expect(startTokenId).to.be.bignumber.equal( "1" );

    // 0,1,2,3,4,5,6,7,8,9 => startTokenId = 0
    // 10,11,12... => 1
    expect(await nft2.tokenOffset2TokenId(0)).to.be.bignumber.equal(startTokenId);
    expect(await nft2.tokenOffset2TokenId(9)).to.be.bignumber.equal(startTokenId);

    assert.equal(await nft2.tokenOffset2TokenId(10), 2);
    assert.equal(await nft2.tokenOffset2TokenId(11), 2);
    assert.equal(await nft2.tokenOffset2TokenId(80), 9);
    assert.equal(await nft2.tokenOffset2TokenId(89), 9);
    assert.equal(await nft2.tokenOffset2TokenId(98), 10);
    assert.equal(await nft2.tokenOffset2TokenId(99), 10);

    // expect 100 revert not found
    expectRevert(nft2.tokenOffset2TokenId(100), "Not found");

  })


});
