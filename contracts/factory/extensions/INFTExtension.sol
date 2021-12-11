// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../SharedImplementationNFT.sol";

interface INFTExtension is IERC165 {
}

interface INFTURIExtension is INFTExtension {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract NFTExtension is INFTExtension, ERC165 {
    SharedImplementationNFT public immutable nft;

    constructor(address _nft) {
        nft = SharedImplementationNFT(_nft);
    }

    function beforeMint() internal view {
        require(nft.isExtensionAllowed(address(this)), "NFTExtension: this contract is not allowed to be used as an extension");
    }

    function supportsInterface(bytes4 interfaceId) public override(IERC165, ERC165) view returns (bool) {
        return interfaceId == type(INFTExtension).interfaceId || super.supportsInterface(interfaceId);
    }

}