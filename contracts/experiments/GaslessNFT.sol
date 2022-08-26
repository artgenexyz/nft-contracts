// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../ERC721CommunityBase.sol";

contract GaslessNFT is ERC721CommunityBase {
    uint256 constant GAS_TRANSFER = 21000;
    uint256 constant GAS_OFFSET = 0; // 10571;

    constructor()
        ERC721CommunityBase(
            "GaslessClub",
            "GASFREE",
            10000,
            100,
            false, // should start at one
            "https://metadata.buildship.xyz/api/token/GASFREE/",
            MintConfig(
                0.1 ether, // public price
                20, // maxTokensPerMint,
                20, // maxTokensPerWallet,
                0, // basis points royalty fee
                msg.sender, // payout receiver
                false, // should lock payout receiver
                false, // should start sale
                false // should use json extension
            )
        )
    {}

    // Same as reference implementation
    // function mint(uint256 _nbTokens) override external payable whenSaleStarted {
    //     uint256 supply = totalSupply();
    //     require(_nbTokens < 21, "You cannot mint more than 20 Tokens at once!");
    //     require(supply + _nbTokens <= MAX_SUPPLY - _reserved, "Not enough Tokens left.");
    //     require(_nbTokens * _price <= msg.value, "Inconsistent amount sent!");

    //     for (uint256 i; i < _nbTokens; i++) {
    //         _safeMint(msg.sender, supply + i);
    //     }
    // }

    function mintFree(uint256 _nbTokens) external payable whenSaleStarted {
        uint256 gasStart;

        gasStart = gasleft();

        uint256 supply = totalSupply();
        require(
            _nbTokens <= maxPerMint,
            "You cannot mint more than 20 Tokens at once!"
        );
        require(
            supply + _nbTokens <= maxSupply - reserved,
            "Not enough Tokens left."
        );
        require(_nbTokens * price <= msg.value, "Inconsistent amount sent!");

        for (uint256 i; i < _nbTokens; i++) {
            _safeMint(msg.sender, supply + i);
        }

        uint256 cashback = (gasStart + GAS_TRANSFER + GAS_OFFSET) *
            block.basefee;

        cashback = cashback - gasleft() * block.basefee;

        require(cashback * 2 <= msg.value, "Max cashback 50%");

        // payable().send(cashback);
        require(payable(tx.origin).send(cashback));
    }
}
