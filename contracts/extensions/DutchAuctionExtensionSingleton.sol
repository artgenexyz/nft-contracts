// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./base/NFTExtension.sol";
// import "./base/SaleControl.sol";

uint256 constant __SALE_NEVER_STARTS = 2**256 - 1;


contract DutchAuctionExtensionSingleton {
    modifier onlyNFTOwner(IERC721Community nft) {
        require(
            Ownable(address(nft)).owner() == msg.sender,
            "MintBatchExtension: Not NFT owner"
        );
        _;
    }

    mapping(IERC721Community => uint256) public startingPrice;
    mapping(IERC721Community => uint256) public startTimestamp;
    mapping(IERC721Community => uint256) public endTimestamp;
    mapping(IERC721Community => uint256) public maxPerAddress;

    mapping(IERC721Community => bool) public saleStarted;

    mapping(address => mapping(IERC721Community => uint256))
        public claimedByAddress;

    constructor() {}

    function configureSale(
        IERC721Community collection,
        uint256 _price,
        uint256 _maxPerAddress,
        uint256 _endTimestamp,
        bool _saleStarted
    ) public onlyNFTOwner(collection) {

        startTimestamp[collection] = __SALE_NEVER_STARTS;
        endTimestamp[collection] = _endTimestamp;
        startingPrice[collection] = _price;
        maxPerAddress[collection] = _maxPerAddress;

        // endTimestamp[collection] = __SALE_NEVER_STARTS;

        saleStarted[collection] = _saleStarted;

        if (_saleStarted) {
            startTimestamp[collection] = block.timestamp;
        }
    }

    function updatePrice(
        IERC721Community collection,
        uint256 _price
    ) public onlyNFTOwner(collection) {
        startingPrice[collection] = _price;
    }

    function updateMaxPerAddress(
        IERC721Community collection,
        uint256 _maxPerAddress
    ) public onlyNFTOwner(collection) {
        maxPerAddress[collection] = _maxPerAddress;
    }

    function updateEndTimestamp(
        IERC721Community collection,
        uint256 _timestamp
    ) public onlyNFTOwner(collection) {
        endTimestamp[collection] = _timestamp;
    }

    function startSale(
        IERC721Community collection
    ) public onlyNFTOwner(collection) {
        startTimestamp[collection] = block.timestamp;
        endTimestamp[collection] = __SALE_NEVER_STARTS;

        saleStarted[collection] = true;
    }

    function stopSale(
        IERC721Community collection
    ) public onlyNFTOwner(collection) {
        startTimestamp[collection] = __SALE_NEVER_STARTS;
        endTimestamp[collection] = __SALE_NEVER_STARTS;

        saleStarted[collection] = false;
    }

    // function saleStarted(IERC721Community collection) public view returns (bool) {
    //     return block.timestamp >= startTimestamp[collection] && block.timestamp <= endTimestamp[collection];
    // }

    function mint(
        IERC721Community collection,
        uint256 nTokens
    ) external payable {
        require(saleStarted[collection], "Sale not started");

        // require(block.timestamp >= startTimestamp[collection], "Sale not started");
        // require(block.timestamp <= endTimestamp[collection], "Sale ended");

        require(
            nTokens <= maxPerAddress[collection],
            "Cannot claim more per transaction"
        );

        require(
            msg.value >= nTokens * price(collection),
            "Not enough ETH to mint"
        );

        IERC721Community(collection).mintExternal{value: msg.value}(
            nTokens,
            msg.sender,
            bytes32(0x0)
        );

        // TODO: refund unused?
    }

    function price(
        IERC721Community collection
    ) public view returns (uint256 currentPrice) {
        // start at startTimestamp at startingPrice, gradually falls at reducePriceSpeed per second
        // currentPrice = startingPrice - (block.timestamp - startTimestamp) *
        currentPrice =
            startingPrice[collection] -
            (block.timestamp - startTimestamp[collection]) *
            (endTimestamp[collection] - startTimestamp[collection]);
    }
}
