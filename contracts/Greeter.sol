// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


contract Greet {
    string public text;
    event Withdrawal(uint amount, uint when);
    
    function setText(string memory argsText) public {
        text = argsText;
    }
    function getText() public view returns (string memory) {
        return text;
    }
}
