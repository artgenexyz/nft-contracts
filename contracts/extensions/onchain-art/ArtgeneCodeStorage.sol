// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "solady/src/utils/Base64.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IRenderer.sol";
import "../base/NFTExtension.sol";

import "./ArtgeneScript.sol";

abstract contract ArtgeneCodeStorage is
    ERC165,
    INFTURIExtension,
    IRenderer
{
    Artgene_js public immutable script;

    constructor(
        address _artgeneScriptAddress
    ) {
        script = Artgene_js(_artgeneScriptAddress);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(INFTURIExtension, IRenderer)
        returns (string memory)
    {}

    function render(
        uint256 tokenId,
        bytes memory optional
    ) public view virtual override returns (string memory) {}

    function tokenHTML(
        uint256 tokenId,
        bytes32 dna,
        bytes memory optional
    ) public view virtual override returns (string memory) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(INFTURIExtension).interfaceId ||
            interfaceId == type(IRenderer).interfaceId ||
            super.supportsInterface(interfaceId);
    }

}
