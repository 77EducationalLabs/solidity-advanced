///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test, console } from "forge-std/Test.sol";

import { NebulaQuest } from "src/NebulaQuest.sol";
import { NebulaStablecoin } from "src/NebulaStablecoin.sol";

//Chainlink contracts
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FuzzHandler is Test{
    NebulaQuest immutable i_quest;
    NebulaStablecoin immutable i_coin;

    address s_admin = makeAddr("s_admin");
    uint256 public s_usersMintedStablecoin;

    uint8 constant EXAM_ID = 1;
    uint256 constant NUMBER_OF_ANSWERS = 10;
    uint256 constant TEN_OF_TEN = 1000;
    uint256 constant NINE_OF_TEN = 900;
    uint256 constant EIGHT_OF_TEN = 800;
    uint256 constant INDEX_ZERO = 0;
    uint256 constant INDEX_ONE = 1;
    uint256 constant INDEX_TWO = 2;

    constructor(address _quest){
        i_quest = NebulaQuest(_quest);
        i_coin = i_quest.i_coin();
    }

    function submitAnswers(bytes32[] memory _answersToSubmit) external {
        vm.assume(_answersToSubmit.length == NUMBER_OF_ANSWERS);

        s_usersMintedStablecoin = s_usersMintedStablecoin + _correctAmount(_answersIndex);

        i_quest.submitAnswers(EXAM_ID, _answersToSubmit);
    }

    function submitAnswersWithCorrectAnswers(uint256 _userIndex, uint256 _answersIndex) external {
        _userIndex = bound(_userIndex, 0, 9);
        _answersIndex = bound(_answersIndex, 0, 2);

        s_usersMintedStablecoin = s_usersMintedStablecoin + _correctAmount(_answersIndex);
        vm.prank(_getUser(_userIndex));
        i_quest.submitAnswers(EXAM_ID, _getCorrectAnswers(_answersIndex));
    }

    /*////////////////////////////////////////////////////////////
                                Helpers
    ////////////////////////////////////////////////////////////*/
    function _correctAmount(uint256 _index) private view returns(uint256 amount_){
        (,int256 feedAnswer,,,) = AggregatorV3Interface(i_quest.i_feeds()).latestRoundData();

        if(_index == INDEX_ZERO){
            amount_ = TEN_OF_TEN * (uint256(feedAnswer) * 10**10);
        } else if (_index == INDEX_ONE){
            amount_ = NINE_OF_TEN * (uint256(feedAnswer) * 10**10);
        } else {
            amount_ = EIGHT_OF_TEN * (uint256(feedAnswer) * 10**10);
        }
    }

    function _getCorrectAnswers(uint256 _index) private pure returns(bytes32[] memory answers_){
        bytes32[] memory correctAnswers = new bytes32[](10);

        if(_index == INDEX_ZERO){
            correctAnswers[0] = keccak256(abi.encodePacked("test1"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("test8"));
            correctAnswers[8] = keccak256(abi.encodePacked("test9"));
            correctAnswers[9] = keccak256(abi.encodePacked("test10"));
        } else if (_index == INDEX_ONE) {
            correctAnswers[0] = keccak256(abi.encodePacked("test1"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("testao"));
            correctAnswers[8] = keccak256(abi.encodePacked("test9"));
            correctAnswers[9] = keccak256(abi.encodePacked("test10"));
        } else {
            correctAnswers[0] = keccak256(abi.encodePacked("test"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("test8"));
            correctAnswers[8] = keccak256(abi.encodePacked("test9"));
            correctAnswers[9] = keccak256(abi.encodePacked("testin"));
        }
        answers_ = correctAnswers;
    }

    function _getUser(uint256 _index) private pure returns(address user_){
        address[] memory users = new address[](10);
        users[0] = address(1);
        users[1] = address(2);
        users[2] = address(3);
        users[3] = address(4);
        users[4] = address(5);
        users[5] = address(6);
        users[6] = address(7);
        users[7] = address(8);
        users[8] = address(9);
        users[9] = address(10);

        user_ = users[_index];
    }
}