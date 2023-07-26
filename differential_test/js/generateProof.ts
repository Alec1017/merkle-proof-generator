import { StandardMerkleTree } from "@openzeppelin/merkle-tree"
import { decodeAbiParameters, encodeAbiParameters } from 'viem'

const encodedLeaves = process.argv[2];

// decode the leaves for the merkle tree
const leaves: string[] = decodeAbiParameters(
    [{ name: 'leaves', type: 'bytes32[]' }],
    encodedLeaves as any
)[0].slice()

// Build the merkle tree. Set the encoding to match the values.
const tree = StandardMerkleTree.of(leaves.map(leaf => [leaf]), ["bytes32"]);

// get a random index to prove
const indexToProve = Math.floor(Math.random() * leaves.length);

// generate the proof. Indices to prove need to be in reverse since they are added backwards to the merkle
// tree in the JS implementation
const proof = tree.getProof(indexToProve)

// convert indices to prove to allow the multiproof contract to 
// access the right leaves
const convertedIndex = (tree.dump().values.length * 2 - 1) - 1 - tree.dump().values[indexToProve].treeIndex

// encode the data to send back to forge
const encodedData = encodeAbiParameters(
    [
      { name: 'openZeppelinLeaves', type: 'bytes32[]'},
      { name: 'openZeppelinIndexToProve', type: 'uint256'},
      { name: 'openZeppelinRoot', type: 'bytes32' },
      { name: 'openZeppelinProof', type: 'bytes32[]' },
    ],
    [
        tree.dump().tree.slice(-leaves.length).reverse() as any,
        convertedIndex as any,
        tree.root as any, 
        proof as any
    ]
)

// write the proof array and flag array to stdout
process.stdout.write(encodedData)