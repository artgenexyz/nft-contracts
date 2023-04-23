// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../../contracts/Artgene721.sol";
import "../../contracts/Artgene721Implementation.sol";
import "../../contracts/ArtgenePlatform.sol";

import "../../scripts/foundry/DeployArtgenePlatform.s.sol";
import "../../scripts/foundry/DeployArtgeneImplementation.s.sol";

contract ArgeneTest is Test {
    Artgene721Implementation nft;

    address owner;
    address user1;
    address user2;
    address beneficiary;

    function setUp() public {
        owner = msg.sender;
        user1 = makeAddr("Alice");
        user2 = makeAddr("Bob");
        beneficiary = owner;

        DeployArtgenePlatformScript deployer1 = new DeployArtgenePlatformScript();
        deployer1.run();

        DeployArtgeneImplementationScript deployer2 = new DeployArtgeneImplementationScript();
        deployer2.run();

        Artgene721 proxy = new Artgene721(
            "Abstract Art NFT",
            "ART",
            10_000,
            1,
            StartFromTokenIdOne.wrap(true), // start from one or zero
            "ipfs://QmABAABBABA",
            MintConfig(0.1 ether, 5, 5, 500, msg.sender, false, false, true)
        );

        nft = Artgene721Implementation(payable(proxy));
    }

    function _testRecordGasCost() public {
        Artgene721 proxy = new Artgene721(
            "Abstract Art NFT",
            "ART",
            10_000,
            1,
            StartFromTokenIdOne.wrap(true), // start from one or zero
            "ipfs://QmABAABBABA",
            MintConfig(0.1 ether, 5, 5, 500, msg.sender, false, false, true)
        );

        assert(address(proxy).code.length != 0);
    }

    function testDeployedCorrectly() public {
        assertEq(nft.name(), "Abstract Art NFT");
        assertEq(nft.symbol(), "ART");
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.maxSupply(), 10_000);
        assertEq(nft.reserved(), 1);

        assertEq(nft.contractURI(), "ipfs://QmABAABBABA");

        assertEq(nft.price(), 0.1 ether);
        assertEq(nft.maxPerMint(), 5);
        assertEq(nft.maxPerWallet(), 5);

        assertEq(nft.getPayoutReceiver(), msg.sender);
        assertEq(nft.isPayoutChangeLocked(), false);
        assertEq(nft.saleStarted(), false);
    }

    // test minting when sale is not started
    function testFailMintNotStarted() public {
        nft.mint(1);
    }

    // test minting when sale is started but not enough funds

    function testMintWhenStartedButNotEnoughFunds() public {
        nft.startSale();

        assertEq(nft.saleStarted(), true);

        vm.prank(user1);

        vm.expectRevert("Inconsistent amount sent!");
        nft.mint(1);

        assertEq(nft.totalSupply(), 0);
    }

    // test minting when sale is started and enough funds
    function testMintSuccess() public {
        nft.startSale();

        assertEq(nft.saleStarted(), true);

        vm.prank(user1);
        vm.deal(user1, 0.1 ether);
        nft.mint{value: 0.1 ether}(1);

        assertEq(nft.totalSupply(), 1);

        vm.prank(user2);
        vm.deal(user2, 0.2 ether);
        nft.mint{value: 0.2 ether}(2);

        assertEq(nft.totalSupply(), 3);
    }

    // test minting when sale is ended
}
