// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


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
contract Market is ERC1155Holder, Ownable {

    // TODO: add royalties, add pendingWithdrawals for payout

    // ERC1155 contract
    IERC1155 public immutable tokenContract;

    mapping (uint256 => Offer) public offers;
    // mapping (address => Offer) public offerByOwner;

    // mapping (uint256 => mapping (address => Offer) userOffers;
    // mapping (address => Offer) pendingOffers;

    struct Offer {
        uint256 price;
        // uint256 itemId;
        uint256 amount;
        address payable owner;
    }

    // users can purchase item if minter didn't run out of supply and if saleStarted = true
    // users can list item for sale
    // users can buy items from other users

    // admin can change price for each item
    // users can purchase item if minter didn't run out of supply and if saleStarted = true
    // users can list item for sale
    // users can buy items from other users
    // admin can withdraw funds from sale, but 10% goes to the developer address "0x704C043CeB93bD6cBE570C6A2708c3E1C0310587"

    constructor (IERC1155 _tokenContract) {
        require(_tokenContract.supportsInterface(type(IERC1155).interfaceId), "Token is not supported");
        tokenContract = _tokenContract;
    }

    // list for sale, receives tokenId, amount of tokens, price
    function list(uint256 tokenId, uint256 amount, uint256 price) public {
        // transfer token from user
        require(tokenContract.balanceOf(msg.sender, tokenId) >= amount, "Not enough tokens");
        require(tokenContract.isApprovedForAll(msg.sender, address(this)), "Cant list for sale if not approved for all");

        // NO transfer, insteaf we just approve
        // tokenContract.safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        // create selling offer
        Offer memory offer = Offer(price, amount, payable(msg.sender));
        offers[tokenId] = offer;
    }
 
    function unlist(uint256 tokenId, uint256 amount) public {
        Offer storage offer = offers[tokenId];

        require(offer.owner == msg.sender, "Only owner can unlist");

        // tokenContract.safeTransferFrom(address(this), msg.sender, tokenId, amount, "");

        offer.amount -= amount;

        // if no more tokens, remove offer
        if (offer.amount == 0) {
            delete offers[tokenId];
        }
    }

    function buy(uint256 tokenId, uint256 amount) payable public {
        // find offer
        Offer storage offer = offers[tokenId];
        require(offer.amount >= amount, "Not enough tokens");

        // check user passed enough ETH
        require(msg.value >= offer.price * amount, "Not enough ETH");

        if(!tokenContract.isApprovedForAll(offer.owner, address(this))) {
            delete offers[tokenId];
            require(false, "Cant buy, offer is not valid");
        }

        // transfer tokens to user
        offer.amount -= amount;
        tokenContract.safeTransferFrom(offer.owner, msg.sender, tokenId, amount, "");

        // payout to buyer
        // TODO: hack, change to pendingWithdrawals
        uint256 rest = msg.value - offer.price * amount;
        // TODO: take fee?

        offer.owner.transfer(offer.price * amount);
        payable(msg.sender).transfer(rest);

        // if no more tokens, remove offer
        if (offer.amount == 0) {
            delete offers[tokenId];
        }
    }

}
