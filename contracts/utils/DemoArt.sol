// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/console.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "./Processing.sol";

contract DemoArt is Processing {
    Processing.Color c;

    constructor() {}

    function setup() public override {
        Processing p = Processing(address(this));

        uint width = 1024;
        uint height = 1024;

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
    }
}
