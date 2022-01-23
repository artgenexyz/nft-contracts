// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./NFTExtension.sol";
import "./SaleControl.sol";

contract MintPassExtension is NFTExtension, Ownable, SaleControl {
  uint256 public price;

  // Maximum tokens that can be mint in the one mint pass
  uint256 public maxPerToken;

  // Number of remaining tokens
  uint256 public nRemainingTokens;

  // The address of ERC721 contract that is used for mint pass
  address public mintPassAddress;

  // For used tokenIds in the mint pass
  mapping(uint256 => bool) public usedTokenIds;

  constructor(address _nft, address _mintPassAddress, uint256 _price, uint256 _maxPerToken, uint256 _maxPerExtension) NFTExtension(_nft) SaleControl() {
    stopSale();
    price = _price;
    maxPerToken = _maxPerToken;
    mintPassAddress = _mintPassAddress;
    
    // At the begining, the number of tokens is max per extension
    nRemainingTokens = _maxPerExtension;
  }  

  function updatePrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function updateMaxPerToken(uint256 _maxPerToken) public onlyOwner {
    maxPerToken = _maxPerToken;
  }

  function updateMintPassAddress(address _mintPassAddress) public onlyOwner {
    mintPassAddress = _mintPassAddress;
  }

  function updateRemainingTokens(uint256 _nRemainingTokens) public onlyOwner {
    nRemainingTokens = _nRemainingTokens;
  }

  function increaseRemainingTokens(uint256 valueToAdd) public onlyOwner {
    nRemainingTokens = nRemainingTokens + valueToAdd;
  }

  function mint(uint256 nTokens, uint256 mintPassTokenId) external whenSaleStarted payable {
    beforeMint();

    require(usedTokenIds[mintPassTokenId] == false, "This tokenId has already been used");

    require(nRemainingTokens >= nTokens, "The number of remaining tokens is less than nTokens");

    require(ERC721(mintPassAddress).ownerOf(mintPassTokenId) == msg.sender, "Does not have the mint pass");

    require(msg.value >= nTokens * price, "Not enough ETH to mint");

    require(nTokens <= maxPerToken, "Cannot claim more per one mint pass");

    nRemainingTokens = nRemainingTokens - nTokens;

    usedTokenIds[mintPassTokenId] = true;

    nft.mintExternal{ value: msg.value }(nTokens, msg.sender, bytes32(0x0));
  }

}