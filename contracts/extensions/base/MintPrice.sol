// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IERC721Community.sol";

abstract contract MintPrice is INFTExtension {
    uint256 public price;

    constructor(uint256 _price) {
        price = _price;
    }

    modifier whenEnoughETH(uint256 amount) {
        require(msg.value >= amount * price, "Not enough ETH to mint");

        _;
    }
}
