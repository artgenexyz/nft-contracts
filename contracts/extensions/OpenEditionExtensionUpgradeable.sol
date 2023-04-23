// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./base-upgradeable/NFTExtensionUpgradeable.sol";

// OpenEdition is a time-limited mint, after the end of the mint, mint will be closed forever
contract OpenEditionExtensionUpgradeable is
    NFTExtensionUpgradeable,
    OwnableUpgradeable
{
    uint startTimestamp;
    uint endTimestamp;

    uint mintPrice;
    uint maxPerMint;
    uint maxPerWallet;

    constructor() initializer {}

    function initialize(
        address _nft,
        uint256 _price,
        uint256 _maxPerMint,
        uint256 _maxPerWallet,
        uint256 _mintStart,
        uint256 _mintEnd
    ) public initializer {
        __Ownable_init();

        NFTExtensionUpgradeable.initialize(_nft);

        mintPrice = _price;
        maxPerMint = _maxPerMint;
        maxPerWallet = _maxPerWallet;

        startTimestamp = _mintStart;
        endTimestamp = _mintEnd;
    }

    modifier whenMintActive() {
        require(block.timestamp >= startTimestamp, "Mint has not started yet");
        require(block.timestamp <= endTimestamp, "Mint has ended");
        _;
    }

    modifier whenEnoughETH(uint256 amount) {
        require(msg.value >= amount * mintPrice, "Not enough ETH");
        _;
    }

    modifier whenNotMaxPerMint(uint256 amount) {
        require(amount <= maxPerMint, "Too many tokens to mint");
        _;
    }

    modifier whenWalletNotFull(uint256 amount) {
        require(
            IERC721(address(nft)).balanceOf(msg.sender) + amount <=
                maxPerWallet,
            "MaxPerWallet: Too many tokens to mint"
        );
        _;
    }

    function mint(
        uint256 amount
    )
        external
        payable
        whenMintActive
        whenEnoughETH(amount)
        whenNotMaxPerMint(amount)
        whenWalletNotFull(amount)
    {
        nft.mintExternal(amount, msg.sender, bytes32(0));
    }
}
