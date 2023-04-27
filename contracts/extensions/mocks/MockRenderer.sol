// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IRenderer.sol";
import "../../interfaces/IArtgene721.sol";

contract MockRenderer is IRenderer, ERC165 {
    IArtgene721 public immutable nft;

    constructor(address _nft) {
        nft = IArtgene721(_nft);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(INFTURIExtension).interfaceId ||
            interfaceId == type(INFTExtension).interfaceId ||
            interfaceId == type(IRenderer).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 id) public pure returns (string memory uri) {
        uri = render(id, new bytes(0));
    }

    function render(uint256, bytes memory) public pure returns (string memory) {
        return "<svg></svg>";
    }

    function tokenHTML(
        uint256 id,
        bytes32 dna,
        bytes calldata data
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<html>",
                    "<head><title>",
                    Strings.toHexString(address(nft)),
                    "</title></head>",
                    "<body>",
                    render(id, data),
                    Strings.toHexString(uint256(dna)),
                    "</body>",
                    "</html>"
                )
            );
    }
}
