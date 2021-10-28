// SPDX-License-Identifier: MIT
// Adapted from World of Women: https://etherscan.io/token/0xe785e82358879f061bc3dcac6f0444462d4b5330#readContract
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./AvatarNFT.sol";

contract AvatarNFTWithMintPass is AvatarNFT {

    address public constant MINT_PASS_ADDRESS = 0x0000000000000000000000000000000000000000;

    constructor() AvatarNFT(0.03 ether, 100, 5, 5, "https://mintpass.io", "Avatar With Mint Pass", "PASS") {}

    function _checkSaleAllowed(address _to)
        internal
        view
        returns (bool)
    {
        // override this if you need custom logic
        return ERC721(MINT_PASS_ADDRESS).balanceOf(_to) > 0;
    }

    // TODO: implement mint
}
