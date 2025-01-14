// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//Foundry
import {Script, console} from "forge-std/Script.sol";

//Our Scripts
import {HelperConfig} from "../HelperConfig.s.sol";

//Protocol Contract
import { NebulaQuestPulsar } from "../../src/NebulaQuestPulsar.sol";

//Cyfrin Awesome Tool
import {DevOpsTools} from "@cyfrin/src/DevOpsTools.sol";

//Chainlink stuff
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import { LinkToken } from "@chainlink/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";

contract VRFAddConsumer is Script {

    /**
        *@notice function to add a consumer using inputs
    */
    function addConsumer(address contractToAddToVrf, address vrfCoordinator, uint256 subId, address account) public {
        console.log("Adding consumer contract: ", contractToAddToVrf);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        ///@notice broadcast the received account to be msg.sender
        vm.startBroadcast(account);
        ///@notice call Coordinator to add the received `contract` as `consumer` to the received `subId`
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, contractToAddToVrf);
        vm.stopBroadcast();
    }

    /**
        *@notice add consumer using the HelperConfig information
    */
    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        ///@notice Deploys a new HelperConfig
        HelperConfig helperConfig = new HelperConfig();
        ///@notice retrieve subId info
        uint256 subId = helperConfig.getConfig().subId;
        ///@notice gets Coordinator address
        address vrfCoordinatorV2_5 = helperConfig.getConfig().vrfCoordinator;
        ///@notice get the account to broadcast
        address account = helperConfig.getConfig().admin;

        ///@notice calls the function to add consumer with HelperConfig inputs
        addConsumer(mostRecentlyDeployed, vrfCoordinatorV2_5, subId, account);
    }

    function run() external {
        ///@notice use foundry-devops to get the most recent deployed NebulaQuestPulsar contract
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("NebulaQuestPulsar", block.chainid);
        ///@notice add the contract as consumer for a specific subscription
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}