// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

contract testDifferential is Test {

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

    function testTrue() public {
        assertTrue(true);
    }
}