// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/solidity-examples/contracts/token/onft/extension/ONFT721A.sol";
import "../lib/solidity-examples/contracts/token/onft/extension/ONFT721A.sol";


import "./Artgene721.sol";
import "./Artgene721Base.sol";

contract Artgenes is ONFT721A {
    constructor(address _layerZeroEndpoint)
        ONFT721A(
            "Generative Endless NFT",
            "GEN",
            50_000,
            _layerZeroEndpoint
        )
        // Artgene721Base(
        //     "Generative Endless NFT",
        //     "GEN",
        //     ARTGENE_MAX_SUPPLY_OPEN_EDITION,
        //     1,
        //     false,
        //     "https://metadata.artgene.xyz/api/g/goerli/midline/",
        //     // optionally, use defaultConfig()
        //     MintConfig(
        //         0.1 ether, // public price
        //         5, // maxTokensPerMint,
        //         5, // maxTokensPerWallet,
        //         500, // basis points royalty fee
        //         msg.sender, // payout receiver
        //         false, // should lock payout receiver
        //         1684290476, // startTimestamp
        //         1684390476 // endTimestamp
        //     )
        // )
    {}


    uint256 nextMintId;

    /// @notice Mint your ONFT
    function mint() external payable {
        require(nextMintId <= 999_999, "UniversalONFT721: max mint limit reached");

        nextMintId += 1;

        _safeMint(msg.sender, 1);
    }


    // empty config
    // MintConfig(
    //     0, // public price
    //     0, // maxTokensPerMint,
    //     0, // maxTokensPerWallet,
    //     0, // basis points royalty fee
    //     address(0), // payout receiver
    //     false, // should lock payout receiver
    //     false, // should start sale
    //     false // should use json extension
    // )

    // default config
    // MintConfig(
    //     0, // public price
    //     50, // maxTokensPerMint,
    //     0, // maxTokensPerWallet,
    //     500, // basis points royalty fee
    //     msg.sender, // payout receiver
    //     false, // should lock payout receiver
    //     false, // should start sale
    //     false // should use json extension
    // );
}
