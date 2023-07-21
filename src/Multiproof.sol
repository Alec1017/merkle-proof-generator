// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/console2.sol";
import {Array} from "src/Array.sol";

library Multiproof {
    using Array for uint256[];

    enum Children {
        IS_LEAF,
        ONE,
        BOTH
    }

    struct VirtualTreeNode {
        // determines whether to include this node in the multiproof
        bool includeInProof;
        // determines whether this node has already been processed during multiproof generation
        bool processed;
        // determines how many children this node has (if any).
        // This value will be used to compute the bool flags
        Children children;
    }

    function _leftChildIndex(uint256 i) private pure returns (uint256) {
        return 2 * i + 1;
    }

    function _rightChildIndex(uint256 i) private pure returns (uint256) {
        return 2 * i + 2;
    }

    function _siblingIndex(uint256 i) private pure returns (uint256) {
        require(i > 0, "There is no sibling index for 0");

        // if i is odd, add 1. otherwise subtract 1
        return i & 0x1 == 1 ? i + 1 : i - 1;
    }

    function _parentIndex(uint256 i) private pure returns (uint256) {
        require(i > 0, "There is no parent index for 0");

        // if i is odd, we subtract only 1 from the i value before dividing by 2.
        // Think of this operation as the reverse of leftChildIndex() and rightChildIndex().
        return (i + (i & 0x1) - 2) / 2;
    }

    function _hashLeafPairs(bytes32 left, bytes32 right) private pure returns (bytes32 _hash) {
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
            tree[i] = _hashLeafPairs(tree[_leftChildIndex(i)], tree[_rightChildIndex(i)]);

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
        returns (bytes32 root, bytes32[] memory proof, bool[] memory flags)
    {
        // generate a merkle tree from the data
        bytes32[] memory tree = getTree(leaves);

        // create a virtual tree
        VirtualTreeNode[] memory virtualTree = new VirtualTreeNode[](tree.length);

        // check if no indices to prove were passed, then just return the root
        if (leafIndicesToProve.length == 0) {
            proof = new bytes32[](1);
            proof[0] = tree[0];
            return (tree[0], proof, flags);
        }

        // convert leafIndicesToProve to align with the tree indices
        // tree indices will be reversed
        uint256[] memory treeIndicesToProve = new uint256[](leafIndicesToProve.length);
        for (uint256 i = 0; i < leafIndicesToProve.length; i++) {
            treeIndicesToProve[i] = tree.length - 1 - leafIndicesToProve[i];
        }

        uint256 flagTotal;
        uint256 proofTotal;

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
                    treeIndicesToProve[i] = _parentIndex(treeIndex);

                    continue;
                }

                // check to see if the sibling has turned on this node
                if (virtualTree[treeIndex].includeInProof) {
                    // if it has, then it means we have the full sibling pair that
                    // doesnt need to be included in the proof. So, we can set the
                    // false bool flag set by the sibling to true.
                    // flags[flagCounter - 1] = true;
                    virtualTree[_parentIndex(treeIndex)].children = Children.BOTH;

                    // set this node to false in the virtual tree so it is not
                    // included in the final proof
                    virtualTree[treeIndex].includeInProof = false;

                    // decrement proof counter because we removed a hash from the proof
                    proofTotal--;
                }
                // this node hasnt been turned on by its sibling yet,
                // so it hasnt appeared in the list of nodes to prove.
                else {
                    // So, we can make sure the sibling gets added to the proof
                    virtualTree[_siblingIndex(treeIndex)].includeInProof = true;

                    // now we make sure the flag array is false, because we need to include
                    // the sibling hash. This value can be overridden by the sibling
                    // if it is also included in the array of leaves to prove
                    // flags[flagCounter] = false;
                    virtualTree[_parentIndex(treeIndex)].children = Children.ONE;

                    // increment the flag counter since we used the index
                    flagTotal++;

                    // increment proof counter because we added a hash to the proof
                    proofTotal++;
                }

                // mark this node as processed
                virtualTree[treeIndex].processed = true;

                // convert the current index to the parent index
                treeIndicesToProve[i] = _parentIndex(treeIndex);
            }

            // remove duplicate parent indices
            treeIndicesToProve = treeIndicesToProve.removeSortedDuplicates();
        }

        // populate proof and flag arrays
        proof = new bytes32[](proofTotal);
        flags = new bool[](flagTotal);

        uint256 proofCounter;
        uint256 flagCounter;
        for (uint256 i = virtualTree.length - 1; i >= 0;) {
            // if there's a virtual tree entry, it means this hash is part of the proof
            if (virtualTree[i].includeInProof) {
                proof[proofCounter] = tree[i];

                proofCounter++;
            }

            // if the virtual tree has children in the proof, then mark it as true or false 
            // for whether the virtual tree has both or one child in the proof
            if (virtualTree[i].children != Children.IS_LEAF) {
                flags[flagCounter] = virtualTree[i].children == Children.BOTH;

                flagCounter++;
            }

            if (i == 0) {
                break;
            } else {
                i--;
            }
        }

        // fetch root from tree
        root = tree[0];
    }
}
