// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRafikGenerator} from "./IRafikGenerator.sol";

contract RafikGame {
    IRafikGenerator public generator;
    IERC20 private gameToken;
    address private admin ;
    uint private totalGameCounter = 1000;
    uint constant private BASE_FEE = 1000000000000000000; 
    mapping (uint => Game) private allGames;

    constructor(address generatorAddress, address gameTokenAddress) {
        generator = IRafikGenerator(generatorAddress);
        gameToken = IERC20(gameTokenAddress);
        admin= msg.sender;
    }

    struct Game{
        uint gameId;
        bool isActive;
        Player[] players;
        uint roll;
        uint price;
        bool isRolled;
    }

    struct Player{
        address playerAddress;
        uint roll;
    }

    modifier onlyOwner (){
        require(admin == msg.sender, "UNAUTHORISED");
        _;
    }

    modifier rollRange (uint roll){
        require(roll > 0 && roll < 7, "INVALID DICE FACE");
        _;
    }

    function joinGame(uint gameId,uint roll) rollRange(roll) external {
        Game storage game = allGames[gameId];
        require(game.players.length<4,"GAME PLAYERS COMPLETE");
        require(game.isActive,"Invalid Game Id Provided");
        require(!isInGame(msg.sender, game),"ALREADY JOINED GAME");
        require(gameToken.balanceOf(msg.sender)> game.price, "INSUFFICIENT BALANCE");
        gameToken.transferFrom(msg.sender, address(this),game.price);
        game.players.push(Player(msg.sender,roll));
    }

    function isInGame(address playerAddress, Game memory game) private pure returns (bool){
        uint index;
        for(;index<game.players.length;){
            if(game.players[index].playerAddress == playerAddress) return true;
            index++;
        }
        return false;
    }
    
    function rollDice(uint gameId) public onlyOwner {
        Game storage game = allGames[gameId];
        require(!game.isRolled,"WINNER ALREADY ATTAINED");
        require(game.isActive,"Invalid Gameid");
        uint roll = generator.getRandomNumber();
        game.roll = roll;
        game.isRolled = true;
    }
    
    function createGameWithPrice(uint price,uint roll) rollRange(roll) external returns(uint){
        require(gameToken.balanceOf(msg.sender) >= price ,"INSUFFICIENT BALANCE");
        require(gameToken.balanceOf(msg.sender)>= BASE_FEE,"PRICE IS LOWER THAN BASE FEE");
        totalGameCounter+=1;
        gameToken.transferFrom(msg.sender, address(this),price);
        Game storage game = allGames[totalGameCounter];
        game.gameId = totalGameCounter;
        game.isActive= true;
        game.players.push(Player(msg.sender,roll));
        game.price = price;
        emit GameCreated(msg.sender, game.gameId, block.timestamp );
        return game.gameId;
    }


    function createNewGame(uint roll) rollRange(roll) external returns(uint){
        require(gameToken.balanceOf(msg.sender) >= BASE_FEE,"INSUFFICIENT BALANCE");
        totalGameCounter+=1;
        gameToken.transferFrom(msg.sender, address(this),BASE_FEE);
        Game storage game = allGames[totalGameCounter];
        game.gameId = totalGameCounter;
        game.isActive= true;
        game.players.push(Player(msg.sender,roll));
        game.price = BASE_FEE;
        emit GameCreated(msg.sender, game.gameId, block.timestamp );
        return game.gameId;
    }


    function getWinner(uint gameId) onlyOwner external returns(address){
        Game storage game = allGames[gameId];
        require(game.isRolled,"NO WINNER YET");
        require(game.isActive, "GAME NOT ACTIVE");
        rollDice(game.gameId);
        emit DiceRolled(gameId,block.timestamp);
        address winner;
        for(uint count; count< game.players.length; count++){
            if(game.players[count].roll-1 == game.roll){
                winner = game.players[count].playerAddress;
                emit GameWinner(game.players[count].playerAddress, game.gameId, block.timestamp);
                return winner;
            }
        }
        return winner;
    }

    receive()payable external{}

    fallback()external{}

    function withdraw()external payable{
        require(admin== msg.sender,"UNAUTHORISED");
        gameToken.transfer(msg.sender, gameToken.balanceOf(address(this)));
        (bool isSuccessful, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(isSuccessful,"eth withdrawal failed");
        emit Withdrawal(block.timestamp);
    }
    
    event RandomRequested(address indexed player, uint256 requestId);
    event RandomResolved(uint256 indexed timeStamp,uint randomValues);
    event GameCreated(address indexed creator, uint gameId, uint timeCreated);
    event DiceRolled(uint indexed gameId, uint timeStamp);
    event GameWinner(address indexed winner, uint indexed gameId, uint timeStamp);
    event Withdrawal(uint withdrawalTime);

}
