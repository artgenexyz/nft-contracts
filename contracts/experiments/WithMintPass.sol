// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

enum MintPassLogic {
    LimitAddress,
    LimitTokenId,
    LimitBoth
}

contract WithMintPass {

    constructor(IERC721 _mintPass, uint256 _maxPerMintPass, MintPassLogic _logic) {
        mintPass = _mintPass;
        logic = _logic;
        MAX_PER_MINT_PASS = _maxPerMintPass;
    }

    uint256 public immutable MAX_PER_MINT_PASS;
    IERC721 public immutable mintPass;
    MintPassLogic public immutable logic;

    mapping(address => uint256) mintPassUsedBy;
    mapping(uint256 => uint256) mintPassUsedByTokenId;

    modifier withMintPass(uint256 amount) {
        require(mintPass.balanceOf(msg.sender) > 0, "You dont have mint pass");

        if (logic == MintPassLogic.LimitAddress || logic == MintPassLogic.LimitBoth) {
            require(mintPassUsedBy[msg.sender] + amount < MAX_PER_MINT_PASS, "Too many items or mint pass is used");

            mintPassUsedBy[msg.sender] += amount;
        }

        if (logic == MintPassLogic.LimitTokenId || logic == MintPassLogic.LimitBoth) {
            if(mintPass.supportsInterface(type(IERC721Enumerable).interfaceId)) {
                uint256 index = 0; // TODO: run around all tokens and check if there is enough allowance
                uint256 tokenId = IERC721Enumerable(address(mintPass)).tokenOfOwnerByIndex(msg.sender, index);

                mintPassUsedByTokenId[tokenId] += amount;
            } else {
                require(false, "Unsupported token type");
            }
        }

        _;
    }

    function hasAvailable(address buyer) public view returns (uint256) {

        if (mintPass.balanceOf(buyer) == 0) {
            return 0;
        }

        if (logic == MintPassLogic.LimitAddress) {
            return MAX_PER_MINT_PASS - mintPassUsedBy[buyer];
        }

        if (logic == MintPassLogic.LimitTokenId) {
            if(!mintPass.supportsInterface(type(IERC721Enumerable).interfaceId)) {
                require(false, "Unsupported token type");
            }

            uint256 balance = IERC721Enumerable(address(mintPass)).balanceOf(buyer);

            uint256 available = balance * MAX_PER_MINT_PASS;

            for (uint256 index = 0; index < balance; index++) {
                // uint256 tokenId = IERC721Enumerable(address(mintPass)).tokenOfOwnerByIndex(msg.sender, index);
                uint256 tokenId = IERC721Enumerable(address(mintPass)).tokenOfOwnerByIndex(buyer, index);

                available -= mintPassUsedByTokenId[tokenId];
            }

            return available;

        }

        if (logic == MintPassLogic.LimitBoth) {
            // TODO


            return 0;
        }

        return 0;
    }
}