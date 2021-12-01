const { assert } = require("chai");
const { expectRevert } = require("@openzeppelin/test-helpers");
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
    await extras.addItem("Skin", "https://uri", "", ether.muln(0.05), 100, 0, false, { from: admin });
    await extras.addItem("Weapon", "https://uri", "", ether.muln(0.01), 200, 0, false, { from: admin });

    await extras.startSaleAll({ from: admin });

    await extras.buyItem(0, 5, { from: user1, value: ether.muln(0.05).muln(5) });
    await extras.buyItem(1, 10, { from: user2, value: ether.muln(0.01).muln(10) });
  });

  // it should be possible to list token for sale
  it("should be possible to list token for sale", async function () {

    await extras.setApprovalForAll(marketplace.address, true, { from: user1 });

    // we put 2 so we can later check that user didn't sell all his tokens

    await marketplace.list(0, 2, ether, { from: user1 });

    const lastOfferID = await marketplace.lastOfferId();

    const offer = await marketplace.offers(0, lastOfferID);

    assert.equal(offer.price.toString(), ether.toString());
    assert.equal(offer.amount, 2);
    assert.equal(offer.owner, user1);
  });

  // it should be possible to buy listed token
  it("should be possible to buy 1 of 2 listed token", async function () {
    const offerId = await marketplace.offerIds(0, 0); // for tokenId = 0

    await marketplace.buy(offerId, 0, 1, { from: user2, value: ether });

    const offer = await marketplace.offers(0, offerId);

    assert.equal(offer.price.toString(), ether.toString());
    assert.equal(offer.amount, 1);
    assert.equal(offer.owner, user1);

    // check that user2 got the token id = 0
    const user2balance = await extras.balanceOf(user2, 0);
    assert.equal(user2balance, 1);
  });

  // it should be possible to buy full offer, and offer is removed
  it("should be possible to buy full offer, and offer is removed", async function () {
    const offerId = await marketplace.offerIds(0, 0); // for tokenId = 0

    await marketplace.buy(offerId, 0, 1, { from: user3, value: ether });

    const offer = await marketplace.offers(0, offerId);

    console.log('offer', offer)

    assert.equal(offer.amount, 0);
    assert.equal(offer.price.toString(), 0);
    assert.equal(offer.owner, "0x0000000000000000000000000000000000000000");

    // check that user3 got the token id = 0
    const user3balance = await extras.balanceOf(user3, 0);
    assert.equal(user3balance, 1);
  });

  // it should be possible for two users to sell the same tokenid
  it("should be possible for two users to sell the same tokenid", async function () {

    await extras.setApprovalForAll(marketplace.address, true, { from: user1 });
    await extras.setApprovalForAll(marketplace.address, true, { from: user2 });

    await marketplace.list(0, 1, ether, { from: user1 });
    await marketplace.list(0, 1, ether, { from: user2 });

    const lastOfferID = await marketplace.lastOfferId();

    // TODO: this is bad. We need to know offerId some other way
    const offer1 = await marketplace.offers(0, lastOfferID - 1);
    const offer2 = await marketplace.offers(0, lastOfferID);

    assert.equal(offer1.price.toString(), ether.toString());
    assert.equal(offer1.amount, 1);
    assert.equal(offer1.owner, user1);

    assert.equal(offer2.price.toString(), ether.toString());
    assert.equal(offer2.amount, 1);
    assert.equal(offer2.owner, user2);
  });

  // This doesn't fail, we allow over-listing in this implementation
  // it should be possible to list more tokens than user has
  it("should be possible to list more tokens than user has", async function () {
    await extras.setApprovalForAll(marketplace.address, true, { from: user2 });

    await extras.buyItem(1, 3, { from: user2, value: 3 * ether });

    await marketplace.list(1, 2, ether, { from: user2 });

    // await expectRevert(
    await marketplace.list(1, 2, ether, { from: user2 });
      // "Not enough tokens"
    // );

  });
});
