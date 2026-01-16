// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    // Custom errors save gas compared to long require strings
    error NotAuthorized();
    error NotRegistered();
    error AlreadyVoted();
    error InvalidCandidate();

    address public owner;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] internal candidates;
    mapping(address => bool) public registeredVoters;
    mapping(address => bool) public hasVoted;

    event CandidateAdded(uint256 indexed id, string name);
    event VoteCast(address indexed voter, uint256 indexed candidateIndex);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotAuthorized();
        _;
    }

    modifier onlyVoter() {
        if (!registeredVoters[msg.sender]) revert NotRegistered();
        if (hasVoted[msg.sender]) revert AlreadyVoted();
        _;
    }

    function registerVoter(address voter) external onlyOwner {
        registeredVoters[voter] = true;
    }

    function vote(uint256 candidateIndex) external onlyVoter {
        if (candidateIndex >= candidates.length) revert InvalidCandidate();

        candidates[candidateIndex].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit VoteCast(msg.sender, candidateIndex);
    }

    // --- FETCHING STRATEGIES ---

    // Method 1: Pagination (Solves "Infinite Gas" warning)
    // Allows you to fetch candidates in chunks (e.g., first 10, then next 10)
    function getCandidatesPaged(
        uint256 offset,
        uint256 limit
    ) external view returns (Candidate[] memory) {
        uint256 total = candidates.length;
        if (offset >= total) return new Candidate[](0);

        uint256 size = limit;
        if (offset + limit > total) {
            size = total - offset;
        }

        Candidate[] memory page = new Candidate[](size);
        for (uint256 i = 0; i < size; i++) {
            page[i] = candidates[offset + i];
        }
        return page;
    }

    // Method 2: Individual Fetching Helper
    // Returns the total number so the frontend knows the loop limit
    function getCandidateCount() external view returns (uint256) {
        return candidates.length;
    }
}
