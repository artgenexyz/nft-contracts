// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";

import "contracts/ERC721CommunityBase.sol";
import "contracts/extensions/OffchainAllowlistExtension.sol";

contract OffchainAllowlistExtensionTest is Test {
    OffchainAllowlistExtension public extension;
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
    }

    // test creating extension and adding to nft contract
    function testAddExtension() public {
        address signer = makeAddr("Alice");

        extension = new OffchainAllowlistExtension(
            address(nft),
            signer,
            0.03 ether,
            10000
        );

        nft.addExtension(address(extension));

        assertEq(address(nft.extensions(0)), address(extension));
    }

    // test minting with extension by signing message from "Alice"
    function testMint(uint256 price, uint8 totalSupply, uint8 mintAmount) public {
        vm.assume(totalSupply > 0);
        vm.assume(mintAmount > 0);
        vm.assume(mintAmount <= totalSupply);

        price = bound(price, 1, 1e9 * 1e18);

        address alice = makeAddr("Alice");

        (address signer, uint256 signerKey) = makeAddrAndKey("Signer");

        extension = new OffchainAllowlistExtension(
            address(nft),
            signer,
            price,
            totalSupply
        );

        nft.addExtension(address(extension));

        extension.startSale();

        bytes32 digest = extension.calculateDigest(alice, address(extension), uint96(mintAmount));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        SignedAllowance memory allowance = SignedAllowance(
            alice,
            address(extension),
            mintAmount,
            signature
        );

        vm.prank(alice);
        vm.deal(alice, 2 * price * mintAmount);

        extension.mint{value: price * mintAmount}(mintAmount, allowance);
    }
}
