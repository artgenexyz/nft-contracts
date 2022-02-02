// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./SaleControl.sol";
import "../../MetaverseBaseNFT.sol";

contract FixedPriceSaleExtension is Ownable, SaleControl {

    MetaverseBaseNFT public immutable nft;

    uint256 public price;
    uint256 public maxPerMint;

    constructor(address payable _nft, uint256 _price, uint256 _maxPerMint) {
        stopSale();
        // sale stopped by default

        nft = MetaverseBaseNFT(_nft);
        price = _price;
        maxPerMint = _maxPerMint;
    }

    function mint(uint256 nTokens) external whenSaleStarted payable {
        require(nTokens <= maxPerMint, "Too many tokens to mint");
        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        nft.mintExternal{ value: msg.value }(nTokens, msg.sender, 0x0);
    }

    // view methods to export totalSupply and maxSupply from nft

    function totalSupply() external view returns (uint256) {
        return nft.totalSupply();
    }

    function maxSupply() external view returns (uint256) {
        return nft.maxSupply();
    }
    
}
