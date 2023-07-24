// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

 /// implementation taken from: 
 /// https://github.com/dmfxyz/murky/blob/1d9566b908b9702c45d354a1caabe8ef5a69938d/differential_testing/test/utils/Strings2.sol
library Strings {

    ///@dev converts bytes array to its ASCII hex string representation
    function toHexString(bytes memory input) public pure returns (string memory) {
        require(input.length < type(uint256).max / 2 - 1, "input is too long");
        bytes16 symbols = "0123456789abcdef";
        bytes memory hex_buffer = new bytes(2 * input.length + 2);
        hex_buffer[0] = "0";
        hex_buffer[1] = "x";

        uint pos = 2;
        uint256 length = input.length;
        for (uint i = 0; i < length; ++i) {
            uint _byte = uint8(input[i]);
            hex_buffer[pos++] = symbols[_byte >> 4];
            hex_buffer[pos++] = symbols[_byte & 0xf];
        }
        return string(hex_buffer);
    }
}