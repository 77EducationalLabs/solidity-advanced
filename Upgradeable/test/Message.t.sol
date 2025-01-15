// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import { DeployInit } from "../script/DeployInit.s.sol";
import { HelperConfig } from "../script/HelperConfig.s.sol";

import { MessageProxy } from "../src/proxy/MessageProxy.sol";
import { Message } from "../src/Message.sol";

import { TransparentUpgradeableProxy, ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MessageTest is Test {
    ///Deploy Script
    DeployInit s_deploy;
    HelperConfig s_helperConfig;

    ///Protocol Contracts Instances
    MessageProxy public s_proxy;
    Message public s_msg;

    ///Proxy Pattern instance for upgrades
    ITransparentUpgradeableProxy s_transp;

    ///Proxy Wrapper
    Message public s_msgProxy;

    ///Utils
    address s_admin = address(1);

    //Events 
    event Message_UpdatedMessage();

    function setUp() public {
        s_deploy = new DeployInit();
        (s_helperConfig, s_msg, s_proxy) = s_deploy.run();

        s_msgProxy = Message(address(s_proxy));
    }

    function test_getMessageWorks() public {
        vm.prank(s_admin);
        string memory message = s_msgProxy.getMessage();

        assertEq(keccak256(abi.encodePacked(message)), keccak256(abi.encodePacked(s_helperConfig.INITIAL_MESSAGE())));
    }

    function test_setMessageWorks() public {
        string memory newMessage = "77 Educational Labs";

        vm.prank(s_admin);
        vm.expectEmit();
        emit Message_UpdatedMessage();
        s_msgProxy.setMessage(newMessage);
    }
}
