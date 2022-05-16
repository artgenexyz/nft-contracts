// REFERENCE SOLIDITY TEST IMPLEMENTATION
// ------------------------------------------
// /// @title MultiRaffleTest
// /// @author Anish Agnihotri
// /// @notice Base test to inherit functionality from. Deploys relevant contracts.
// contract MultiRaffleTest is DSTestExtended {

//     /// ============ Storage ============

//     /// @dev Raffle setup
//     MultiRaffle internal RAFFLE;
//     /// @dev Hevm setup
//     Hevm constant internal HEVM = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
//     /// @dev Raffle user — Alice
//     MultiRaffleUser internal ALICE;
//     /// @dev Raffle user — Bob
//     MultiRaffleUser internal BOB;

//     /// ============ Tests setup ============

//     function setUp() public virtual {
//         // Start at timestamp 0
//         HEVM.warp(0);

//         // Setup raffle
//         RAFFLE = new MultiRaffle(
//             "Test NFT Project", // Name
//             "TNFT", // Symbol
//             0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445, // Chainlink key hash
//             0x514910771AF9Ca656af840dff83E8264EcF986CA, // LINK token
//             0xf0d54349aDdcf704F77AE15b96510dEA15cb7952, // Coordinator address
//             1e17, // 0.1 eth per NFT
//             10, // 10 second start time
//             1000, // 1000 second end time
//             10, // 10 available NFTs
//             6 // 6 max raffle entries per address
//         );

//         // Setup raffle users
//         ALICE = new MultiRaffleUser(RAFFLE);
//         BOB = new MultiRaffleUser(RAFFLE);
//     }

//     /// @notice Allows receiving ETH
//     receive() external payable { }

//     /// ============ Helper functions ============

//     /// @notice Sets time to before raffle starts
//     function setTimePreRaffleStart() public {
//         HEVM.warp(0);
//     }

//     /// @notice Sets time to during the raffle
//     function setTimeDuringRaffle() public {
//         HEVM.warp(50);
//     }

//     /// @notice Sets time to after raffle conclusion
//     function setTimePostRaffle() public {
//         HEVM.warp(1050);
//     }

//     /// @notice Enters Alice + Bob with max. 6 tickets each
//     /// @param numAliceTickets to purchase
//     /// @param numBobTickets to purchase
//     function standardEnterRaffle(
//         uint256 numAliceTickets,
//         uint256 numBobTickets
//     ) public {
//         setTimeDuringRaffle();
//         ALICE.enterRaffle{ value: 1e17 * numAliceTickets } (numAliceTickets);
//         BOB.enterRaffle{ value: 1e17 * numBobTickets } (numBobTickets);
//         setTimePostRaffle();
//     }

//     function standardClearRaffle() public {
//         ALICE.devSetRandomness(123);
//         ALICE.clearRaffle(10);
//     }

//     /// @notice Enters Alice + Bob into raffle and shuffles
//     function standardFullEnterAndClear() public {
//         standardEnterRaffle(6, 6);
//         standardClearRaffle();
//     }

import { ethers, network } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

import { MultiRaffleExtension, MetaverseBaseNFT, MultiRaffleExtension__factory, MetaverseBaseNFT__factory } from '../../typechain-types'

const { parseEther } = ethers.utils;


const chainlinkParamsMainnet = [
    // bytes32 _LINK_KEY_HASH,
    // address _LINK_ADDRESS,
    // address _LINK_VRF_COORDINATOR_ADDRESS,
    "0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445",
    "0x514910771AF9Ca656af840dff83E8264EcF986CA",
    "0xf0d54349aDdcf704F77AE15b96510dEA15cb7952",
]

const chainlinkParamsRinkeby = [
    // bytes32 _LINK_KEY_HASH,
    // address _LINK_ADDRESS,
    // address _LINK_VRF_COORDINATOR_ADDRESS,
    // LINK Token	0x01BE23585060835E02B77ef475b0Cc51aA1e0709
    // VRF Coordinator	0x6168499c0cFfCaCD319c818142124B7A15E857ab
    // 30 gwei Key Hash	0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc

    "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    "0x01BE23585060835E02B77ef475b0Cc51aA1e0709",
    "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
]

const chainlinkParams = chainlinkParamsRinkeby

const currentTimestamp = () => {
    return Math.floor(Date.now() / 1000);
}

describe("MultiRaffleExtension", function () {

    let factories: {
        MetaverseBaseNFT: MetaverseBaseNFT__factory;
        MultiRaffleExtension: MultiRaffleExtension__factory;
    };

    let raffle: MultiRaffleExtension;
    let nft: MetaverseBaseNFT;
    let link: Contract;

    beforeEach(async function () {
        const MetaverseNFT = await ethers.getContractFactory("MetaverseBaseNFT")
        const Raffle = await ethers.getContractFactory("MultiRaffleExtension")

        factories = {
            MetaverseBaseNFT: MetaverseNFT,
            MultiRaffleExtension: Raffle,
        };

        nft = await MetaverseNFT.deploy(
            parseEther("0.1"),
            10, // max supply
            2, // reserved
            10, // max per tx
            0, // royalty
            "ipfs://QmMetadataHash/", "NFT", "NFT",
            false,
        );

        const ERC20 = await ethers.getContractFactory("MockERC20CurrencyToken");

        link = ERC20.attach("0x01BE23585060835E02B77ef475b0Cc51aA1e0709");

    });

    it("should deploy successfully", async function () {
        const [owner] = await ethers.getSigners();

        const raffleExtension = await factories.MultiRaffleExtension.deploy(
            nft.address, // nft address
            chainlinkParams[0],
            chainlinkParams[1],
            chainlinkParams[2],
            parseEther("0.1"),
            10,
            1000,
            10,
            6
        );

        expect(await raffleExtension.nft()).to.equal(nft.address);
    });

    // it should deploy and add extension to MetaverseBaseNFT
    it("should deploy and add extension to MetaverseBaseNFT", async function () {
        const [owner] = await ethers.getSigners();

        expect(nft.address).to.not.be.empty;

        raffle = await factories.MultiRaffleExtension.deploy(
            nft.address,
            chainlinkParams[0],
            chainlinkParams[1],
            chainlinkParams[2],
            parseEther("0.1"),
            currentTimestamp() - 100,
            currentTimestamp() + 60, // 1 minute raffle
            10, // max raffle entries
            6
        );

        await nft.addExtension(raffle.address);

        const nftExtension = await nft.extensions(0);
        expect(nftExtension).to.equal(raffle.address);

    });

    // it should be possible to mint via extension
    it("should be possible to mint via extension", async function () {
        const [ owner, alice, bob ] = await ethers.getSigners();

        raffle = await factories.MultiRaffleExtension.deploy(
            nft.address,
            chainlinkParams[0],
            chainlinkParams[1],
            chainlinkParams[2],
            parseEther("0.1"),
            currentTimestamp() - 100,
            currentTimestamp() + 60, // 1 minute raffle
            10, // available supply
            5,
        );

        await nft.addExtension(raffle.address);

        // only 2 + 3 entries, while max raffle entries is 10
        await raffle.connect(alice).enterRaffle(2, { value: parseEther("0.2") });
        await raffle.connect(bob).enterRaffle(3, { value: parseEther("0.3") });
        await network.provider.send("evm_mine")

        // TODO: scroll blocktime 30 seconds forward
        await network.provider.send("evm_increaseTime", [200])
        await network.provider.send("evm_mine")

        await raffle.connect(alice).claimRaffle([0,1]);
        await raffle.connect(bob).claimRaffle([2,3,4]);

        const aliceBalance = await nft.balanceOf(alice.address);
        const bobBalance = await nft.balanceOf(bob.address);

        expect(aliceBalance).to.equal(2);
        expect(bobBalance).to.equal(3);


    });

    // it should not mint more than AVAILABLE SUPPLY if number of entries is more than AVAILABLE SUPPLY
    it("should not mint more than AVAILABLE SUPPLY if number of entries is more than AVAILABLE SUPPLY", async function () {
        const [ owner, alice, bob ] = await ethers.getSigners();

        raffle = await factories.MultiRaffleExtension.deploy(
            nft.address,
            chainlinkParams[0],
            chainlinkParams[1],
            chainlinkParams[2],
            parseEther("0.1"),
            currentTimestamp() - 100,
            currentTimestamp() + 200, // 1 minute raffle
            10, // available supply
            10,
        );

        await nft.addExtension(raffle.address);

        // make 7 + 5 entries, while max raffle entries is 10
        await raffle.connect(alice).enterRaffle(7, { value: parseEther("0.7") });
        await raffle.connect(bob).enterRaffle(5, { value: parseEther("0.5") });

        await network.provider.send("evm_mine")

        // TODO: scroll blocktime 30 seconds forward
        await network.provider.send("evm_increaseTime", [400])
        await network.provider.send("evm_mine")

        await link.connect(owner).transfer(raffle.address, parseEther("2.5")); // 0.25 LINK per randomness

        expect(await link.balanceOf(raffle.address)).to.be.above(parseEther("0"));
        expect(await link.balanceOf(owner.address)).to.be.below(parseEther("10"));

        const _tx = await raffle.setClearingEntropy();

        const tx = await _tx.wait();

        // extract logs from tx, event RandomWordsRequested.requestId
        const logs = tx.logs;
        expect(logs.length).to.equal(1);

        console.log('logs', logs);

        const randomWordsRequested = logs[0];
        expect(randomWordsRequested.topics[0]).to.not.be.empty;

        const reqId = randomWordsRequested.topics[0];

        console.log('calling setClearing', reqId);

        const VRF_COORDINATOR_ADDRESS = chainlinkParams[2];

        console.log('calling impersonate', VRF_COORDINATOR_ADDRESS);
        await network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [VRF_COORDINATOR_ADDRESS],
        });

        // delay 3 seconds
        await network.provider.send("evm_increaseTime", [3000])
        await network.provider.send("evm_mine")

        // top up eth balance for VRF_COORDINATOR_ADDRESS
        await owner.sendTransaction({
            to: VRF_COORDINATOR_ADDRESS,
            value: parseEther("0.1"),
        });

        const signer = await ethers.getSigner(VRF_COORDINATOR_ADDRESS);

        await raffle.connect(signer).rawFulfillRandomWords(reqId, [12312312312312]);

        console.log('calling clearRaffle');
        await raffle.clearRaffle(7);

        console.log('calling claimRaffle');
        await raffle.connect(alice).claimRaffle([0,1,2,3,4,5,6]);
        await raffle.connect(bob).claimRaffle([7,8,9,10,11]);

        const aliceBalance = await nft.balanceOf(alice.address);
        const bobBalance = await nft.balanceOf(bob.address);

        expect(Number(aliceBalance) + Number(bobBalance)).to.equal(10);

    });

});
