// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./base-upgradeable/NFTExtensionUpgradeable.sol";

// OpenEdition is a time-limited mint, after the end of the mint, mint will be closed forever
contract OpenEditionExtensionUpgradeable is
    NFTExtensionUpgradeable,
    OwnableUpgradeable
{
    error MintExceedsMaxPerWallet();
    error MintNotStarted();
    error MintHasEnded();

    error NotEnoughETH();
    error NotEnoughTokens();
    error MintExceedsMaxPerMint();

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
        if (block.timestamp < startTimestamp) {
            revert MintNotStarted();
        }

        if (block.timestamp > endTimestamp) {
            revert MintHasEnded();
        }

        _;
    }

    modifier whenEnoughETH(uint256 amount) {
        if (msg.value < amount * mintPrice) {
            revert NotEnoughETH();
        }

        _;
    }

    modifier whenNotMaxPerMint(uint256 amount) {
        if (amount > maxPerMint) {
            revert MintExceedsMaxPerMint();
        }

        _;
    }

    modifier whenWalletNotFull(uint256 amount) {
        if (
            IERC721(address(nft)).balanceOf(msg.sender) + amount > maxPerWallet
        ) {
            revert MintExceedsMaxPerWallet();
        }

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
