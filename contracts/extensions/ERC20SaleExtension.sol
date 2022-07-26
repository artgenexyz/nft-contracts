// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./base/NFTExtension.sol";

contract ERC20SaleExtension is NFTExtension, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public currency;

    uint256 public price;
    uint256 public maxPerMint;

    event currencyChanged(address indexed newCurrency, uint256 newPrice);

    // Currently looking for solution how to check if _currencyTokenAddress is address of valid ERC20 contract
    constructor(
        address _nft,
        address _currencyAddress,
        uint256 _price,
        uint256 _maxPerMint
    ) NFTExtension(_nft) {
        currency = IERC20(_currencyAddress);
        price = _price;
        maxPerMint = _maxPerMint;

        emit currencyChanged(_currencyAddress, _price);
    }

    // In order to mint user have to approve ERC20 tokens to extension address
    function mint(uint256 nTokens) external {
        super.beforeMint();

        require(nTokens <= maxPerMint, "Too many tokens to mint");
        uint256 currencyPrice = nTokens * price;
        require(
            currency.balanceOf(msg.sender) >= currencyPrice,
            "Not enough currency to mint"
        );

        currency.safeTransferFrom(msg.sender, address(nft), currencyPrice);
        nft.mintExternal(nTokens, msg.sender, bytes32(0x0));
    }

    function changeCurrency(address _newCurrency, uint256 _newPrice)
        external
        onlyOwner
    {
        require(_newPrice > 0, "New price must be bigger then zero");
        currency = IERC20(_newCurrency);
        price = _newPrice;

        emit currencyChanged(_newCurrency, _newPrice);
    }
}
