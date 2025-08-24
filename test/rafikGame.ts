import hre, { ethers } from "hardhat";
import { expect } from "chai";


describe("rafik game test suite", function () {
    var RafikGame, game, RafikToken, token, Generator, generator;
    var p1, p2, p3, p4, p5, p6;
    const BASE_FEE = ethers.parseEther("1");
     async function deployAll() { 
        Generator = await ethers.getContractFactory("TestGenerator");
        generator = await Generator.deploy();
        RafikToken = await ethers.getContractFactory("Rafikk",);
        token = await RafikToken.deploy();
        RafikGame = await ethers.getContractFactory("RafikGame", generator.address, token.address );
        game = await RafikGame.deploy();
        [p1, p2, p3, p4, p5, p6] = await ethers.getSigners();
        return (p1, p2, p3, p4, p5, p6, game)
    }
    describe("player game entrance", function () {
        it("tests 4 players can join a game", async function () { 
            (p1, p2, p3, p4, p5, game) = await hre.loadFixture(deployAll);
            await game.connect(p1).joinGame();
        })
     })


})

