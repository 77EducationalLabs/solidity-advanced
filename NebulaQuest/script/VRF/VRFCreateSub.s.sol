// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//Foundry
import {Script, console2} from "forge-std/Script.sol";

//Our Scripts
import {HelperConfig} from "../HelperConfig.s.sol";

//Chainlink stuff
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract VRFCreateSub is Script {

    /**
        *@notice function to collect info for subscription creation using the info provided on HelperConfig.s.sol
    */
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        ///@notice Deploys a new HelperConfig
        HelperConfig helperConfig = new HelperConfig();
        ///@notice retrieve vrfCoordinator address for the specific chain
        address vrfCoordinatorV2_5 = helperConfig.getConfigByChainId(block.chainid).vrfCoordinator;
        ///@notice retrieve the account for the specific chain
        address account = helperConfig.getConfigByChainId(block.chainid).admin;
        ///@notice calls createSubscription and returns the subId and vrfCoordinator address
        return createSubscription(vrfCoordinatorV2_5, account);
    }

    /**
        *@notice function to create the subscription given the info received
        *@param _vrfCoordinatorV2_5 the coordinator address
        *@param _account the account to create the subscription for
        *@return subId & coordinator address
    */
    function createSubscription(address _vrfCoordinatorV2_5, address _account) public returns (uint256, address) {
        console2.log("Creating subscription on chainId: ", block.chainid);
        //broadcast using the account, so it can be the msg.sender
        vm.startBroadcast(_account);
        //get the subId created
        uint256 subId = VRFCoordinatorV2_5Mock(_vrfCoordinatorV2_5).createSubscription();
        vm.stopBroadcast();
        console2.log("Your subscription Id is: ", subId);
        console2.log("Please update the subscriptionId in HelperConfig.s.sol");
        return (subId, _vrfCoordinatorV2_5);
    }

    /**
        *@notice script's main function.
        *@return subId and coordinator address
    */
    function run() external returns (uint256, address) {
        return createSubscriptionUsingConfig();
    }
}