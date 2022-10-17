// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IERC721Community.sol";

abstract contract LimitedSupply is INFTExtension {

    uint256 private totalMinted;
    uint256 public immutable extensionSupply;

    constructor(uint256 _extensionSupply) {
        extensionSupply = _extensionSupply;
    }

    modifier whenLimitedSupplyNotReached(uint256 amount) {
        require(
            amount + totalMinted <= extensionSupply,
            "max extensionSupply reached"
        );

        totalMinted += amount;

        _;
    }

}
