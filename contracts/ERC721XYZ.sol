// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MetaverseNFTProxy.sol";

/**
 * @title made by buildship.xyz
 * @dev ERC721XYz is extendable implementation of ERC721 based on ERC721A and MetaverseNFT.
 */

contract ERC721XYZ is MetaverseNFTProxy {
    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 nReserved,
        bool startAtOne,
        string memory uri,
        MetaverseNFTConfig memory config
    )
        MetaverseNFTProxy(
            name,
            symbol,
            maxSupply,
            nReserved,
            startAtOne,
            uri,
            config
        )
    {}
}
