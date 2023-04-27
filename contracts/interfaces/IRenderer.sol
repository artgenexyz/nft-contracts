// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IRenderer is IERC165 {
    function render(uint256 tokenId, bytes memory optional) external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function tokenHTML(uint256 tokenId, bytes32 dna, bytes calldata optional) external view returns (string memory);
}
