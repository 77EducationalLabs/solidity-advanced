// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {NebulaQuest} from "../src/NebulaQuest.sol";

contract DeployInit is Script {
    function run() external returns (NebulaQuest quest, HelperConfig helperConfig) {
        ///@notice holds all the data from the Config file
        helperConfig = new HelperConfig();

        ///@notice gets the struct data for the chain being used
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.deployer);
        ///Deploy the contracts
        quest = new NebulaQuest(
            config.admin,
            config.dataFeedsAggregator
        );
        vm.stopBroadcast();
    }
}