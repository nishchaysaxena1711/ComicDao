const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComicDAO", function () {
    let ComicCoin, ComicDao, ComicGovernor, comicDao, comicCoin, comicGovernor, owner, c1, c2, c3, c4, w1, w2, a1, a2;

    before(async function () {
        ComicCoin = await ethers.getContractFactory('Comic');
        ComicDao = await ethers.getContractFactory('ComicDao');
        ComicGovernor = await ethers.getContractFactory('ComicGovernor');

        comicDao = await ComicDao.deploy();
        await comicDao.deployed();

        comicCoin = await ComicCoin.deploy(comicDao.address);
        await comicCoin.deployed();
        await comicDao.setCoinAddress(comicCoin.address);

        comicGovernor = await ComicGovernor.deploy(comicCoin.address);
        await comicGovernor.deployed();
        await comicDao.setGovernor(comicGovernor.address);

        [owner, c1, c2, c3, c4, w1, w2, a1, a2] = await ethers.getSigners();
    });

    it("should mint comic tokens for an address", async function () {
        await comicDao.contribute({ value: 100 });
        expect(await comicCoin.balanceOf(owner.address)).to.eq("100");
    });
});
