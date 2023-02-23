// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MintEndsAt is Ownable {
    uint256 public endTimestamp;

    constructor(uint256 _endTimestamp) {
        endTimestamp = _endTimestamp;
    }

    modifier whenMintActive() {
        require(isMintActive(), "Mint already ended");
        _;
    }

    function updateEndTimestamp(uint256 _endTimestamp) public onlyOwner {
        require(!isMintActive(), "Can only change if not finished");
        endTimestamp = _endTimestamp;
    }

    function end() public onlyOwner {
        endTimestamp = block.timestamp;
    }

    function isMintActive() public view returns (bool) {
        return block.timestamp <= endTimestamp;
    }
}
