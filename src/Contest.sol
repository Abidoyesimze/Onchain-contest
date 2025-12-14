// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Contest {
    enum Status {
        Open,
        Closed
    }

    struct ContestData {
        uint256 contestId;
        uint256 entryFee;
        uint256 maxParticipants;
        uint256 currentParticipants;
        Status status;
        uint256 prizePool;
        address creator;
    }

    mapping(uint256 => ContestData) public contests;
    mapping(uint256 => mapping(address => bool)) public participants;

    uint256 public nextContestId;

    event ContestCreated(uint256 indexed contestId, address indexed creator, uint256 entryFee, uint256 maxParticipants);

    event ContestJoined(uint256 indexed contestId, address indexed participant, uint256 entryFee);

    function createContest(uint256 _entryFee, uint256 _maxParticipants) external returns (uint256) {
        require(_entryFee > 0, "Entry fee must be greater than 0");
        require(_maxParticipants > 0, "Max participants must be greater than 0");

        uint256 contestId = nextContestId;
        nextContestId++;

        contests[contestId] = ContestData({
            contestId: contestId,
            entryFee: _entryFee,
            maxParticipants: _maxParticipants,
            currentParticipants: 0,
            status: Status.Open,
            prizePool: 0,
            creator: msg.sender
        });

        emit ContestCreated(contestId, msg.sender, _entryFee, _maxParticipants);

        return contestId;
    }

    function joinContest(uint256 _contestId) external payable {
        ContestData storage contest = contests[_contestId];

        require(contest.contestId == _contestId, "Contest does not exist");
        require(contest.status == Status.Open, "Contest is not open");
        require(contest.currentParticipants < contest.maxParticipants, "Contest is full");
        require(msg.value == contest.entryFee, "Incorrect entry fee");
        require(!participants[_contestId][msg.sender], "Already joined");

        participants[_contestId][msg.sender] = true;
        contest.currentParticipants++;
        contest.prizePool += msg.value;

        emit ContestJoined(_contestId, msg.sender, msg.value);
    }

    function getContest(uint256 _contestId) external view returns (ContestData memory) {
        return contests[_contestId];
    }

    function closeContest(uint256 _contestId) external {
        ContestData storage contest = contests[_contestId];
        require(contest.creator == msg.sender, "Only creator can close");
        require(contest.status == Status.Open, "Contest already closed");

        contest.status = Status.Closed;
    }
}

