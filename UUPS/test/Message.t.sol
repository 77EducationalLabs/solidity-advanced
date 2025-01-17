// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/Test.sol";

import { Helper } from "./helpers/Helper.t.sol";

contract MessageTest is Helper {

    ///@notice get store message on initialization
    function test_getMessageWorks() public view {
        string memory message = s_msgProxy.getMessage();

        assertEq(keccak256(abi.encodePacked(message)), keccak256(abi.encodePacked(s_helperConfig.INITIAL_MESSAGE())));
    }

    ///@notice query implementation storage => must be empty
    function test_getMessageFromImplementation() public view {
        string memory message = s_msg.getMessage();

        console2.log(message);
        assertEq(keccak256(abi.encodePacked(message)), keccak256(abi.encodePacked("")));
    }

    ///@notice update shared storage variable
    function test_setMessageWorks() public {
        string memory newMessage = "77 Educational Labs";

        vm.expectEmit();
        emit Message_UpdatedMessage();
        s_msgProxy.setMessage(newMessage);

        string memory storedMessage = s_msgProxy.getMessage();

        assertEq(keccak256(abi.encodePacked(storedMessage)), keccak256(abi.encodePacked(newMessage)));
    }

    ///@notice upgrade contract and checks the storage
    function test_upgradedCorrectlyAndStorageIntact() public {
        //Deploy and Initialization happens

        //We update the storage
        test_setMessageWorks();

        //Deploy a New Version and Update the implementation
        helper_deploySecondContractAndUpgrade();

        //declare the expectMessage
        string memory expectMessage = "77 Educational Labs";
        string memory storedMessage = s_secondMsgProxy.getMessage();

        //Compare results
        assertEq(keccak256(abi.encodePacked(expectMessage)), keccak256(abi.encodePacked(storedMessage)));
    }

    ///@notice delete the message stored using the new function
    function test_canDeleteMessageUsingTheNewFunction() public {
        test_upgradedCorrectlyAndStorageIntact();

        vm.expectEmit();
        emit Message_MessageDeleted();
        s_secondMsgProxy.deleteMessage();

        //declare the expectMessage
        string memory expectMessage = "";
        string memory storedMessage = s_secondMsgProxy.getMessage();

        //Compare results
        assertEq(keccak256(abi.encodePacked(expectMessage)), keccak256(abi.encodePacked(storedMessage)));
    }
}
