// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./base/NFTExtension.sol";

contract MintBatchExtension is NFTExtension, Ownable {

    constructor(address _nft) NFTExtension(_nft) {}

    function mint(uint256 nTokens) external onlyOwner {
        nft.mintExternal(nTokens, msg.sender, bytes32(0x0));
    }

}
