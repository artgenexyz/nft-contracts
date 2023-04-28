// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/console.sol";

import "solidity-trigonometry/Trigonometry.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract ProccessingOnchain {
    string public constant GRAYSCALE_PIXELS =
        "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,'^`'";

    uint public canvasWidth;
    uint public canvasHeight;
    uint[][] public canvas;

    string buffer =
        '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">';

    constructor(uint _width, uint _height) {
        canvasWidth = _width;
        canvasHeight = _height;

        canvas = new uint[][](canvasWidth);

        for (uint i = 0; i < canvasWidth; i++) {
            canvas[i] = new uint[](canvasHeight);
        }
    }

    function background(uint color) public {
        for (uint x = 0; x < canvasWidth; x++) {
            for (uint y = 0; y < canvasHeight; y++) {
                canvas[x][y] = color;
            }
        }
    }

    function drawLine(uint x1, uint y1, uint x2, uint y2, uint color) public {
        int deltaX = int(x2) - int(x1);
        int deltaY = int(y2) - int(y1);

        uint distance = sqrt(uint(deltaX * deltaX + deltaY * deltaY));

        if (distance == 0) {
            canvas[x1][y1] = color;
            return;
        }

        // uint xStep = deltaX / distance;
        // uint yStep = deltaY / distance;

        console.log(
            string.concat(
                "x1, y1, x2, y2, deltaX, deltaY, distance, xStep, yStep: ",
                Strings.toString(x1),
                ",",
                Strings.toString(y1),
                ",",
                Strings.toString(x2),
                ",",
                Strings.toString(y2),
                ",",
                deltaX > 0
                    ? Strings.toString(uint(deltaX))
                    : string.concat("-", Strings.toString(uint(-deltaX))),
                ",",
                deltaY > 0
                    ? Strings.toString(uint(deltaY))
                    : string.concat("-", Strings.toString(uint(-deltaY))),
                ",",
                Strings.toString(distance)
            )
        );

        // require(xStep > 0 || yStep > 0, "xStep > 0 || yStep > 0");

        for (uint i = 0; i < distance; i++) {
            if (
                int(x1 * distance) < int(i) * deltaX ||
                int(y1 * distance) < int(i) * deltaY
            ) {
                console.log("Out of bounds, skipping...");
                break;
            }

            uint x = uint(int(x1) + ((int(i) * deltaX) / int(distance)));
            uint y = uint(int(y1) + ((int(i) * deltaY) / int(distance)));

            console.log(
                string.concat(
                    "x, y, i: ",
                    Strings.toString(x),
                    ",",
                    Strings.toString(y),
                    ",",
                    Strings.toString((i))
                )
            );
            // require(x < canvasWidth, "x1 + (i * xStep) < canvasWidth");
            // require(y < canvasHeight, "y1 + (i * yStep) < canvasHeight");

            if (x < canvasWidth && y < canvasHeight) {
                canvas[x][y] = color;
            } else {
                console.log("Out of bounds, ignoring and skipping");
                break;
                // if (x >= canvasWidth) {
                //     require(false, "x1 + (i * xStep) < canvasWidth");
                // } else {
                //     require(false, "y1 + (i * yStep) < canvasHeight");
                // }
            }
        }
    }

    function min(uint a, uint b) public pure returns (uint) {
        return a < b ? a : b;
    }

    function max(uint a, uint b) public pure returns (uint) {
        return a > b ? a : b;
    }

    function drawRectangle(
        uint x,
        uint y,
        uint width,
        uint height,
        uint color
    ) public {
        if (x >= canvasWidth || y >= canvasHeight) {
            console.log("Out of bounds, skipping...");
            return;
        }

        width = min(width, canvasWidth - x);
        height = min(height, canvasHeight - y);

        for (uint i = x; i < x + width; i++) {
            for (uint j = y; j < y + height; j++) {
                canvas[i][j] = color;
            }
        }
    }

    function drawCircle(uint x, uint y, uint radius, uint color) public {
        // require(x + radius <= canvasWidth, "x + radius <= canvasWidth");

        for (uint i = 0; i < canvasWidth; i++) {
            for (uint j = 0; j < canvasHeight; j++) {
                // uint distance = sqrt((i - x) * (i - x) + (j - y) * (j - y));

                // add type casting to int to avoid overflow

                uint distance = sqrt(
                    uint(
                        (int(i) - int(x)) *
                            (int(i) - int(x)) +
                            (int(j) - int(y)) *
                            (int(j) - int(y))
                    )
                );

                if (distance <= radius) {
                    canvas[i][j] = color;
                }
            }
        }
    }

    function printCanvas() public view returns (string memory) {
        for (uint i = 0; i < canvasWidth; i++) {
            string memory row = "";
            for (uint j = 0; j < canvasHeight; j++) {
                // treat color value as rgba, and convert to brightness
                // uint256 brightness = (canvas[i][j] & 0xff) +
                //     ((canvas[i][j] >> 8) & 0xff) +
                //     ((canvas[i][j] >> 16) & 0xff);

                // grayscale = 299 * R + 587 * G + 114 * B // of 1000

                uint grayscale = (299 *
                    (canvas[i][j] & 0xff) +
                    587 *
                    ((canvas[i][j] >> 8) & 0xff) +
                    114 *
                    ((canvas[i][j] >> 16) & 0xff));

                uint charIndex = (grayscale * (69)) / 255 / 1000;

                // console.log("charIndex", Strings.toString(charIndex));

                // string memory char = string.concat(
                //     Strings.toString(canvas[i][j]),
                //     ":"
                // );
                string memory char = string(
                    abi.encodePacked(bytes(GRAYSCALE_PIXELS)[charIndex])
                );

                // uint256 charCode = 0x2800 +
                //     (brightness * 0x28) /
                //     (255 * 3) -
                //     0x2800;
                // uint256 charCode = canvas[i][j] + 0x2800;
                row = string.concat(row, char);
                // result = string(abi.encodePacked(result, canvas[i][j]));
            }
            console.log(row);

            // result = string(abi.encodePacked(result, "\n"));
        }
        // return result;
    }

    function printCanvasSVG() public view returns (string memory svg) {
        string memory result = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="',
                Strings.toString(canvasWidth),
                '" height="',
                Strings.toString(canvasHeight),
                '">'
            )
        );

        for (uint i = 0; i < canvasWidth; i++) {
            for (uint j = 0; j < canvasHeight; j++) {
                string memory color = string(
                    abi.encodePacked(
                        "rgb(",
                        Strings.toString(canvas[i][j] & 0xff),
                        ",",
                        Strings.toString((canvas[i][j] >> 8) & 0xff),
                        ",",
                        Strings.toString((canvas[i][j] >> 16) & 0xff),
                        ")"
                    )
                );
                string memory rect = string(
                    abi.encodePacked(
                        '<rect x="',
                        Strings.toString(i),
                        '" y="',
                        Strings.toString(j),
                        '" width="1" height="1" fill="',
                        color,
                        '" />'
                    )
                );
                result = string(abi.encodePacked(result, rect));
            }
        }

        result = string(abi.encodePacked(result, "</svg>"));

        return result;
    }

    function sqrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
