// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";

import "contracts/standards/ERC721CommunityBase.sol";
import "contracts/extensions/OpenEditionExtensionUpgradeable.sol";
import "contracts/extensions/OpenEditionFactory.sol";

contract OpenEditionFactoryTest is Test {
    OpenEditionExtensionUpgradeable public extension;
    OpenEditionFactory public factory;
    ERC721CommunityBase public nft;

    function setUp() public {
        nft = new ERC721CommunityBase(
            "Test",
            "NFT",
            10000,
            3,
            false,
            "ipfs://factory-test/",
            MintConfig(0.03 ether, 20, 20, 500, msg.sender, false, false, false)
        );

        factory = new OpenEditionFactory();
    }

    // test creating extension and adding to nft contract
    function testAddExtension() public {
        extension = factory.createOpenEdition(
            "Test",
            address(nft),
            0.03 ether,
            1, // max per mint
            1, // max per wallet
            block.timestamp, // minting starts
            block.timestamp + 60000 // minting ends
        );

        nft.addExtension(address(extension));

        assertEq(address(nft.extensions(0)), address(extension));
    }

    // test minting with extension by signing message from "Alice"
    function testMint(uint256 price, uint8 mintAmount) public {
        mintAmount = uint8(bound(mintAmount, 1, 5));

        price = bound(price, 1, 1e9 * 1e18);

        address alice = makeAddr("Alice");

        extension = factory.createOpenEdition(
            "Test",
            address(nft),
            price,
            5, // max per mint
            5, // max per wallet
            block.timestamp, // minting starts
            block.timestamp + 60000 // minting ends
        );

        nft.addExtension(address(extension));

        vm.prank(alice);
        vm.deal(alice, 2 * price * mintAmount);

        extension.mint{value: price * mintAmount}(mintAmount);
    }

    // function test mint fails after time limit
    function testCannotMintAfterEnd(uint256 price, uint8 mintAmount) public {
        mintAmount = uint8(bound(mintAmount, 1, 5));

        price = bound(price, 1, 1e9 * 1e18);

        address alice = makeAddr("Alice");

        extension = factory.createOpenEdition(
            "Test",
            address(nft),
            price,
            5, // max per mint
            5, // max per wallet
            block.timestamp, // minting starts
            block.timestamp + 60000 // minting ends
        );

        nft.addExtension(address(extension));

        vm.warp(70_000);

        vm.prank(alice);
        vm.deal(alice, 2 * price * mintAmount);

        vm.expectRevert("Mint has ended");
        extension.mint{value: price * mintAmount}(mintAmount);
    }
}
