// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "contracts/ERC721CommunityBase.sol";

contract CounterTest is Test {
    ERC721CommunityBase public nft;

    //   "Test", // name
    //   "NFT", // symbol
    //   10000, // maxSupply
    //   3, // nReserved
    //   false, // startAtOne
    //   "ipfs://factory-test/", // uri
    //   // MintConfig
    //   {
    //     publicPrice: ether.times(0.03).toFixed(),
    //     maxTokensPerMint: 20,
    //     maxTokensPerWallet: 20,
    //     royaltyFee: 500,
    //     payoutReceiver: user1,
    //     shouldLockPayoutReceiver: false,
    //     shouldStartSale: false,
    //     shouldUseJsonExtension: false,
    //   },

    function setUp() public {
        nft = new ERC721CommunityBase(
            "Test",
            "NFT",
            10000,
            3,
            false,
            "ipfs://factory-test/",
            MintConfig(
                0.03 ether,
                20,
                20,
                500,
                msg.sender,
                false,
                false,
                false
            )
        );

    }

    function testIncrement() public {
        nft.startSale();
        assertEq(nft.saleStarted(), true);
    }

    function testSetNumber(uint256 x) public {
        nft.setPrice(x);
        assertEq(nft.price(), x);
    }

    function xtestMint() public {
        nft.startSale();

        // log in as user1
        nft.mint{value: nft.price()}(1);

        assertEq(nft.balanceOf(msg.sender), 1);
    }


}
