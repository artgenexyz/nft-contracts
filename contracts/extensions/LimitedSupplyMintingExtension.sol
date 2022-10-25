// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";
import "./base/LimitedSupply.sol";

interface NFT is IERC721Community {
    function maxSupply() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

contract LimitedSupplyMintingExtension is
    NFTExtension,
    Ownable,
    SaleControl,
    LimitedSupply
{
    uint256 public price;
    uint256 public maxPerMint;
    uint256 public maxPerWallet;

    constructor(
        address _nft,
        uint256 _price,
        uint256 _maxPerMint,
        uint256 _maxPerWallet,
        uint256 _extensionSupply
    ) NFTExtension(_nft) LimitedSupply(_extensionSupply) {
        stopSale();
        // sale stopped by default

        price = _price;
        maxPerMint = _maxPerMint;
        maxPerWallet = _maxPerWallet;
    }

    function mint(uint256 amount)
        external
        payable
        whenSaleStarted
        whenLimitedSupplyNotReached(amount)
    {
        require(
            IERC721(address(nft)).balanceOf(msg.sender) + amount <=
                maxPerWallet,
            "LimitedSupplyMintingExtension: max per wallet reached"
        );

        require(amount <= maxPerMint, "Too many tokens to mint");
        require(msg.value >= amount * price, "Not enough ETH to mint");

        nft.mintExternal{value: msg.value}(amount, msg.sender, bytes32(0x0));
    }

    function maxSupply() public view returns (uint256) {
        return NFT(address(nft)).maxSupply();
    }

    function totalSupply() public view returns (uint256) {
        return NFT(address(nft)).totalSupply();
    }
}
