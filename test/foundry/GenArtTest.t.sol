// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "contracts/utils/Processing.sol";
import "contracts/utils/DemoArt.sol";

import "contracts/utils/StringConcat.sol";

// import "contracts/utils/DemoArtJCode.sol";

contract GenArtTest is Test {
    Processing public p;
    Processing.Color c;

    function setUp() public {
        // p = new Processing();
        // p.createCanvas(1024, 1024);
    }

    function OFFtestArtRender() public {
        DemoArt art = new DemoArt();

        art.setup();

        string memory output = art.renderSVG();

        console.log(output);
    }

    // function OFFtestArtJcode() public {
    //     DemoArtJCode art = new DemoArtJCode();

    //     art.setup();

    //     string memory output = art.renderSVG();

    //     console.log(output);
    // }

    // function OFFtestArtJcodeGasReport() public {
    //     uint256 gasBefore = gasleft();

    //     DemoArtJCode art = new DemoArtJCode();

    //     art.setup();

    //     console.log("Gas report:");
    //     console.log("  - setup: ", gasBefore - gasleft());

    //     string memory output = art.renderSVG();

    //     console.log("  - renderSVG: ", gasBefore - gasleft());
    // }

    function OFFtestDraw() public {
        uint width = 1024;
        uint height = 1024;

        p = new Processing();
        p.createCanvas(1024, 1024);

        p.background(p.color(0, 0, 0, 100));

        p.strokeWeight(3);

        p.randomSeed(uint256(blockhash(block.number - 1)));

        uint seed = p.rand(0, 10000);
        p.noiseSeed(seed);

        uint step = 20;
        uint noiseStep = 3; // of 100

        // Vertical lines
        for (uint x = step; x < width; x += step) {
            c = p.color(p.rand(0, 360), 78, 54, 100);

            uint y1 = p.rand(0, (height + step));
            uint y2 = height;

            uint x1 = x + ((p.rand(0, step)) / 2) - (step / 4);
            uint x2 = x + ((p.rand(0, step)) / 2) - (step / 4);

            x1 +=
                (p.noise((x1 * noiseStep) / 100, (0 * noiseStep) / 100) * 20) /
                type(uint8).max;
            x2 +=
                (p.noise((x2 * noiseStep) / 100, (0 * noiseStep) / 100) * 20) /
                type(uint8).max;

            p.stroke(c);
            p.line(x1, y1, x2, y2);
        }

        // Horizontal lines
        for (uint y = step; y < height; y += step) {
            c = p.color(p.rand(0, 360), 78, 54, 100);

            uint x1 = p.rand(0, width + step);
            uint x2 = width;
            uint y1 = y + ((p.rand(0, step)) / 2) - (step / 4);
            uint y2 = y + ((p.rand(0, step)) / 2) - (step / 4);

            y1 +=
                (p.noise((0 * noiseStep) / 100, (y1 * noiseStep) / 100) * 20) /
                type(uint8).max;
            y2 +=
                (p.noise((0 * noiseStep) / 100, (y2 * noiseStep) / 100) * 20) /
                type(uint8).max;

            p.stroke(c);
            p.line(x1, y1, x2, y2);
        }

        // // (p.printCanvas());

        string memory output = p.renderSVG();

        // save to file

        string[] memory inputs = new string[](4);

        inputs[0] = "echo";
        inputs[1] = '"hello"'; // p.renderSVG();
        inputs[2] = ">";
        inputs[3] = "./tmp/canvas.svg";

        console.log("result:\n\n\n", output, "\n\n");

        bytes memory res = vm.ffi(inputs);
        console.log("stript result:\n", string(res), "\n");
    }

    function OFFtestPrint() public {
        // save to file

        string[] memory inputs = new string[](4);

        // sh -c 'echo "hello" > ./tmp/canvas.svg'
        inputs[0] = 'sh -c "';
        inputs[1] = "echo 'hello'"; // p.renderSVG();
        inputs[2] = "> ./tmp/canvas.svg";
        inputs[3] = '"';

        console.log(
            "script inputs:\n",
            StringConcat.concatStringsNaive(inputs),
            "\n"
        );

        bytes memory res = vm.ffi(inputs);

        console.log("stript result:\n", string(res), "\n");
    }

    function testStringConcat() public {
        string[] memory arr = new string[](239);

        // fill array with random strings 50-100 chars long

        for (uint i = 0; i < arr.length; i++) {
            arr[i] = randomString(uint8(i));
        }

        // concat strings three different ways, measure gas and compare

        uint256 gasBefore;

        gasBefore = gasleft();

        console.log("[concatStringsNaive]:");

        string memory res1 = StringConcat.concatStringsNaive(arr);

        console.log("  - gas: ", gasBefore - gasleft());
        console.log("  - res.length: ", bytes(res1).length);

        // 2. using string raw buffer copy bytes

        gasBefore = gasleft();

        console.log("[concatStrings]:");
        string memory res2 = StringConcat.concatStrings(arr);

        console.log("  - gas: ", gasBefore - gasleft());
        console.log("  - res.length: ", bytes(res2).length);

        // 3. using string concatenation in batches

        gasBefore = gasleft();

        console.log("[concatStringsBatch]:");

        string memory res3 = StringConcat.concatStringsBatch(arr);

        console.log("  - gas: ", gasBefore - gasleft());
        console.log("  - res.length: ", bytes(res3).length);

        // 4. using string concatenation with bytes in batches

        gasBefore = gasleft();

        console.log("[concatStringsBatchBytes]:");

        string memory res4 = StringConcat.concatStringsBatchBytes(arr);

        console.log("  - gas: ", gasBefore - gasleft());
        console.log("  - res.length: ", bytes(res4).length);

        // print results

        // console.log("\n\nres1:\n", res1);
        // console.log("\n\nres2:\n", res2);
        // console.log("\n\nres3:\n", res3);
        // console.log("\n\nres4:\n", res4);

        // print input array

        // console.log("\n\narr1: ", arr[0]);
        // console.log("\n\narr2: ", arr[1]);
        // console.log("\n\narr3: ", arr[2]);
        // console.log("\n\narr4: ", arr[3]);

        // compare all four resulting strings are the same

        assertTrue(checkStringsEqual(res1, res2, 0));
        console.log("res1 == res2: true");

        assertTrue(checkStringsEqual(res1, res3, 0));
        console.log("res1 == res3: true");

        assertTrue(checkStringsEqual(res1, res4, 0));
        console.log("res1 == res4: true");

        assertTrue(checkStringsEqual(res2, res3, 0));
        console.log("res2 == res3: true");

        assertTrue(checkStringsEqual(res2, res4, 0));
        console.log("res2 == res4: true");

        // compare with input array

        assertTrue(checkStringsEqual(res1, arr[0], bytes(arr[0]).length));
        console.log("res1 == arr[0]: true");
    }

    function randomString(uint8 offset) public view returns (string memory) {
        // convert blockhash to string

        // bytes32 hash = blockhash(block.number - 1 - offset);
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, offset));

        return
            string.concat(
                "<div>",
                Strings.toHexString(uint256(hash)),
                "</div>\n"
            );
        // return bytes32ToHexString(hash);
    }

    function checkStringsEqual(
        string memory a,
        string memory b,
        uint limit
    ) public view returns (bool) {
        console.log(
            "check strings equal: ",
            bytes(a).length,
            bytes(b).length,
            limit
        );

        if (limit == 0) {
            if (bytes(a).length != bytes(b).length) {
                console.log("lengths not equal");
                return false;
            }

            limit = bytes(a).length;
        }

        for (uint i = 0; i < limit; i++) {
            if (bytes(a)[i] != bytes(b)[i]) {
                console.log("bytes not equal at index: ", i);
                return false;
            }
        }

        return true;
    }
}
