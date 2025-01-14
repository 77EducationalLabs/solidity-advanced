// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

///Foundry Scripts
import {Script} from "forge-std/Script.sol";

///Protocol Contracts
import {NebulaQuest} from "../src/NebulaQuest.sol";
import {NebulaQuestPulsar} from "../src/NebulaQuestPulsar.sol";

///General Script
import {HelperConfig} from "./HelperConfig.s.sol";

///VRF Scripts Import
import { VRFCreateSub } from "./VRF/VRFCreateSub.s.sol";
import { VRFAddConsumer } from "./VRF/VRFAddConsumer.s.sol";
import { VRFFundSubscription } from "./VRF/VRFFundSubscription.s.sol";

contract DeployInit is Script {
    function run() external returns (NebulaQuest quest, NebulaQuestPulsar pulsar, HelperConfig helperConfig) {
        ///@notice Deploys a Helper Config which holds all the data from the Config file
        helperConfig = new HelperConfig();
        ///@notice Deploys a VRFAddConsumer helper
        VRFAddConsumer consumer = new VRFAddConsumer();

        ///@notice gets the struct data for the chain being used
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        ///@notice checks if has a valid subscription
        if (config.subId == 0) {
            ///@notice if it's not valid. Deploys a create script
            VRFCreateSub create = new VRFCreateSub();
            ///@notice calls `createSubscription` and override the initial config info
            (config.subId, config.vrfCoordinator) =
                create.createSubscription(config.vrfCoordinator, config.admin);
            
            ///@notice deploys a new funding script
            VRFFundSubscription fund = new VRFFundSubscription();
            ///@notice fund the recently created subscription
            fund.fundSubscription(
                config.vrfCoordinator, config.subId, config.link, config.admin
            );

            ///@notice update the helperConfig info for the particular chain with the data recently created.
            helperConfig.setConfig(block.chainid, config);
        }

        vm.startBroadcast(config.deployer);
        ///Deploy the contracts
        quest = new NebulaQuest(
            config.admin,
            config.dataFeedsAggregator
        );

        pulsar = new NebulaQuestPulsar(
            config.subId,
            config.keyHash,
            config.vrfCoordinator,
            address(quest.i_nft())
        );

        vm.stopBroadcast();

        ///@notice add the contract deployed as a consumer
        consumer.addConsumer(
            address(pulsar),
            config.vrfCoordinator,
            config.subId,
            config.admin
        );
    }
}