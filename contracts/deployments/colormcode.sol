// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Artgene721Base.sol";

contract colormcode is Artgene721Base {
    constructor()
        Artgene721Base(
            "Color. Machine. Code. (on L2)",
            "colormcode",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION,
            100,
            false,
            "https://metadata.artgene.xyz/api/g/era/colormcode/",
            MintConfig(
                0.001 ether, // public price
                50, // maxTokensPerMint,
                50, // maxTokensPerWallet,
                500, // basis points royalty fee
                0x5c1e262f68De7A2dc70Ed9227D435380Ef9dD739, // payout receiver
                false, // should lock payout receiver
                1690300800, // startTimestamp
                1690408800 // endTimestamp
            )
        )
    {
        // opensea proxy is disabled on zksync
        setIsOpenSeaProxyActive(false);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

}
