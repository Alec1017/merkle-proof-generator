// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library ArrayUtils {
    // removes duplicates from a sorted array
    function removeSortedDuplicates(uint256[] memory sortedArr) public pure returns (uint256[] memory) {
        require(sortedArr.length > 0, "must have an array with at least one value");

        // create result array placeholder
        uint256[] memory result = new uint[](sortedArr.length);

        // add the first element of the array to the result, and set it as the
        // current value to check for duplicates against
        result[0] = sortedArr[0];
        uint256 count = 1;
        uint256 duplicateComparator = sortedArr[0];

        // skip the first value
        for (uint256 i = 1; i < sortedArr.length; i++) {
            // If the divided value is not a duplicate, add it to the result array
            //
            // dont add zero values either
            if (sortedArr[i] != duplicateComparator && sortedArr[i] != 0) {
                result[count] = sortedArr[i];

                count++;
                duplicateComparator = sortedArr[i];
            }
        }

        // Resize the result array to remove any unused slots
        uint256[] memory finalResult = new uint[](count);
        for (uint256 i = 0; i < count; i++) {
            finalResult[i] = result[i];
        }

        return finalResult;
    }

    function divideByTwo(uint256[] memory arr) public pure returns (uint256[] memory) {
        assembly {
            // load the array length
            let arrLength := mload(arr)

            // loop through each
            for { let i := 0 } lt(i, arrLength) { i := add(i, 1) } {
                let currentValue := mload(add(arr, mul(add(i, 1), 0x20)))

                // Divide the current value by 2 using right-shift (bit shifting)
                let dividedValue := shr(1, currentValue)

                mstore(add(arr, mul(add(i, 1), 0x20)), dividedValue)
            }
        }

        return arr;
    }

    function trimBytes32Array(bytes32[] memory arr, uint256 newSize)
        internal
        pure
        returns (bytes32[] memory trimmedArr)
    {
        require(arr.length >= newSize, "newSize is not smaller than original array size");

        // Resize the array to remove any unused slots
        trimmedArr = new bytes32[](newSize);
        for (uint256 i = 0; i < newSize; i++) {
            trimmedArr[i] = arr[i];
        }
    }

    function trimBoolArray(bool[] memory arr, uint256 newSize) internal pure returns (bool[] memory trimmedArr) {
        require(arr.length >= newSize, "newSize is not smaller than original array size");

        // Resize the array to remove any unused slots
        trimmedArr = new bool[](newSize);
        for (uint256 i = 0; i < newSize; i++) {
            trimmedArr[i] = arr[i];
        }
    }
}
