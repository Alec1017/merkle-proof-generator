// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console2.sol";
import {Array} from "src/Array.sol";

library MerkleMultiproofUtils {
    using Array for uint256[];
    using Array for bytes32[];
    using Array for bool[];

    struct virtualTreeNode {
        // determines whether to include this node in the multiproof
        bool includeInProof;
        // determines whether this node has already been processed during multiproof generation
        bool processed;
    }

    function leftChildIndex(uint256 i) private pure returns (uint256) {
        return 2 * i + 1;
    }

    function rightChildIndex(uint256 i) private pure returns (uint256) {
        return 2 * i + 2;
    }

    function siblingIndex(uint256 i) private pure returns (uint256) {
        require(i > 0, "There is no sibling index for 0");

        // if i is odd, add 1. otherwise subtract 1
        return i & 0x1 == 1 ? i + 1 : i - 1;
    }

    function parentIndex(uint256 i) private pure returns (uint256) {
        require(i > 0, "There is no parent index for 0");

        // if i is odd, we subtract only 1 from the i value before dividing by 2.
        // Think of this operation as the reverse of leftChildIndex() and rightChildIndex().
        return (i + (i & 0x1) - 2) / 2;
    }

    function getTree(bytes32[] memory leaves) internal pure returns (bytes32[] memory tree) {
        // create a merkle tree placeholder array
        tree = new bytes32[](2 * leaves.length - 1);

        // place all leaves into the tree
        for (uint256 i = 0; i < leaves.length; i++) {
            tree[tree.length - 1 - i] = leaves[i];
        }

        // start from the back of the tree, at the first index before all the leaves, and build up
        // the parent nodes
        for (uint256 i = tree.length - 1 - leaves.length; i >= 0;) {
            // the parent is the hash of the left child and the right child
            tree[i] = hashLeafPairs(tree[leftChildIndex(i)], tree[rightChildIndex(i)]);

            // an underflow error is hit on the final iteration. This check avoids the final decrement.
            if (i == 0) {
                break;
            } else {
                i--;
            }
        }
    }

    function getRoot(bytes32[] memory leaves) internal pure returns (bytes32 root) {
        bytes32[] memory tree = getTree(leaves);

        root = tree[0];
    }

    function getMultiproof(bytes32[] memory leaves, uint256[] memory leafIndicesToProve)
        internal
        pure
        returns (bytes32[] memory proof, bool[] memory flags)
    {
        // generate a merkle tree from the data
        bytes32[] memory tree = MerkleMultiproofUtils.getTree(leaves);

        // create a virtual tree
        virtualTreeNode[] memory virtualTree = new virtualTreeNode[](tree.length);

        // check if no indices to prove were passed, then just return the root
        if (leafIndicesToProve.length == 0) {
            proof = new bytes32[](1);
            proof[0] = tree[0];
            return (proof, flags);
        }

        // convert leafIndicesToProve to align with the tree indices
        // tree indices will be reversed
        uint256[] memory treeIndicesToProve = new uint256[](leafIndicesToProve.length);
        for (uint256 i = 0; i < leafIndicesToProve.length; i++) {
            treeIndicesToProve[i] = tree.length - 1 - leafIndicesToProve[i];
        }

        // create flags array
        flags = new bool[](virtualTree.length);
        uint256 flagCounter;

        while (true) {
            // break when there is one index left to check, and its the root node
            if (treeIndicesToProve.length == 1 && treeIndicesToProve[0] == 0) {
                break;
            }

            // loop through the tree index for each node to prove
            for (uint256 i = 0; i < treeIndicesToProve.length; i++) {
                // current node in the tree to determine inclusion in the multiproof
                uint256 treeIndex = treeIndicesToProve[i];

                // skip this node if it has already been processed
                if (virtualTree[treeIndex].processed) {
                    // convert the current index to the parent index
                    treeIndicesToProve[i] = parentIndex(treeIndex);

                    continue;
                }
                console2.log("virtual tree node processed", virtualTree[treeIndex].processed);

                console2.log("current index is:", treeIndex);

                // check to see if the sibling has turned on this node
                if (virtualTree[treeIndex].includeInProof) {
                    // if it has, then it means we have the full sibling pair that
                    // doesnt need to be included in the proof. So, we can set the
                    // false bool flag set by the sibling to true.
                    flags[flagCounter - 1] = true;

                    // set this node to false in the virtual tree so it is not
                    // included in the final proof
                    virtualTree[treeIndex].includeInProof = false;

                    console2.log("sibling %d has already turned on this node", siblingIndex(treeIndex));
                    console2.log("we turn off current node: %d", treeIndex);
                    console2.log(
                        "flag counter is currently: %d, but we change counter index: %d to true",
                        flagCounter,
                        flagCounter - 1
                    );
                }
                // this node hasnt been turned on by its sibling yet,
                // so it hasnt appeared in the list of nodes to prove.
                else {
                    // So, we can make sure the sibling gets added to the proof
                    virtualTree[siblingIndex(treeIndex)].includeInProof = true;

                    // now we make sure the flag array is false, because we need to include
                    // the sibling hash. This value can be overridden by the sibling
                    // if it is also included in the array of leaves to prove
                    flags[flagCounter] = false;

                    // increment the flag counter since we used the index
                    flagCounter++;

                    console2.log(
                        "sibling %d has NOT turned on this node, so set sibling to true", siblingIndex(treeIndex)
                    );
                    console2.log("flag counter is currently: %d, and we set it to false", flagCounter - 1);
                }

                console2.log("--------------------");

                // mark this node as processed
                virtualTree[treeIndex].processed = true;

                // convert the current index to the parent index
                treeIndicesToProve[i] = parentIndex(treeIndex);
            }

            console2.log("NEW LAYER STARTED");

            // remove duplicate parent indices
            treeIndicesToProve = treeIndicesToProve.removeSortedDuplicates();
        }

        // create proofs array
        proof = new bytes32[](virtualTree.length);
        uint256 proofCounter;
        for (uint256 i = virtualTree.length - 1; i >= 0;) {
            // if there's a virtual tree entry, it means this hash is part of the proof
            if (virtualTree[i].includeInProof) {
                proof[proofCounter] = tree[i];

                // increment the counter
                proofCounter++;
            }

            if (i == 0) {
                break;
            } else {
                i--;
            }
        }

        // Resize the proof and flags arrays to remove any unused slots
        proof = proofCounter > 0 ? proof.trimBytes32Array(proofCounter) : new bytes32[](0);
        flags = flagCounter > 0 ? flags.trimBoolArray(flagCounter) : new bool[](0);
    }

    function hashLeafPairs(bytes32 left, bytes32 right) internal pure returns (bytes32 _hash) {
        assembly {
            switch lt(left, right)
            case 0 {
                mstore(0x0, right)
                mstore(0x20, left)
            }
            default {
                mstore(0x0, left)
                mstore(0x20, right)
            }
            _hash := keccak256(0x0, 0x40)
        }
    }
}
