// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "contracts/utils/MultiTransfer.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "./constants.sol";

// take hardcoded list of addresses
// and amounts
// send ether

// test everyone received ether

address constant MULTISEND_EM = 0xCD5485b34c9902527bbEE21F69312fe2A73bc802;

contract MultiTransferTest is Test {
    MultiTransfer multiTransfer;

    function setUp() public {
        multiTransfer = MultiTransfer(MULTISEND_EM);

        // test if it's deployed

        if (address(multiTransfer).code.length == 0) {
            revert("MultiTransferTest: not deployed");
        }
    }

    uint256 constant ARRAY_SIZE = 90;

    function testMultiTransfer() public {
        address[ARRAY_SIZE] memory RECIPIENTS = [
            0xBfE8Fb6e66513784e6e05fe4a8048DA4A0DCECB6,
            0xBfE8Fb6e66513784e6e05fe4a8048DA4A0DCECB6,
            0x2Ca5D416d1fd797B598D0300Ad8fFf4aE32BaA4C,
            0x7e7761C14f70A98Ad81e20B5Bd08688e32c7eAE5,
            0xF7e59A0F64cEE03ECE4C10F87016a51c5ac729ce,
            0xfAD41D46D96C31a539E6af9c7f8dD58fE6353153,
            0xcA6894423940aB96828C50CC97a9F24b5E7c8016,
            0xD5a7dc388a1dF96197E77d3F48cE881417B40997,
            0x0A49fbe88cFC413181dbE93c9e3B6184b2264071,
            0xfAD41D46D96C31a539E6af9c7f8dD58fE6353153,
            0xfAD41D46D96C31a539E6af9c7f8dD58fE6353153,
            0x3E199580A778c0C507904Fb2f46Ca727103F4ed3,
            0x8a0Dff41336F5a46517899a89D748cC172d31bE8,
            0x713EeA22eBfFc56fe130E2768909A1BEa7D75Da0,
            0xD45022572f4337A69fA371ab1Fd86214574D1097,
            0xD45022572f4337A69fA371ab1Fd86214574D1097,
            0x488D71Da13a7Bd72D4c56C31AFE727a94CE7866A,
            0x35Bd369fE668588Bd299b6d8068C41Bfce0C17dF,
            0x1eDc0b7073CF1a8Cfa70dB39daBbdF16673d1DA2,
            0x1eDc0b7073CF1a8Cfa70dB39daBbdF16673d1DA2,
            0x3ABA7f1A35EEd304C53afa44912c3AF06b01092e,
            0x3ABA7f1A35EEd304C53afa44912c3AF06b01092e,
            0x3E199580A778c0C507904Fb2f46Ca727103F4ed3,
            0xf9414b5ABE4F56b9B548a824945ecF1AA1D7acE4,
            0x0283FD9d9947F29f1668d0380C5aBC16A54d59Ac,
            0x637399a7EDb88803da910c31ab20a5fdd5A7f564,
            0xf9414b5ABE4F56b9B548a824945ecF1AA1D7acE4,
            0x0A49fbe88cFC413181dbE93c9e3B6184b2264071,
            0x26A25F95f321D0dC2988651913b607B9017fe4a3,
            0x2C1B72a988915642C020929F41A2cdD2Cb97Fb03,
            0x69C89ecC6C77eAe6766125bc6C80E0aC0041E055,
            0x7Ea3D40d92c933bf4503435AAf65d2706D566393,
            0x7FA67e8c6d1569e086a5763947160eBB0097D30D,
            0x4DA73F16eA68796CF8cd5dD26F90B090280f4517,
            0x7Ea3D40d92c933bf4503435AAf65d2706D566393,
            0x5Ea4533B5456C55953EAAbC03dFAAfd5284aF71C,
            0x7Ea3D40d92c933bf4503435AAf65d2706D566393,
            0xCD42401677bB6ED0c2Ac17d63A2823D6E299b3BA,
            0x7Ea3D40d92c933bf4503435AAf65d2706D566393,
            0x137331ed7e7C9fffFb24f738C6D0Fb52BEdD97F9,
            0xD198469304F741672b0ce156Bb9757404BaFD669,
            0x137331ed7e7C9fffFb24f738C6D0Fb52BEdD97F9,
            0xF1D052871519f4f62733c0Ef0089061984765F76,
            0x7f68a6610ce77E77d843EF6EF9EDD63ABf12AE40,
            0x44b402c5CD93962AE3d58F9d82EA84220A255180,
            0xF1D052871519f4f62733c0Ef0089061984765F76,
            0x7ad9d8711788ef3bCAba5348C5BA3C8d58b58ca8,
            0x7Ec9467a62372f90C95Ef0dB704bD0CD075B2393,
            0xE1DB56fF537ED65f859c5d550b4DbDE1d7543D7e,
            0x7Ec9467a62372f90C95Ef0dB704bD0CD075B2393,
            0x7Ec9467a62372f90C95Ef0dB704bD0CD075B2393,
            0x7Ec9467a62372f90C95Ef0dB704bD0CD075B2393,
            0x59d898caA9cD3318e887B5CE472EcC51a9631Dd8,
            0x59d898caA9cD3318e887B5CE472EcC51a9631Dd8,
            0x7f68a6610ce77E77d843EF6EF9EDD63ABf12AE40,
            0x4B30697B4Eba165510f98f18B11dd205530afAD0,
            0xF1D052871519f4f62733c0Ef0089061984765F76,
            0x4B30697B4Eba165510f98f18B11dd205530afAD0,
            0x7Ec9467a62372f90C95Ef0dB704bD0CD075B2393,
            0x6B45279B8a5B2Cfe3311f60E3caF0E74BE30FCc2,
            0x8599BdA60364a61c5775B0EB230B24B37ff2F187,
            0x30439021Ed5B3BB247bF0FDbb92F18010930ee7c,
            0x428BA87Cc89d457eA0754B7FA8bf39cFb53eD63a,
            0x8bb9B5d417a7fFF837c501Ff87491047E1598104,
            0x2c5B3EEfdBc52871028cCB36a6b0af35664A0dED,
            0x7Ec9467a62372f90C95Ef0dB704bD0CD075B2393,
            0xa8247ddbDCbc3277DA28E7feFcAa147Da0D66242,
            0x7Ea3D40d92c933bf4503435AAf65d2706D566393,
            0x431973B9593a6F273512008670979d32cE4f756D,
            0xa91EEe49d2Fea98f0C8F364e416ba66345579f0f,
            0xa91EEe49d2Fea98f0C8F364e416ba66345579f0f,
            0x7E8B539955aBE7DF695E875A38584A2251dde463,
            0x29bD2D1BC9382aB20ee799B6a8beaF9dE1a8E929,
            0xa91EEe49d2Fea98f0C8F364e416ba66345579f0f,
            0x7E8B539955aBE7DF695E875A38584A2251dde463,
            0x14745892448fE4eA70804ffD8466286C5998eAC9,
            0x7Ea3D40d92c933bf4503435AAf65d2706D566393,
            0xa671f9e3f71dC217B2F3220B7a92CC89ff004510,
            0x3D79727cf5d4A935C589DbE2ddB4613fF975794b,
            0x653d8554B690d54EA447aD82C933A6851CC35BF2,
            0x5D3c2427f5CadD42D734990b5898a8E8b17bF1f1,
            0x5D3c2427f5CadD42D734990b5898a8E8b17bF1f1,
            0xa35010a4055e9daB4a7308D7f83307771D57fc7f,
            0x653d8554B690d54EA447aD82C933A6851CC35BF2,
            0xf5c566a9c5801FD12294e405550FD9c38afBd4b9,
            0xb38810977193852E17A278D00e322da567594320,
            0x11C7d5699ecA3cE65264903606a37700aEaf92Da,
            0x2f49954c093e36325Af639838b9A6824B988b824,
            0xF7b51a6C7982385B116119Ef9187253Cc8C8e2A9,
            0x9F4732c9e545454896De9c81f9f3B0E8938D735c
        ];

        uint56[ARRAY_SIZE] memory AMOUNTS = [
            6324925636235460,
            6268278385058720,
            6520350808200550,
            7762536874322450,
            6918868255126070,
            6837566524992070,
            7012832993338970,
            1253503461496100,
            6739231926837590,
            6412412458594710,
            6809610703408170,
            6934513072255630,
            1742170487070110,
            6487941717154940,
            5721849972013190,
            5462524283888940,
            1433305823177110,
            1756119368672060,
            5475449153989600,
            5611850985434430,
            5774810587902990,
            6021591939649140,
            5990770848477230,
            5336355773254890,
            5442967177605390,
            5619914131425690,
            5448250953941220,
            5140434065847850,
            5403365687778900,
            2707759503457350,
            5620164237973110,
            5345425405742500,
            4849501138996910,
            2565556921140480,
            7506003075612000,
            6599044009913480,
            7487397737897500,
            6469313552516680,
            6920196404531520,
            7147839157952240,
            7291262127283140,
            7044861270171380,
            6586785024355030,
            6717704064843490,
            6716046122990460,
            7790658777621700,
            7445414189706460,
            7263796465260900,
            7245357958115470,
            6911312993325940,
            8259276133181730,
            7625573578586650,
            7161431993842180,
            6858099141321310,
            6398850155479550,
            6410212944287940,
            6132220562705930,
            6441459483542140,
            6236520404253620,
            6351872593967940,
            5962018146784080,
            6300129892454470,
            6033283221903070,
            6033283221903070,
            6567185988538450,
            6235472243373100,
            6281388087862910,
            6315438499912160,
            6403635542787590,
            6413343753082860,
            6053691223687670,
            6194362486539280,
            6194322626802810,
            5951836531765830,
            6094045967473960,
            6564398368981650,
            7525600764774120,
            5948428466462410,
            6360452650525960,
            6364939783705110,
            7069785843212110,
            6776034811809450,
            7662162864521230,
            7104154389986140,
            6472413790634720,
            5573458000000000,
            5905491386354310,
            5257930166755300,
            5036848486293360,
            5313573587510740
        ];

        // Convert constant arrays to memory

        address payable[]
            memory _recipients = convertConstantAddressArrayToMemory(
                RECIPIENTS
            );

        uint256[] memory _amounts = convertConstantUint256ArrayToMemory(
            AMOUNTS
        );

        uint256[] memory oldBalances = new uint256[](ARRAY_SIZE);

        for (uint256 i = 0; i < ARRAY_SIZE; i++) {
            oldBalances[i] = _recipients[i].balance;
        }

        (_recipients, _amounts) = findUniqueAddressSumAmounts(
            _recipients,
            _amounts
        );

        // print addresses as one big string, and amounts as one big string

        string memory addressesString = convertAddressArrayToString(
            _recipients
        );

        string memory amountsString = convertUint256ArrayToString(_amounts);

        console.log("recipients:\n", addressesString);
        console.log("amounts", amountsString);

        vm.deal(address(this), 1 ether);

        // measure gas

        uint256 gasBefore = gasleft();

        multiTransfer.multiTransfer_OST{value: 1 ether}(_recipients, _amounts);

        uint256 gasAfter = gasleft();

        console.log("gas used", gasBefore - gasAfter);

        console.log(
            "gas used per recipient",
            (gasBefore - gasAfter) / ARRAY_SIZE
        );

        // check if balances are correct

        // for (uint256 i = 0; i < ARRAY_SIZE; i++) {
        //     console.log("new balance", _recipients[i].balance);
        //     console.log("old balance", oldBalances[i]);
        //     console.log("amounts", _amounts[i]);

        //     assertEq(oldBalances[i] + _amounts[i], _recipients[i].balance);
        // }
    }

    function findUniqueAddressSumAmounts(
        address payable[] memory recipients,
        uint256[] memory amounts
    )
        private
        view
        returns (
            address payable[] memory _recipients,
            uint256[] memory _amounts
        )
    {
        // find unique addresses

        uint256 uniqueAddresses = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            bool found = false;

            for (uint256 j = 0; j < uniqueAddresses; j++) {
                if (recipients[i] == _recipients[j]) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                uniqueAddresses++;
            }
        }

        // create new arrays

        _recipients = new address payable[](uniqueAddresses);
        _amounts = new uint256[](uniqueAddresses);

        uint256 k = 0;

        // fill new arrays: for each duplicating recipient, sum up his amounts

        for (uint256 i = 0; i < recipients.length; i++) {
            // if recipients[i] already in _recipients, add amounts[i] to _amounts[i]
            // otherwise add recipients[i] to _recipients and amounts[i] to _amounts[i]

            bool found = false;

            for (uint256 j = 0; j < k; j++) {
                if (recipients[i] == _recipients[j]) {
                    _amounts[j] += amounts[i];
                    found = true;
                    break;
                }
            }

            if (!found) {
                _recipients[k] = recipients[i];
                _amounts[k] = amounts[i];

                k++;
            }
        }

        // check that total amounts are the same

        uint256 totalAmount = 0;
        uint256 newTotalAmount = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            totalAmount += amounts[i];
        }

        for (uint256 i = 0; i < _recipients.length; i++) {
            newTotalAmount += _amounts[i];
        }

        assert(totalAmount == newTotalAmount);

        require(totalAmount == newTotalAmount, "totalAmount != newTotalAmount");
    }

    // ===== Helpers ======

    function convertConstantAddressArrayToMemory(
        address[ARRAY_SIZE] memory _recipients
    ) internal pure returns (address payable[] memory recipients) {
        recipients = new address payable[](_recipients.length);

        for (uint256 i = 0; i < _recipients.length; i++) {
            recipients[i] = payable(_recipients[i]);
        }
    }

    function convertConstantUint256ArrayToMemory(
        uint56[ARRAY_SIZE] memory _recipients
    ) internal pure returns (uint256[] memory recipients) {
        recipients = new uint256[](_recipients.length);

        for (uint256 i = 0; i < _recipients.length; i++) {
            recipients[i] = uint256(_recipients[i]);
        }
    }

    // "[" + recipients.map(Strings.toHexString).join(",") + "]"
    function convertAddressArrayToString(
        address payable[] memory _recipients
    ) internal pure returns (string memory) {
        string memory addressesString = "";

        for (uint256 i = 0; i < _recipients.length; i++) {
            addressesString = string.concat(
                addressesString,
                Strings.toHexString(uint160(address(_recipients[i])), 20),
                "," // add comma between addresses
            );
        }

        return string.concat("[", addressesString, "]");
    }

    function convertUint256ArrayToString(
        uint256[] memory _amounts
    ) internal pure returns (string memory) {
        string memory amountsString = "";

        for (uint256 i = 0; i < _amounts.length; i++) {
            amountsString = string.concat(
                amountsString,
                Strings.toString(_amounts[i]),
                "," // add comma between amounts
            );
        }

        return string.concat("[", amountsString, "]");
    }
}
