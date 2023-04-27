// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

address constant ARTGENE_PROXY_IMPLEMENTATION = 0x00000721bEb748401E0390Bb1c635131cDe1Fae8;

uint256 constant ARTGENE_MAX_SUPPLY_OPEN_EDITION = 0;

struct MintConfig {
    uint256 publicPrice;
    uint256 maxTokensPerMint;
    uint256 maxTokensPerWallet;
    uint256 royaltyFee;
    address payoutReceiver;
    bool shouldLockPayoutReceiver;
    uint32 startTimestamp;
    uint32 endTimestamp;
}

interface IArtgene721 {
    // ------ View functions ------
    function saleStarted() external view returns (bool);

    function isExtensionAdded(address extension) external view returns (bool);

    function renderer() external view returns (address);

    /**
        Extra information stored for each tokenId. Optional, provided on mint
     */
    function data(uint256 tokenId) external view returns (bytes32);

    // ------ Mint functions ------
    /**
        Mint from NFTExtension contract. Optionally provide data parameter.
     */
    function mintExternal(
        uint256 amount,
        address to,
        bytes32 data
    ) external payable;

    // ------ Admin functions ------
    function addExtension(address extension) external;

    function revokeExtension(address extension) external;

    function withdraw() external;

    // ------ View functions ------
    /**
        Recommended royalty for tokenId sale.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);

    // ------ Admin functions ------
    function setRoyaltyReceiver(address receiver) external;

    function setRoyaltyFee(uint256 fee) external;

    // ------ IERC4906 ------

    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    /// @dev This event emits when the metadata of a range of tokens is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFTs.
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
}

interface IArtgene721Implementation {
    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _nReserved,
        bool _startAtOne,
        string memory uri,
        MintConfig memory config
    ) external;
}
