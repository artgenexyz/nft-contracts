// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@divergencetech/ethier/contracts/random/PRNG.sol";
import "./NextShuffler.sol";

contract NextShufflerLazyInit is NextShuffler {
    using PRNG for PRNG.Source;

    uint256[2] private _nextShufflerSourceStore;
    bool private _isRandomnessSourceSet;

    constructor () NextShuffler(0) {}

    function isNumToShuffleSet() public view returns (bool) {
        return numToShuffle != 0;
    }

    function isRandomnessSourceSet() internal view returns (bool) {
        return _isRandomnessSourceSet;
    }

    function _setNumToShuffle(uint256 _num) internal {
        require(numToShuffle == 0, "NextShufflerLazyInit: numToShuffle can only be set once");
        numToShuffle = _num;
    }

    function _setRandomnessSource(bytes32 seed) internal {
        require(
            !isNumToShuffleSet(),
            "Can't change source after seed has been set"
        );

        PRNG.Source src = PRNG.newSource(seed);

        src.store(_nextShufflerSourceStore);

        _isRandomnessSourceSet = true;
    }

    function _load() internal view returns (PRNG.Source) {
        return PRNG.loadSource(_nextShufflerSourceStore);
    }

    function _store(PRNG.Source _src) internal {
        _src.store(_nextShufflerSourceStore);
    }
}

