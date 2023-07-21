// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";
import {Multiproof} from "src/Multiproof.sol";

contract TestMultiproof is Test {

    bytes32[] public data;

    function setUp() public {
        data = new bytes32[](8);

        data[0] = keccak256(bytes.concat(keccak256(abi.encode("Kumquat"))));
        data[1] = keccak256(bytes.concat(keccak256(abi.encode("Peach"))));
        data[2] = keccak256(bytes.concat(keccak256(abi.encode("Apple"))));
        data[3] = keccak256(bytes.concat(keccak256(abi.encode("Kiwi"))));
        data[4] = keccak256(bytes.concat(keccak256(abi.encode("Lemon"))));
        data[5] = keccak256(bytes.concat(keccak256(abi.encode("Orange"))));
        data[6] = keccak256(bytes.concat(keccak256(abi.encode("Banana"))));
        data[7] = keccak256(bytes.concat(keccak256(abi.encode("Pineapple"))));
    }

    function testMerkleProof() public {
        assertEq(Multiproof.getRoot(data), 0x4c5abaa82239ce47415214c5238011c87ec997ecf0702d453df977be70efbbd6);
    }

    function testMerkleMultiProof() public {

        uint256[] memory leafIndexesToProve = new uint256[](4);
        leafIndexesToProve[0] = 1;
        leafIndexesToProve[1] = 2;
        leafIndexesToProve[2] = 4;
        leafIndexesToProve[3] = 6;

        bytes32[] memory leavesToProve = new bytes32[](4);
        leavesToProve[0] = data[1];
        leavesToProve[1] = data[2];
        leavesToProve[2] = data[4];
        leavesToProve[3] = data[6];

        (bytes32 root, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(data, leafIndexesToProve);

        // console2.log("proof:");
        // for (uint256 i = 0; i < proof.length; i++) {
        //     console2.logBytes32(proof[i]);
        // }

        // console2.log("flags:");
        // for (uint256 i = 0; i < flags.length; i++) {
        //     console2.log(flags[i]);
        // }

        bool isVerified = MerkleProof.multiProofVerify(
            proof,
            flags,
            root,
            leavesToProve
        );

        assertTrue(isVerified);
    }
}