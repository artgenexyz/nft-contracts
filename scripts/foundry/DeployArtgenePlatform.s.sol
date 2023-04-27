// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../../contracts/ArtgenePlatform.sol";

// from deploy-platform.ts
address constant PLATFORM_ADDRESS = 0xAaaeEee77ED0D0ffCc2813333b796E367f1E12d9;
address constant PLATFORM_DEPLOYER_ADDRESS = 0xE4A02093339a9a908cF9d897481813Ddb5494d44;

function loginVanity(Vm vm) {
    vm.prank(PLATFORM_DEPLOYER_ADDRESS);
}

function setupPlatform() {
    // deploy platform to vanity address
    ArtgenePlatform platform = new ArtgenePlatform();

    // assert platform is deployed to vanity address
    require(
        address(platform) == PLATFORM_ADDRESS,
        "ArtgenePlatform: deployed to wrong address"
    );
}

contract DeployArtgenePlatformScript is Script {
    function setUp() public {}

    function run() public {
        // TODO: learn how to login to vanity address properly using private key from .env
        vm.prank(PLATFORM_DEPLOYER_ADDRESS);

        // deploy platform to vanity address
        setupPlatform();

        vm.broadcast();
    }
}
