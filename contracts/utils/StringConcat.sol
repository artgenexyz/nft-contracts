// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library StringConcat {
    function concatStringsNaive(
        string[] memory arr
    ) public pure returns (string memory) {
        // uint256 totalLength = 0;
        // for (uint256 i = 0; i < arr.length; i++) {
        //     totalLength += bytes(arr[i]).length;
        // }
        // = new bytes(totalLength)

        bytes memory result;

        for (uint256 i = 0; i < arr.length; i++) {
            // console.log("result", i, string(result));
            result = abi.encodePacked(result, bytes(arr[i]));
        }

        return string(result);
    }

    function concatStrings(
        string[] memory arr
    ) public pure returns (string memory result) {
        // string memory result;

        for (uint256 i = 0; i < arr.length; i++) {
            result = string.concat(result, arr[i]);
        }

        return result;
    }

    function concatStringsSlow(
        string[] memory arr
    ) public pure returns (string memory) {
        // uint256 totalLength = 0;
        // for (uint256 i = 0; i < arr.length; i++) {
        //     totalLength += bytes(arr[i]).length;
        // }
        // bytes memory result = new bytes(totalLength);
        // uint256 offset = 0;
        // for (uint256 i = 0; i < arr.length; i++) {
        //     bytes memory strBytes = bytes(arr[i]);
        //     uint256 len = strBytes.length;
        //     for (uint256 j = 0; j < len; j++) {
        //         result[offset + j] = strBytes[j];
        //     }
        //     offset += len;
        // }
        // return string(result);

        uint256 totalLength = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            totalLength += bytes(arr[i]).length;
        }

        // console.log("[concatStrings] totalLength", totalLength);

        bytes memory buffer = new bytes(totalLength);
        uint256 offset = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            // console.log("result", i, string(buffer));
            // copy string piece into buffer

            for (uint256 j = 0; j < bytes(arr[i]).length; j++) {
                buffer[offset + j] = bytes(arr[i])[j];
            }

            offset += bytes(arr[i]).length;
        }

        return string(buffer);
    }

    function concatStringsBatch(
        string[] memory arr
    ) public pure returns (string memory result) {
        uint BATCH_SIZE = 14;

        uint remainder = arr.length % BATCH_SIZE;

        // use constant length function for the first elements of the array,

        if (remainder == 0) {
            // skip
        } else if (remainder == 1) {
            result = arr[0];
        } else if (remainder == 2) {
            result = string.concat(arr[0], arr[1]);
        } else if (remainder == 3) {
            result = string.concat(arr[0], arr[1], arr[2]);
        } else if (remainder == 4) {
            result = string.concat(arr[0], arr[1], arr[2], arr[3]);
        } else if (remainder == 5) {
            result = string.concat(arr[0], arr[1], arr[2], arr[3], arr[4]);
        } else if (remainder == 6) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5]
            );
        } else if (remainder == 7) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6]
            );
        } else if (remainder == 8) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7]
            );
        } else if (remainder == 9) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8]
            );
        } else if (remainder == 10) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9]
            );
        } else if (remainder == 11) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9],
                arr[10]
            );
        } else if (remainder == 12) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9],
                arr[10],
                arr[11]
            );
        } else if (remainder == 13) {
            result = string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9],
                arr[10],
                arr[11],
                arr[12]
            );
        }

        if (arr.length < BATCH_SIZE) {
            return result;
        }

        // if the array is longer than BATCH_SIZE, then there are more elements to process
        // and we need to start at the first unprocessed element

        // process batches of BATCH_SIZE strings at a time
        for (
            uint i = remainder;
            i + BATCH_SIZE - 1 < arr.length;
            i += BATCH_SIZE
        ) {
            result = string.concat(
                result,
                arr[i],
                arr[i + 1],
                arr[i + 2],
                arr[i + 3],
                arr[i + 4],
                arr[i + 5],
                arr[i + 6],
                arr[i + 7],
                arr[i + 8],
                arr[i + 9],
                arr[i + 10],
                arr[i + 11],
                arr[i + 12],
                arr[i + 13]
                // arr[i + 14]
            );
        }

        // process the rest of the last batch manually
        // for (
        //     uint j = arr.length - (arr.length % BATCH_SIZE);
        //     j < arr.length;
        //     j++
        // ) {
        //     result = string.concat(result, arr[j]);
        // }
    }

    function concatStringsBatchBytes(
        string[] memory arr
    ) public pure returns (string memory) {
        bytes memory result;

        uint BATCH_SIZE = 8;

        // process batches of 8 strings at a time
        for (uint i; i + BATCH_SIZE - 1 < arr.length; i += BATCH_SIZE) {
            result = abi.encodePacked(
                result,
                bytes(arr[i]),
                bytes(arr[i + 1]),
                bytes(arr[i + 2]),
                bytes(arr[i + 3]),
                bytes(arr[i + 4]),
                bytes(arr[i + 5]),
                bytes(arr[i + 6]),
                bytes(arr[i + 7])
                // ,
                // bytes(arr[i + 8]),
                // bytes(arr[i + 9]),
                // bytes(arr[i + 10]),
                // bytes(arr[i + 11])
                // ,
                // bytes(arr[i + 12]),
                // bytes(arr[i + 13]),
                // bytes(arr[i + 14])
            );
        }

        // process the rest of the last batch manually
        for (
            uint j = arr.length - (arr.length % BATCH_SIZE);
            j < arr.length;
            j++
        ) {
            result = abi.encodePacked(result, bytes(arr[j]));
        }

        return string(result);
    }

    function concatStrings2(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 2, "Array is not of size 2");

        return string.concat(arr[0], arr[1]);
    }

    function concatStrings3(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 3, "Array is not of size 3");

        return string.concat(arr[0], arr[1], arr[2]);
    }

    function concatStrings4(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 4, "Array is not of size 4");

        return string.concat(arr[0], arr[1], arr[2], arr[3]);
    }

    function concatStrings5(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 5, "Array is not of size 5");

        return string.concat(arr[0], arr[1], arr[2], arr[3], arr[4]);
    }

    function concatStrings6(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 6, "Array is not of size 6");

        return string.concat(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
    }

    function concatStrings7(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 7, "Array is not of size 7");

        return
            string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6]
            );
    }

    function concatStrings8(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 8, "Array is not of size 8");

        return
            string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7]
            );
    }

    function concatStrings9(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 9, "Array is not of size 9");

        return
            string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8]
            );
    }

    function concatStrings10(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 10, "Array is not of size 10");

        return
            string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9]
            );
    }

    function concatStrings11(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 11, "Array is not of size 11");

        return
            string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9],
                arr[10]
            );
    }

    function concatStrings12(
        string[] memory arr
    ) public pure returns (string memory) {
        require(arr.length == 12, "Array is not of size 12");

        return
            string.concat(
                arr[0],
                arr[1],
                arr[2],
                arr[3],
                arr[4],
                arr[5],
                arr[6],
                arr[7],
                arr[8],
                arr[9],
                arr[10],
                arr[11]
            );
    }
}
