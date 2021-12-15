// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFTv2.sol";

// Replace with this if you want to deploy from https://remix.ethereum.org :
// import "https://github.com/buildship-dev/nft-contracts/blob/main/contracts/AvatarNFTv2.sol";

// This is an example usage of AvatarNFT 
contract TemplateNFTv2 is AvatarNFTv2 {

    constructor() AvatarNFTv2(
        1 ether,
        10000, // total supply
        200, // reserved supply
        20, // max mint per transaction
        "https://metadata.buildship.dev/api/token/SYMBOL/",
        "Avatar Collection NFT", "SYMBOL"
    ) {}

}
