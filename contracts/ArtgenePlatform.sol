// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

import "./interfaces/IArtgenePlatform.sol";

bytes32 constant _ARTGENE_PLATFORM_SLOT = bytes32(
    uint256(keccak256("xyz.artgene.platform.info")) - 1
);

bytes32 constant _ARTGENE_PLATFORM_DEPLOY_SALT = bytes32(bytes3(0x000721));

function _DEPLOY_ARTGENE_PLATFORM(address fromDeployer) returns (address) {

    // deploy using create2
    ArtgenePlatform platform = new ArtgenePlatform{ salt: _ARTGENE_PLATFORM_DEPLOY_SALT }();

    // address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
    //     bytes1(0xff),
    //     address(this),
    //     bytes32(bytes3(0x000721)),
    //     keccak256(abi.encodePacked(
    //         type(ArtgenePlatform).creationCode
    //     ))
    // )))));

    platform.transferOwnership(msg.sender);

    require(
        address(platform) == _ARTGENE_PLATFORM_ADDRESS(fromDeployer),
        "ArtgenePlatformConfig: platform address mismatch"
    );

    // address predictedAddress = _ARTGENE_PLATFORM_ADDRESS(address(this));

    return address(platform);
}

function _ARTGENE_PLATFORM_GET_INFO() view returns (uint256, address payable) {
    address pl = StorageSlot.getAddressSlot(_ARTGENE_PLATFORM_SLOT).value;

    if (pl == address(0)) {
        revert("ArtgenePlatformConfig: platform not set");
    }

    return ArtgenePlatform(pl).PLATFORM_INFO();
}

// function _ARTGENE_PLATFORM_GET_ADDRESS_SLOT_VALUE() view returns (address) {
//     return StorageSlot.getAddressSlot(_ARTGENE_PLATFORM_SLOT).value;

//     // return _ARTGENE_PLATFORM_SLOT;
// }

function _ARTGENE_PLATFORM_SET_ADDRESS_SLOT_FOR(address deployer) {
    StorageSlot.getAddressSlot(_ARTGENE_PLATFORM_SLOT).value = _ARTGENE_PLATFORM_ADDRESS(deployer);
    // StorageSlot.getAddressSlot(_ARTGENE_PLATFORM_SLOT).value = value;
}

// address constant PLATFORM_ADDRESS =
//     address(uint160(uint(keccak256(abi.encodePacked(
//         bytes1(0xff),
//         proxyImplementation,
//         bytes32(bytes3(0x000721)),
//         keccak256(abi.encodePacked(type(ArtgenePlatform).creationCode))
//     )))));

function _ARTGENE_PLATFORM_ADDRESS(address deployer) pure returns (address) {
    return
        address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            deployer,
                            _ARTGENE_PLATFORM_DEPLOY_SALT,
                            keccak256(
                                abi.encodePacked(
                                    type(ArtgenePlatform).creationCode
                                )
                            )
                        )
                    )
                )
            )
        );
}

contract ArtgenePlatform is Ownable, IArtgenePlatform {
    // bytes32 public constant _ARTGENE_PLATFORM_SLOT =
    //     bytes32(uint256(keccak256("xyz.artgene.platform.info")) - 1);

    uint256 public platformFee; // in bps
    address payable public platformAddress;

    constructor() {
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

    function PLATFORM_FEE() external view override returns (uint256) {
        return platformFee;
    }

    function PLATFORM_ADDRESS()
        external
        view
        override
        returns (address payable)
    {
        return platformAddress;
    }

    function PLATFORM_INFO() external view returns (uint256, address payable) {
        return (platformFee, platformAddress);
    }

    // function _PLATFORM_SETUP()
    //     external
    //     view
    //     returns (bytes32 slot, bytes32 padded)
    // {
    //     slot = _ARTGENE_PLATFORM_SLOT;
    //     padded = bytes32(abi.encodePacked(platformAddress));
    // }
}
