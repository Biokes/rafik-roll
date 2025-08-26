// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IRafikGenerator} from "./RafikGenerator.sol";

contract TestGenerator is IRafikGenerator {
    uint256 private nonce;

    function getRandomNumber() external returns (uint) {
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender,
                    nonce
                )
            )
        );
        nonce++;

        return random % 6;
    }
  
}
