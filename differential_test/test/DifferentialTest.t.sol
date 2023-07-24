// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console2.sol";
import {Strings as OpenZeppelinStrings} from "openzeppelin/utils/Strings.sol";

import {Array} from "src/Array.sol";
import {Strings} from "src/Strings.sol";
import {Multiproof} from "src/Multiproof.sol";

import {Assertions} from "test/Assertions.sol";

contract TestDifferential is Assertions {
    using Array for uint256[];
    using Array for uint16[];
    using OpenZeppelinStrings for uint256;
    using Strings for bytes;

    /// forge-config: default.fuzz.runs = 10
    function testMultiproofMatchesOpenZeppelinJSImplementation(
        uint8[] memory leaves, 
        uint256[] memory leafIndicesToProve
    ) public {
        // number of leaves to prove should be less than or equal to the number of leaves in the tree
        vm.assume(leaves.length < 100);
        vm.assume(leaves.length > 1);
        vm.assume(leaves.length >= leafIndicesToProve.length);

        // set up the leaves to prove array by preventing index out of bounds
        for (uint256 i = 0; i < leafIndicesToProve.length; i++) {
            // use a modulo operation to make sure that the index of the 
            // leaf to prove always exists in the leaves array
            leafIndicesToProve[i] = leafIndicesToProve[i] % leaves.length;
        }

         // foundry doesnt have support yet for fuzzed arrays with strategies (sorted arrays, no-duplicate arrays).
        // so we should sort and remove dupes
        if (leafIndicesToProve.length > 0) {
            // sort the leaf indices to prove
            leafIndicesToProve.quickSort(0, leafIndicesToProve.length - 1);

            // remove duplicates from the array
            leafIndicesToProve = leafIndicesToProve.removeSortedDuplicates();
        }

        // prepare data for ffi
        string[] memory jsInputs = new string[](8);

        // build ffi command
        jsInputs[0] = 'npm';
        jsInputs[1] = '--prefix';
        jsInputs[2] = 'differential_test/js/';
        jsInputs[3] = '--silent';
        jsInputs[4] = 'run';
        jsInputs[5] = 'generate-multiproof';
        jsInputs[6] = vm.toString(abi.encode(leaves));
        jsInputs[7] = vm.toString(abi.encode(leafIndicesToProve));

        // execute the command to return the js multiproof
        bytes memory jsResult = vm.ffi(jsInputs);

        // generate the multiproof using open zeppelin
        (   
            bytes32[] memory openZeppelinLeaves,
            bytes32 openZeppelinRoot,
            bytes32[] memory openZeppelinProof, 
            bool[] memory openZeppelinFlags
        ) = abi.decode(jsResult, (bytes32[], bytes32, bytes32[], bool[]));

        // generate the multiproof
        (
            bytes32 root, 
            bytes32[] memory proof, 
            bool[] memory flags
        ) = Multiproof.getMultiproof(openZeppelinLeaves, leafIndicesToProve);

        // assert root, proof, and flags are equal
        assertEq(root,  openZeppelinRoot);
        assertEq(proof, openZeppelinProof);
        assertEq(flags, openZeppelinFlags);

        assertTrue(true);
    }
}