// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

///Foundry Scripts
import {Script, console} from "forge-std/Script.sol";

///Protocol Contracts
import {NebulaQuest} from "../src/NebulaQuest.sol";
import {NebulaQuestPulsar} from "../src/NebulaQuestPulsar.sol";
import {NebulaAirdrop} from "src/NebulaAirdrop.sol";
import {NebulaQuestToken} from "src/NebulaQuestToken.sol";

///General Script
import {HelperConfig} from "./HelperConfig.s.sol";

///VRF Scripts Import
import { VRFCreateSub } from "./VRF/VRFCreateSub.s.sol";
import { VRFAddConsumer } from "./VRF/VRFAddConsumer.s.sol";
import { VRFFundSubscription } from "./VRF/VRFFundSubscription.s.sol";

contract DeployInit is Script {
    HelperConfig s_helperConfig;
    HelperConfig.NetworkConfig s_config;

    function run() external returns (NebulaQuest quest_, NebulaQuestPulsar pulsar_, NebulaQuestToken token_, NebulaAirdrop drop_, HelperConfig helperConfig_) {
        
        helper_prepareEnvironment();

        vm.startBroadcast(s_config.deployer);
        quest_ = new NebulaQuest(
            s_config.admin,
            s_config.dataFeedsAggregator
        );

        pulsar_ = new NebulaQuestPulsar(
            s_config.subId,
            s_config.keyHash,
            s_config.vrfCoordinator,
            address(quest_.i_nft())
        );

        token_ = new NebulaQuestToken(
            s_config.admin,
            s_config.admin
        );

        drop_ = new NebulaAirdrop(
            s_config.root,
            token_
        );
        vm.stopBroadcast();

        helper_addConsumer(pulsar_);

        helperConfig_ = s_helperConfig;
    }

    function helper_prepareEnvironment() public {
        ///@notice Deploys a Helper Config which holds all the data from the Config file
        s_helperConfig = new HelperConfig();
        ///@notice gets the struct data for the chain being used
        s_config = s_helperConfig.getConfig();

        ///@notice checks if has a valid subscription
        if (s_config.subId == 0) {
            ///@notice if it's not valid. Deploys a create script
            VRFCreateSub create = new VRFCreateSub();
            ///@notice calls `createSubscription` and override the initial config info
            (s_config.subId, s_config.vrfCoordinator) =
                create.createSubscription(s_config.vrfCoordinator, s_config.admin);
            
            ///@notice deploys a new funding script
            VRFFundSubscription fund = new VRFFundSubscription();
            ///@notice fund the recently created subscription
            fund.fundSubscription(
                s_config.vrfCoordinator, s_config.subId, s_config.link, s_config.admin
            );

            ///@notice update the helperConfig info for the particular chain with the data recently created.
            s_helperConfig.setConfig(block.chainid, s_config);
        } else {
            console.log("Adding funds to Subscription");
            ///@notice deploys a new funding script
            VRFFundSubscription fund = new VRFFundSubscription();
            ///@notice fund the recently created subscription
            fund.fundSubscription(
                s_config.vrfCoordinator,
                s_config.subId,
                s_config.link,
                s_config.admin
            );
        }
    }

    function helper_addConsumer(NebulaQuestPulsar _pulsar) public {
        ///@notice Deploys a VRFAddConsumer helper
        VRFAddConsumer consumer = new VRFAddConsumer();

        ///@notice add the contract deployed as a consumer
        consumer.addConsumer(
            address(_pulsar),
            s_config.vrfCoordinator,
            s_config.subId,
            s_config.admin
        );

    }
}