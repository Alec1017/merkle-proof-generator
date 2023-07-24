import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import * as fs from "fs";

// Load the tree from the description that was generated previously.
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", 'utf-8')));

// Loop through the entries to find the one you're interested in.
for (const [i, v] of tree.entries()) {
  if (v[0] === 'Kiwi') {
    
    // Generate the proof using the index of the entry.
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}
