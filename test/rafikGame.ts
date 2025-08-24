import hre, { ethers } from "hardhat";
import { expect } from "chai";


describe("rafik game test suite", function () {
    var RafikGame, game, RafikToken, token, Generator, generator;
    var p1, p2, p3, p4, p5, p6;
    const BASE_FEE = ethers.parseEther("1");
    const deployAll = async function () { 
        RafikToken = await ethers.getContractFactory("Rafikk");
        token = await RafikToken.deploy()
        Generator = await ethers.getContractFactory("RafikGenerator");
        generator = await Generator.deploy();

    }
    describe("player game entrance", function () {
        
        it("tests 4 players can join a game", async function () { 
            
        })
     })


})