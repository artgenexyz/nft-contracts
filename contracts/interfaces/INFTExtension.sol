// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface INFTExtension is IERC165 {}

interface IERC721CommunityExtension {
    function community() external view returns (address);
}

interface INFTURIExtension is INFTExtension {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721CommunityTokenURIExtension is INFTURIExtension {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721CommunityBeforeTransferExtension is INFTExtension {
    function beforeTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
