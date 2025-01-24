///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";

import { DeployInit } from "script/DeployInit.s.sol";

import { NebulaQuest } from "src/NebulaQuest.sol";

// import { FuzzHandler } from "test/helpers/FuzzHandler.t.sol";

contract OpenNebulaQuestStatefulFuzzTest is StdInvariant, Test {
    DeployInit deploy;
    NebulaQuest quest;

    address s_admin = makeAddr("s_admin");

    function setUp() public {
        deploy = new DeployInit();
        (quest, , , ,) = deploy.run();
        
        //Add NebulaQuest as the target contract
        targetContract(address(quest));
        //Remove the deploy script
        excludeContract(address(deploy));

        setAnswers(s_admin);
    }

    function invariant_totalSupplyEqualToUsersBalancesOpen() public {

        //Calculations to obtain the total amount emitted in a call
        assertEq(quest.i_coin().totalSupply(), quest.g_usersMintedStablecoin());
    }

    function setAnswers(address _admin) public {
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
        vm.prank(_admin);
        quest.answerSetter(examNumber, correctAnswers);
    }
}