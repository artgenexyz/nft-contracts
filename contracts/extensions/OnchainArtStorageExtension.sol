// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IERC721Community.sol";
import "../interfaces/INFTExtension.sol";
import "./base/NFTExtension.sol";
import "../interfaces/IRenderer.sol";

contract OnchainArtStorageExtension is
    NFTExtension,
    INFTURIExtension,
    IRenderer
{
    string constant TOKEN_URI_TEMPLATE_START =
        'data:application/json;{"name":"OnchainArt","description":"OnchainArt","image":"';
    string constant TOKEN_URI_TEMPLATE_END = '"}';

    string constant SVG_PREFIX =
        "data:image/svg+xml;<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text x='0' y='50' font-size='50'>";
    string constant SVG_SUFFIX = "</text></svg>";

    string public generativeArt = "HELLO WORLD";

    constructor(address _nft, string memory _art) NFTExtension(_nft) {
        // nft = IERC721Community(_nft);
        generativeArt = _art;
    }

    function updateArt(string calldata _generativeArt) external {
        generativeArt = _generativeArt;
    }

    function tokenURI(
        uint256 tokenId
    ) public view       override(INFTURIExtension, IRenderer)
returns (string memory) {
        return
            string.concat(
                TOKEN_URI_TEMPLATE_START,
                SVG_PREFIX,
                generativeArt,
                SVG_SUFFIX,
                TOKEN_URI_TEMPLATE_END
            );
    }

    function render(
        uint256 tokenId,
        bytes memory optional
    ) external view returns (string memory) {
        return generativeArt;
    }

    function tokenHTML(
        uint256 tokenId,
        bytes32 dna,
        bytes calldata optional
    ) external view override returns (string memory) {
        return generativeArt;
    }
}
