// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

contract VotingSystem {
    bool public isStarted;
    uint256 numCandidates;
    uint256 numVoters;

    struct Candidate {
        string candidateName;
        int cid;
        int256 voteCounts;
    }
    mapping(int256 => Candidate) private candidates;

    struct Voter {
        int256 voterId;
        string voterName;
        bool hasVoted;
        int256 candidateIdVoted;
    }
    mapping(int256 => Voter) private voters;

    constructor() {
        isStarted = false; // Initially the system is stopped
        numCandidates = 1;
        numVoters = 1;
    }

    function startVoting() public {
        require(!isStarted, "Voting is already started.");
        isStarted = true;
    }

    function stopVoting() public {
        require(isStarted, "Voting is already stopped.");
        isStarted = false;
    }

    function addCandidates(string memory _candidateName) public {
        require(!isStarted, "Cannot add candidates after voting has started.");
        int256 candidateId = int256(numCandidates);
        candidates[candidateId] = Candidate(_candidateName,candidateId, 0);
        numCandidates++;
    }

    function getCandidates()
        public
        view
        returns (int256[] memory, string[] memory)
    {
        int256[] memory candidatesIds = new int256[](numCandidates - 1);
        string[] memory candidatesNames = new string[](numCandidates - 1);
        uint256 index = 0;
        for (uint256 i = 1; i < numCandidates; i++) {
            candidatesIds[index] = int256(i);
            candidatesNames[index] = candidates[int256(i)].candidateName;
            index++;
        }
        return (candidatesIds, candidatesNames);
    }

    function getNoOfCandidate() public view returns (uint256) {
        return (numCandidates - 1);
    }

    function addVoters(uint256 _voterId, string memory _voterName) public {
        require(!isStarted, "Cannot add voters after voting has started.");
        require(voters[int256(_voterId)].voterId == 0, "Voter already exists");
        uint256 voterId = _voterId;
        voters[int256(voterId)] = Voter(int256(voterId), _voterName, false, 0);
        numVoters++;
        return;
    }

    function vote(int256 voterId, int256 candidateId) public {
        require(isStarted, "Voting has not started yet.");
        require(voters[voterId].voterId != 0, "Invalid voter ID.");
        require(!voters[voterId].hasVoted, "You have already voted.");
        require(
             candidates[candidateId].cid != 0,
            "Invalid candidate ID."
        );

        voters[voterId] = Voter(
            voterId,
            voters[voterId].voterName,
            true,
            candidateId
        );
        candidates[candidateId].voteCounts++;
    }


    function getResult() public view returns (string memory, int256) {
        require(!isStarted, "Cannot get results before ending voting.");
        int256 maxVotes = 0;
        int256 winningCandidateId = 0;
        for (int256 i = 1; i <= int256(numCandidates); i++) {
            if (candidates[i].voteCounts > maxVotes) {
                maxVotes = candidates[i].voteCounts;
                winningCandidateId = i;
            }
        }
        return (candidates[winningCandidateId].candidateName, maxVotes);
    }

    function getCandidateResults()
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            int256[] memory
        )
    {
        require(!isStarted, "Cannot get results before ending voting.");
        uint256[] memory candidateIds = new uint256[](numCandidates - 1);
        string[] memory candidateNames = new string[](numCandidates - 1);
        int256[] memory voteCounts = new int256[](numCandidates - 1);

        uint256 index = 0;
        for (uint256 i = 1; i < numCandidates; i++) {
            candidateIds[index] = i;
            candidateNames[index] = candidates[int256(i)].candidateName;
            voteCounts[index] = candidates[int256(i)].voteCounts;
            index++;
        }

        return (candidateIds, candidateNames, voteCounts);
    }
}
