// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../ERC1155Sale.sol";

/// @custom:security-contact aleks@buildship.dev
contract AmeegosMarketplace is ERC1155Sale {

    // Buildship storage
    address payable buildship = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    address public immutable AGOS;

    constructor(address _AGOS)
        ERC1155Sale()
    {
        AGOS = _AGOS;
    }

    // -------- User functions

    function claimItem(uint256 itemId, uint256 amount)
        external
        whenSaleStarted(itemId)
    {
        require(itemId < totalItems, "No itemId");

        GameItem memory item = items[itemId];

        require(item.itemType == ItemType.Claimable, "Item is not claimable");

        uint256 total = item.price * amount; // this is in AGOS

        ERC20Burnable(AGOS).burnFrom(msg.sender, total);

        _buyItem(itemId, amount);
    }

    // ----- Admin functions -----

    // Withdraw sale money
    function withdraw() public override onlyOwner {
        uint256 _balance = address(this).balance;

        uint256 baseAmount = _balance * 17 / 20;

        require(payable(msg.sender).send(baseAmount));

        (bool success,) = buildship.call{value: _balance - baseAmount}("");
        require(success);
    }

}
