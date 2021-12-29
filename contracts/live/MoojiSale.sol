// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../ERC1155Sale.sol";

/// @custom:security-contact aleks@buildship.dev
contract MoojiSale is ERC1155Sale {
    constructor() ERC1155Sale() {}

    // Add new item to the marketplace
    // Here we allow anyone to add, removing onlyOwner modifier
    function addItemUser(
        string memory name,
        string memory imageUrl,
        string calldata animationUrl,
        uint256 price,
        uint256 maxSupply,
        ItemType itemType,
        bool
    ) public {
        super.addItem(
            name,
            imageUrl,
            animationUrl,
            price,
            maxSupply,
            itemType,
            // also startSale always false if not owner
            false
        );
    }

    // TODO: mintAndBuyItem
}
