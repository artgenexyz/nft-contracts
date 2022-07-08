// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/INFTExtension.sol";
import "../interfaces/IMetaverseNFT.sol";

abstract contract PriceControlUpgradeable is OwnableUpgradeable {

    uint256 public price;
    uint256 public maxPerMint;

    function __PriceControlUpgradeable_init(uint256 _price, uint256 _maxPerMint) internal onlyInitializing {
        price = _price;
        maxPerMint = _maxPerMint;
    }

    modifier checkPrice(uint256 nTokens) {
        require(nTokens * price <= msg.value, "Inconsistent amount sent!");
        _;
    }

    modifier checkMaxPerMint(uint256 nTokens) {
        require(
            nTokens <= maxPerMint,
            "You cannot mint more than MAX_TOKENS_PER_MINT tokens at once!"
        );
        _;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

}
