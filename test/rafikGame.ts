import hre, { ethers } from "hardhat";
import { expect } from "chai";

import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("rafik game test suite", function () {
  let RafikGame, RafikToken, Generator;
  const BASE_FEE = ethers.parseEther("1");

  async function deployAll() {
    const [p1, p2, p3, p4, p5, p6] = await ethers.getSigners();
    Generator = await ethers.getContractFactory("TestGenerator");
    const generator = await Generator.connect(p1).deploy();
    RafikToken = await ethers.getContractFactory("Rafikk");
    const token = await RafikToken.connect(p1).deploy();
    RafikGame = await ethers.getContractFactory("RafikGame");
    const game = await RafikGame.connect(p1).deploy(
      generator.getAddress(),
      token.getAddress()
    );
    return { p1, p2, p3, p4, p5, p6, game, token, generator };
  }

  describe("player joining creates game", function () {
    it("tests insufficient balance cannot join game", async function () {
      const { p1, p2, game } = await loadFixture(deployAll);
      await game.connect(p1).createGameWithPrice(ethers.parseEther("1.2"));
      await expect(game.connect(p2).joinGame(1001)).to.be.revertedWith(
        "INSUFFICIENT BALANCE"
      );
    });

    it("tests a player cannot join twice", async function () {
      const { p1, game } = await loadFixture(deployAll);
      await game.connect(p1).createGameWithPrice(ethers.parseEther("1.2"));
      await expect(game.connect(p1).joinGame(1001)).to.be.revertedWith(
        "ALREADY JOINED GAME"
      );
    });

    it("tests 4 players with sufficient balance can join game", async function () {
      const { p1, p2, p3, p4, game, token } = await loadFixture(deployAll);
      const gameId = await game.connect(p1).createNewGame();
      await token.connect(p1).transfer(p2.address, ethers.parseEther("3"));
      await token.connect(p1).transfer(p3.address, ethers.parseEther("3"));
      await token.connect(p1).transfer(p4.address, ethers.parseEther("3"));
      await game.connect(p2).joinGame(gameId);
      await game.connect(p3).joinGame(gameId);
      await game.connect(p4).joinGame(gameId);
    });
  });
});
// test only 4 player can join game 
// test that when 4 players join game no one can join again
// test that if a player selects a roll anither player cannit select roll 
// test that if a players wins he is sent the pool prize
// test that when no one wins from the roll the contract owns the all the stakes