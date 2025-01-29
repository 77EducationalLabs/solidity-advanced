///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//Foundry Tools
import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
//Protocol Scripts
import { DeployInit } from "script/DeployInit.s.sol";
//Protocol contracts
import { NebulaQuest } from "src/NebulaQuest.sol";
//Protocol FuzzHandler
import { FuzzHandler } from "test/helpers/FuzzHandler.t.sol";

contract NebulaQuestStatefulFuzzTest is StdInvariant, Test {
    DeployInit deploy;
    NebulaQuest quest;

    FuzzHandler handler;

    address s_admin = makeAddr("s_admin");

    function setUp() public {
        deploy = new DeployInit();
        (quest, , , ,) = deploy.run();

        handler = new FuzzHandler(address(quest));
        
        setAnswers();

        //Add NebulaQuest as the target contract
        targetContract(address(handler));
    }

    function setAnswers() public {
        //Mock Data
        uint8 examNumber = 1;
        bytes32[] memory correctAnswers = new bytes32[](10);
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

        //Test
        vm.prank(s_admin);
        quest.answerSetter(examNumber, correctAnswers);
    }

    function invariant_totalSupplyEqualToUsersBalancesWithHandler() public view {
        //Calculations to obtain the total amount emitted in a call
        assertEq(quest.i_coin().totalSupply(), handler.s_usersMintedStablecoin());
    }
}