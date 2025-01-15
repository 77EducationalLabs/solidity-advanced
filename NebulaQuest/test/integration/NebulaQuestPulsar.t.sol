//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Helper } from "../helpers/Helper.t.sol";
import { console2 } from "forge-std/console2.sol";
import { Vm } from "forge-std/Vm.sol";

contract NebulaQuestPulsarTest is Helper {
    ///requestRandomWords
        function test_requestRandomWordsRevertOverParticipantsNumber() public {
            uint32 numWords = 2;
            uint32 participants = 0;

            vm.prank(s_admin);
            vm.expectRevert(abi.encodeWithSelector(NebulaQuestPulsar_NotEnoughParticipants.selector, numWords, participants));
            pulsar.requestRandomWords(numWords);
        }

        function test_requestRandomWordsCreateARequest() public setLevels setAnswers {
            uint32 numOfWords = 4;
            
            ///@notice prepare answers and submit for four users
            prepareEnvironmentToVRFRequest();

            //Check for four NFTs minted. Function must return 4.
            assertEq(nft.getLastNFTId(), numOfWords);
            //But, why four is the last token is 3?
            //That's because we start in zero and update the Id, so next nft will have a higher id
            //That's an expected behavior. But is it right?
            //It's a bug. We will account for one more people on the draw than it really exists
            //When we call processWinners it will count from 0 to 4. And not until 3, as it should be
            //Correct the bug on `NebulaQuestPulsar.sol`

            vm.recordLogs();
                vm.prank(s_admin);
                uint256 requestId = pulsar.requestRandomWords(numOfWords);
            Vm.Log[] memory logs = vm.getRecordedLogs();

            (uint256 requestIdCaptured, uint256 randomWordCaptured) = abi.decode(logs[1].data, (uint256, uint256));

            assertEq(logs[1].topics[0], keccak256("NebulaQuestPulsar_RequestSent(uint256,uint256)"));
            assertEq(requestIdCaptured, requestId);
            assertEq(randomWordCaptured, numOfWords);
        }

        function test_requestRandomWordsCreateARequestAndFulfill() public setLevels setAnswers returns(uint256 requestId_){
            uint32 numOfWords = 4;
            
            ///@notice prepare answers and submit for four users
            prepareEnvironmentToVRFRequest();

            //Check for four NFTs minted. Function must return 4.
            // assertEq(nft.getLastNFTId(), numOfWords);

            vm.recordLogs();
                vm.prank(s_admin);
                requestId_ = pulsar.requestRandomWords(numOfWords);
            Vm.Log[] memory logs = vm.getRecordedLogs();

            (uint256 requestIdCaptured, uint256 randomWordCaptured) = abi.decode(logs[1].data, (uint256, uint256));

            assertEq(logs[1].topics[0], keccak256("NebulaQuestPulsar_RequestSent(uint256,uint256)"));
            assertEq(requestIdCaptured, requestId_);
            assertEq(randomWordCaptured, numOfWords);

            vm.recordLogs();
                /// implement logic to fulfill
                coordinator.fulfillRandomWords(requestId_, address(pulsar));
            Vm.Log[] memory fulfillLogs = vm.getRecordedLogs();

            assertEq(fulfillLogs[0].topics[0], keccak256("NebulaQuestPulsar_RequestFulfilled(uint256,uint256[])"));
            (uint256 fulfilledRequestIdCaptured, uint256[] memory randomWords) = abi.decode(fulfillLogs[0].data, (uint256, uint256[]));
            assertEq(fulfilledRequestIdCaptured, requestId_);
            assertEq(randomWords.length, numOfWords);
        }

    //processWinners
        function test_ifProcessWinnersChooseCorrectly() public {
            uint256 requestId = test_requestRandomWordsCreateARequestAndFulfill();
            address[] memory winnersAddresses = new address[](4);
            winnersAddresses[0] = s_user03;
            winnersAddresses[1] = s_user01;
            winnersAddresses[2] = s_user02;
            winnersAddresses[3] = s_user02;

            vm.prank(s_admin);
            vm.expectEmit();
            emit NebulaQuestPulsar_WinnersSelected(requestId, winnersAddresses);
            pulsar.processWinners(requestId);
        }
}