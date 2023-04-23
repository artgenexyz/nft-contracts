// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

import "../../contracts/Artgene721Implementation.sol";

// from deploy-proxy.ts
address constant IMPLEMENTATION_ADDRESS = 0x000007214f56DaF21c803252cc610360C70C01D5;
address constant IMPLEMENTATION_DEPLOYER_ADDRESS = 0x1a597827e5d8818689200d521A28E477514db8B2;

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
