// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IMetaverseNFT.sol";

contract MockTokenURIExtension is INFTURIExtension, ERC165 {
    IMetaverseNFT public immutable nft;

    constructor(address _nft) {
        nft = IMetaverseNFT(_nft);
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
            super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256) public pure returns (string memory uri) {
        uri = "<svg></svg>";
    }
}
