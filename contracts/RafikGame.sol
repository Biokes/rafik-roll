// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRafikGenerator} from "./IRafikGenerator.sol";

contract RafikGame {
    IRafikGenerator public generator;
    IERC20 private gameToken;

    event RandomRequested(address indexed player, uint256 requestId);
    event RandomResolved(uint256 indexed timeStamp,uint randomValues);

    constructor(address generatorAddress) {
        generator = IRafikGenerator(generatorAddress);
        gameToken = IERC20(gameToken);
    }

    function generateRandomumber() public returns(uint){
        uint256 requestID = generator.requestRandomWords(true);
        (bool fulfilled, uint256[] memory words) = generator.getRequestStatus(requestID);
        require(fulfilled, "number generation failed and is not fulfilled yet");
        uint random = words.length > 0 ? words[0] : 0;
        emit RandomResolved(block.timestamp, random); 
        return random%6;
    }
    struct Game{
        uint gameId;
        bool isActive;
        address[] players;
        uint roll;
    }
    mapping (uint => Game) private allGames;
    uint constant private BASE_FEE = 1000000000000000000; 

    function joinGame(uint gameId)external {
        Game memory game = allGames[gameId];
        require(game.isActive,"Invalid Game Id Provided");
        require(!isInGame(msg.sender, game),"Already in this game");
        require(gameToken.balanceOf(msg.sender)> BASE_FEE, "Insufficient balance to join game");
        gameToken.approve(address(this), BASE_FEE);
        gameToken.transferFrom(msg.sender, address(this),BASE_FEE);
    }

    function isInGame(address playerAddress, Game memory game) private pure returns (bool){
        uint index;
        for(;index<game.players.length;){
            if(game.players[index]== playerAddress) return true;
            index++;
        }
        return false;
    }
    
    function rollDice(uint gameId) external {
        uint roll = generateRandomumber();
        Game storage game = allGames[gameId];
        require(game.isActive,"Invalid Gameid");
        game.roll = roll;
    }
}
