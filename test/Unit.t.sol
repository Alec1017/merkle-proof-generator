// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import {Multiproof} from "src/Multiproof.sol";

contract TestUnit is Test {

    bytes32[] public leavesSeven;
    bytes32[] public leavesEight;

    function setUp() public {
        // create a merkle tree with 7 leaves
        leavesSeven = new bytes32[](7);
        leavesSeven[0] = keccak256(bytes.concat(keccak256(abi.encode("Peach"))));
        leavesSeven[1] = keccak256(bytes.concat(keccak256(abi.encode("Apple"))));
        leavesSeven[2] = keccak256(bytes.concat(keccak256(abi.encode("Kiwi"))));
        leavesSeven[3] = keccak256(bytes.concat(keccak256(abi.encode("Lemon"))));
        leavesSeven[4] = keccak256(bytes.concat(keccak256(abi.encode("Orange"))));
        leavesSeven[5] = keccak256(bytes.concat(keccak256(abi.encode("Banana"))));
        leavesSeven[6] = keccak256(bytes.concat(keccak256(abi.encode("Pineapple"))));

        // create a merkle tree with 8 leaves
        leavesEight = new bytes32[](8);
        leavesEight[0] = keccak256(bytes.concat(keccak256(abi.encode("Kumquat"))));
        leavesEight[1] = keccak256(bytes.concat(keccak256(abi.encode("Peach"))));
        leavesEight[2] = keccak256(bytes.concat(keccak256(abi.encode("Apple"))));
        leavesEight[3] = keccak256(bytes.concat(keccak256(abi.encode("Kiwi"))));
        leavesEight[4] = keccak256(bytes.concat(keccak256(abi.encode("Lemon"))));
        leavesEight[5] = keccak256(bytes.concat(keccak256(abi.encode("Orange"))));
        leavesEight[6] = keccak256(bytes.concat(keccak256(abi.encode("Banana"))));
        leavesEight[7] = keccak256(bytes.concat(keccak256(abi.encode("Pineapple"))));
    }

    function _assertProof(bytes32[] memory proof, bytes32[] memory openZeppelinProof) internal {
        // assert proof array has equal length as OZ
        assertEq(proof.length, openZeppelinProof.length);

        // assert proof values are correct
        for (uint256 i = 0; i < openZeppelinProof.length; i++) {
            assertEq(proof[i], openZeppelinProof[i]);
        }
    }

    function _assertFlags(bool[] memory flags, bool[] memory openZeppelinFlags) internal {
        // assert flag arrays have equal length as OZ
        assertEq(flags.length, openZeppelinFlags.length);

        // assert flag values are correct
        for (uint256 i = 0; i < openZeppelinFlags.length; i++) {
            assertEq(flags[i], openZeppelinFlags[i]);
        }
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_allSiblings_empty() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](0);

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](1);
        openZeppelinProof[0] = 0x9da8f0c1d6d8b85813911cddc46a2f705eae3a88f3ba3d8c9ab2bb24a4c24f9d;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](0);

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }    

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_allSiblings_one() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](1);
        leavesToProve[0] = 0; // peach

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](3);
        openZeppelinProof[0] = 0x8baea5474fbbe1b4229dff91b22179665864368d3a8da6163defafb406affd75;
        openZeppelinProof[1] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;
        openZeppelinProof[2] = 0x08a3e6b087f89c3235e28b17b1f6343c48ad297a273ec6dd3e979be45a84124c;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](3);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }
}