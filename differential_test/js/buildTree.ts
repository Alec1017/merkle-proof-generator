import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// Get the values to include in the tree. (Note: Consider reading them from a file.)
const values = [
  ["Pineapple"],  // 0
  ["Banana"],     // 1
  ["Orange"],     // 2
  ["Lemon"],      // 3
  ["Kiwi"],       // 4
  ["Apple"],      // 5 
  ["Peach"],      // 6
  // ["Kumquat"],    // 7
];

// Build the merkle tree. Set the encoding to match the values.
const tree = StandardMerkleTree.of(values, ["string"]);

// Print the merkle root. You will probably publish this value on chain in a smart contract.
console.log('Merkle Root:', tree.root);

// Write a file that describes the tree. You will distribute this to users so they can generate proofs for values in the tree.
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
