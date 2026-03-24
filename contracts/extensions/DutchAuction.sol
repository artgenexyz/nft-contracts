// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/Clones.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import "./allowlist-factory/base/NFTExtensionUpgradeable.sol";
import "./allowlist-factory/base/SaleControlUpgradeable.sol";

import "./base/NFTExtension.sol";
import "./base/SaleControl.sol";

contract DutchAuctionFactory {
    DutchAuction public implementation;

    constructor() {
        implementation = new DutchAuction();
    }

    function createExtension(
        address _nft,
        uint256 _price,
        uint256 _maxPerAddress,
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) public returns (DutchAuction) {
        address clone = Clones.clone(address(implementation));

        DutchAuction(clone).initialize(
            _nft,
            _price,
            _maxPerAddress,
            _startTimestamp,
            _endTimestamp,
            msg.sender
        );

        // if (startSale) {
        //     DutchAuction(clone).startSale();
        // }

        // DutchAuction(clone).transferOwnership(msg.sender);

        return DutchAuction(clone);
    }
}

contract DutchAuction is
    NFTExtensionUpgradeable,
    OwnableUpgradeable
    // SaleControlUpgradeable
{
    uint256 public startingPrice;
    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public maxPerAddress;

    mapping(address => uint256) public claimedByAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(
        address _nft,
        uint256 _price,
        uint256 _maxPerAddress,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        address owner
    ) public initializer {
        NFTExtensionUpgradeable.initialize(_nft);
        // SaleControlUpgradeable.initialize();
        __Ownable_init();
        transferOwnership(owner);

        startingPrice = _price;
        maxPerAddress = _maxPerAddress;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;

    }

    function updatePrice(uint256 _price) public onlyOwner {
        startingPrice = _price;
    }

    function updateMaxPerAddress(uint256 _maxPerAddress) public onlyOwner {
        maxPerAddress = _maxPerAddress;
    }

    function updateEndTimestamp(uint256 _timestamp) public onlyOwner {
        endTimestamp = _timestamp;
    }

    function mint(uint256 nTokens) external payable {
        require(block.timestamp <= endTimestamp, "Sale has ended");
        require(block.timestamp >= startTimestamp, "Sale has not started");

        require(nTokens <= maxPerAddress, "Cannot claim more per transaction");

        require(msg.value >= nTokens * price(), "Not enough ETH to mint");

        nft.mintExternal{value: msg.value}(nTokens, msg.sender, bytes32(0x0));

        // TODO: refund unused?
    }

    function price() public view returns (uint256 currentPrice) {
        // start at startTimestamp at startingPrice, gradually falls at reducePriceSpeed per second
        // currentPrice = startingPrice - (block.timestamp - startTimestamp) *
        currentPrice =
            startingPrice -
            (block.timestamp - startTimestamp) *
            (endTimestamp - startTimestamp);
    }
}
