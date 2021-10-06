const { expect } = require("chai");
const { ethers } = require("hardhat");

// Note: To run tests faster, lower the value of voting dealy in ComicGovernor.sol

describe("ComicDAO", function () {
    let ComicCoin, ComicDao, ComicGovernor, comicDao, comicCoin, comicGovernor, owner, c1, c2, c3, c4, w1, w2, a1, a2;

    beforeEach(async function () {
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

    it("should allow a writer to propose, get votes on and approved", async function () {
        await comicDao.contribute({ value: 10000 });

        await comicDao.connect(c1).contribute({ value: 5000 });
        expect(await comicCoin.balanceOf(c1.address)).to.eq("5000");

        await comicDao.createProposal("addOrRemoveWriter", w1.address);
        const proposalId = await comicDao.getProposalId("addOrRemoveWriter", w1.address);

        await ethers.provider.send('evm_mine');

        expect(await comicGovernor.state(proposalId)).to.eq(1); // voting is on(Active)
        await expect(comicDao.executeProposal("addOrRemoveWriter", w1.address)).to.be.reverted; // not allowed till now

        expect(await comicGovernor.getVotes(c1.address, 0)).to.eq("5010");

        await comicGovernor.castVote(proposalId, 1);
        await comicGovernor.connect(c2).castVote(proposalId, 0);

        const votingPeriod = await comicGovernor.votingPeriod();
        let i = 0;
        while(i <= votingPeriod.toNumber()) {
            await ethers.provider.send('evm_mine');
            i++;
        }

        expect(await comicGovernor.state(proposalId)).to.eq(4); // Success

        await comicDao.executeProposal("addOrRemoveWriter", w1.address);

        expect((await comicDao.writers(w1.address))).to.eq(true)
    });

    it("should allow an idea to be proposed, get votes on it and approved.", async function () {

        await comicDao.contribute({ value: 10000 });
        await comicDao.connect(c1).contribute({ value: 5000 });

        expect(await comicCoin.balanceOf(c1.address)).to.eq("5000");

        const encodedConceptURI = ethers.utils.formatBytes32String("hello_url");
        await comicDao.createProposal("addIdeas", encodedConceptURI);

        const proposalId = await comicDao.getProposalId("addIdeas", encodedConceptURI);

        await ethers.provider.send('evm_mine');
        const proposalState1 = await comicGovernor.state(proposalId);

        expect(proposalState1).to.eq(1); // voting is on(Active)
        await expect(comicDao.executeProposal("addIdeas", encodedConceptURI)).to.be.reverted; // not allowed till now

        expect(await comicGovernor.getVotes(c1.address, 0)).to.eq("5010");

        await comicGovernor.castVote(proposalId, 1);
        await comicGovernor.connect(c2).castVote(proposalId, 0);

        const votingPeriod = await comicGovernor.votingPeriod();
        let i = 0;
        while(i <= votingPeriod.toNumber()) {
            await ethers.provider.send('evm_mine');
            i++;
        }

        expect(await comicGovernor.state(proposalId)).to.eq(4); // Success

        await comicDao.executeProposal("addIdeas", encodedConceptURI);

        expect((await comicDao.ideas(0)).toString('utf8').replace(/\0/g, '')).to.eq("hello_url")

    });

    it("should mint comic tokens for an address", async function () {
        await comicDao.contribute({ value: 100 });
        expect(await comicCoin.balanceOf(owner.address)).to.eq("100");
    });
});
