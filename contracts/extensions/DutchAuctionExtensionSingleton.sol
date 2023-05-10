// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./base/NFTExtension.sol";
// import "./base/SaleControl.sol";

uint256 constant __SALE_NEVER_STARTS = 2 ** 256 - 1;

contract DutchAuctionExtensionSingleton {
    modifier onlyNFTOwner(IERC721Community nft) {
        require(
            Ownable(address(nft)).owner() == msg.sender,
            "MintBatchExtension: Not NFT owner"
        );
        _;
    }

    mapping(IERC721Community => uint256) public startPrice;
    mapping(IERC721Community => uint256) public endPrice;

    mapping(IERC721Community => uint256) public startTimestamp;
    mapping(IERC721Community => uint256) public endTimestamp;

    mapping(IERC721Community => uint256) public maxPerAddress;

    mapping(IERC721Community => mapping(address => uint256))
        public claimedByAddress;

    constructor() {}

    function configureSale(
        IERC721Community collection,
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        uint256 _maxPerAddress
    ) public onlyNFTOwner(collection) returns (address) {
        require(
            _startTimestamp >= block.timestamp,
            "Start time must be in the future"
        );
        require(
            _endTimestamp > _startTimestamp,
            "End time must be after start time"
        );

        require(
            _startPrice > _endPrice,
            "Start price must be greater than end price"
        );

        startTimestamp[collection] = _startTimestamp;
        endTimestamp[collection] = _endTimestamp;

        startPrice[collection] = _startPrice;
        endPrice[collection] = _endPrice;

        maxPerAddress[collection] = _maxPerAddress;

        return address(this);
    }

    function updatePrice(
        IERC721Community collection,
        uint256 _price
    ) public onlyNFTOwner(collection) {
        startPrice[collection] = _price;
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
    }

    function stopSale(
        IERC721Community collection
    ) public onlyNFTOwner(collection) {
        startTimestamp[collection] = __SALE_NEVER_STARTS;
        endTimestamp[collection] = __SALE_NEVER_STARTS;
    }

    // function saleStarted(IERC721Community collection) public view returns (bool) {
    //     return block.timestamp >= startTimestamp[collection] && block.timestamp <= endTimestamp[collection];
    // }

    function mint(
        IERC721Community collection,
        uint256 nTokens
    ) external payable {
        require(
            block.timestamp >= startTimestamp[collection],
            "Sale not started"
        );
        require(block.timestamp <= endTimestamp[collection], "Sale ended");

        require(
            nTokens + claimedByAddress[collection][msg.sender] <=
                maxPerAddress[collection],
            "Cannot claim more than maxPerAddress"
        );

        require(
            msg.value >= nTokens * price(collection),
            "Not enough ETH to mint"
        );

        collection.mintExternal{value: msg.value}(
            nTokens,
            msg.sender,
            bytes32(0x0)
        );

        // TODO: refund unused?
    }

    function price(
        IERC721Community collection
    ) public view returns (uint256 currentPrice) {
        // start at startTimestamp at startPrice, gradually falls until endTimestamp at endPrice

        if (block.timestamp <= startTimestamp[collection]) {
            return startPrice[collection];
        }

        if (block.timestamp >= endTimestamp[collection]) {
            return endPrice[collection];
        }

        uint256 timeDelta = endTimestamp[collection] -
            startTimestamp[collection];

        uint256 priceDelta = startPrice[collection] - endPrice[collection];

        uint256 timeElapsed = block.timestamp - startTimestamp[collection];

        uint256 priceChange = (timeElapsed * priceDelta) / timeDelta;

        return startPrice[collection] - priceChange;
    }
}
