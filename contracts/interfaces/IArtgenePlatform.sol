// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

address constant ARTGENE_PLATFORM_ADDRESS = 0x88fadDFE9eC2d34C37F592c42141b152b382AE1b;

interface IArtgenePlatform {
    function getPlatformFee() external view returns (uint256);
    function getPlatformAddress() external view returns (address payable);

    function getPlatformInfo() external view returns (uint256, address payable);

    function setPlatformFee(uint256 _platformFee) external;
    function setPlatformAddress(address payable _platformAddress) external;
}
