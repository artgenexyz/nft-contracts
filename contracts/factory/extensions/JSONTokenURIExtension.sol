// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./INFTExtension.sol";
import "./NFTExtension.sol";
import "../IMetaverseNFT.sol";

contract JSONTokenURIExtension is NFTExtension, INFTURIExtension {

    // IMetaverseNFT public immutable nft;

    string public suffix;

    constructor(address _nft, string memory _suffix) NFTExtension(_nft) {
        // nft = IMetaverseNFT(_nft);
        suffix = _suffix;
    }

    function supportsInterface(bytes4 interfaceId) public override(IERC165, NFTExtension) view returns (bool) {
        return interfaceId == type(INFTURIExtension).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256) public view returns (string memory uri) {
        uri = string(abi.encodePacked(uri, suffix));
    }
}
