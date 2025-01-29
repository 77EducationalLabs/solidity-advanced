// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//Foundry
import { Script, console } from "forge-std/Script.sol";

//Our Scripts
import { HelperConfig } from "../HelperConfig.s.sol";
import { VRFCreateSub } from "./VRFCreateSub.s.sol";

//Chainlink stuff
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import { LinkToken } from "@chainlink/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";

contract VRFFundSubscription is Script {
    uint96 public constant LOCAL_INITIAL_LINK_AMOUNT = 100*10**18;
    uint96 public constant INITIAL_LINK_AMOUNT = 25*10**18;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    /**
        *@notice function to add funds to a subscription
    */
    function fundSubscriptionUsingConfig() public {
        ///@notice deploys a new HelperConfig to get chain info.
        HelperConfig helperConfig = new HelperConfig();
        ///@notice get subId from config for the specific chain
        uint256 subId = helperConfig.getConfig().subId;
        ///@notice get the coordinator for the specific chain
        address vrfCoordinatorV2_5 = helperConfig.getConfig().vrfCoordinator;
        ///@notice get the link token for the specific chain
        address link = helperConfig.getConfig().link;
        ///@notice get the account for the specific chain
        address account = helperConfig.getConfig().admin;

        ///@notice checks if has a valid subId
        if (subId == 0) {
            ///@notice if not, deploys a new instance of VRFCreateSub
            VRFCreateSub createSub = new VRFCreateSub();
            (uint256 updatedSubId, address updatedVRFv2) = createSub.run();
            subId = updatedSubId;
            vrfCoordinatorV2_5 = updatedVRFv2;
            console.log("New SubId Created! ", subId, "VRF Address: ", vrfCoordinatorV2_5);
        }

        ///@notice calls `fundSubscription` to add funds to the previous or recently created sub
        fundSubscription(vrfCoordinatorV2_5, subId, link, account);
    }

    /**
        *@notice function to add funds to the subscription.
        *@param vrfCoordinatorV2_5 the address of the coordinator to fund the subscription
        *@param subId the sub to be funded
        *@param link the address of the funding token
        *@param account the caller and owner of the sub.
    */
    function fundSubscription(address vrfCoordinatorV2_5, uint256 subId, address link, address account) public {
        console.log("Funding subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinatorV2_5);
        console.log("On ChainID: ", block.chainid);
        
        ///@notice checks if the chain is a local anvil chain
        if (block.chainid == LOCAL_CHAIN_ID) {
            ///@notice start broadcasting the account
            vm.startBroadcast(account);
            ///@notice fund the mock subscription with link
            VRFCoordinatorV2_5Mock(vrfCoordinatorV2_5).fundSubscription(subId, LOCAL_INITIAL_LINK_AMOUNT);
            vm.stopBroadcast();
            ///@notice if it's not a local chain
        } else {
            console.log(LinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(LinkToken(link).balanceOf(address(this)));
            console.log(address(this));

            ///@notice broadcast the account
            vm.startBroadcast(account);
            ///@notice transfer the amount of link to be funded with a built-in call to register the deposit
            LinkToken(link).transferAndCall(vrfCoordinatorV2_5, INITIAL_LINK_AMOUNT, abi.encode(subId));
            vm.stopBroadcast();
        }
    }

    /**
        *@notice Script's main function
    */
    function run() external {
        fundSubscriptionUsingConfig();
    }
}