const { assert } = require("chai");

const { BN } = web3.utils;

const Market = artifacts.require("Market");

const AmeegosMarketplace = artifacts.require("AmeegosMarketplace");

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

// FULL CONTRACT CODE FOR REFERENCE:

// contract AmeegosMarket is ERC1155Holder, Ownable {

//     // ERC1155 contract
//     IERC1155 public immutable tokenContract;

//     mapping (uint256 => Offer) offers;

//     struct Offer {
//         uint256 price;
//         uint256 amount;
//         uint256 owner;
//     }

//     // users can purchase item if minter didn't run out of supply and if saleStarted = true
//     // users can list item for sale
//     // users can buy items from other users

//     // admin can change price for each item
//     // users can purchase item if minter didn't run out of supply and if saleStarted = true
//     // users can list item for sale
//     // users can buy items from other users
//     // admin can withdraw funds from sale, but 10% goes to the developer address "0x704C043CeB93bD6cBE570C6A2708c3E1C0310587"

//     constructor (IERC1155 _tokenContract) {
//         require(_tokenContract.supportsInterface(type(IERC1155).interfaceId), "Token is not supported");
//         tokenContract = _tokenContract;
//     }

//     // list for sale, receives tokenId, amount of tokens, price
//     function list(uint256 tokenId, uint256 amount, uint256 price) {
//         // transfer token from user
//         require(tokenContract.balanceOf(msg.sender) >= amount, "Not enough tokens");
//         tokenContract.safeTransferFrom(msg.sender, address(this), tokenId, amount);

//         // create selling offer
//         Offer memory offer = Offer(price, amount, msg.sender);
//         offers[tokenId] = offer;
//     }

//     function buy(uint256 tokenId, uint256 amount) payable {
//         // find offer
//         Offer memory offer = offers[tokenId];
//         require(offer.amount >= amount, "Not enough tokens");

//         // check user passed enough ETH
//         require(msg.value >= offer.price * amount, "Not enough ETH");

//         // transfer tokens to user
//         tokenContract.safeTransferFrom(address(this), msg.sender, tokenId, amount);
//         offer.amount -= amount;

//         // payout to buyer
//         send(offer.owner, offer.price * amount);

//         // if no more tokens, remove offer
//         if (offer.amount == 0) {
//             delete offers[tokenId];
//         }
//     }

// }


/*
TODO:
- test list token for sale
- test buy token
- test unlist token from sale, buy doesn't work
*/

contract("Market", function (accounts) {
  const [admin, user1, user2, user3] = accounts;

  let marketplace, extras;

  const ether = new BN(web3.utils.toWei("1", "ether"));

  // it should be possible to deploy marketplace
  it("should be possible to deploy marketplace", async function () {
    extras = await AmeegosMarketplace.deployed();

    marketplace = await Market.new(extras.address, { from: admin });

    assert.isTrue(marketplace.address !== undefined);

    const tokenContract = await marketplace.tokenContract();

    assert.equal(tokenContract, extras.address);

    const owner = await marketplace.owner();

    assert.equal(owner, admin);

  });

  // prepare users: buy tokens from extras for each user
  xit("should be possible to buy tokens from extras", async function () {
    await extras.addItem("Skin", "https://uri", ether.muln(0.05), 100, { from: admin });
    await extras.addItem("Weapon", "https://uri", ether.muln(0.01), 200, { from: admin });

    await extras.startSaleAll({ from: admin });

    await extras.buyItem(0, 5, { from: user1, value: ether.muln(0.05).muln(5) });
    await extras.buyItem(1, 10, { from: user2, value: ether.muln(0.01).muln(10) });
  });

  // it should be possible to list token for sale
  xit("should be possible to list token for sale", async function () {

    await extras.setApprovalForAll(marketplace.address, true, { from: user1 });

    // we put 2 so we can later check that user didn't sell all his tokens

    await marketplace.list(0, 2, ether, { from: user1 });

    const offer = await marketplace.offers(0);

    assert.equal(offer.price.toString(), ether.toString());
    assert.equal(offer.amount, 2);
    assert.equal(offer.owner, user1);
  });

  // it should be possible to buy listed token
  xit("should be possible to buy 1 of 2 listed token", async function () {
    await marketplace.buy(0, 1, { from: user2, value: ether });

    const offer = await marketplace.offers(0);

    assert.equal(offer.price.toString(), ether.toString());
    assert.equal(offer.amount, 1);
    assert.equal(offer.owner, user1);

    // check that user2 got the token id = 0
    const user2balance = await extras.balanceOf(user2, 0);
    assert.equal(user2balance, 1);
  });

  // it should be possible to buy full offer, and offer is removed
  xit("should be possible to buy full offer, and offer is removed", async function () {
    await marketplace.buy(0, 1, { from: user3, value: ether });

    const offer = await marketplace.offers(0);

    assert.equal(offer.price.toNumber(), 0);
    assert.equal(offer.amount, 0);
    assert.equal(offer.owner, "0x0000000000000000000000000000000000000000");

    // check that user3 got the token id = 0
    const user3balance = await extras.balanceOf(user3, 0);
    assert.equal(user3balance, 1);
  });

});
