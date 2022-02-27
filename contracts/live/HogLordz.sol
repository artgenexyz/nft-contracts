// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../MetaverseBaseNFT.sol";

contract HogLordz is MetaverseBaseNFT {

    constructor() MetaverseBaseNFT(
        1000000000000000000,
        5000, // total supply
        20, // reserved supply
        6, // max mint per transaction
        50, // royalty fee
        "https://metadata.buildship.dev/api/dummy-metadata-for/bafybeianop3ltvag6t533qzyvguhpqbnkaixfxba7s4znaajnmmzcwok6m/",
        "Hog Lordz", "HL"
    ) {
        setRoyaltyReceiver(msg.sender);
    }

    function withdraw() public override onlyOwner {
        uint256 balance = address(this).balance;

        Address.sendValue(payable(msg.sender), balance);

    }

}
