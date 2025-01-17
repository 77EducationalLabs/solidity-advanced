// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

///@notice Forge Tools
import { Script, console } from "forge-std/Script.sol";

///@notice Protocol Contracts
import { Message } from "../src/Message.sol";

///@notice Config Helper Script
import { HelperConfig } from "./HelperConfig.s.sol";

///@notice OZ Contracts
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployInit is Script {
    Message public s_msg;

    function run() public returns(HelperConfig helperConfig_, Message message_, ERC1967Proxy proxy_){
        vm.startBroadcast();

        helperConfig_ = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig_.getConfig();

        message_ = new Message();
        proxy_ = new ERC1967Proxy(
            address(message_),
            config.data
        );

        config.proxy = address(proxy_);
        config.implementation = address(message_);

        helperConfig_.setConfig(block.chainid, config);

        vm.stopBroadcast();
    }
}
