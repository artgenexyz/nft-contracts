// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
// import "forge-std/StdJson.sol";

import "../contracts/Artgenes.sol";

contract DeployArtgenes is Script {
    using stdJson for string;

    Artgenes public artgenes;

    constructor() {
        run();
    }

    function run() public {

        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);
        vm.startBroadcast();

        // "goerli": "0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23",
        // "ethereum": "0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675",
        // "zksync-testnet": "0x093D2CF57f764f09C3c2Ac58a42A2601B8C79281"
        // "zksync-era": "0x9b896c0e23220469C7AE69cb4BbAE391eAa4C8da"

        address lzEndpoint = 0x093D2CF57f764f09C3c2Ac58a42A2601B8C79281;

        artgenes = new Artgenes(lzEndpoint);

        uint16 remoteChainId = 5;

        // _path = abi.encodePacked(remoteAddress, localAddress)
        bytes memory path = abi.encodePacked(remoteAddress, localAddress);

        artgenes.setTrustedRemote(remoteChainId, path);

        vm.stopBroadcast();
    }
}
