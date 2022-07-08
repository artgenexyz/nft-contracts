// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract MockERC20CurrencyToken is ERC20PresetFixedSupply {
    constructor()
        ERC20PresetFixedSupply("testCurrency", "TC", 10000, msg.sender)
    {}
}
