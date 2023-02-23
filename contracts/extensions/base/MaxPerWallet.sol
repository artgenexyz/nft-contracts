// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./NFTExtension.sol";
import "../../interfaces/INFTExtension.sol";
import "../../interfaces/IERC721Community.sol";

abstract contract MaxPerWallet is NFTExtension {
    uint256 public maxPerWallet;

    constructor(uint256 _maxPerWallet) {
        maxPerWallet = _maxPerWallet;
    }

    modifier whenWalletNotFull(uint256 amount) {
        require(
            IERC721(address(nft)).balanceOf(msg.sender) + amount <=
                maxPerWallet,
            "MaxPerWallet: Too many tokens to mint"
        );

        _;
    }
}
