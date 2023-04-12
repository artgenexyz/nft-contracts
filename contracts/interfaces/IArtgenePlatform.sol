// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArtgenePlatform {
    function PLATFORM_FEE() external view returns (uint256);
    function PLATFORM_ADDRESS() external view returns (address payable);

    function PLATFORM_INFO() external view returns (uint256, address payable);

    function setPlatformFee(uint256 _platformFee) external;
    function setPlatformAddress(address payable _platformAddress) external;
}
