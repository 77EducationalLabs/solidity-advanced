///SPDX-License-Identifier:MIT
pragma solidity 0.8.26;

import { Helper } from "test/helpers/Helper.t.sol";

contract NebulaQuestFuzzTest is Helper {
    uint8 constant ONE = 1;
    uint8 constant NUM_ANSWERS = 10;
    uint16 constant MIN_SCORE = 800;

    function test_fuzz_submitAnswers(address _user, uint8 _examIndex, bytes32[] memory _encryptedAnswers) public {
        uint256 inputLength = _encryptedAnswers.length;
        bytes32[] memory answers = new bytes32[](10);

        if(inputLength != NUM_ANSWERS) {
            vm.prank(quest.owner());
            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_WrongAmountOfAnswers.selector, inputLength, NUM_ANSWERS));
            quest.answerSetter(_examIndex, _encryptedAnswers);
        } else {
            vm.prank(quest.owner());
            quest.answerSetter(_examIndex, _encryptedAnswers);
            answers = quest.getCorrectAnswers(_examIndex);

            assert(answers[0] == _encryptedAnswers[0]);
        }

        if(quest.getCorrectAnswers(_examIndex).length < ONE){
            vm.prank(_user);
            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_NonExistentExam.selector, _examIndex));
            quest.submitAnswers(_examIndex, _encryptedAnswers);
        } else if(inputLength != NUM_ANSWERS){
            vm.prank(_user);
            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_MustAnswerAllQuestions.selector,inputLength, NUM_ANSWERS));
            quest.submitAnswers(_examIndex, _encryptedAnswers);
        } else {
            vm.prank(_user);
            quest.submitAnswers(_examIndex, _encryptedAnswers);
            assertGt(coin.balanceOf(_user), MIN_SCORE);
        }
    }
}