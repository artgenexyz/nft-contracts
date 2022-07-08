// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";

contract TokenPassExtension is NFTExtension, Ownable, SaleControl {
    uint256 public price;

    uint256 public minBalance;

    // Number of remaining tokens
    uint256 public nRemainingTokens;

    // The address of ERC20 contract that is used for mint pass
    address public mintPassAddress;

    // For used tokenIds in the mint pass
    mapping(address => bool) public hasMinted;

    constructor(
        address _nft,
        address _mintPassAddress,
        uint256 _minBalance,
        uint256 _price,
        uint256 _maxPerExtension
    ) NFTExtension(_nft) SaleControl() {
        stopSale();

        price = _price;
        mintPassAddress = _mintPassAddress;
        minBalance = _minBalance;

        // At the begining, the number of tokens is max per extension
        nRemainingTokens = _maxPerExtension;
    }

    function updatePrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function updateMintPassAddress(address _mintPassAddress) public onlyOwner {
        mintPassAddress = _mintPassAddress;
    }

    function mint(uint256 nTokens) public payable whenSaleStarted {
        require(
            nRemainingTokens >= nTokens,
            "The number of remaining tokens is less than nTokens"
        );

        require(msg.value >= nTokens * price, "Not enough ETH to mint");

        // for (uint256 i = 0; i < mintPassTokenIds.length; i++) {
        //   uint256 mintPassTokenId = mintPassTokenIds[i];

        require(
            hasMinted[msg.sender] == false,
            "This tokenId has already been used"
        );

        require(
            ERC20(mintPassAddress).balanceOf(msg.sender) >= minBalance,
            "Does not have enough of mint pass tokens"
        );

        hasMinted[msg.sender] == true;
        // usedTokenIds[mintPassTokenId] = true;
        // }

        nRemainingTokens -= nTokens;

        nft.mintExternal{value: msg.value}(nTokens, msg.sender, bytes32(0x0));
    }
}
