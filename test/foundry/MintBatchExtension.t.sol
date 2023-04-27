// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "contracts/extensions/MintBatchExtension.sol";
import "contracts/standards/ERC721CommunityBase.sol";

// import "contracts/Artgene721Implementation.sol";

contract MintBatchExtensionTest is Test {
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

        mintBatchExtension.mintAndSendBatch(nft, recipients, amounts);

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

        mintBatchExtension.mintAndSendBatch(nft, recipients, amounts);

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

        mintBatchExtension.mintAndSend(nft, recipients);

        assertEq(nft.balanceOf(recipients[0]), 1);
        assertEq(nft.balanceOf(recipients[1]), 1);
        assertEq(nft.balanceOf(recipients[2]), 1);

        assertEq(nft.balanceOf(recipients[3]), 1);
        assertEq(nft.balanceOf(recipients[4]), 1);
    }

    function testCannotMintExtensionNotAdded() public {
        address[] memory recipients = new address[](3);
        recipients[0] = makeAddr("Alice");
        recipients[1] = makeAddr("Bob");
        recipients[2] = makeAddr("Charlie");

        vm.expectRevert("Extension should be added to contract before minting");
        mintBatchExtension.mintAndSend(nft, recipients);

        vm.expectRevert("Extension should be added to contract before minting");
        mintBatchExtension.mintAndSend(nft, recipients);

        assertEq(nft.balanceOf(recipients[0]), 0);
        assertEq(nft.balanceOf(recipients[1]), 0);
        assertEq(nft.balanceOf(recipients[2]), 0);
    }

    function testCannotMintNonOwner() public {
        address[] memory recipients = new address[](3);
        recipients[0] = makeAddr("Alice");
        recipients[1] = makeAddr("Bob");
        recipients[2] = makeAddr("Charlie");

        nft.addExtension(address(mintBatchExtension));

        vm.stopPrank();
        vm.startPrank(makeAddr("Alice"));

        vm.expectRevert("MintBatchExtension: Not NFT owner");
        mintBatchExtension.mintAndSend(nft, recipients);

        assertEq(nft.balanceOf(recipients[0]), 0);
        assertEq(nft.balanceOf(recipients[1]), 0);
        assertEq(nft.balanceOf(recipients[2]), 0);
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

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function testMultiMintManyFork() public {
        ERC721CommunityBase piris = ERC721CommunityBase(
            payable(0x04AEDebB9b3F88c7e2bA28Dd7ef82eb868E91D6d)
        );
        MintBatchExtension deployedExtension = MintBatchExtension(
            0x06Cb98a36D3564b1CCb542b2F47e233Af63FFEBC
        );

        // check that we're running on a fork, if no, skip this test
        if (address(piris).code.length == 0) {
            vm.createSelectFork("mainnet");
        }

        if (address(piris).code.length == 0) {
            revert("PiRIS contract not found on this chain");
        }

        if (address(deployedExtension).code.length == 0) {
            revert("MintBatchExtension contract not found on this chain");
        }

        vm.stopPrank();

        address james = 0x4C5489fA2ccE6687f2390854f65FA88Aa338d133;
        vm.startPrank(james);

        // slice recipients from airdrop list

        // 0x26b3f5214fe3faef6811204ecda0c72854790e0e,9
        // 0x08a31368cc747621252abb9029440c1af6237fc7,1
        // 0xe37f987967cfb7c0f7c2a45624a92d34ece681a8,9
        // 0x0a602e90a9a8edf67274f06569af640873e8e7d5,3
        // 0xad3c9aefb16ce19e0c31b505d7b76e5b8e7eb9d6,2
        // 0x95b128b19d961a1f85ff128d69fa77bec69901c2,3
        // 0x69459ba40bb3b8cff9b0a1daa54ba5571c4dcef1,2

        address[] memory recipients = new address[](7);

        recipients[0] = 0x26B3f5214fe3faeF6811204EcdA0c72854790e0E;
        recipients[1] = 0x08a31368cC747621252ABB9029440C1Af6237Fc7;
        recipients[2] = 0xe37f987967cFb7C0F7c2a45624a92D34Ece681A8;
        recipients[3] = 0x0a602E90A9a8EDf67274F06569af640873e8e7d5;
        recipients[4] = 0xaD3C9aefB16cE19e0c31b505D7B76E5b8E7Eb9d6;
        recipients[5] = 0x95B128b19d961A1F85fF128D69Fa77BeC69901c2;
        recipients[6] = 0x69459BA40bB3B8cFf9b0a1daa54ba5571c4dCeF1;

        uint256[] memory amounts = new uint256[](7);

        amounts[0] = 9;
        amounts[1] = 1;
        amounts[2] = 9;
        amounts[3] = 3;
        amounts[4] = 2;
        amounts[5] = 3;
        amounts[6] = 2;

        // mintBatchExtension.mintAndSendMany(nft, recipients, amounts);

        uint256[] memory oldBalances = new uint256[](7);

        oldBalances[0] = piris.balanceOf(recipients[0]);
        oldBalances[1] = piris.balanceOf(recipients[1]);
        oldBalances[2] = piris.balanceOf(recipients[2]);
        oldBalances[3] = piris.balanceOf(recipients[3]);
        oldBalances[4] = piris.balanceOf(recipients[4]);
        oldBalances[5] = piris.balanceOf(recipients[5]);
        oldBalances[6] = piris.balanceOf(recipients[6]);

        piris.addExtension(address(deployedExtension));

        vm.expectEmit(true, true, true, true);
        emit Transfer(
            address(0),
            recipients[0],
            piris.totalSupply() + piris.startTokenId() // next token id
        );

        deployedExtension.mintAndSendBatch(piris, recipients, amounts);

        assertEq(piris.balanceOf(recipients[0]) - oldBalances[0], 9);
        assertEq(piris.balanceOf(recipients[1]) - oldBalances[1], 1);
        assertEq(piris.balanceOf(recipients[2]) - oldBalances[2], 9);
        assertEq(piris.balanceOf(recipients[3]) - oldBalances[3], 3);
        assertEq(piris.balanceOf(recipients[4]) - oldBalances[4], 2);
        assertEq(piris.balanceOf(recipients[5]) - oldBalances[5], 3);
        assertEq(piris.balanceOf(recipients[6]) - oldBalances[6], 2);

        vm.stopPrank();
    }
}
