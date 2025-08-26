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
        uint price;
    }

    mapping (uint => Game) private allGames;
    // mapping (address=> bool) playersActivity;

    uint private totalGameCounter = 1000;
    uint constant private BASE_FEE = 1000000000000000000; 

    function joinGame(uint gameId)external {
        Game storage game = allGames[gameId];
        require(game.players.length<4,"GAME PLAYERS COMPLETE");
        require(game.isActive,"Invalid Game Id Provided");
        require(!isInGame(msg.sender, game),"ALREADY JOINED GAME");
        require(gameToken.balanceOf(msg.sender)> game.price, "INSUFFICIENT BALANCE");
        gameToken.transferFrom(msg.sender, address(this),game.price);
        game.players.push(msg.sender);
    }

    function isInGame(address playerAddress, Game memory game) private pure returns (bool){
        uint index;
        for(;index<game.players.length;){
            if(game.players[index]== playerAddress) return true;
            index++;
        }
        return false;
    }

    function rollDice(uint gameId) public {
        uint roll = generator.getRandomNumber();
        Game storage game = allGames[gameId];
        require(game.isActive,"Invalid Gameid");
        game.roll = roll;
    }
    
    function createGameWithPrice(uint price)external returns(uint){
        require(gameToken.balanceOf(msg.sender) >= price ,"INSUFFICIENT BALANCE");
        require(gameToken.balanceOf(msg.sender)>= BASE_FEE,"PRICE IS LOWER THAN BASE FEE");
        totalGameCounter+=1;
        gameToken.transferFrom(msg.sender, address(this),price);
        Game storage game = allGames[totalGameCounter];
        game.gameId = totalGameCounter;
        game.isActive= true;
        game.players.push(msg.sender);
        game.price = price;
        return game.gameId;
    }

    function createNewGame()external returns(uint){
        require(gameToken.balanceOf(msg.sender) >= BASE_FEE,"INSUFFICIENT BALANCE");
        totalGameCounter+=1;
        gameToken.transferFrom(msg.sender, address(this),BASE_FEE);
        Game storage game = allGames[totalGameCounter];
        game.gameId = totalGameCounter;
        game.isActive= true;
        game.players.push(msg.sender);
        game.price = BASE_FEE;
        return game.gameId;
    }

    function getWinner(uint gameId)external returns(uint){
        Game storage game = allGames[gameId];
        require(game.isActive && game.players.length>3,"NO WINNER YET");
        rollDice(game.gameId);
        
        return game.roll;
    }
}
