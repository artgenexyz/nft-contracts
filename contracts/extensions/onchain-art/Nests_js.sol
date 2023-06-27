// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ScriptyOnchainArt.sol";

contract Nests_js is ScriptyOnchainArt {
    /* (minified, gunzipped, hex-encoded) */
    bytes private constant artScript =
        hex"1f8b080005fa9a6400038d554b8fd33010bef32bca01c96edc36719a9455361c0021900021ed81c36a0f21715bab56bc72dc2ea8ca7f67fcc8abdd151c9a3a33e3797cf3cde454a8999045c5ebdd5da918abf36d211a966d8f75a9b9ac670dd3c74784cfa02c34fb50d4a7a241117d1b920d0d71f6c87f33f191d50dd77fd01a67a514527d9315439fefde93380d4914da1f6e7b97952a9ec023dfa2d793d0f82c989eb15c1575859e78a5f72bba5887a43b9a78c6423b8b3de3bbbd5ed18086a43bf73662e2c59874c7b5b750ffe1853b1b11c444049117d64ea81631518b4e282796a91356de1284ca0a1bade481210b1232e0840442e1ac969fb810a833f869f3401467bf8af2b053f2085ec697127349f09a2146341144f93738114eead19b2415ce9810fcb1613da6d1502ac04128a15736ff34089e733265925647d63260d3b914ac50509ee9fc77d668644afe2a2510ab9df2c269cf27a0a52782634f066c61ef6e527cbe828442f40d244031b6d166d61420ba361d201f2c6fd7cf18ae29d96c481a7bc3973c6d8ca75adeb9b6e26c0b1ac7d030d3b7294b321d048ed6baabc6e2b798d2b48372d173331af32f244b6a101be218b6f8ea6d2221e1d863640a1fe95da26608b92dc635d1920668d38e525bd2842c37c924b188c04c8b9cd71a89c9d88466b671a6e1a511b0183c2dd673d1b302d85c160262e14c496d6cd464aa0063d759eb9e4f862b723041d15659774376ffd063cc006376cb337681b04d59deb3077b53bb12ab49d6465238094cfd5b2fd97b89c12a66b113965e4892cbeee65b21415062d7e3a9d2663f345fe4a80af4aac06f20be87d1b547d8d62434f0f9d1144f029bfdd76dac6d3f10178b62db6f1635da25c0069de77507ce980ee1882b9d669d9234719bda3bd357fbc862b9cb7d87b9cdeac9e23c6cdbf9727d7343fc3109235fcf21f78be3e5068afc30246d4793cf97710cdf1e8f05b5b33b1a5dd0a7e9a07758f995e365115c8accadd6ec94a68730761858a2e41003820765561ed589a143d090dd9cc1f360fe61567673c48208c36e6fba73d00c99382fb4f362b7efc5559f96a9f139f56299e0f6908bd68fca8f2fab3de4fca8d88933f85ab6affe0203330b19aa070000";

    constructor(
        address _nft,
        address _artgeneScriptAddress,
        address _ethfsFileStorageAddress,
        address _scriptyStorageAddress,
        address _scriptyBuilderAddress
    )
        ScriptyOnchainArt(
            _nft,
            _artgeneScriptAddress,
            _ethfsFileStorageAddress,
            _scriptyStorageAddress,
            _scriptyBuilderAddress
        )
    {}

    function _getArtScript() internal pure override returns (bytes memory) {
        /* (minified, gunzipped, hex-encoded) */
        return artScript;
    }
}
