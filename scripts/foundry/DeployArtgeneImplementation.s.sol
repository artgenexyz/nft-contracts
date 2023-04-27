// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../../contracts/Artgene721Implementation.sol";

// from deploy-proxy.ts
address constant IMPLEMENTATION_ADDRESS = 0x00000721bEb748401E0390Bb1c635131cDe1Fae8;
address constant IMPLEMENTATION_DEPLOYER_ADDRESS = 0x156deFdb1c699B48506FfBC97d37612189de788D;

// function loginVanity(Vm vm) {
//     vm.prank(IMPLEMENTATION_DEPLOYER_ADDRESS);
// }

function setupImplementation() {
    // deploy platform to vanity address
    Artgene721Implementation implementation = new Artgene721Implementation();

    // assert platform is deployed to vanity address
    require(
        address(implementation) == IMPLEMENTATION_ADDRESS,
        "ArtgenePlatform: deployed to wrong address"
    );
}

contract DeployArtgeneImplementationScript is Script {
    function setUp() public {}

    function run() public {
        // TODO: learn how to login to vanity address properly using private key from .env
        vm.prank(IMPLEMENTATION_DEPLOYER_ADDRESS);

        // deploy platform to vanity address
        setupImplementation();

        vm.broadcast();
    }
}
