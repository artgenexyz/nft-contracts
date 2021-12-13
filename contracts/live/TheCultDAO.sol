// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../AvatarNFT.sol";

contract TheCultDAO is AvatarNFT {

    constructor() AvatarNFT(
        100 ether, // MATIC
        10100, // total supply
        700, // reserved supply
        50, // max mint per transaction
        "https://metadata.buildship.dev/api/token/thecultdao-rock/",
        "The Cult DAO", "CULD"
    ) {}

    // --- Admin functions ---

    // Update beneficiary, override to make updateable
    function setBeneficiary(address payable _beneficiary) public override onlyOwner {
        beneficiary = _beneficiary;
    }

}
