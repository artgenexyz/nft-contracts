// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "contracts/extensions/DutchAuctionExtension.sol";
import "contracts/extensions/DutchAuctionExtensionSingleton.sol";
import "contracts/extensions/DutchAuction.sol";

import "contracts/standards/ERC721CommunityBase.sol";

contract DutchAuctionTest is Test {
    DutchAuctionExtensionSingleton dutchAuctionExtensionSingleton;
    DutchAuctionExtension dutchAuctionExtension;

    DutchAuction dutchAuction;

    DutchAuctionFactory dutchAuctionFactory;

    IERC721Community nft;

    address admin;

    uint amount = 1;

    function setUp() public {
        admin = makeAddr("Admin");
        vm.deal(admin, 100 ether);
        vm.startPrank(admin);

        nft = new ERC721CommunityBase(
            "Test",
            "NFT",
            10000,
            15, // reserved
            false,
            "ipfs://factory-test/",
            MintConfig(0.03 ether, 20, 20, 500, msg.sender, false, false, false)
        );

        dutchAuctionFactory = new DutchAuctionFactory();

        dutchAuctionExtensionSingleton = new DutchAuctionExtensionSingleton();
    }

    function OFFtestSingleton() public {
        amount = 1; // bound(amount, 1, 100);

        nft.addExtension(address(dutchAuctionExtensionSingleton));

        dutchAuctionExtensionSingleton.startSale(nft);
        dutchAuctionExtensionSingleton.updatePrice(nft, 100);
        dutchAuctionExtensionSingleton.updateMaxPerAddress(nft, 200);
        dutchAuctionExtensionSingleton.updateEndTimestamp(
            nft,
            block.timestamp + 1000
        );

        assertEq(dutchAuctionExtensionSingleton.startingPrice(nft), 100);
        assertEq(dutchAuctionExtensionSingleton.maxPerAddress(nft), 200);
        assertEq(
            dutchAuctionExtensionSingleton.endTimestamp(nft),
            block.timestamp + 1000
        );
        assertTrue(dutchAuctionExtensionSingleton.saleStarted(nft));

        // test mint gas cost
        uint256 gasCost = gasleft();

        dutchAuctionExtensionSingleton.mint{value: 100 * amount}(nft, amount);

        gasCost = gasCost - gasleft();

        console.log("Gas cost per mint singleton: ", gasCost / amount);
    }

    function OFFtestExtension() public {
        amount = 1; // bound(amount, 1, 100);

        dutchAuctionExtension = new DutchAuctionExtension(
            (address(nft)),
            100,
            10_000_000_000
        );

        nft.addExtension(address(dutchAuctionExtension));
        dutchAuctionExtension.startSale();

        dutchAuctionExtension.updatePrice(100);
        dutchAuctionExtension.updateMaxPerAddress(200);
        dutchAuctionExtension.updateEndTimestamp(block.timestamp + 1000);

        assertEq(dutchAuctionExtension.startingPrice(), 100);
        assertEq(dutchAuctionExtension.maxPerAddress(), 200);
        assertEq(dutchAuctionExtension.endTimestamp(), block.timestamp + 1000);
        assertTrue(dutchAuctionExtension.saleStarted());

        // test mint gas cost

        uint256 gasCost = gasleft();

        dutchAuctionExtension.mint{value: 100 * amount}(amount);

        gasCost = gasCost - gasleft();

        console.log("Gas cost per mint extension: ", gasCost / amount);
    }

    function OFFtestCrosscompare(uint amount) public {
        amount = bound(amount, 5, 100);

        dutchAuctionExtensionSingleton = new DutchAuctionExtensionSingleton();

        nft.addExtension(address(dutchAuctionExtensionSingleton));

        dutchAuctionExtensionSingleton.startSale(nft);
        dutchAuctionExtensionSingleton.updatePrice(nft, 100);
        dutchAuctionExtensionSingleton.updateMaxPerAddress(nft, 200);
        dutchAuctionExtensionSingleton.updateEndTimestamp(
            nft,
            block.timestamp + 1000
        );

        assertEq(dutchAuctionExtensionSingleton.startingPrice(nft), 100);
        assertEq(dutchAuctionExtensionSingleton.maxPerAddress(nft), 200);
        assertEq(
            dutchAuctionExtensionSingleton.endTimestamp(nft),
            block.timestamp + 1000
        );
        assertTrue(dutchAuctionExtensionSingleton.saleStarted(nft));

        // test mint gas cost
        uint256 gasCost = gasleft();

        dutchAuctionExtensionSingleton.mint{value: 100 * amount}(nft, amount);

        gasCost = gasCost - gasleft();

        console.log("Gas cost per mint singleton: ", gasCost / amount);

        dutchAuctionExtension = new DutchAuctionExtension(
            (address(nft)),
            100,
            10_000_000_000
        );

        nft.addExtension(address(dutchAuctionExtension));
        dutchAuctionExtension.startSale();

        dutchAuctionExtension.updatePrice(100);
        dutchAuctionExtension.updateMaxPerAddress(200);
        dutchAuctionExtension.updateEndTimestamp(block.timestamp + 1000);

        assertEq(dutchAuctionExtension.startingPrice(), 100);
        assertEq(dutchAuctionExtension.maxPerAddress(), 200);
        assertEq(dutchAuctionExtension.endTimestamp(), block.timestamp + 1000);
        assertTrue(dutchAuctionExtension.saleStarted());

        // test mint gas cost

        gasCost = gasleft();

        dutchAuctionExtension.mint{value: 100 * amount}(amount);

        gasCost = gasCost - gasleft();

        console.log("Gas cost per mint extension: ", gasCost / amount);

        assertTrue(false);
    }

    function testDeployExtension() public {

        DutchAuction implementation = new DutchAuction();

        // we already have nft configured, we need to deploy the extension and add it to the nft

        uint gasCost = gasleft();

        // dutchAuction = dutchAuctionFactory.createExtension(
        //     address(nft),
        //     100,
        //     10,
        //     block.timestamp,
        //     block.timestamp + 1000
        // );

        // nft.addExtension(address(dutchAuction));

        address ext = ERC721CommunityBase(payable(address(nft))).deployExtension(
            address(implementation),
            abi.encodeWithSelector(
                DutchAuction.initialize.selector,
                address(nft),
                100,
                10,
                block.timestamp,
                block.timestamp + 1000,
                admin
            )
        );

        // console.log("Deploy result: ", string(result));

        gasCost = gasCost - gasleft();

        console.log("Gas cost to deploy extension: ", gasCost);

        // test mint

        gasCost = gasleft();

        DutchAuction(ext).mint{value: 100 * amount}(amount);

        gasCost = gasCost - gasleft();

        console.log("Gas cost to mint via extension: ", gasCost / amount);
    }

    function testConfigSingleton() public {
        // we already have nft configured, we need to deploy the extension and add it to the nft

        uint gasCost = gasleft();

        dutchAuctionExtensionSingleton.configureSale(
            (nft),
            100,
            10,
            10_000_000_000,
            true
        );

        nft.addExtension(address(dutchAuctionExtensionSingleton));

        gasCost = gasCost - gasleft();

        console.log("Gas cost to configure singleton: ", gasCost);

        // test mint

        gasCost = gasleft();

        dutchAuctionExtensionSingleton.mint{value: 100 * amount}(nft, amount);

        gasCost = gasCost - gasleft();

        console.log("Gas cost to mint via singleton: ", gasCost / amount);
    }
}
