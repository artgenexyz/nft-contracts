// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./AvatarNFT.sol";

contract OnChainGAN is AvatarNFT {
    using Strings for uint256;

    uint256 constant INPUT_SIZE = 32;
    uint256 constant SQUARE_SIZE = 10; // px
    uint256 constant OUTPUT_SIZE = SQUARE_SIZE*SQUARE_SIZE;

    uint256[INPUT_SIZE][OUTPUT_SIZE] public matrix;

    constructor() AvatarNFT(0.2 ether, 10000, 200, 5, "https://metadata.buildship.dev/api/token/gan/", "GAN", "GAN") {}

    function initMatrix() public {
        uint256[INPUT_SIZE] memory vector;

        for (uint256 i = 0; i < OUTPUT_SIZE; i++) {
            vector = createRandomVector32(i);

            copy(vector, matrix[i]);
        }
    }

    function fillRandomVector32(uint256[32] memory vector, uint256 seed) view internal {

        // BlockHash only works for the most 256 recent blocks.
        uint256 _block_shift = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        _block_shift =  1 + (_block_shift % 255);

        uint256 _block_ref;

        for (uint256 i = 0; i < INPUT_SIZE; i++) {
            _block_ref = block.number - (_block_shift + i + seed * INPUT_SIZE) % 255;

            vector[i] = uint(blockhash(_block_ref));
            // vector[i] = uint(keccak256(abi.encodePacked(blockhash(_block_ref), seed)));
        }

        // uint256[INPUT_SIZE] memory randomVector = createRandomVector32(seed);

        // for (uint256 i = 0; i < INPUT_SIZE; i++) {
        //     vector[i] = randomVector[i];
        // }

    }

    function createRandomVector32(uint256 seed) view internal returns (uint256[INPUT_SIZE] memory vector) {
        // uint256[INPUT_SIZE] memory randomVector;

        fillRandomVector32(vector, seed);

        // // BlockHash only works for the most 256 recent blocks.
        // uint256 _block_shift = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        // _block_shift =  1 + (_block_shift % 255);

        // uint256 _block_ref;

        // for (uint256 i = 0; i < INPUT_SIZE; i++) {
        //     _block_ref = block.number - (_block_shift + i + seed * INPUT_SIZE) % 255;

        //     vector[i] = uint(blockhash(_block_ref));
        // }

        return vector;
    }

    function copy(uint256[INPUT_SIZE] memory vector, uint256[INPUT_SIZE] storage vector_out) internal {
        for (uint256 i = 0; i < INPUT_SIZE; i++) {
            vector_out[i] = vector[i];
        }
    }

    function printMatrix() public view returns (string memory _matrix) {
        // string memory _matrix;

        for (uint256 i = 0; i < OUTPUT_SIZE; i++) {
            for (uint256 j = 0; j < INPUT_SIZE; j++) {
                _matrix = string(abi.encodePacked(
                    _matrix, " ", matrix[i][j].toString()
                ));
            }

            _matrix = string(abi.encodePacked(_matrix, "\n"));
        }

        return _matrix;
    }

    function tokenURI() public view returns (string memory output) {
        // string memory output = "";

        uint256[INPUT_SIZE] memory seed = createRandomVector32(0);


        // uint[3][3] memory mat1 = [];
        // uint[3][3] memory mat2 = [];

        // uint r1 = mat1.length; // rows of mat1
        // uint c1 = mat1[0].length; // columns of mat1
        // uint c2 = mat2[0].length; // columns of mat2

        uint[OUTPUT_SIZE] memory result; 

        for (uint i = 0; i < INPUT_SIZE; ++i) {
            for (uint j = 0; j < 1; ++j) {
                for (uint k = 0; k < OUTPUT_SIZE; ++k) {
                    result[i] += seed[i] * matrix[i][k];
                }
            }
        }

        return output;
    }
}
