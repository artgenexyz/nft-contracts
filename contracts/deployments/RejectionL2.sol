// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Artgene721Base.sol";

contract RejectionL2 is Artgene721Base {
    constructor()
        Artgene721Base(
            "Rejection",
            "REJECTION",
            200,
            15,
            false,
            "https://metadata.artgene.xyz/api/g/era/rejection/",
            MintConfig(
                0.05 ether, // public price
                10, // maxTokensPerMint,
                10, // maxTokensPerWallet,
                500, // basis points royalty fee
                0x9aDb2F02a759488353c600f5A42BdA9e14d6e283, // payout receiver
                false, // should lock payout receiver
                1692288000, // startTimestamp
                TIMESTAMP_INFINITY // endTimestamp
            )
        )
    {
        // opensea proxy is disabled on zksync
        setIsOpenSeaProxyActive(false);

        // transfer to artist wallet
        transferOwnership(0x653d8554B690d54EA447aD82C933A6851CC35BF2);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

}
