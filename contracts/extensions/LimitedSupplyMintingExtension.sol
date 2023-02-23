// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";
import "./base/LimitedSupply.sol";
import "./base/MaxPerWallet.sol";
import "./base/MaxPerMint.sol";
import "./base/MintPrice.sol";

interface NFT is IERC721Community {
    function maxSupply() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

contract LimitedSupplyMintingExtension is
    NFTExtension,
    Ownable,
    SaleControl,
    LimitedSupply,
    MaxPerWallet,
    MaxPerMint,
    MintPrice
{
    constructor(
        address _nft,
        uint256 _price,
        uint256 _maxPerMint,
        uint256 _maxPerWallet,
        uint256 _extensionSupply
    )
        NFTExtension(_nft)
        LimitedSupply(_extensionSupply)
        MintPrice(_price)
        MaxPerMint(_maxPerMint)
        MaxPerWallet(_maxPerWallet)
    {
        stopSale();
        // sale stopped by default
    }

    function mint(
        uint256 amount
    )
        external
        payable
        whenSaleStarted
        whenEnoughETH(amount)
        whenNotMaxPerMint(amount)
        whenWalletNotFull(amount)
        whenLimitedSupplyNotReached(amount)
    {
        nft.mintExternal{value: msg.value}(amount, msg.sender, bytes32(0x0));
    }

    function maxSupply() public view returns (uint256) {
        return NFT(address(nft)).maxSupply();
    }

    function totalSupply() public view returns (uint256) {
        return NFT(address(nft)).totalSupply();
    }
}
