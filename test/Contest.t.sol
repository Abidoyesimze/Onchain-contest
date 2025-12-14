// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Contest} from "../src/Contest.sol";

contract ContestTest is Test {
    Contest public contest;
    address public creator = address(1);
    address public participant1 = address(2);
    address public participant2 = address(3);

    function setUp() public {
        vm.prank(creator);
        contest = new Contest();
    }

    function test_CreateContest() public {
        vm.prank(creator);
        uint256 contestId = contest.createContest(1 ether, 10);
        
        assertEq(contestId, 0);
        Contest.ContestData memory contestData = contest.getContest(contestId);
        assertEq(contestData.contestId, 0);
        assertEq(contestData.entryFee, 1 ether);
        assertEq(contestData.maxParticipants, 10);
        assertEq(contestData.currentParticipants, 0);
        assertEq(contestData.prizePool, 0);
    }

    function test_JoinContest() public {
        vm.prank(creator);
        uint256 contestId = contest.createContest(1 ether, 10);
        
        vm.prank(participant1);
        vm.deal(participant1, 1 ether);
        contest.joinContest{value: 1 ether}(contestId);
        
        assertTrue(contest.participants(contestId, participant1));
        Contest.ContestData memory contestData = contest.getContest(contestId);
        assertEq(contestData.prizePool, 1 ether);
    }

    function test_CannotJoinWithWrongFee() public {
        vm.prank(creator);
        uint256 contestId = contest.createContest(1 ether, 10);
        
        vm.prank(participant1);
        vm.deal(participant1, 0.5 ether);
        vm.expectRevert("Incorrect entry fee");
        contest.joinContest{value: 0.5 ether}(contestId);
    }

    function test_CannotJoinWhenFull() public {
        vm.prank(creator);
        uint256 contestId = contest.createContest(1 ether, 2);
        
        vm.deal(participant1, 1 ether);
        vm.deal(participant2, 1 ether);
        
        vm.prank(participant1);
        contest.joinContest{value: 1 ether}(contestId);
        
        vm.prank(participant2);
        contest.joinContest{value: 1 ether}(contestId);
        
        address participant3 = address(4);
        vm.deal(participant3, 1 ether);
        vm.prank(participant3);
        vm.expectRevert("Contest is full");
        contest.joinContest{value: 1 ether}(contestId);
    }

    function test_CannotJoinTwice() public {
        vm.prank(creator);
        uint256 contestId = contest.createContest(1 ether, 10);
        
        vm.deal(participant1, 2 ether);
        vm.prank(participant1);
        contest.joinContest{value: 1 ether}(contestId);
        
        vm.prank(participant1);
        vm.expectRevert("Already joined");
        contest.joinContest{value: 1 ether}(contestId);
    }

    function test_CloseContest() public {
        vm.prank(creator);
        uint256 contestId = contest.createContest(1 ether, 10);
        
        vm.prank(creator);
        contest.closeContest(contestId);
        
        vm.deal(participant1, 1 ether);
        vm.prank(participant1);
        vm.expectRevert("Contest is not open");
        contest.joinContest{value: 1 ether}(contestId);
    }
}

