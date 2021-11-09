// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../AvatarNFT.sol";

contract NonChimpzNFT is AvatarNFT {

    constructor() AvatarNFT(
        0.0555 ether,
        17777,
        0,
        17777,
        "https://meta.nonchimpz.com/api/token/nonchimpz/",
        "Non-Chimpz Headz", "NONCHH"
    ) {}

    // --- Admin functions ---

    // Update beneficiary, override to make updateable
    function setBeneficiary(address payable _beneficiary) public override onlyOwner {
        beneficiary = _beneficiary;
    }

    function withdraw() public override onlyOwner {
        uint256 balance = address(this).balance;

        uint256 amount = balance * 95 / 100; // 95% : 5%

        require(payable(beneficiary).send(amount));

        address dev = DEVELOPER_ADDRESS();
        (bool success,) = dev.call{value: balance - amount}("");
        require(success);
    }

    function withdrawAmount(uint256 _amount) public onlyOwner {

        uint256 amount = _amount * 95 / 100; // 95% : 5%

        require(payable(beneficiary).send(amount));

        // this is needed to forward remaining gas
        address _dev = DEVELOPER_ADDRESS();
        (bool success,) = _dev.call{value: _amount - amount}("");
        require(success);
    }

}
