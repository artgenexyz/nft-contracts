// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract LimitedSupplyUpgradeable is OwnableUpgradeable {

    uint256 public totalMinted;
    uint256 public extensionSupply;

    function initialize(uint256 _extensionSupply) internal onlyInitializing {
        __Ownable_init();

        extensionSupply = _extensionSupply;
    }

    modifier whenLimitedSupplyNotReached(uint256 amount) {
        require(
            amount + totalMinted <= extensionSupply,
            "LimitedSupplyUpgradeable: max extensionSupply reached"
        );

        totalMinted += amount;

        _;
    }

}
