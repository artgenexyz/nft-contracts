pragma solidity ^0.8.0;

import "./NFTExtension.sol";
import "./IRenderer.sol";

contract OnchainArtStorageExtension is NFTExtension, IRenderer {
    mapping(uint256 => string) public generativeArt;

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return generativeArt[tokenId];
    }

    function render(uint256 tokenId) public view override returns (string memory) {
        return generativeArt[tokenId];
    }
}