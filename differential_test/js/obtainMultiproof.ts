import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import * as fs from "fs";

// Load the tree from the description that was generated previously.
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", 'utf-8')));

// obtain the multiproof
const { proof, proofFlags, leaves } = tree.getMultiProof([6, 5, 4, 0]);
console.log("proof:", proof);
console.log("proof flags: ", proofFlags);
console.log("leaves:", leaves);