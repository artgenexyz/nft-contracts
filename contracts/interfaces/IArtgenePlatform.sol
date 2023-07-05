// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

address constant ARTGENE_PLATFORM_ADDRESS = 0xAaaeEee77ED0D0ffCc2813333b796E367f1E12d9;
address constant ARTGENE_PLATFORM_ADDRESS_ZKSYNC = 0x983A23615aC3ECdeBe7d1438251403d57956Ccba;

function getChainID() view returns (uint256) {
    uint256 id;
    assembly {
        id := chainid()
    }
    return id;
}

function getArtgenePlatformAddress() view returns (address) { 
    uint256 chainID = getChainID();
    if (chainID == 1) {
        // mainnet
        return ARTGENE_PLATFORM_ADDRESS;
    } else if (chainID == 5) {
        // goerli
        return ARTGENE_PLATFORM_ADDRESS;
    } else if (chainID == 280) {
        // zksync testnet
        return ARTGENE_PLATFORM_ADDRESS_ZKSYNC;
    } else if (chainID == 324) {
        // zksync era
        return ARTGENE_PLATFORM_ADDRESS_ZKSYNC;
    } else {
        return address(0);
    }
}


interface IArtgenePlatform {
    function getPlatformFee() external view returns (uint256);
    function getPlatformAddress() external view returns (address payable);

    function getPlatformInfo() external view returns (uint256, address payable);

    function setPlatformFee(uint256 _platformFee) external;
    function setPlatformAddress(address payable _platformAddress) external;
}
