// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./NFTExtension.sol";
import "./SaleControl.sol";

contract MintPass is NFTExtension, Ownable, SaleControl {
  uint256 public price;

  uint256 public maxPerAddress;

  // The address of ERC721 contract that is used for mint pass
  address public mintPassAddress;

  // For used tokenIds in the mint pass
  mapping(uint256 => bool) usedTokenIds;

  mapping(address => uint256) public claimedByAddress;

  constructor(address _nft, address _mintPassAddress, uint256 _price, uint256 _maxPerAddress) NFTExtension(_nft) SaleControl() {
    stopSale();
    price = _price;
    maxPerAddress = _maxPerAddress;
    mintPassAddress = _mintPassAddress;
  }  

  function updatePrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function updateMaxPerAddress(uint256 _maxPerAddress) public onlyOwner {
    maxPerAddress = _maxPerAddress;
  }

  function updateMintPassAddress(address _mintPassAddress) public onlyOwner {
    mintPassAddress = _mintPassAddress;
  }

  function mint(uint256 nTokens, uint256 mintPassTokenId) external whenSaleStarted payable {
    super.beforeMint();

    require(usedTokenIds[mintPassTokenId] == false, "This tokenId has already been used");

    require(IERC721(mintPassAddress).ownerOf(mintPassTokenId) == msg.sender, "Does not have mint pass");

    require(msg.value >= nTokens * price, "Not enough ETH to mint");

    require(claimedByAddress[msg.sender] + nTokens <= maxPerAddress, "Cannot claim more per address");

    usedTokenIds[mintPassTokenId] = true;
    
    claimedByAddress[msg.sender] += nTokens;

    nft.mintExternal{ value: msg.value }(nTokens, msg.sender, bytes32(0x0));
  }

}