// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";

import {Merkle} from "src/Merkle.sol";

import {Array} from "test/utils/Array.sol";
import {Assertions} from "test/utils/Assertions.sol";

contract TestProver is Test {
    using Array for uint256[];

    /// forge-config: default.fuzz.runs = 1000
    function testOpenZeppelinSingleProverCompatibility(bytes32[] memory leaves, uint256 leafIndexToProve) public {
        // leaf index to prove should be less than or equal to the number of leaves in the tree
        vm.assume(leaves.length > leafIndexToProve);
        vm.assume(leaves.length > 1);

        // generate the proof
        (bytes32 root, bytes32[] memory proof) = Merkle.getProof(leaves, leafIndexToProve);

        // verify the multiproof
        bool isVerified = MerkleProof.verify(proof, root, leaves[leafIndexToProve]);

        // assert the multiproof can be verified by Open Zeppelin
        assertTrue(isVerified, "Single proof verification was not valid");
    }

    /// forge-config: default.fuzz.runs = 1000
    function testOpenZeppelinMultiProverCompatibility(bytes32[] memory leaves, uint256[] memory leafIndicesToProve) public {
        // number of leaves to prove should be less than or equal to the number of leaves in the tree
        vm.assume(leaves.length >= leafIndicesToProve.length);
        vm.assume(leaves.length > 1);

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

        // OZ expects an array of leaf elements so we need to convert from indices to leafs
        bytes32[] memory leavesToProve = new bytes32[](leafIndicesToProve.length);
        for (uint256 i = 0; i < leavesToProve.length; i++) {
            leavesToProve[i] = leaves[leafIndicesToProve[i]];
        }

        // generate the multiproof
        (bytes32 root, bytes32[] memory proof, bool[] memory flags) = Merkle.getMultiproof(leaves, leafIndicesToProve);

        // verify the multiproof
        bool isVerified = MerkleProof.multiProofVerify(
            proof,
            flags,
            root,
            leavesToProve
        );

        // assert the multiproof can be verified by Open Zeppelin
        assertTrue(isVerified, "Multiproof verification was not valid");
    }
}