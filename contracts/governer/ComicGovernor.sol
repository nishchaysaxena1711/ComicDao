// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "../coin/Comic.sol";

contract ComicGovernor is Governor, GovernorCountingSimple {

    Comic private coin;
    mapping(address => uint) private accountVotes;
    
    constructor(Comic _voteCoin) Governor('ComicGovernor') {
        coin = _voteCoin;
    }
    
    function votingDelay() public pure override returns (uint256) {
        return 1;
    }

    function votingPeriod() public pure override returns (uint256) {
        return 17280; // ~3 days in blocks (assuming 15s blocks). Not sure what should be the ideal value.
    }

    function quorum(uint256 blockNumber) public pure override returns (uint256) {
        return 1;
    }

    function _castVote(uint256 proposalId, address account, uint8 support, string memory reason) internal override returns (uint256) {
        accountVotes[msg.sender]++;
        return super._castVote(proposalId, account, support, reason);
    }

    function getVotes(address account, uint256 blockNumber) public view override(IGovernor) returns (uint256) {
        // https://docs.barnbridge.com/governance/barnbridge-dao-faq/how-to-obtain-voting-power-on-the-dao
        // For better/more participation in voting.
        return coin.balanceOf(account) + (sqrt(accountVotes[msg.sender] + 1) * 10);
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}