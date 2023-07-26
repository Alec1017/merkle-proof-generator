// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {log2, floor} from "prb-math/ud60x18/Math.sol";
import {convert} from "prb-math/ud60x18/Conversions.sol";

library Multiproof {

    enum Children {
        IS_LEAF,
        ONE,
        BOTH
    }

    struct MerkleTreeNode {
        // determines whether to include this node in the multiproof
        bool includeInProof;
        // determines how many children this node has (if any).
        // This value will be used to compute the bool flags
        Children children;
        // hash of the data
        bytes32 dataHash;
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

    function _getTree(bytes32[] memory leaves) private pure returns (bytes32[] memory tree) {
        require(leaves.length > 0, "cannot build tree with 0 leaves");

        // create a merkle tree placeholder array
        tree = new bytes32[](2 * leaves.length - 1);

        // place all leaves into the tree
        for (uint256 i = 0; i < leaves.length; i++) {
            tree[tree.length - 1 - i] = leaves[i];
        }

        // a single leaf becomes the root
        if (tree.length == 1) {
            return tree;
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
        bytes32[] memory tree = _getTree(leaves);

        root = tree[0];
    }

    function getProof(bytes32[] memory leaves, uint256 indexToProve) 
        internal 
        pure 
        returns (bytes32 root, bytes32[] memory proof) 
    {
        require(indexToProve < leaves.length, "invalid index to prove");

        // create a merkle tree
        bytes32[] memory tree = _getTree(leaves);

        // Convert the index to prove to its corresponding index in the tree
        indexToProve = tree.length - 1 - indexToProve;

        // proof length is the floor of log2(indexToProve + 1)
        proof = new bytes32[](convert(floor(log2(convert(indexToProve + 1)))));
        uint256 proofCounter;

        // add each sibling to the proof, then prove the parent node
        while (indexToProve > 0) {
            // include the sibling in the proof
            proof[proofCounter] = tree[_siblingIndex(indexToProve)];

            // the next index to prove becomes the parent node
            indexToProve = _parentIndex(indexToProve);

            // increment the proof counter
            proofCounter++;
        }

        // fetch root from tree
        root = tree[0];
    }

    function getMultiproof(bytes32[] memory leaves, uint256[] memory leafIndicesToProve)
        internal
        pure
        returns (bytes32 root, bytes32[] memory proof, bool[] memory flags)
    {
        require(leaves.length > 0, "cannot build tree with 0 leaves");

        // create a merkle tree
        MerkleTreeNode[] memory tree = new MerkleTreeNode[](2 * leaves.length - 1);

        // create a static queue which will hold the nodes awaiting to be processed in the multiproof
        uint256[] memory staticQueue = new uint256[](leafIndicesToProve.length);

        // load up the static queue with the indices of the nodes to prove, converted
        // to their corresponding indices in the tree
        for (uint256 i = 0; i < leafIndicesToProve.length; i++) {
            staticQueue[i] = tree.length - 1 - leafIndicesToProve[i];
        }

        // define operation pointers for the static queue
        uint256 pop;
        uint256 push;

        // track how large the resulting proof array and flag array will be
        uint256 flagTotal;
        uint256 proofTotal;

        // start from the bottom of the tree, and build up the parent nodes to the root
        for (uint256 i = tree.length - 1; i >= 0;) {
            // if the node is a leaf, then add the hash to the tree
            if (i + 1 > tree.length - leaves.length) {
                tree[i].dataHash = leaves[tree.length - 1 - i];
            } 
            // otherwise, it has 2 children so we should calculate the hash
            else {
                // the parent is the hash of the left child and the right child
                tree[i].dataHash = _hashLeafPairs(tree[_leftChildIndex(i)].dataHash, tree[_rightChildIndex(i)].dataHash);
            }

            // check that the queue has elements waiting to be processed
            if (staticQueue.length != 0 && staticQueue[pop] != 0) {
                // pop an item off the stack to determine inclusion in the multiproof
                uint256 treeIndex = staticQueue[pop++];

                // check to see if the sibling has included this node in the proof
                if (tree[treeIndex].includeInProof) {
                    // if it has, then it means we have the full sibling pair available.
                    // this will change the bool flag array value from false to true
                    tree[_parentIndex(treeIndex)].children = Children.BOTH;

                    // make sure this node is not included in the proof
                    tree[treeIndex].includeInProof = false;

                    // decrement proof counter because we removed a hash from the proof
                    proofTotal--;
                }
                // this node hasnt been included by its sibling yet,
                // so it hasnt appeared in the list of nodes to prove
                else {
                    // So, we can make sure the sibling gets added to the proof
                    tree[_siblingIndex(treeIndex)].includeInProof = true;

                    // mark that the parent node has one sibling included in the proof. 
                    // This can be overridden to Children.BOTH if the sibling node
                    // appears later in the indicesTOProve array
                    tree[_parentIndex(treeIndex)].children = Children.ONE;

                    // push the parent node to the queue for processing
                    staticQueue[push++] = _parentIndex(treeIndex);

                    // increment the totals because we added a hash to the proof
                    proofTotal++;
                    flagTotal++;
                }

                // perform a modulus operation on the queue pointers. This enables the pointers
                // to continuously wrap around the static queue.
                pop = pop % staticQueue.length;
                push = push % staticQueue.length;
            }

            // an underflow error is hit on the final iteration. This check avoids the final decrement.
            if (i == 0) {
                break;
            } else {
                i--;
            }
        }

        // fetch root from tree
        root = tree[0].dataHash;

        // check if no indices to prove were given
        if (leafIndicesToProve.length == 0) {
            proof = new bytes32[](1);
            proof[0] = tree[0].dataHash;
        } 
        // otherwise, we need to process the tree to build up the proof and flags arrays
        else {
            // populate proof and flag arrays
            proof = new bytes32[](proofTotal);
            flags = new bool[](flagTotal);

            // counters for tracking the indices of the proof and flags arrays
            uint256 proofCounter;
            uint256 flagCounter;

            // start the iteration from the first leaf node that was processed
            for (uint256 i = tree.length - 1; i >= 0;) {
                // include the hash in the proof it it was marked
                if (tree[i].includeInProof) {
                    proof[proofCounter] = tree[i].dataHash;

                    proofCounter++;
                }

                // if the node has children in the proof, then mark it as true or false 
                // depending on whether the node has both or one child in the proof
                if (tree[i].children != Children.IS_LEAF) {
                    flags[flagCounter] = tree[i].children == Children.BOTH;

                    flagCounter++;
                }

                if (i == 0) {
                    break;
                } else {
                    i--;
                }
            }
        }
    }
}
