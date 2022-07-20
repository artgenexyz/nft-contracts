// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@divergencetech/ethier/contracts/random/NextShuffler.sol";
import "@divergencetech/ethier/contracts/random/PRNG.sol";
import "@divergencetech/ethier/contracts/random/CSPRNG.sol";

contract NextShufflerLazyInit is NextShuffler {
    using PRNG for PRNG.Source;

    // uint256[2] internal sourceStore;

    constructor () NextShuffler(0) {}

    function _setNumToShuffle(uint256 _num) internal {
        require(numToShuffle == 0, "NextShufflerLazyInit: numToShuffle can only be set once");
        numToShuffle = _num;
    }

    // function _setSource(bytes32 _seed) internal {
    //     PRNG.Source src = PRNG.newSource(_seed);

    //     src.store(sourceStore);
    // }

    // function next() internal returns (uint256 val) {
    //     PRNG.Source src = PRNG.loadSource(sourceStore);

    //     val = _next(src);

    //     src.store(sourceStore);
    // }

}

