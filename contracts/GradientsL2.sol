// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Artgene721Base.sol";

contract GradientsL2 is Artgene721Base {
    constructor()
        Artgene721Base(
            "Infinite Shades of Gradient",
            "GRADIENTS",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION,
            10,
            false,
            "https://metadata.artgene.xyz/api/g/era/gradients/",
            MintConfig(
                0.001 ether, // public price
                10, // maxTokensPerMint,
                10, // maxTokensPerWallet,
                500, // basis points royalty fee
                msg.sender, // payout receiver
                false, // should lock payout receiver
                1688572800, // startTimestamp
                1688659200 // endTimestamp
            )
        )
    {
        // opensea proxy is disabled on zksync
        setIsOpenSeaProxyActive(false);

        // transfer to artist wallet
        // transferOwnership(0x653d8554B690d54EA447aD82C933A6851CC35BF2);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

}
