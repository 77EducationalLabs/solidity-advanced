// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";

import { Message } from "../src/Message.sol";
import { MessageProxy } from "../src/proxy/MessageProxy.sol";

import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployInit is Script {
    Message public s_msg;

    function run() public returns(HelperConfig helperConfig_, Message message_, MessageProxy proxy_){
        vm.startBroadcast();

        helperConfig_ = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig_.getConfig();

        message_ = new Message();
        proxy_ = new MessageProxy(
            address(message_),
            config.admin,
            config.data
        );

        vm.stopBroadcast();
    }
}
