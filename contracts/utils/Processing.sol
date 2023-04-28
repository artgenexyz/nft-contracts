// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/console.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Processing {
    uint public canvasWidth;
    uint public canvasHeight;

    struct Style {
        uint fill;
        uint stroke;
        uint strokeWidth;
        // Add other relevant style properties here
    }

    Style currentStyle;

    struct Color {
        uint8 r;
        uint8 g;
        uint8 b;
        uint8 a;
    }

    enum ShapeMode {
        POINTS,
        LINES,
        TRIANGLES,
        TRIANGLE_FAN,
        TRIANGLE_STRIP,
        QUADS,
        QUAD_STRIP
    }

    ShapeMode shapeMode;

    string private buffer = "";

    constructor(uint _width, uint _height) {
        canvasWidth = _width;
        canvasHeight = _height;
    }

    // Set the fill color
    function fill(uint color) public {
        currentStyle.fill = color;
    }

    // Set the stroke color and width
    function stroke(uint color, uint strokeWidth) public {
        currentStyle.stroke = color;
        currentStyle.strokeWidth = strokeWidth;
    }

    // declare global variables to track the current shape and vertices
    string[] shapeBuffer;
    uint[] currentShapeVertices;

    function beginShape() public {
        // initialize shape buffer and current shape vertices
        shapeBuffer = new string[](0);
        currentShapeVertices = new uint[](0);
    }

    function endShape(bool closeShape) public {
        // add vertices to shape buffer
        if (currentShapeVertices.length > 1) {
            string memory verticesString = getVerticesString(
                currentShapeVertices
            );
            shapeBuffer.push(verticesString);
        }

        // close shape if requested
        if (closeShape && currentShapeVertices.length > 2) {
            string memory closeString = getCloseString(currentShapeVertices);
            shapeBuffer.push(closeString);
        }

        // combine all shape buffer strings and return svg tag using currentStyle

        buffer = string.concat(
            buffer,
            "<path ",
            'fill="',
            uintToRGBA(currentStyle.fill),
            '" stroke="',
            uintToRGBA(currentStyle.stroke),
            '" ',
            'stroke-width="',
            Strings.toString(currentStyle.strokeWidth),
            '" ',
            'd="'
        );

        for (uint i = 0; i < shapeBuffer.length; i++) {
            buffer = string.concat(buffer, shapeBuffer[i]);
        }

        buffer = string.concat(buffer, '"/>');
    }

    function vertex(uint x, uint y) public {
        // if first vertex. add M command to shape buffer
        if (currentShapeVertices.length == 0) {
            shapeBuffer.push(
                string.concat(
                    "M ",
                    Strings.toString(x),
                    " ",
                    Strings.toString(y),
                    " "
                )
            );
        }

        // add current vertex to current shape vertices
        currentShapeVertices.push(x);
        currentShapeVertices.push(y);
    }

    function getVerticesString(
        uint[] memory vertices
    ) private pure returns (string memory) {
        // There are three commands that draw lines. The most generic is the "Line To" command, called with L. L takes two parameters—x and y coordinates—and draws a line from the current position to a new position.

        // L x y
        // (or)
        // l dx dy
        // Copy to Clipboard
        // There are two abbreviated forms for drawing horizontal and vertical lines. H draws a horizontal line, and V draws a vertical line. Both commands only take one parameter since they only move in one direction.

        // H x
        // (or)
        // h dx

        // V y
        // (or)
        // v dy
        // Copy to Clipboard
        // An easy place to start is by drawing a shape. We will start with a rectangle (the same type that could be more easily made with a <rect> element). It's composed of horizontal and vertical lines only.

        // A square with black fill is drawn within a white square. The black square's edges begin at position (10,10), move horizontally to position (90,10), move vertically to position (90,90), move horizontally back to position (10,90), and finally move back to the original position (10, 10).
        // <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">

        // <path d="M 10 10 H 90 V 90 H 10 L 10 10"/>

        // convert vertices to string format
        string memory result = "";

        for (uint i = 0; i < vertices.length; i += 2) {
            string memory vertexString = string.concat(
                "L ",
                Strings.toString(vertices[i]),
                " ",
                Strings.toString(vertices[i + 1]),
                " "
            );
            result = string.concat(result, vertexString);
        }

        return result;

        // add move to command to start of string

        // result = string.concat(
        //     "M",
        //     Strings.toString(vertices[0]),
        //     " ",
        //     Strings.toString(vertices[1]),
        //     result
        // );
    }

    function getCloseString(
        uint[] memory vertices
    ) private pure returns (string memory) {
        // close shape by drawing line to first vertex
        string memory closeString = string.concat(
            "L ",
            Strings.toString(vertices[0]),
            " ",
            Strings.toString(vertices[1]),
            " "
        );
        return string.concat(closeString, "Z");
    }

    // ============ Colors =================

    function uintToColor(uint256 c) public returns (Color memory color) {
        color = Color(uint8(c >> 24), uint8(c >> 16), uint8(c >> 8), uint8(c));
    }

    function uintToRGBA(uint256 c) public returns (string memory rgb) {
        Color memory color = uintToColor(c);
        rgb = string(
            abi.encodePacked(
                "rgba(",
                Strings.toString(color.r),
                ",",
                Strings.toString(color.g),
                ",",
                Strings.toString(color.b),
                ",",
                Strings.toString(color.a),
                ")"
            )
        );
    }

    function colorToRGBA(
        Color memory color
    ) public returns (string memory rgb) {
        rgb = string(
            abi.encodePacked(
                "rgb(",
                Strings.toString(color.r),
                ",",
                Strings.toString(color.g),
                ",",
                Strings.toString(color.b),
                ")"
            )
        );
    }

    function background(uint256 color) public {
        string memory bg = string(
            abi.encodePacked(
                "<rect x='0' y='0' width='",
                Strings.toString(canvasWidth),
                "' height='",
                Strings.toString(canvasHeight),
                "' fill='",
                uintToRGBA(color),
                "'/>\n"
            )
        );

        buffer = string(abi.encodePacked(buffer, bg));
    }

    function drawLine(
        uint x1,
        uint y1,
        uint x2,
        uint y2,
        uint256 color
    ) public {
        string memory line = string(
            abi.encodePacked(
                "<line x1='",
                Strings.toString(x1),
                "' y1='",
                Strings.toString(y1),
                "' x2='",
                Strings.toString(x2),
                "' y2='",
                Strings.toString(y2),
                "' stroke='",
                uintToRGBA(color),
                "' stroke-width='1'/>\n"
            )
        );

        buffer = string(abi.encodePacked(buffer, line));
    }

    function drawRectangle(
        uint x,
        uint y,
        uint w,
        uint h,
        uint256 color
    ) public {
        // (uint64 r, uint64 g, uint64 b, uint256 a) = colorToRGBA(color);

        string memory rect = string(
            abi.encodePacked(
                "<rect x='",
                Strings.toString(x),
                "' y='",
                Strings.toString(y),
                "' width='",
                Strings.toString(w),
                "' height='",
                Strings.toString(h),
                "' fill='",
                uintToRGBA(color),
                "'/>\n"
            )
        );

        buffer = string(abi.encodePacked(buffer, rect));
    }

    function drawEllipse(uint x, uint y, uint w, uint h, uint256 color) public {
        string memory ellipse = string(
            abi.encodePacked(
                "<ellipse cx='",
                Strings.toString(x + w / 2),
                "' cy='",
                Strings.toString(y + h / 2),
                "' rx='",
                Strings.toString(w / 2),
                "' ry='",
                Strings.toString(h / 2),
                "'/>\n"
            )
        );

        buffer = string(abi.encodePacked(buffer, ellipse));
    }

    function drawCircle(uint x, uint y, uint r, uint256 color) public {
        string memory circle = string(
            abi.encodePacked(
                "<circle cx='",
                Strings.toString(x),
                "' cy='",
                Strings.toString(y),
                "' r='",
                Strings.toString(r),
                "'/>\n"
            )
        );

        buffer = string(abi.encodePacked(buffer, circle));
    }

    function renderSVG() public view returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="',
                Strings.toString(canvasWidth),
                '" height="',
                Strings.toString(canvasHeight),
                '">\n',
                buffer,
                "</svg>"
            );
    }
}

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
