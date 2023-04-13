// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

import "./interfaces/IArtgenePlatform.sol";

contract ArtgenePlatform is Ownable, IArtgenePlatform {

    uint256 platformFee; // in bps
    address payable platformAddress;

    constructor() {
        require(
            ARTGENE_PLATFORM_ADDRESS == address(this),
            "ArtgenePlatformConfig: platform address mismatch"
        );

        platformFee = 500;
        platformAddress = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    }

    function setPlatformFee(uint256 _platformFee) public onlyOwner {
        require(
            _platformFee <= 1000,
            "ArtgenePlatformConfig: platform fee cannot be more than 10%"
        );

        platformFee = _platformFee;
    }

    function setPlatformAddress(
        address payable _platformAddress
    ) public onlyOwner {
        platformAddress = _platformAddress;
    }

    function getPlatformFee() external view override returns (uint256) {
        return platformFee;
    }

    function getPlatformAddress()
        external
        view
        override
        returns (address payable)
    {
        return platformAddress;
    }

    function getPlatformInfo()
        external
        view
        returns (uint256, address payable)
    {
        return (platformFee, platformAddress);
    }
}
