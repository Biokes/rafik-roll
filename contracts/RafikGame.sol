// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRafikGenerator} from "./IRafikGenerator.sol";

contract RafikGame {
    IRafikGenerator public generator;
    IERC20 private gameToken;

    event RandomRequested(address indexed player, uint256 requestId);
    event RandomResolved(uint256 indexed timeStamp,uint randomValues);

    constructor(address generatorAddress, address gameTokenAddress) {
        generator = IRafikGenerator(generatorAddress);
        gameToken = IERC20(gameTokenAddress);
    }

    struct Game{
        uint gameId;
        bool isActive;
        address[] players;
        uint roll;
    }

    mapping (uint => Game) private allGames;
    mapping (address=> bool) playersActivity;

    uint private totalGameCounter;
    uint constant private BASE_FEE = 1000000000000000000; 

    function joinGame(uint gameId)external {
        Game memory game = allGames[gameId];
        require(game.isActive,"Invalid Game Id Provided");
        // require(!playersActivity[msg.sender], "ALready in a game");
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
        uint roll = generator.getRandomNumber();
        Game storage game = allGames[gameId];
        require(game.isActive,"Invalid Gameid");
        game.roll = roll;
    }
    
    function createGameWithPrice(uint price)external returns(uint){
        require(!playersActivity[msg.sender],"DOUBLE ENTRY IS NOT ALLOWED");
        require(gameToken.balanceOf(msg.sender) >= price ,"Insufficient balance to join game");
        require(gameToken.balanceOf(msg.sender)>= BASE_FEE,"Customed price must be greter than BASE FEE");
        totalGameCounter+=1;
        Game storage game = allGames[totalGameCounter];
        game.gameId = totalGameCounter;
        game.isActive= true;
        game.players.push(msg.sender);
        return game.gameId;
    }
}
// test only 4 player can join game
// test that when 4 players join game no one can join again
// test that if a player selects a roll anither player cannit select roll 
// test that if a players wins he is sent the pool prize
// test that when no one wins from the roll the contract owns the all the stakes