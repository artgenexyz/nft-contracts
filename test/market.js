const { assert } = require("chai");

const { BN } = web3.utils;

const Market = artifacts.require("Market");

const ERC1155Sale = artifacts.require("ERC1155Sale");

/*
 Simple ERC1155 marketplace. It represents in-game items, so each option corresponds to an game item, like: Skin, Weapon, Armor.
 
 The features:
 - admin can add new items to the marketplace (provides ipfs metadata url, name, price, max supply)
 - admin can change price for each item
 - users can purchase item if minter didn't run out of supply and if saleStarted = true
 - users can list item for sale
 - users can buy items from other users
 - admin can withdraw funds from sale, but 10% goes to the developer address "0x704C043CeB93bD6cBE570C6A2708c3E1C0310587"
 - tokens are burnable
 - admin can flipSaleStarted, switching between sale active or disabled (saleStarted is true/false)

 Items are stored in array of struct GameItem.

 In ERC1155, tokens have id, which represents itemId.
 */


contract("Market", function (accounts) {
  const [admin, user1, user2, user3] = accounts;

  let marketplace, extras;

  const ether = new BN(web3.utils.toWei("1", "ether"));

  // it should be possible to deploy marketplace
  it("should be possible to deploy marketplace", async function () {
    extras = await ERC1155Sale.new();

    marketplace = await Market.new(extras.address, { from: admin });

    assert.isTrue(marketplace.address !== undefined);

    const tokenContract = await marketplace.tokenContract();

    assert.equal(tokenContract, extras.address);

    const owner = await marketplace.owner();

    assert.equal(owner, admin);
  });

  // prepare users: buy tokens from extras for each user
  it("should be possible to buy tokens from extras", async function () {
    await extras.addItem(
      "Test Item",
      "https://uri",
      "ipfs://animation",
      (10 * 1e16).toString(),
      1000,
      0,
      false
    );
    await extras.addItem(
      "Golden Sword",
      "https://uri",
      "ipfs://animation",
      (20 * 1e16).toString(),
      50,
      0,
      true
    );
    await extras.startSaleAll({ from: admin });
    await extras.buyItem(0, 10, { from: user1, value: 1e18 });
    await extras.buyItem(1, 10, { from: user1, value: 2 * 1e18 });
  });

  // it should be possible to list token for sale
  it("should be possible to list token for sale", async function () {
    // we put 2 so we can later check that user didn't sell all his tokens
    await extras.setApprovalForAll(marketplace.address, true, { from: user1 });
    await marketplace.list(0, 2, 2, { from: user1 });

    const offer = await marketplace.offers(0, user1);
    // const offer = tokenOffers(user1.address);

    assert.equal(offer.price, 2);
    assert.equal(offer.amount, 2);
    // assert.equal(offer.owner, user1);
  });

  // it should be possible to buy listed token
  it("should be possible to buy 1 of 2 listed token", async function () {
    await extras.setApprovalForAll(marketplace.address, true, { from: user1 });
    await marketplace.buy(0, user1, 1, { from: user2, value: 2 * 1e18 });

      const offer = await marketplace.offers(0, user1);

    assert.equal(offer.price, 2);
    assert.equal(offer.amount, 1);
    // assert.equal(offer.owner, user1);

    // check that user2 got the token id = 0
    const user2balance = await extras.balanceOf(user2, 0);
    assert.equal(user2balance, 1);
  });

  // it should be possible to buy full offer, and offer is removed
  it("should be possible to buy full offer, and offer is removed", async function () {
    await extras.setApprovalForAll(marketplace.address, true, { from: user1 });
    await marketplace.buy(0, user1, 1, { from: user3, value: 2 * 1e18 });

    const offer = await marketplace.offers(0, user1);

    assert.equal(offer.price, 0);
    assert.equal(offer.amount, 0);
    // assert.equal(offer.owner, "0x0000000000000000000000000000000000000000");

    // check that user3 got the token id = 0
    const user3balance = await extras.balanceOf(user3, 0);
    assert.equal(user3balance, 1);
  });

});
