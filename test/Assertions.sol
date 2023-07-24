// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MerkleProof} from "openzeppelin/utils/cryptography/MerkleProof.sol";

import {Multiproof} from "src/Multiproof.sol";

contract Assertions is Test {
    event log_named_array(string key, bytes32[] val);
    event log_named_array(string key, bool[] val);

    function assertEq(bytes32[] memory a, bytes32[] memory b) internal virtual {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log("Error: a == b not satisfied [bytes32[]]");
            emit log_named_array("      Left", a);
            emit log_named_array("     Right", b);
            fail();
        }
    }

    function assertEq(bool[] memory a, bool[] memory b) internal virtual {
        if (keccak256(abi.encode(a)) != keccak256(abi.encode(b))) {
            emit log("Error: a == b not satisfied [bool[]]");
            emit log_named_array("      Left", a);
            emit log_named_array("     Right", b);
            fail();
        }
    }

    function assertMultiproofVerify(
        bytes32[] memory data, 
        uint256[] memory leafIndicesToProve,
        bytes32[] memory openZeppelinProof,
        bool[] memory openZeppelinFlags
    ) internal {
        // convert leaf indices to prove to the expected leaves to prove array
        bytes32[] memory leavesToProve = new bytes32[](leafIndicesToProve.length);
        for (uint256 i = 0; i < leavesToProve.length; i++) {
            leavesToProve[i] = data[leafIndicesToProve[i]];
        }

        // generate the multiproof
        (bytes32 root, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(data, leafIndicesToProve);


        // verify the multiproof
        bool isVerified = MerkleProof.multiProofVerify(
            proof,
            flags,
            root,
            leavesToProve
        );

        // assert proofs and flags are equal
        assertEq(proof, openZeppelinProof);
        assertEq(flags, openZeppelinFlags);

        // assert the multiproof can be verified by Open Zeppelin
        assertTrue(isVerified, "Multiproof verification was not valid");
    }
}
