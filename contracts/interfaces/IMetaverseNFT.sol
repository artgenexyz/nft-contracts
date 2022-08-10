// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAvatarNFT {
    function DEVELOPER() external pure returns (string memory _url);

    function DEVELOPER_ADDRESS() external pure returns (address payable _dev);

    // ------ View functions ------
    function saleStarted() external view returns (bool);

    function isExtensionAdded(address extension) external view returns (bool);

    /**
        Extra information stored for each tokenId. Optional, provided on mint
     */
    function data(uint256 tokenId) external view returns (bytes32);

    // ------ Mint functions ------
    /**
        Mint from NFTExtension contract. Optionally provide data parameter.
     */
    function mintExternal(
        uint256 tokenId,
        address to,
        bytes32 data
    ) external payable;

    // ------ Admin functions ------
    function addExtension(address extension) external;

    function revokeExtension(address extension) external;

    function withdraw() external;
}

interface IMetaverseNFT is IAvatarNFT {
    // ------ View functions ------
    /**
        Recommended royalty for tokenId sale.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

    // ------ Admin functions ------
    function setRoyaltyReceiver(address receiver) external;

    function setRoyaltyFee(uint256 fee) external;
}

interface IMetaverseNFTSetup {

    function initialize(
        uint256 _price,
        uint256 _maxSupply,
        uint256 _nReserved,
        uint256 _maxPerMint,
        uint256 _royaltyFee,
        string memory _uri,
        string memory _name,
        string memory _symbol,
        bool _startAtOne
    ) external;

    function startSale() external;
    function stopSale() external;

    function saleStarted() external view returns (bool);

    function setPostfixURI(string memory postfix) external;
    function setRoyaltyReceiver(address _receiver) external;
    function setPayoutReceiver(address _receiver) external;

    function lockPayoutChange() external;

}