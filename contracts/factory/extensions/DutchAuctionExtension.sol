// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./NFTExtension.sol";
import "./SaleControl.sol";

contract DutchAuctionExtension is NFTExtension, Ownable, SaleControl {

    uint256 public startingPrice;
    uint256 public endTimestamp;
    uint256 public maxPerAddress;

    mapping (address => uint256) public claimedByAddress;

    constructor(address _nft, uint256 _price, uint256 _endTimestamp) NFTExtension(_nft) SaleControl() {
        stopSale();

        startingPrice = _price;
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

    function mint(uint256 nTokens) external whenSaleStarted payable {

        require(nTokens <= maxPerAddress, "Cannot claim more per transaction");

        require(msg.value >= nTokens * price(), "Not enough ETH to mint");

        nft.mintExternal{ value: msg.value }(nTokens, msg.sender, bytes32(0x0));

        // TODO: refund unused?

    }


    function price() public view returns (uint256 currentPrice) {
        // start at startTimestamp at startingPrice, gradually falls at reducePriceSpeed per second
        // currentPrice = startingPrice - (block.timestamp - startTimestamp) * 
        currentPrice = startingPrice - (block.timestamp - startTimestamp) * (endTimestamp - startTimestamp);
    }

}
