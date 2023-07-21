// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import {Multiproof} from "src/Multiproof.sol";

contract TestRandom is Test {

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
    function test_size7_random_0() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](3);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 2; // kiwi 
        leavesToProve[2] = 5; // banana

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](4);
        openZeppelinProof[0] = 0x8baea5474fbbe1b4229dff91b22179665864368d3a8da6163defafb406affd75;
        openZeppelinProof[1] = 0xe3c0795f4340b8cb9aaacb0b84a5d46d57e263e6ee8e01d08c2dfe5be0d87d00;
        openZeppelinProof[2] = 0xe8e0064a49a1b6064455c7016b1ff3ce7f945d352584a7f2d1faacc0b777626d;
        openZeppelinProof[3] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }   

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_random_1() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](4);
        leavesToProve[0] = 1; // apple
        leavesToProve[1] = 2; // kiwi 
        leavesToProve[2] = 4; // orange
        leavesToProve[3] = 6; // pineapple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](3);
        openZeppelinProof[0] = 0x728a2eec54d3bf1754740947e515528302bb428999d773980dd7fd9870caef14;
        openZeppelinProof[1] = 0xe3c0795f4340b8cb9aaacb0b84a5d46d57e263e6ee8e01d08c2dfe5be0d87d00;
        openZeppelinProof[2] = 0xecb3feca3704b516b9ee4ba684d787cd989afc23f4d1162df12977c381d53e32;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = true;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }  

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_random_2() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](2);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 6; // pineapple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0x8baea5474fbbe1b4229dff91b22179665864368d3a8da6163defafb406affd75;
        openZeppelinProof[1] = 0x08a3e6b087f89c3235e28b17b1f6343c48ad297a273ec6dd3e979be45a84124c;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](3);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = false;

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }  

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_random_0() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](4);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 4; // lemon
        leavesToProve[2] = 5; // orange
        leavesToProve[3] = 6; // banana

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](3);
        openZeppelinProof[0] = 0x728a2eec54d3bf1754740947e515528302bb428999d773980dd7fd9870caef14;
        openZeppelinProof[1] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;
        openZeppelinProof[2] = 0x1ba09cccd47be6550a2f2fbaf04bab9de534f19830ef640d6b8ead593a73ba72;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }  

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_random_1() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](4);
        leavesToProve[0] = 1; // peach
        leavesToProve[1] = 2; // apple
        leavesToProve[2] = 3; // kiwi
        leavesToProve[3] = 7; // pineapple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](3);
        openZeppelinProof[0] = 0x12fd111d06d40d32bfcd18b4f5605ac3d9721c0cf5675c1f152c9e75f2bb6140;
        openZeppelinProof[1] = 0xecb3feca3704b516b9ee4ba684d787cd989afc23f4d1162df12977c381d53e32;
        openZeppelinProof[2] = 0xe8e260f33ff659c5d728517bca82ff5dda2d14cc449023412e851c393b29f143;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = true;
        openZeppelinFlags[4] = false;
        openZeppelinFlags[5] = true;

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }  

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_random_2() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](2);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 7; // pineapple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](4);
        openZeppelinProof[0] = 0x728a2eec54d3bf1754740947e515528302bb428999d773980dd7fd9870caef14;
        openZeppelinProof[1] = 0xecb3feca3704b516b9ee4ba684d787cd989afc23f4d1162df12977c381d53e32;
        openZeppelinProof[2] = 0x1ba09cccd47be6550a2f2fbaf04bab9de534f19830ef640d6b8ead593a73ba72;
        openZeppelinProof[3] = 0xe8e260f33ff659c5d728517bca82ff5dda2d14cc449023412e851c393b29f143;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](5);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;

        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    } 
}