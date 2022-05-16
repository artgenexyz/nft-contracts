// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";

contract MintPassExtension is NFTExtension, Ownable, SaleControl {
  uint256 public price;

  // Number of remaining tokens
  uint256 public nRemainingTokens;

  // The address of ERC721 contract that is used for mint pass
  address public mintPassAddress;

  // For used tokenIds in the mint pass
  mapping(uint256 => bool) public usedTokenIds;

  constructor(
    address _nft,
    address _mintPassAddress,
    uint256 _price,
    uint256 _maxPerExtension
  ) NFTExtension(_nft) SaleControl() {
    stopSale();

    price = _price;
    mintPassAddress = _mintPassAddress;

    // At the begining, the number of tokens is max per extension
    nRemainingTokens = _maxPerExtension;
  }

  function updatePrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function updateMintPassAddress(address _mintPassAddress) public onlyOwner {
    mintPassAddress = _mintPassAddress;
  }

  function mint(uint256[] memory mintPassTokenIds)
    public
    payable
    whenSaleStarted
  {

    require(
      nRemainingTokens >= mintPassTokenIds.length,
      "The number of remaining tokens is less than nTokens"
    );

    require(msg.value >= mintPassTokenIds.length * price, "Not enough ETH to mint");

    for (uint256 i = 0; i < mintPassTokenIds.length; i++) {
      uint256 mintPassTokenId = mintPassTokenIds[i];

      require(
        usedTokenIds[mintPassTokenId] == false,
        "This tokenId has already been used"
      );

      require(
        ERC721(mintPassAddress).ownerOf(mintPassTokenId) == msg.sender,
        "Does not have the mint pass"
      );

      usedTokenIds[mintPassTokenId] = true;
    }

    nRemainingTokens -= mintPassTokenIds.length;

    nft.mintExternal{ value: msg.value }(mintPassTokenIds.length, msg.sender, bytes32(0x0));
  }

}