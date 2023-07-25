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

// randomly pick n leaf indices from the tree to prove
const numSamples = Math.floor(Math.random() * leaves.length)
let samples = new Set<number>();
for (let i = 0; i < numSamples; i++) {
    var r = Math.floor(Math.random() * leaves.length);
    samples.add(r)
}
let indicesToProve: number[] = Array.from(samples).sort((a: number, b: number) => a - b) as any

// generate the proof. Indices to prove need to be in reverse since they are added backwards to the merkle
// tree in the JS implementation
const { proof, proofFlags } = tree.getMultiProof(indicesToProve);

// convert indices to prove to allow the multiproof contract to 
// access the right leaves
const convertedIndices = indicesToProve.map(index => {
    const treeValues = tree.dump().values

    return (treeValues.length * 2 - 1) - 1 - treeValues[index].treeIndex
})

// encode the data to send back to forge
const encodedData = encodeAbiParameters(
    [
      { name: 'openZeppelinLeaves', type: 'bytes32[]'},
      { name: 'openZeppelinIndices', type: 'uint256[]'},
      { name: 'openZeppelinRoot', type: 'bytes32' },
      { name: 'openZeppelinProof', type: 'bytes32[]' },
      { name: 'openZeppelinFlags', type: 'bool[]' }
    ],
    [
        tree.dump().tree.slice(-leaves.length).reverse() as any,
        convertedIndices.sort((a: number, b: number) => a- b) as any,
        tree.root as any, 
        proof as any, 
        proofFlags
    ]
)

// write the proof array and flag array to stdout
process.stdout.write(encodedData)