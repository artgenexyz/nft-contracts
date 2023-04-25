// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "../../contracts/Artgene721.sol";
import "../../contracts/Artgene721Implementation.sol";
import "../../contracts/ArtgenePlatform.sol";

import "../../contracts/extensions/mocks/MockRenderer.sol";

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
            MintConfig(0.1 ether, 5, 5, 500, msg.sender, false, 0, 0)
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
            MintConfig(0.1 ether, 5, 5, 500, msg.sender, false, 0, 0)
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

    event BatchMetadataUpdate(uint256 fromTokenId, uint256 toTokenId);

    function testUpdateBaseURIEmits() public {
        nft.claim(1, user1);

        vm.expectEmit(true, true, false, true);

        // The event we expect: update token 1 metadata
        emit BatchMetadataUpdate(1, 1);

        nft.setBaseURI("ipfs://QmABAABBABA");
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

    function testMintMeasureGas() public {
        nft.startSale();

        vm.deal(user1, 1 ether);
        vm.prank(user1);

        uint256 gas = gasleft();

        nft.mint{value: 0.1 ether}(1);

        gas = gas - gasleft();

        console.log("[mint] gas used: ", gas);
    }


    event Evolution(uint256 indexed, bytes32);
    function testMintEmitsEvent() public {
        nft.startSale();

        vm.deal(user1, 1 ether);
        vm.prank(user1);

        bytes32 predictedDNA = keccak256(abi.encodePacked(
            bytes32(block.prevrandao),
            blockhash(block.number - 1),
            bytes32(uint256(1))
        ));

        // console.log("Predicted DNA: ", Strings.toHexString(uint256(predictedDNA)));

        vm.expectEmit(true, true, false, true);
        emit Evolution(1, predictedDNA);

        // The event we expect: minted token 1

        nft.mint{value: 0.1 ether}(1);
    }

    function testTokenHTMLReturnsString() public {
        nft.startSale();
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        nft.mint{value: 0.1 ether}(1);

        MockRenderer renderer = new MockRenderer(address(nft));
        nft.setRenderer(address(renderer));

        string memory html = nft.tokenHTML(1, "0x123123", new bytes(0));

        assertGe(bytes(html).length, 100, "HTML too small");
    }

    // test minting when sale is ended
    // it should be able to set endTimestamp
    // and you cant mint before startTimestamp, you can not mint after
    // but you can mint between
    function testMintWithTimestamps() public {

        uint32 _now = uint32(block.timestamp);

        nft.updateMintStartEnd(_now + 2 hours, _now + 5 hours);

        // setup

        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        // time travel
        skip(1 hours);

        assertEq(nft.saleStarted(), false);

        vm.expectRevert("Sale not active");
        nft.mint{value: 0.1 ether}(1);

        // skip
        skip(1 hours);

        assertEq(nft.saleStarted(), true);

        nft.mint{value: 0.1 ether}(1);
        assertEq(nft.totalSupply(), 1);

        // time travel
        skip(5 hours);

        assertEq(nft.saleStarted(), false);

        vm.expectRevert("Sale not active");
        nft.mint{value: 0.1 ether}(1);

        assertEq(nft.totalSupply(), 1);
    }

    function testOpenEditionCannotDeploy() public {

        vm.expectRevert("OpenEdition requires start and end timestamp");
        Artgene721 proxy = new Artgene721(
            "Abstract Art NFT",
            "ART",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION, // max supply is ZERO, this is open edition
            1,
            StartFromTokenIdOne.wrap(true), // start from one or zero
            "ipfs://QmABAABBABA",
            MintConfig(0.1 ether, 5, 5, 500, msg.sender, false, 0, 0)
        );

        assert(address(proxy).code.length == 0);

    }

    // test creating open edition
    // (max supply = 0, start timestamp = now + 1 days, end timestamp = now + 2 days)
    function testOpenEdition() public {
        uint32 _now = uint32(block.timestamp);

        Artgene721 proxy = new Artgene721(
            "Abstract Art NFT",
            "ART",
            ARTGENE_MAX_SUPPLY_OPEN_EDITION, // max supply is ZERO, this is open edition
            1,
            StartFromTokenIdOne.wrap(true), // start from one or zero
            "ipfs://QmABAABBABA",
            // hack: set maxPerMint to 999_999
            MintConfig(0.0001 ether, 999_999, 999_999, 500, msg.sender, false, _now + 1 days, _now + 2 days)
        );

        nft = Artgene721Implementation(payable(proxy));
        // nft.updateMaxPerWallet(0); // no limit
        // nft.updateMaxPerMint(50); // no limit

        assertEq(nft.name(), "Abstract Art NFT");
        assertEq(nft.symbol(), "ART");

        assertEq(nft.totalSupply(), 0);

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);

        // test mint

        assertEq(nft.saleStarted(), false);

        vm.expectRevert("Sale not active");
        nft.mint{value: 0.0001 ether}(1);

        // skip

        skip(1 days);

        assertEq(nft.saleStarted(), true);

        nft.mint{value: 0.0001 ether}(1);

        assertEq(nft.totalSupply(), 1);

        // it allows to mint unlimited amount of tokens

        nft.mint{value: 0.1 ether}(1000);
        assertEq(nft.totalSupply(), 1001);

        nft.mint{value: 0.1 ether}(1000);
        assertEq(nft.totalSupply(), 2001);

        vm.deal(user1, 10 ether);

        nft.mint{value: 1 ether}(10_000);

        assertEq(nft.totalSupply(), 12_001);

    }


}
