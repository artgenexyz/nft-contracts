// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IMetaverseNFT {
    function isExtensionAllowed(address extension) external view returns (bool);
    function mintExternal(uint256 nTokens, address to, bytes32 data) external payable;
}
