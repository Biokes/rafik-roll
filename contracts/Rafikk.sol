// SPDX-License-Identifier : MIT
pragma solidity ^0.8.30;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract Rafikk is ERC20{
    constructor() ERC20("Rafikk","RFK"){
        _mint(msg.sender, 5_000_000_000_000_000_000_000_000);
    }
}