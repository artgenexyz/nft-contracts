// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

address constant ARTGENE_PLATFORM_ADDRESS = 0xAaaeEee77ED0D0ffCc2813333b796E367f1E12d9;

interface IArtgenePlatform {
    function getPlatformFee() external view returns (uint256);
    function getPlatformAddress() external view returns (address payable);

    function getPlatformInfo() external view returns (uint256, address payable);

    function setPlatformFee(uint256 _platformFee) external;
    function setPlatformAddress(address payable _platformAddress) external;
}
