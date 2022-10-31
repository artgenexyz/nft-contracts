// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "contracts/extensions/MintBatchExtension.sol";
import "contracts/ERC721CommunityBase.sol";

// import Mock NFT contract

contract MintBatchExtensionTest is Test {
    // Utils internal utils;

    // address payable[] internal users;

    address owner;
    address alice;
    address bob;

    MintBatchExtension mintBatchExtension;
    ERC721CommunityBase nft;

    function setUp() public {
        // utils = new Utils();
        // users = utils.createUsers(3);
        owner = makeAddr("Owner");
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");

        mintBatchExtension = new MintBatchExtension();

        vm.startPrank(owner);

        nft = new ERC721CommunityBase(
            "Test",
            "NFT",
            10000,
            15, // reserved
            false,
            "ipfs://factory-test/",
            MintConfig(0.03 ether, 20, 20, 500, owner, false, false, false)
        );
    }

    function testMintToOwner() public {
        nft.addExtension(address(mintBatchExtension));

        mintBatchExtension.mintToOwner(nft, 10);

        assertEq(nft.balanceOf(owner), 10);
    }

    function testCannotMintExtensionNotAdded() public {
        vm.expectRevert("Extension should be added to contract before minting");
        mintBatchExtension.mintToOwner(nft, 5);

        vm.expectRevert("Extension should be added to contract before minting");
        mintBatchExtension.mintToOwner(nft, 10);

        assertEq(nft.balanceOf(owner), 0);
    }

    function testCannotMintNonOwner() public {
        nft.addExtension(address(mintBatchExtension));

        vm.stopPrank();
        vm.startPrank(makeAddr("Alice"));

        vm.expectRevert("MintBatchExtension: Not NFT owner");
        mintBatchExtension.mintToOwner(nft, 10);

        assertEq(nft.balanceOf(makeAddr("Alice")), 0);
    }

    function testMultimintMany(uint256[5] memory _amounts) public {
        for (uint256 i = 0; i < _amounts.length; i++) {
            _amounts[i] = bound(_amounts[i], 1, 100);
        }

        nft.addExtension(address(mintBatchExtension));

        address[] memory recipients = new address[](_amounts.length);
        uint256[] memory amounts = new uint256[](_amounts.length);

        for (uint256 i = 0; i < _amounts.length; i++) {
            recipients[i] = makeAddr(string(abi.encodePacked("Recipient ", i)));
            amounts[i] = _amounts[i];
        }

        mintBatchExtension.multimintMany(nft, recipients, amounts);

        assertEq(nft.balanceOf(recipients[0]), amounts[0]);
        assertEq(nft.balanceOf(recipients[1]), amounts[1]);
        assertEq(nft.balanceOf(recipients[2]), amounts[2]);
        assertEq(nft.balanceOf(recipients[3]), amounts[3]);
        assertEq(nft.balanceOf(recipients[4]), amounts[4]);
    }

    function xxxtestMultimintMany(
        address[] memory recipients,
        uint256[] memory amounts
    ) public {
        nft.addExtension(address(mintBatchExtension));

        vm.assume(recipients.length == amounts.length);
        vm.assume(recipients.length > 4);
        vm.assume(recipients.length < 30);

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            recipients[i] = recipients[i] != address(0)
                ? recipients[i]
                : makeAddr(string(abi.encodePacked("Recipient ", i)));
            amounts[i] = bound(amounts[i], 1, 100);
            totalAmount += amounts[i];
        }
        vm.assume(totalAmount <= nft.maxSupply());

        mintBatchExtension.multimintMany(nft, recipients, amounts);

        assertEq(nft.balanceOf(recipients[0]), amounts[0]);
    }

    function testMultimintOne() public {
        nft.addExtension(address(mintBatchExtension));

        address[] memory recipients = new address[](5);
        recipients[0] = makeAddr("Alice");
        recipients[1] = makeAddr("Bob");
        recipients[2] = makeAddr("Charlie");
        recipients[3] = makeAddr("Dave");
        recipients[4] = makeAddr("Eve");

        mintBatchExtension.multimintOne(nft, recipients);

        assertEq(nft.balanceOf(recipients[0]), 1);
        assertEq(nft.balanceOf(recipients[1]), 1);
        assertEq(nft.balanceOf(recipients[2]), 1);

        assertEq(nft.balanceOf(recipients[3]), 1);
        assertEq(nft.balanceOf(recipients[4]), 1);
    }

    function testMultisendBatch() public {
        // multisend batch accepts an array of recipients and start token id
        // transfers tokens sequentially from startTokenId to startTokenId + recipients.length

        nft.claim(10, owner);

        assertEq(nft.balanceOf(owner), 10);

        address[] memory recipients = new address[](5);
        recipients[0] = makeAddr("Alice");
        recipients[1] = makeAddr("Alice");
        recipients[2] = makeAddr("Bob");
        recipients[3] = makeAddr("Bob");
        recipients[4] = makeAddr("Charlie");

        nft.setApprovalForAll(address(mintBatchExtension), true);

        // startTokenId = 1
        mintBatchExtension.multisendBatch(nft, 1, recipients);

        assertEq(nft.balanceOf(recipients[0]), 2); // Alice has 2
        assertEq(nft.balanceOf(recipients[2]), 2); // Bob has 2
        assertEq(nft.balanceOf(recipients[4]), 1); // Charlie has 1
    }

    function testMultisend() public {
        // multisend batch accepts an array of recipients and an array of ids

        nft.claim(10, owner);

        assertEq(nft.balanceOf(owner), 10);

        uint256[] memory ids = new uint256[](10);

        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;
        ids[3] = 3;
        ids[4] = 4;
        ids[5] = 5;
        ids[6] = 6;
        ids[7] = 7;
        ids[8] = 8;
        ids[9] = 9;

        address[] memory recipients = new address[](10);

        recipients[0] = makeAddr("Alice");
        recipients[1] = makeAddr("Alice");

        recipients[2] = makeAddr("Bob");

        recipients[3] = makeAddr("Charlie");
        recipients[4] = makeAddr("Charlie");

        recipients[5] = makeAddr("Dave");
        recipients[6] = makeAddr("Dave");
        recipients[7] = makeAddr("Dave");

        recipients[8] = makeAddr("Eve");
        recipients[9] = makeAddr("Eve");

        nft.setApprovalForAll(address(mintBatchExtension), true);

        mintBatchExtension.multisend(nft, ids, recipients);

        assertEq(nft.balanceOf(makeAddr("Alice")), 2); // Alice has 2
        assertEq(nft.balanceOf(makeAddr("Bob")), 1); // Bob has 1
        assertEq(nft.balanceOf(makeAddr("Charlie")), 2); // Charlie has 2
        assertEq(nft.balanceOf(makeAddr("Dave")), 3); // Dave has 3
        assertEq(nft.balanceOf(makeAddr("Eve")), 2); // Eve has 2
    }
}
