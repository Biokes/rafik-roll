// SPDX-License-Identifier : MIT
pragma solidity ^0.8.30;

interface IRafikGenerator {
    function getRandomNumber() external returns(uint numberGenerated);
}