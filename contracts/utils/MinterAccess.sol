
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MinterAccess is Ownable {

    address internal _minter;

    constructor() {
        // _minter = minter;
    }

    function setMinter(address minter) public onlyOwner {
        _minter = minter;
    }

    modifier onlyMinter() {
        require(_minter == msg.sender, "MinterAccess: only minter allowed");
        _;
    }

}
