// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Artgene721Base.sol";

contract GoWithTheFlow is Artgene721Base {
    constructor()
        Artgene721Base(
            "Go With The Flow",
            "GWTF",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION,
            2,
            false,
            "https://metadata.artgene.xyz/api/g/era/go-with-the-flow/",
            MintConfig(
                0.0075 ether, // public price
                3, // maxTokensPerMint,
                3, // maxTokensPerWallet,
                500, // basis points royalty fee
                0xE619d906188cfF594D3396c1F82F66ef00DEA82c, // payout receiver
                false, // should lock payout receiver
                1692288000, // startTimestamp
                TIMESTAMP_INFINITY // endTimestamp
            )
        )
    {
        // opensea proxy is disabled on zksync
        setIsOpenSeaProxyActive(false);

        transferOwnership(0xffE06cb4807917bd79382981f23d16A70C102c3B);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

}
