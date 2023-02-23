// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";
import "./base/MintEndsAt.sol";
import "./base/MaxPerWallet.sol";
import "./base/MaxPerMint.sol";
import "./base/MintPrice.sol";

// OpenEdition is a time-limited mint, after the end of the mint, mint will be closed forever
contract OpenEditionExtension is
    NFTExtension,
    SaleControl,
    MintEndsAt,
    MintPrice,
    MaxPerMint,
    MaxPerWallet
{
    constructor(
        address _nft,
        uint256 _price,
        uint256 _maxPerMint,
        uint256 _maxPerWallet,
        uint256 _mintStart,
        uint256 _mintEnd
    )
        NFTExtension(_nft)
        MintPrice(_price)
        MaxPerMint(_maxPerMint)
        MaxPerWallet(_maxPerWallet)
        MintEndsAt(_mintEnd)
    {
        updateStartTimestamp(_mintStart);
    }

    function mint(
        uint256 amount
    )
        external
        payable
        whenMintActive
        whenSaleStarted
        whenEnoughETH(amount)
        whenNotMaxPerMint(amount)
        whenWalletNotFull(amount)
    {
        nft.mintExternal(amount, msg.sender, bytes32(0x0));
    }
}
