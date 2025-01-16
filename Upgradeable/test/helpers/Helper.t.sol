///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { DeployInit } from "../../script/DeployInit.s.sol";
import { UpgradeInit } from "../../script/UpgradeInit.s.sol";

import { MessageProxy } from "../../src/proxy/MessageProxy.sol";
import { Message } from "../../src/Message.sol";
import { SecondMessage } from "../../src/SecondMessage.sol";

import { ITransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract Helper is Test {
    ///Deploy Script
    HelperConfig s_helperConfig;
    DeployInit s_deploy;
    UpgradeInit s_upgrade;

    ///Protocol Contracts Instances
    MessageProxy public s_proxy;
    Message public s_msg;

    ///Proxy Pattern instance for upgrades
    ITransparentUpgradeableProxy s_transp;

    ///Proxy Wrapper
    Message public s_msgProxy;
    SecondMessage public s_secondMsgProxy;

    ///Utils
    address s_admin = address(1);

    //Events 
    event Message_UpdatedMessage();
    event Message_MessageDeleted();

    //Errors
    error Helper_FailedToUpgrade();

    function setUp() public {
        s_deploy = new DeployInit();
        (s_helperConfig, s_msg, s_proxy) = s_deploy.run();

        s_msgProxy = Message(address(s_proxy));
    }

    function helper_deploySecondContractAndUpgrade() public {
        s_upgrade = new UpgradeInit();
        
        SecondMessage message = s_upgrade.run(s_helperConfig);

        if(address(message) == address(0)) revert Helper_FailedToUpgrade();

        s_secondMsgProxy = SecondMessage(address(s_proxy));
    }

}