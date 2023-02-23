// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IERC721Community.sol";

abstract contract MaxPerMint is INFTExtension {
    uint256 public maxPerMint;

    constructor(uint256 _maxPerMint) {
        maxPerMint = _maxPerMint;
    }

    modifier whenNotMaxPerMint(uint256 amount) {
        require(amount <= maxPerMint, "Too many tokens to mint");

        _;
    }
}
