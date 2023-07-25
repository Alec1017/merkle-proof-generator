// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Array {

    // quicksort implementation 
    function quickSort(uint256[] memory arr, uint256 left, uint256 right) internal pure {
        if (left >= right) {
            return;
        }

        unchecked {
            // p = the pivot element
            uint256 p = arr[(left + right) / 2];
            uint256 i = left;
            uint256 j = right;
            while (i < j) {
                while (arr[i] < p) {
                    ++i;
                }
                while (arr[j] > p) {
                    --j; // arr[j] > p means p still to the left, so j > 0
                }
                if (arr[i] > arr[j]) {
                    (arr[i], arr[j]) = (arr[j], arr[i]);
                } else {
                    ++i;
                }
            }

            // Note --j was only done when a[j] > p.  So we know: a[j] == p, a[<j] <= p, a[>j] > p
            if (j > left) {
                quickSort(arr, left, j - 1); // j > left, so j > 0
            }
            quickSort(arr, j + 1, right);
        }
    }

    // removes duplicates from a sorted array
    function removeSortedDuplicates(uint256[] memory sortedArr) public pure returns (uint256[] memory) {
        require(sortedArr.length > 0, "must have an array with at least one value");

        // create result array placeholder
        uint256[] memory result = new uint256[](sortedArr.length);

        // add the first element of the array to the result, and set it as the
        // current value to check for duplicates against
        result[0] = sortedArr[0];
        uint256 count = 1;
        uint256 duplicateComparator = sortedArr[0];

        // skip the first value
        for (uint256 i = 1; i < sortedArr.length; i++) {
            // If the divided value is not a duplicate, add it to the result array
            if (sortedArr[i] != duplicateComparator) {
                result[count] = sortedArr[i];

                count++;
                duplicateComparator = sortedArr[i];
            }
        }

        // Resize the result array to remove any unused slots
        uint256[] memory finalResult = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            finalResult[i] = result[i];
        }

        return finalResult;
    }
}
