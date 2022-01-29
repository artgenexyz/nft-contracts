// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/Address.sol";
import "../AvatarNFTv2.sol";

contract CypherPunkNFT is AvatarNFTv2 {

    uint256 public constant DEVELOPER_FEE = 250; // of 10,000 = 2.5%

    constructor() AvatarNFTv2(
        0.2 ether,
        3000,
        0, // reserved
        3, // max per tx
        "https://metadata.buildship.dev/api/token/cypherpunk/",
        "CypherPunk: Rebels", "CYPHER"
    ) {}

    function withdraw() public override onlyOwner {
        require(beneficiary != address(0), "Beneficiary not set");

        uint256 balance = address(this).balance;
        uint256 amount = balance * (10000 - DEVELOPER_FEE) / 10000;

        address payable dev = DEVELOPER_ADDRESS();

        Address.sendValue(beneficiary, amount);
        Address.sendValue(dev, balance - amount);
    }
}
