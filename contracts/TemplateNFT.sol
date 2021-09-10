// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./AvatarNFT.sol";

contract TemplateNFT is AvatarNFT {

    constructor() AvatarNFT(1 ether, 200, 10000, 20, "https://metadata.buildship.dev/api/token/SYMBOL", "Avatar Collection NFT", "SYMBOL") {}
    
}
