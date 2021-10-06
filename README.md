# ComicDao

Base Project Spec : https://app.optilistic.com/training/solidity-project-4/lessons/1

Spec for investment:
- Created a Comic Coin which will be used for investment in DAO.
- The person who participate first will get more coins.
- Anyone can contribute now, Initially, I was trying only whitelisted users can contribute but later I removed that condition to simplify code.
Meaning: I am checking first first how many drawings are completed and based on that coins are minted.
Let's say if completed drawings are 3 and a person contributes, then they may get X coins
but if completed drawings are 10 and now a person contributes, then they may get less than X coins.
(Note : Found this investment idea in some youtube video. Purpose is the person who will come first will get more coins.)

Spec for Voting mechanism:
- Only whitelisted artists/writers can submit drawing/sketch. Once submitted they will get payments accordingly.
- OnlyGovernor can can create proposals for it. Once proposal is created for a function (addOrRemoveWriter, addOrRemoveArtist, addIdeas) then community peoples can vote. I have used simple voting mechanism using GovernorCountingSimple openzepplin contract. There will be three three types of votes as per contract(For, Against and Abstain). Once voting period is over governor can execute function executePropsal. If no of votes are more or equal than quorum value then the proposal is passed else it failed. I was thinking if the proposal fails, then remove it's entry from sketch/drawing mapping. But I removed this condition as well to simplify business logic.
- For better participation in voting, I have increased voting powers by some mathematical formula considering account votes of the voter address.
- Quorum is set low intentionally. It should be greater so that proposal can be passed only by a large no of voters.

Took help from below resources:

- https://docs.openzeppelin.com/contracts/4.x/governance#erc20votes_erc20votescomp
- https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts
- https://github.com/compound-finance/compound-protocol/tree/master/contracts
- and multiple youtube and medium resources
