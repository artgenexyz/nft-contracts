// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "./ArtgenePlatform.sol";

bytes32 constant _ARTGENE_PLATFORM_SLOT = bytes32(
    uint256(keccak256("xyz.artgene.platform.info")) - 1
);

bytes32 constant _ARTGENE_PLATFORM_DEPLOY_SALT = bytes32(bytes4(0x00000721));

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

    // if no code at this address, revert
    uint256 size;
    assembly { size := extcodesize(pl) }
    if (size == 0) {
        revert("ArtgenePlatformConfig: platform is not deployed");
    }

    return ArtgenePlatform(pl).getPlatformInfo();
}

// function _ARTGENE_PLATFORM_GET_ADDRESS_SLOT_VALUE() view returns (address) {
//     return StorageSlot.getAddressSlot(_ARTGENE_PLATFORM_SLOT).value;

//     // return _ARTGENE_PLATFORM_SLOT;
// }

function _ARTGENE_PLATFORM_SET_ADDRESS_SLOT_FOR(address deployer) {
    StorageSlot.getAddressSlot(_ARTGENE_PLATFORM_SLOT).value = _ARTGENE_PLATFORM_ADDRESS(deployer);
}

// address constant PLATFORM_ADDRESS =
//     address(uint160(uint(keccak256(abi.encodePacked(
//         bytes1(0xff),
//         proxyImplementation,
//         bytes32(bytes3(0x000721)),
//         keccak256(abi.encodePacked(type(ArtgenePlatform).creationCode))
//     )))));

function _ARTGENE_PLATFORM_ADDRESS(address deployer) view returns (address) {


    // console.log(abi.encodePacked(
    //     bytes1(0xff),
    //     deployer,
    //     _ARTGENE_PLATFORM_DEPLOY_SALT,
    //     keccak256(
    //         abi.encodePacked(
    //             type(ArtgenePlatform).creationCode
    //         )
    //     )
    // ));

    console.log("0xff");

    console.log(deployer);
    bytes32 salt = _ARTGENE_PLATFORM_DEPLOY_SALT;

    console.logBytes32(salt);

    bytes32 codeHash = keccak256(
        abi.encodePacked(
            type(ArtgenePlatform).creationCode
        )
    );

    console.logBytes32(codeHash);
    require(
        codeHash == bytes32(0x5d436ddf7f9828af99a6bea190b6665d5632fe6b57891d17be7eb86a7293a4a5),
        "ArtgenePlatformConfig: code hash mismatch"
    );

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

