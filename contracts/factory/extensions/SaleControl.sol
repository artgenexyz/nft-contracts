// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract SaleControl is Ownable {

    uint256 public constant SALE_NOT_ACTIVE_FOREVER = 2**256 - 1;

    uint256 public startTimestamp = SALE_NOT_ACTIVE_FOREVER;

    modifier whenSaleStarted {
        require(saleStarted(), "Not started yet");
        _;
    }

    function updateStartTimestamp(uint256 _startTimestamp) public onlyOwner {
        startTimestamp = _startTimestamp;
    }

    function startSale() public onlyOwner {
        startTimestamp = block.timestamp;
    }

    function stopSale() public onlyOwner {
        startTimestamp = SALE_NOT_ACTIVE_FOREVER;
    }

    function saleStarted() public view returns (bool) {
        return block.timestamp > startTimestamp;
    }
}