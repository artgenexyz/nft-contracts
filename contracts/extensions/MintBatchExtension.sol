// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../interfaces/IERC721Community.sol";

contract MintBatchExtension {
    modifier onlyNFTOwner(IERC721Community nft) {
        require(
            Ownable(address(nft)).owner() == msg.sender,
            "MintBatchExtension: Not NFT owner"
        );
        _;
    }

    function mintToOwner(IERC721Community nft, uint256 nTokens)
        external
        onlyNFTOwner(nft)
    {
        nft.mintExternal(nTokens, msg.sender, bytes32(0));
    }

    function multimintMany(
        IERC721Community nft,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyNFTOwner(nft) {
        require(
            recipients.length == amounts.length,
            "MintBatchExtension: recipients and amounts length mismatch"
        );
        for (uint256 i = 0; i < recipients.length; i++) {
            nft.mintExternal(amounts[i], recipients[i], bytes32(0));
        }
    }

    /**
     * @dev Mint tokens to a list of recipients
     * @param nft The NFT contract
     * @param recipients The list of recipients, each getting exactly one token
     */
    function multimintOne(IERC721Community nft, address[] calldata recipients)
        external
        onlyNFTOwner(nft)
    {
        for (uint256 i = 0; i < recipients.length; i++) {
            nft.mintExternal(1, recipients[i], bytes32(0));
        }
    }

    /**
     * @dev Send a batch of tokens to a list of recipients
     * @dev The sender must have approved this contract to transfer the tokens
     * @dev Use `multisendBatch` for ERC721A-optimized transfer
     * @param nft The NFT contract
     * @param ids Token IDs to send
     * @param recipients The list of recipients
     */
    function multisend(
        IERC721Community nft,
        uint256[] calldata ids,
        address[] calldata recipients
    ) external {
        require(
            recipients.length == ids.length,
            "MintBatchExtension: recipients and amounts length mismatch"
        );
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC721(address(nft)).safeTransferFrom(
                msg.sender,
                recipients[i],
                ids[i]
            );
        }
    }

    /**
     * @dev Sequentially sends tokens to a list of recipients, starting from `startTokenId`
     * @dev The sender must have approved this contract to transfer the tokens
     * @dev Optimized for ERC721A: when you transfer tokenIds sequentially, the gas cost is lower
     * @param nft The NFT contract
     * @param startTokenId The first token ID to send
     * @param recipients The list of recipients
     */
    function multisendBatch(
        IERC721Community nft,
        uint256 startTokenId,
        address[] calldata recipients
    ) external {
        for (uint256 i = 0; i < recipients.length; i++) {
            IERC721(address(nft)).safeTransferFrom(
                msg.sender,
                recipients[i],
                startTokenId + i
            );
        }
    }
}
