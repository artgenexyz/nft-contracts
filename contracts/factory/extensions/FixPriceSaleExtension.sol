// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./INFTExtension.sol";
import "../SharedImplementationNFT.sol";

contract FixPriceSaleExtension is NFTExtension, Ownable, Pausable {

    uint256 public price;
    uint256 public maxPerMint;

    constructor(address _nft, uint256 _price, uint256 _maxPerMint) NFTExtension(_nft) {
        _pause();
        // sale stopped by default

        price = _price;
        maxPerMint = _maxPerMint;
    }

    function mint(uint256 nTokens) external whenNotPaused payable {
        super.beforeMint();

        require(nTokens <= maxPerMint, "Too many tokens to mint");
        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        nft.mintExternal{ value: msg.value }(nTokens, msg.sender, 0x0);
    }

    function flipSaleStarted () public onlyOwner {
        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
    }
}
