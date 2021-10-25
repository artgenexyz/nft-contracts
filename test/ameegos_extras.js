const { expectRevert } = require("@openzeppelin/test-helpers");

const { expect, assert } = require("chai");

const { BN } = web3.utils;

const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("AmeegosMarketplace", function (accounts) {
  const [ owner, user1, user2, user3 ] = accounts;

  // const marketplace = await AmeegosMarketplace.new();

  it("should assert true", async function () {
    await AmeegosMarketplace.deployed();
    return assert.isTrue(true);
  });

  // it should not allow to buyItem when sale is not started
  it("should not allow to buyItem when sale is not started", async function () {
    const extras = await AmeegosMarketplace.deployed();
    const saleStarted = await extras.saleStarted(0);

    assert.equal(saleStarted, false, "sale should not be started");

    const itemId = 0;
    const nItems = 1;

    try {
      await extras.buyItem(0, 1, { from: user1, value: 1e18 });
    } catch (error) {
      // error message should be Sale not started
      assert.include(error.message, "Sale not started");
    }

  });

  // TODO: rewrite so it makes sense
  // // it should fail if you try to buy item when there are no items (totalItems == 0)
  // it("should fail if you try to buy item when there are no items (totalItems == 0)", async function () {
  //   const extras = await AmeegosMarketplace.deployed();

  //   const itemId = 0;
  //   const nItems = 1;

  //   const totalItems = await extras.totalItems();

  //   assert(totalItems, 0, "there should be no items until we create");

  //   try {
  //     await extras.buyItem(0, 1, { from: user1, value: 1e18 });
  //   } catch (error) {
  //     // Error message should include "No itemId"
  //     assert.include(error.message, "No itemId");
  //   }
  // });

  // it should be able to add item
  it("should be able to add item", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const itemId = 0;
    const nItems = 1;

    const totalItems = await extras.totalItems();

    assert(totalItems, 0, "there should be no items until we create");

    await extras.addItem("Test Item", "https://uri", 1e18.toString(), 1000, false);

    const totalItems2 = await extras.totalItems();

    assert(totalItems2, 1, "there should be one item");

    const item = await extras.items(itemId);

    assert.equal(item.name, "Test Item", "item name should be Test Item");
    assert.equal(item.price, 1e18, "item price should be 1e18");
    assert.equal(item.maxSupply, 1000, "item quantity should be 1000");
  });

  // it should be able to flipSaleStarted if you're an owner
  it("should be able to flipSaleStarted if you're an owner", async function () {
    const extras = await AmeegosMarketplace.deployed();
    const saleStarted = await extras.saleStarted(0);

    assert.equal(saleStarted, false, "sale should not be started");

    await extras.flipSaleStarted(0);

    const saleStarted2 = await extras.saleStarted(0);

    assert.equal(saleStarted2, true, "sale should be started");
  });

  // it should be able to add multiple items: Lizard Skin with price 0.1 ether, Stone Armour with price 0.05 ether, Golden Sword with price 0.2 ether
  it("should be able to add multiple items: Lizard Skin with price 0.1 ether, Stone Armour with price 0.05 ether, Golden Sword with price 0.2 ether", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const totalItems = await extras.totalItems();

    await extras.addItem("Lizard Skin", "https://uri", (10 * 1e16).toString(), 100, true);
    await extras.addItem("Stone Armour", "https://uri", (5 * 1e16).toString(), 200, true);
    await extras.addItem("Golden Sword", "https://uri", (20 * 1e16).toString(), 50, true);

    const totalItems2 = await extras.totalItems();

    assert(totalItems2 - totalItems, 3, "there should be three new items");

    const item = await extras.items(Number(totalItems) + 0);

    assert.equal(item.name, "Lizard Skin", "item name should be Lizard Skin");
    assert.equal(item.price, 10 * 1e16, "item price should be 10 * 1e16");
    assert.equal(item.maxSupply, 100, "item quantity should be 100");

    const item2 = await extras.items(Number(totalItems) + 1);

    assert.equal(item2.name, "Stone Armour", "item name should be Stone Armour");
    assert.equal(item2.price, 5 * 1e16, "item price should be 5 * 1e16");
    assert.equal(item2.maxSupply, 200, "item quantity should be 200");

    const item3 = await extras.items(Number(totalItems) + 2);

    assert.equal(item3.name, "Golden Sword", "item name should be Golden Sword");
    assert.equal(item3.price, 20 * 1e16, "item price should be 20 * 1e16");
    assert.equal(item3.maxSupply, 50, "item quantity should be 50");

  });

  // it should not be able to add item with invalid maxSupply = 0
  it("should not be able to add item with invalid maxSupply = 0", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const totalItems = await extras.totalItems();

    try {
      await extras.addItem("Test Item", "https://uri", 1e18.toString(), 0, true);
    } catch (error) {
      // Error message should include "Invalid maxSupply"
      assert.include(error.message, "Invalid maxSupply");
    }

    const totalItems2 = await extras.totalItems();

    assert.equal(totalItems2 - totalItems, 0, "there should be no new items");
  });

  // it should be able to buy items if sale is started and there are items
  it("should be able to buy items if sale is started and there are items", async function () {
    const extras = await AmeegosMarketplace.deployed();
    const saleStarted = await extras.saleStarted(0);

    assert.equal(saleStarted, true, "sale should be started");

    await extras.buyItem(0, 1, { from: user1, value: 1e18 });

    const itemBought = await extras.balanceOf(user1, 0);

    assert.equal(itemBought, 1, "item should be bought");
  });

  // it should be able to buy 5 items of Lizard Skin
  it("should be able to buy 5 items", async function () {

    const extras = await AmeegosMarketplace.deployed();

    const itemId = 1; // Lizard Skin
    const nItems = 5;

    await extras.buyItem(1, 5, { from: user1, value: 5 * 10 * 1e16 });

    const itemBought = await extras.balanceOf(user1, 1);

    assert.equal(itemBought, 5, "5 items should be bought");
  });

  // it should be able to buy all 200 tokens of Stone Armour
  it("should be able to buy all 200 tokens of Stone Armour, but no more than that", async function () {

    const extras = await AmeegosMarketplace.deployed();

    const itemId = 4; // Incredible Capricorn

    await extras.addItem("Incredible Capricorn", "https://uri", (2 * 1e16).toString(), 200, true);

    await extras.buyItem(4, 200, { from: user1, value: 200 * 2 * 1e16 });

    // check item.mintedSupply equals to item.maxSupply

    const item = await extras.items(itemId);

    assert(item.mintedSupply.eq(item.maxSupply), "item.mintedSupply should be equal to item.maxSupply");

    // check that can't buy more

    try {
      await extras.buyItem(4, 1, { from: user1, value: 2 * 1e16 });
    } catch (err) {
      // should include "Out of stock"
      assert.include(err.message, "Out of stock");
    }
  });

  // it should be able to lower the price for Golden Sword and buy 10 pieces at the new price
  it("should be able to lower the price for Golden Sword and buy at the new price", async function () {

    const extras = await AmeegosMarketplace.deployed();

    const itemId = 3; // Golden Sword

    const newPrice = 19 * 1e16;

    await extras.changePrice(3, newPrice.toString(), { from: owner });

    await extras.buyItem(3, 10, { from: user2, value: (10 * newPrice).toString() });

    const itemsBought = await extras.balanceOf(user2, 3);

    assert.equal(itemsBought, 10, "item should be bought");
  });

  // it should be able to withdraw sales money, and 10% should go to 0x704C043CeB93bD6cBE570C6A2708c3E1C0310587
  it("should be able to withdraw sales money, and 10% should go to 0x704C043CeB93bD6cBE570C6A2708c3E1C0310587", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const buildship = "0x704C043CeB93bD6cBE570C6A2708c3E1C0310587";

    const buildshipBalanceBefore = await web3.eth.getBalance(buildship);
    const ownerBalanceBefore = await web3.eth.getBalance(owner);
    const salesBalanceBefore = await web3.eth.getBalance(extras.address);

    const tx = await extras.withdraw({ from: owner });

    const gasCost = new BN(tx.receipt.gasUsed).mul(await web3.eth.getGasPrice());

    const buildshipBalanceAfter = await web3.eth.getBalance(buildship);
    const ownerBalanceAfter = await web3.eth.getBalance(owner);
    const salesBalanceAfter = await web3.eth.getBalance(extras.address);

    assert(buildshipBalanceAfter - buildshipBalanceBefore > 0, "buildship should have more money after withdraw");
    assert(ownerBalanceAfter - ownerBalanceBefore > 0, "owner should have more money after withdraw");
    assert(salesBalanceAfter == 0, "contract should withdraw all money");

    // check that 10% of salesBalanceBefore goes to buildship, and 90% goes to owner
    assert.equal(buildshipBalanceAfter - buildshipBalanceBefore, salesBalanceBefore / 10, "10% of salesBalanceBefore should go to buildship");

    assert.equal(
      new BN(ownerBalanceAfter).sub(new BN(ownerBalanceBefore)).add(gasCost).toString(),
      new BN(salesBalanceBefore).muln(9).divn(10).toString(),
      "90% of salesBalanceBefore should go to owner"
    );

  });


  it("should be able to call URI", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const itemId = 2; // Stone Armour

    const uri = await extras.uri(itemId);

    assert.include(uri, 'application/json', "URI should encode json into base64");

  });

  // it should be able to call and parse contractURI as base64 json
  it("should be able to call and parse contractURI as base64 json", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const uriData = await extras.contractURI();

    // remove 'data:application/json;base64,' from beginning of string

    const rawData = uriData.replace('data:application/json;base64,', '');

    const uri = Buffer.from(rawData, 'base64').toString();

    const json = JSON.parse(uri);

    // '"name": "Ameegos Extra Items Collection",',
    // '"description": "The Fight for Meegosa is an NFT community MMORPG that utilises blockchain technology to give the gamer true ownership of their in-game assets. Our vision is to become the leader in decentralised, play-to-earn, PVM & PVP gaming. Learn more in our discord: https://discord.gg/c7NRVvvVZt https://twitter.com/AmeegosOfficial https://ameegos.io/",',
    // '"external_link": "https://ameegos.io"',

    assert.equal(json.name, "Ameegos Extra Items Collection", "name should be Ameegos Extra Items Collection");
    assert.equal(json.external_link, "https://ameegos.io");
    assert.include(json.description, "Fight for Meegosa");
  });

  // it should not be able to buy if supply less ETH than price
  it("should not be able to buy if supply less ETH than price", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const itemId = 1; // Lizard Skin

    try {
      await extras.buyItem(itemId, 1, { from: user1, value: 1e16 });
    } catch (err) {
      // should include "Not enough ETH"
      assert.include(err.message, "Not enough ETH");
    }
  });

  // it should be able to buyItemBatch
  it("should be able to buyItemBatch", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const itemIds = [1, 2]; // Lizard Skin, Stone Armour

    const amounts = [5, 5]; // 5 Lizard Skin, 5 Stone Armour

    const total = 5 * 10 * 1e16 + 5 * 5 * 1e16;

    await extras.buyItemBatch(itemIds, amounts, { from: user3, value: total });

    const lizards = await extras.balanceOf(user3, 1);
    const stones = await extras.balanceOf(user3, 2);

    assert.equal(lizards, 5, "items 1 should be bought");
    assert.equal(stones, 5, "items 2 should be bought");
  });

  // it should allow owner to claim items for free
  it("should allow owner to claim items for free", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const itemIds = [1, 2]; // Lizard Skin, Stone Armour

    const amounts = [5, 5]; // 5 Lizard Skin, 5 Stone Armour
    await extras.claimItemBatch(itemIds, amounts, { from: owner });

    const lizards = await extras.balanceOf(owner, 1);
    const stones = await extras.balanceOf(owner, 2);

    assert.equal(lizards, 5, "items 1 should be claimed");
    assert.equal(stones, 5, "items 2 should be claimed");
  });

  // it should allow owner to create new item and claim it all before sale started
  it("should allow owner to create new item and claim it all before sale started", async function () {
    const extras = await AmeegosMarketplace.deployed();

    const amount = 100;

    // addItem Bankless Banker with 100 supply
    const tx = await extras.addItem("Bankless Banker", "https://mock", (100 * 1e16).toString(), amount, { from: owner });

    const { itemId } = tx.logs[0].args;

    await extras.claimItem(itemId, amount, { from: owner });

    const newItemBalance = await extras.balanceOf(owner, itemId);

    assert.equal(newItemBalance, amount, "new item should be created");
  });

})
