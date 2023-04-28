// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "contracts/utils/Processing.sol";

contract GenArtTest is Test {
    Processing public p;

    function setUp() public {
        p = new Processing(1024, 1024);
    }

    function testDraw() public {
        p.background(0xffff00ff);

        p.drawLine(0, 0, 1024, 1024, 0xff00aaff);
        p.drawLine(1024, 0, 0, 1024, 0xff00bbff);

        p.drawRectangle(25, 25, 50, 50, 0xfe00bbff);

        p.stroke(0xff00bbff, 5);

        p.beginShape();
        p.vertex(120, 80);
        p.vertex(230, 80);
        p.vertex(230, 190);
        p.vertex(340, 190);
        p.vertex(340, 300);
        p.vertex(120, 300);
        p.endShape(true);

        p.stroke(0x1f1f1fff, 3);

        p.beginShape();
        p.vertex(520, 80);
        p.vertex(530, 80);
        p.vertex(530, 190);
        p.vertex(540, 190);
        p.vertex(540, 300);
        p.vertex(520, 300);
        p.endShape(true);

        // // draw more random rectangles
        // p.drawRectangle(0, 0, 10, 10, 0xfe00bb00);
        // p.drawRectangle(10, 10, 20, 20, 0xfe00bb00);
        // p.drawRectangle(20, 20, 30, 30, 0xfe00bb00);
        // // with very different colors
        // p.drawRectangle(30, 30, 40, 40, 0xfe00bbff);
        // p.drawRectangle(40, 40, 50, 50, 0xaa00bbff);
        // p.drawRectangle(50, 50, 60, 60, 0x0000bbff);
        // p.drawRectangle(60, 60, 70, 70, 0x00ffbb00);

        // p.drawCircle(50, 50, 25, 0xff00bb00);

        // // (p.printCanvas());

        string memory output = p.renderSVG();

        // save to file

        string[] memory inputs = new string[](4);

        inputs[0] = "echo";
        inputs[1] = p.renderSVG();
        inputs[2] = "|";
        inputs[3] = "pbcopy";

        // bytes memory res = vm.ffi(inputs);

        // console.log("stript result:\n", string(res), "\n");

        console.log("result:\n\n\n", output, "\n\n");
    }
}
