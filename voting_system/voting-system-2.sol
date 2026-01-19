// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting {
    error AlreadyVoted();
    error InvalidCandidateIndex(uint256 _indexGiven, uint256 _maximumIndex);
    error NotOwner();
    error NotRegistered();

    event CandidateAdded(uint256 indexed id, string name);
    event VoteCast(address indexed voter, uint256 indexed candidateIndex);

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public owner;

    Candidate[] private candidates;

    mapping(address => bool) public registeredVoters;
    mapping(address => bool) public hasVoted;

    uint256 public registeredVotersCount;
    uint256 public hasVotedCount;

    uint256 PAGE_SIZE = 10;

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyRegistered() {
        if (!registeredVoters[msg.sender]) revert NotRegistered();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addCandidate(string calldata name) external onlyOwner {
        candidates.push(Candidate(name, 0));
        emit CandidateAdded(candidates.length - 1, name);
    }

    function registerVoter(address voter) external onlyOwner {
        if (!registeredVoters[voter]) {
            registeredVoters[voter] = true;
            registeredVotersCount++;
        }
    }

    function vote(uint256 _index) external onlyRegistered {
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        if (_index >= candidates.length) {
            revert InvalidCandidateIndex(_index, candidates.length - 1);
        }

        hasVoted[msg.sender] = true;
        hasVotedCount++;

        candidates[_index].voteCount++;

        emit VoteCast(msg.sender, _index);
    }

    function getCandidate(uint256 _index) external view returns (Candidate memory) {
        if (_index >= candidates.length) {
            revert InvalidCandidateIndex(_index, candidates.length - 1);
        }

        return candidates[_index];
    }

    function getCandidateCount() external view returns (uint256) {
        return candidates.length;
    }

    function getCandidatesPagedByTen(uint256 offset) external view returns (Candidate[] memory) {
        if (offset >= candidates.length) {
            return new Candidate[](0);
        }

        uint256 end = offset + PAGE_SIZE;
        if (end > candidates.length) {
            end = candidates.length;
        }

        Candidate[] memory page = new Candidate[](end - offset);

        for (uint256 i = 0; i < end - offset; i++) {
            page[i] = candidates[i + offset];
        }

        return page;
    }
}
