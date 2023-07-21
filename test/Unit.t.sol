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
    function test_size7_sequential_0() public {
        
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
    function test_size7_sequential_1() public {
        
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

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_sequential_2() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](2);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 1; // apple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;
        openZeppelinProof[1] = 0x08a3e6b087f89c3235e28b17b1f6343c48ad297a273ec6dd3e979be45a84124c;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](3);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_sequential_3() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](3);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 1; // apple
        leavesToProve[2] = 2; // kiwi

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](3);
        openZeppelinProof[0] = 0xe3c0795f4340b8cb9aaacb0b84a5d46d57e263e6ee8e01d08c2dfe5be0d87d00;
        openZeppelinProof[1] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;
        openZeppelinProof[2] = 0x242558898141bf96749cfa64bca4ed4e75e5149371d780acead36b1c7cfb31cc;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](5);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_sequential_4() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](4);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 1; // apple
        leavesToProve[2] = 2; // kiwi
        leavesToProve[3] = 3; // lemon

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;
        openZeppelinProof[1] = 0x242558898141bf96749cfa64bca4ed4e75e5149371d780acead36b1c7cfb31cc;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](5);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = false;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_sequential_5() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](5);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 1; // apple
        leavesToProve[2] = 2; // kiwi
        leavesToProve[3] = 3; // lemon
        leavesToProve[4] = 4; // orange

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0xecb3feca3704b516b9ee4ba684d787cd989afc23f4d1162df12977c381d53e32;
        openZeppelinProof[1] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = true;
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
    function test_size7_sequential_6() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](6);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 1; // apple
        leavesToProve[2] = 2; // kiwi
        leavesToProve[3] = 3; // lemon
        leavesToProve[4] = 4; // orange
        leavesToProve[5] = 5; // banana

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](1);
        openZeppelinProof[0] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size7_sequential_7() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](7);
        leavesToProve[0] = 0; // peach
        leavesToProve[1] = 1; // apple
        leavesToProve[2] = 2; // kiwi
        leavesToProve[3] = 3; // lemon
        leavesToProve[4] = 4; // orange
        leavesToProve[5] = 5; // banana
        leavesToProve[6] = 6; // pineapple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesSeven, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](0);

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = true;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_0() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](0);

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](1);
        openZeppelinProof[0] = 0x4c5abaa82239ce47415214c5238011c87ec997ecf0702d453df977be70efbbd6;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](0);
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_1() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](1);
        leavesToProve[0] = 0; // kumquat

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](3);
        openZeppelinProof[0] = 0x728a2eec54d3bf1754740947e515528302bb428999d773980dd7fd9870caef14;
        openZeppelinProof[1] = 0x1ba09cccd47be6550a2f2fbaf04bab9de534f19830ef640d6b8ead593a73ba72;
        openZeppelinProof[2] = 0x2a57f0f80f87fb667c4ac5be7d24bb42205fb5c6c6225535ba2cb2eac488e7f0;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](3);
        openZeppelinFlags[0] = false;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_2() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](2);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0x1ba09cccd47be6550a2f2fbaf04bab9de534f19830ef640d6b8ead593a73ba72;
        openZeppelinProof[1] = 0x2a57f0f80f87fb667c4ac5be7d24bb42205fb5c6c6225535ba2cb2eac488e7f0;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](3);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = false;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_3() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](3);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach
        leavesToProve[2] = 2; // apple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0xd7aba628dff65b7e6d2afd0d3c494fedf8c2a0336d8c4efad140c16038d886a2;
        openZeppelinProof[1] = 0x2a57f0f80f87fb667c4ac5be7d24bb42205fb5c6c6225535ba2cb2eac488e7f0;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](4);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = false;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = false;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_4() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](4);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach
        leavesToProve[2] = 2; // apple
        leavesToProve[3] = 3; // kiwi

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](1);
        openZeppelinProof[0] = 0x2a57f0f80f87fb667c4ac5be7d24bb42205fb5c6c6225535ba2cb2eac488e7f0;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](4);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = false;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_5() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](5);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach
        leavesToProve[2] = 2; // apple
        leavesToProve[3] = 3; // kiwi
        leavesToProve[4] = 4; // lemon

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](2);
        openZeppelinProof[0] = 0xe8e0064a49a1b6064455c7016b1ff3ce7f945d352584a7f2d1faacc0b777626d;
        openZeppelinProof[1] = 0xe0682f6a7668708b4c95c44f384dbe1c846f91115c7b379f279bc695ad39722c;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = true;
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
    function test_size8_sequential_6() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](6);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach
        leavesToProve[2] = 2; // apple
        leavesToProve[3] = 3; // kiwi
        leavesToProve[4] = 4; // lemon
        leavesToProve[5] = 5; // orange

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](1);
        openZeppelinProof[0] = 0xe0682f6a7668708b4c95c44f384dbe1c846f91115c7b379f279bc695ad39722c;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](6);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = true;
        openZeppelinFlags[4] = false;
        openZeppelinFlags[5] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_7() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](7);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach
        leavesToProve[2] = 2; // apple
        leavesToProve[3] = 3; // kiwi
        leavesToProve[4] = 4; // lemon
        leavesToProve[5] = 5; // orange
        leavesToProve[6] = 6; // banana

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](1);
        openZeppelinProof[0] = 0xf07ce44ac19ae4e371cbb0a575c6a1f14f469bc11e66ee0d7965fb09c7397725;

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](7);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = false;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;
        openZeppelinFlags[6] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }

    // solhint-disable-next-line func-name-mixedcase
    function test_size8_sequential_8() public {
        
        // build up the leaves to prove 
        uint256[] memory leavesToProve = new uint256[](8);
        leavesToProve[0] = 0; // kumquat
        leavesToProve[1] = 1; // peach
        leavesToProve[2] = 2; // apple
        leavesToProve[3] = 3; // kiwi
        leavesToProve[4] = 4; // lemon
        leavesToProve[5] = 5; // orange
        leavesToProve[6] = 6; // banana
        leavesToProve[7] = 7; // pineapple

        // generate the multiproof
        (, bytes32[] memory proof, bool[] memory flags) = Multiproof.getMultiproof(leavesEight, leavesToProve);

        // the expected proof from OpenZeppelin
        bytes32[] memory openZeppelinProof = new bytes32[](0);

        // the expected flags from OpenZeppelin
        bool[] memory openZeppelinFlags = new bool[](7);
        openZeppelinFlags[0] = true;
        openZeppelinFlags[1] = true;
        openZeppelinFlags[2] = true;
        openZeppelinFlags[3] = true;
        openZeppelinFlags[4] = true;
        openZeppelinFlags[5] = true;
        openZeppelinFlags[6] = true;
        
        // assert proofs and flags are equal
        _assertProof(proof, openZeppelinProof);
        _assertFlags(flags, openZeppelinFlags);
    }
}