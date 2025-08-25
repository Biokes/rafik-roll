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
        const game = await RafikGame.connect(p1).deploy(generator.address, token.address);
        return { p1, p2, p3, p4, p5, p6, game, token, generator };
    }

    describe("player joining creates game", function () {
        it("tests insufficient balance cannot join game", async function () {
            const { p1, p2, game } = await loadFixture(deployAll);
            const gameId = await game.connect(p1).createGameWithPrice(BASE_FEE * 2n);
            await expect(game.connect(p2).joinGame(gameId))
                .to.be.revertedWithCustomError(game, "INSUFFICIENT_BALANCE");
        });

        it("tests 4 players with sufficient balance can join game", async function () {
            const { p1, p2, p3, p4, game, token } = await loadFixture(deployAll);
            const gameId = await game.connect(p1).createGameWithPrice(BASE_FEE * 2n);
            await token.connect(p1).transfer(p2.address, BASE_FEE * 2n + ethers.parseUnits("1", 8));
            await token.connect(p1).transfer(p3.address, BASE_FEE * 2n + ethers.parseUnits("1", 8));
            await token.connect(p1).transfer(p4.address, BASE_FEE * 2n + ethers.parseUnits("1", 8));
            await game.connect(p2).joinGame(gameId);
            await game.connect(p3).joinGame(gameId);
            await game.connect(p4).joinGame(gameId);
        });
        it("tests a player cannot join twice", async function () {
            const { p1, p2, game, token } = await loadFixture(deployAll);
            const gameId = await game.connect(p1).createGameWithPrice(BASE_FEE * 2n);
            await token.connect(p1).transfer(p2.address, BASE_FEE * 2n + ethers.parseUnits("1", 8));
            await game.connect(p2).joinGame(gameId);
            await expect(game.connect(p2).joinGame(gameId))
                .to.be.revertedWithCustomError(game, "ALREADY_JOINED_GAME");
        });
    });
});

