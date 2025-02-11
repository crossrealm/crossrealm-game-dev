const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CrossRealm", function () {
  let CrossRealm;
  let crossRealm;
  let owner;
  let player1;
  let player2;

  beforeEach(async function () {
    // Get signers for testing
    [owner, player1, player2] = await ethers.getSigners();

    // Deploy contract
    CrossRealm = await ethers.getContractFactory("CrossRealm");
    crossRealm = await CrossRealm.deploy();
    await crossRealm.deployed();
  });

  describe("Realm Management", function () {
    it("Should add new realm", async function () {
      await crossRealm.addRealm("fire");
      expect(await crossRealm.validRealms("fire")).to.equal(true);
    });

    it("Should allow players to enter realm", async function () {
      await crossRealm.addRealm("fire");
      await crossRealm.connect(player1).enterRealm("fire");
      expect(await crossRealm.getPlayerCurrentRealm(player1.address)).to.equal("fire");
    });
  });

  describe("Asset Management", function () {
    it("Should mint assets to player", async function () {
      await crossRealm.mintAsset(player1.address, "GOLD", 100);
      expect(await crossRealm.getPlayerAssetBalance(player1.address, "GOLD")).to.equal(100);
    });

    it("Should transfer assets between players", async function () {
      await crossRealm.mintAsset(player1.address, "GOLD", 100);
      await crossRealm.connect(player1).transferAsset(player2.address, "GOLD", 50);
      
      expect(await crossRealm.getPlayerAssetBalance(player1.address, "GOLD")).to.equal(50);
      expect(await crossRealm.getPlayerAssetBalance(player2.address, "GOLD")).to.equal(50);
    });
  });

  describe("Level System", function () {
    it("Should level up player", async function () {
      await crossRealm.connect(player1).levelUp();
      expect(await crossRealm.getPlayerLevel(player1.address)).to.equal(1);
    });
  });
});
