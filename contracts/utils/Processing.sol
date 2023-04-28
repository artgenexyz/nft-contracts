// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/console.sol";

import "solidity-trigonometry/Trigonometry.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Processing {
    uint public width;
    uint public height;

    string constant LINE_BREAK = "";

    struct Style {
        Color fill;
        Color stroke;
        uint strokeWidth;
    }

    Style currentStyle;

    enum ColorType {
        RGB,
        HSL
    }

    struct Color {
        uint8 r;
        uint8 g;
        uint8 b;
        uint8 a;
        uint h;
        uint s;
        uint l;
        ColorType kind;
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

    uint _randSeed;
    uint _noiseSeed;

    constructor() {}

    function setup() public virtual {}

    function draw() public virtual {}

    function fxpreview() public virtual {}

    function createCanvas(uint256 _width, uint256 _height) public {
        width = _width;
        height = _height;
    }

    // Set the fill color
    function fill(Color memory color) public {
        currentStyle.fill = color;
    }

    // Set the stroke color and width
    function stroke(Color memory color, uint strokeWidth) public {
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
            colorToString(currentStyle.fill),
            '" stroke="',
            colorToString(currentStyle.stroke),
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
        color = Color({
            kind: ColorType.RGB,
            r: uint8((c >> 24) & 0xff),
            g: uint8((c >> 16) & 0xff),
            b: uint8((c >> 8) & 0xff),
            a: uint8(c & 0xff),
            h: 0,
            s: 0,
            l: 0
        });
    }

    function uintToRGBA(uint256 c) public returns (string memory rgb) {
        Color memory color = uintToColor(c);
        return colorToString(color);
    }

    function colorToString(
        Color memory color
    ) public returns (string memory rgb) {
        if (color.kind == ColorType.RGB) {
            return
                string(
                    abi.encodePacked(
                        "rgba(",
                        Strings.toString(color.r),
                        " ",
                        Strings.toString(color.g),
                        " ",
                        Strings.toString(color.b),
                        " / ",
                        Strings.toString(color.a),
                        "%)"
                    )
                );
        } else {
            // background: hsl(50 100% 40% / 100%);
            return
                string(
                    abi.encodePacked(
                        "hsl(",
                        Strings.toString(color.h),
                        " ",
                        Strings.toString(color.s),
                        "% ",
                        Strings.toString(color.l),
                        "% / ",
                        Strings.toString(color.a),
                        "%)"
                    )
                );
        }
    }

    function colorToUint(Color memory color) public returns (uint256 c) {
        if (color.kind == ColorType.HSL) {
            revert("We cant convert HSL to uint yet");
        }

        c =
            (uint256(color.r) << 24) |
            (uint256(color.g) << 16) |
            (uint256(color.b) << 8) |
            uint256(color.a);
    }

    function background(Color memory color) public {
        string memory bg = string(
            abi.encodePacked(
                "<rect x='0' y='0' width='",
                Strings.toString(width),
                "' height='",
                Strings.toString(height),
                "' fill='",
                colorToString(color),
                "'/>",
                LINE_BREAK
            )
        );

        buffer = string(abi.encodePacked(buffer, bg));
    }

    function drawLine(uint x1, uint y1, uint x2, uint y2) public {
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
                colorToString(currentStyle.stroke),
                "' stroke-width='",
                Strings.toString(currentStyle.strokeWidth),
                "'/>",
                LINE_BREAK
            )
        );

        buffer = string(abi.encodePacked(buffer, line));
    }

    function drawRectangle(
        uint x,
        uint y,
        uint w,
        uint h,
        Color memory color
    ) public {
        // (uint64 r, uint64 g, uint64 b, uint256 a) = colorToString(color);

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
                colorToString((color)),
                "'/>",
                LINE_BREAK
            )
        );

        buffer = string(abi.encodePacked(buffer, rect));
    }

    function rect(uint x, uint y, uint w, uint h) public {
        drawRectangle(x, y, w, h, currentStyle.fill);
    }

    function circle(uint x, uint y, uint r) public {
        string memory circle = string(
            abi.encodePacked(
                "<circle cx='",
                Strings.toString(x),
                "' cy='",
                Strings.toString(y),
                "' r='",
                Strings.toString(r),
                "' fill='",
                colorToString(currentStyle.fill),
                "'/>",
                LINE_BREAK
            )
        );

        buffer = string(abi.encodePacked(buffer, circle));
    }

    function noStroke() public {
        currentStyle.stroke = Color({
            kind: ColorType.RGB,
            r: 0,
            g: 0,
            b: 0,
            a: 0,
            h: 0,
            s: 0,
            l: 0
        });
    }

    function noFill() public {
        currentStyle.fill = Color({
            kind: ColorType.RGB,
            r: 0,
            g: 0,
            b: 0,
            a: 0,
            h: 0,
            s: 0,
            l: 0
        });
    }

    // function abs(int x) public returns (int) {
    //     if (x < 0) {
    //         return -x;
    //     } else {
    //         return x;
    //     }
    // }

    struct Vector {
        uint x;
        uint y;
    }

    function createVector(uint x, uint y) public returns (Vector memory) {
        return Vector(x, y);
    }

    function dist(uint x1, uint y1, uint x2, uint y2) public returns (uint) {
        uint dx = x2 > x1 ? x2 - x1 : x1 - x2;
        uint dy = y2 > y1 ? y2 - y1 : y1 - y2;
        return sqrt(dx * dx + dy * dy);
    }

    function dist2(uint x1, uint y1, uint x2, uint y2) public returns (uint) {
        uint dx = x2 > x1 ? x2 - x1 : x1 - x2;
        uint dy = y2 > y1 ? y2 - y1 : y1 - y2;
        return (dx * dx + dy * dy);
    }

    function sqrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function sin(uint x) public pure returns (int) {
        return Trigonometry.sin(x);
    }

    function cos(uint x) public pure returns (int) {
        return Trigonometry.cos(x);
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
                "'/>",
                LINE_BREAK
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
                "'/>",
                LINE_BREAK
            )
        );

        buffer = string(abi.encodePacked(buffer, circle));
    }

    function renderSVG() public view returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="',
                Strings.toString(width),
                '" height="',
                Strings.toString(height),
                '">\n',
                buffer,
                "</svg>"
            );
    }

    // Solidity implementation of noise() function using _noiseSeed to seed the random number generator
    // Perlin noise
    // returns values between 0 and type(uint8).max
    function noise(uint x, uint y) public pure returns (uint) {
        uint n = x + y * 57;
        n = (n << 13) ^ n;
        uint nn = (n * (n * n * 15731 + 789221) + 1376312589);
        return uint8(nn >> 24);
    }

    // Solidity implementation of noiseSeed() function
    function noiseSeed(uint seed) public {
        _noiseSeed = seed;
    }

    function randomFrom(uint[] calldata arr) public returns (uint) {
        return arr[random(0, arr.length)];
    }

    function randomFrom(Color[] memory arr) public returns (Color memory) {
        return arr[random(0, arr.length)];
    }

    function random(uint a, uint b) public returns (uint) {
        if (a > b) return rand(b, a);

        return rand(a, b);
    }

    // Solidity implementation of generateRandom() function
    function generateRandom() public returns (uint) {
        unchecked {
            _randSeed = (_randSeed * 16807) % 2147483647;
            return _randSeed % 10000;
        }
    }

    function append(
        uint[] memory arr,
        uint value
    ) public returns (uint[] memory newArr) {
        newArr = new uint[](arr.length + 1);

        for (uint i = 0; i < arr.length; i++) {
            newArr[i] = arr[i];
        }

        newArr[arr.length] = value;

        return newArr;
    }

    function rand(uint a, uint b) public returns (uint) {
        require(a < b, "a must be less than b");

        // console.log(
        //     "rand a, b",
        //     string.concat(Strings.toString(a), ", ", Strings.toString(b))
        // );

        uint _rand = generateRandom();

        // console.log("rand ", Strings.toString(_rand));
        uint result = a + (_rand * (b - a)) / 10000;

        // console.log("rand result ", Strings.toString(result));

        return result;
    }

    // Solidity implementation of randomSeed() function
    function randomSeed(uint seed) public {
        _randSeed = seed;
    }

    // Solidity implementation of color() function
    function color(
        uint hue,
        uint saturation,
        uint luminance,
        uint alpha
    ) public pure returns (Color memory) {
        Color memory c = Color({
            r: 0,
            g: 0,
            b: 0,
            a: uint8(alpha),
            h: hue,
            s: saturation,
            l: luminance,
            kind: ColorType.HSL
        });

        return (c);
    }

    // Solidity implementation of stroke() function
    function stroke(Color memory color) public {
        currentStyle.stroke = color;
    }

    // Solidity implementation of strokeWeight() function
    function strokeWeight(uint width) public {
        currentStyle.strokeWidth = width;
    }

    // Solidity implementation of line() function
    function line(uint x1, uint y1, uint x2, uint y2) public {
        // use drawLine

        drawLine(x1, y1, x2, y2);
    }

    // Solidity implementation of fxpreview() function
    // function fxpreview() public view returns (string memory) {
    //     string memory svg = string(
    //         abi.encodePacked(
    //             '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024">\n'
    //         )
    //     );

    //     // Add background rectangle
    //     svg = string(
    //         abi.encodePacked(
    //             svg,
    //             "<rect x='0' y='0' width='1024' height='1024' fill='",
    //             _getColorHex(_backgroundColor),
    //             "' />", LINE_BREAK
    //         )
    //     );

    //     // Add all shapes to SVG
    //     svg = string(abi.encodePacked(svg, string(_buffer), "</svg>", LINE_BREAK));

    //     return svg;
    // }
}
