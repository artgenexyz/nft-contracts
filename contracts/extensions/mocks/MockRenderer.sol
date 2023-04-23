// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IRenderer.sol";
import "../../interfaces/IArtgene721.sol";

contract MockRenderer is IRenderer, ERC165 {
    IArtgene721 public immutable nft;

    constructor(address _nft) {
        nft = IArtgene721(_nft);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC165)
        returns (bool)
    {
        return
            interfaceId == type(INFTURIExtension).interfaceId ||
            interfaceId == type(INFTExtension).interfaceId ||
            interfaceId == type(IRenderer).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256) public pure returns (string memory uri) {
        uri = "<svg></svg>";
    }

    function render(uint256) public pure returns (string memory) {
        return "<svg></svg>";
    }
}
