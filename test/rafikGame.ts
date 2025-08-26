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
    for (const player of [p2, p3, p4, p5, p6]) {
      await token.conect(p1).transfer(player.address, ethers.parseEther("20"));
      await token
        .connect(player)
        .approve(game.getAddress(), ethers.parseEther("20"));
    }
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
      it("should not allow player with insufficient balance to create game", async function () {
        const { p2, game } = await loadFixture(deployAll);
        await expect(
          game.connect(p2).createGameWithPrice(BASE_FEE.mul(100))
        ).to.be.revertedWith("INSUFFICIENT BALANCE");
      });

      it("should allow a player to create a game with BASE_FEE", async function () {
        const { p1, game } = await loadFixture(deployAll);
        const gameId = await game.connect(p1).createNewGame();
        expect(gameId).to.not.equal(0);
      });
      
    it("should not allow same player to join twice", async function () {
      const { p1, game } = await loadFixture(deployAll);
      const gameId = await game.connect(p1).createNewGame();
      await expect(game.connect(p1).joinGame(gameId)).to.be.revertedWith("ALREADY JOINED GAME");
    });

    it("should allow 4 unique players to join", async function () {
      const { p1, p2, p3, p4, game } = await loadFixture(deployAll);
      const gameId = await game.connect(p1).createNewGame();
      await game.connect(p2).joinGame(gameId);
      await game.connect(p3).joinGame(gameId);
      expect(await game.connect(p4).joinGame(gameId)).to.not.be.reverted;
    });

    it("should not allow 5th player to join", async function () {
      const { p1, p2, p3, p4, p5, game } = await loadFixture(deployAll);
      const gameId = await game.connect(p1).createNewGame();
      await game.connect(p2).joinGame(gameId);
      await game.connect(p3).joinGame(gameId);
      await game.connect(p4).joinGame(gameId);
      await expect(game.connect(p5).joinGame(gameId)).to.be.revertedWith("MAX PLAYERS REACHED");
    });

    it("tests 4 players with sufficient balance can join game", async function () {
      const { p1, p2, p3, p4, game, token } = await loadFixture(deployAll);
      const gameId = await game.connect(p1).createNewGame();
      await token.connect(p1).transfer(p2.address, ethers.parseEther("3"));
      await token.connect(p1).transfer(p3.address, ethers.parseEther("3"));
      await token.connect(p1).transfer(p4.address, ethers.parseEther("3"));
      await game.connect(p2).joinGame(gameId);
      await game.connect(p3).joinGame(gameId);
      expect(await game.connect(p4).joinGame(gameId)).to.not.be.reverted;
    });
  });

  });

  describe("Game Roll & Outcomes", function () {
    
  })
});
// test only 4 player can join a game
// test that when 4 players join game no one can join again
// test that if a players wins he is sent the pool prize
// test that when no one wins from the roll the contract owns the all the stakes
// test that a player wins and the his token increases
