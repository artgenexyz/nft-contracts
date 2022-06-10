// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";

contract LimitedSupplyMintingExtension is NFTExtension, Ownable, SaleControl {

    uint256 public price;
    uint256 public maxPerMint;
    uint256 public maxPerWallet;
    uint256 public totalMinted;
    uint256 public supply;

    constructor(address _nft, uint256 _price, uint256 _maxPerMint, uint256 _maxPerWallet, uint256 _supply) NFTExtension(_nft) {
        stopSale();
        // sale stopped by default

        price = _price;
        maxPerMint = _maxPerMint;
        maxPerWallet = _maxPerWallet;
        supply = _supply;
    }

    function mint(uint256 nTokens) external whenSaleStarted payable {
        // super.beforeMint();

        require(IERC721(address(nft)).balanceOf(msg.sender) + nTokens <= maxPerWallet, "LimitedSupplyMintingExtension: max per wallet reached");

        require(nTokens + totalMinted <= supply, "max supply reached");
        require(nTokens <= maxPerMint, "Too many tokens to mint");
        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        nft.mintExternal{ value: msg.value }(nTokens, msg.sender, bytes32(0x0));

        totalMinted += nTokens;
    }

    function maxSupply() public returns (uint256) { return nft.maxSupply(); }

    function totalSupply() public returns (uint256) { return nft.totalSupply(); }

}
