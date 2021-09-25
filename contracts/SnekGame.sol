// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./AvatarNFT.sol";

enum Rule {
    MUST,
    MUST_NOT,
    OPTIONAL
}
enum Field {
    SNAKE_HEAD,
    SNAKE_BODY,
    SNAKE_TAIL,
    WALL
}

// constant bytes32 SNAKE_HEAD = 0x0;


contract Snek is AvatarNFT {
    mapping (uint256 => Pattern) patternByTokenId;
    // TODO: snek can have multiple patterns

    struct Pattern {
        bytes32[7][7] map;
    }

    constructor() AvatarNFT(0.05 ether, 10000, 200, 5, "https://metadata.buildship.dev/api/token/snek/", "Snek Game", "SNEK") {}

}

contract SnekGame {
    Snek snekContract = new Snek();

    struct Arena {
        bytes32[9][9] map;
    }

    function startBattle(uint256 snek1, uint256 snek2) pure public {
        // Arena memory arena = Arena();
        // arena.map[0][0] = snek1;
        // arena.map[0][1] = snek2;
        // arena.map[0][2] = snek1;
        // arena.map[0][3] = snek2;
        require(snek1 != snek2);
    }
}