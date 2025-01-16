// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

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

        config.proxyAdmin = proxy_.getAdmin();
        config.proxy = address(proxy_);
        config.implementation = address(message_);

        helperConfig_.setConfig(block.chainid, config);

        vm.stopBroadcast();
    }
}
