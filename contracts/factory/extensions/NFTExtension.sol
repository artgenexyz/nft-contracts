// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./INFTExtension.sol";

interface IMetaverseNFT {
    function isExtensionAllowed(address extension) external view returns (bool);
    function mintExternal(uint256 nTokens, address to, bytes32 data) external payable;
}

contract NFTExtension is INFTExtension, ERC165 {
    IMetaverseNFT public immutable nft;

    constructor(address _nft) {
        nft = IMetaverseNFT(_nft);
    }

    function beforeMint() internal view {
        require(nft.isExtensionAllowed(address(this)), "NFTExtension: this contract is not allowed to be used as an extension");
    }

    function supportsInterface(bytes4 interfaceId) public override(IERC165, ERC165) view returns (bool) {
        return interfaceId == type(INFTExtension).interfaceId || super.supportsInterface(interfaceId);
    }

}
