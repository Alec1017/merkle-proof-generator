// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Merkle} from "src/Merkle.sol";

import {Assertions} from "test/utils/Assertions.sol";
import {Array} from "test/utils/Array.sol";

contract TestDifferential is Assertions {
    using Array for uint256[];

    /// forge-config: default.fuzz.runs = 10
    function testProofMatchesOpenZeppelinJSImplementation(
        bytes32[] memory leaves
    ) public {
        vm.assume(leaves.length > 1);

        // prepare data for ffi
        string[] memory jsInputs = new string[](7);

        // build ffi command
        jsInputs[0] = 'npm';
        jsInputs[1] = '--prefix';
        jsInputs[2] = 'differential_test/js/';
        jsInputs[3] = '--silent';
        jsInputs[4] = 'run';
        jsInputs[5] = 'generate-proof';
        jsInputs[6] = vm.toString(abi.encode(leaves));

        // execute the command to return the js multiproof
        bytes memory jsResult = vm.ffi(jsInputs);

        // generate the proof using open zeppelin
        (   
            bytes32[] memory openZeppelinLeaves,
            uint256 openZeppelinIndexToProve,
            bytes32 openZeppelinRoot,
            bytes32[] memory openZeppelinProof
        ) = abi.decode(jsResult, (bytes32[], uint256, bytes32, bytes32[]));

        // generate the proof
        (
            bytes32 root, 
            bytes32[] memory proof
        ) = Merkle.getProof(openZeppelinLeaves, openZeppelinIndexToProve);
        
        // assert root and proof are equal
        assertEq(root,  openZeppelinRoot);
        assertEq(proof, openZeppelinProof);
    }

    /// forge-config: default.fuzz.runs = 10
    function testMultiproofMatchesOpenZeppelinJSImplementation(
        bytes32[] memory leaves
    ) public {
        vm.assume(leaves.length > 1);

        // prepare data for ffi
        string[] memory jsInputs = new string[](7);

        // build ffi command
        jsInputs[0] = 'npm';
        jsInputs[1] = '--prefix';
        jsInputs[2] = 'differential_test/js/';
        jsInputs[3] = '--silent';
        jsInputs[4] = 'run';
        jsInputs[5] = 'generate-multiproof';
        jsInputs[6] = vm.toString(abi.encode(leaves));

        // execute the command to return the js multiproof
        bytes memory jsResult = vm.ffi(jsInputs);

        // generate the multiproof using open zeppelin
        (   
            bytes32[] memory openZeppelinLeaves,
            uint256[] memory openZeppelinIndices,
            bytes32 openZeppelinRoot,
            bytes32[] memory openZeppelinProof, 
            bool[] memory openZeppelinFlags
        ) = abi.decode(jsResult, (bytes32[], uint256[], bytes32, bytes32[], bool[]));

        // generate the multiproof
        (
            bytes32 root, 
            bytes32[] memory proof, 
            bool[] memory flags
        ) = Merkle.getMultiproof(openZeppelinLeaves, openZeppelinIndices);

        // assert root, proof, and flags are equal
        assertEq(root,  openZeppelinRoot);
        assertEq(proof, openZeppelinProof);
        assertEq(flags, openZeppelinFlags);
    }
}