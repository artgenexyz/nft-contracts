// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@divergencetech/ethier/contracts/random/PRNG.sol";
import "./NextShuffler.sol";

contract NextShufflerLazyInit is NextShuffler {
    using PRNG for PRNG.Source;

    constructor () NextShuffler(0) {}

    function isNumToShuffleSet() public view returns (bool) {
        return numToShuffle != 0;
    }

    function _setNumToShuffle(uint256 _num) internal {
        require(numToShuffle == 0, "NextShufflerLazyInit: numToShuffle can only be set once");
        numToShuffle = _num;
    }
}

