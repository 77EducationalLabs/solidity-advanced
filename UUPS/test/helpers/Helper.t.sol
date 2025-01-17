///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

///@notice Foundry Helpers
import {Test, console} from "forge-std/Test.sol";

///@notice Protocol Scripts
import { DeployInit } from "../../script/DeployInit.s.sol";
import { UpgradeInit } from "../../script/UpgradeInit.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";

///@notice Protocol Contracts
import { Message } from "../../src/Message.sol";
import { SecondMessage } from "../../src/SecondMessage.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Helper is Test {
    ///Deploy Script
    DeployInit s_deploy;
    UpgradeInit s_upgrade;
    HelperConfig s_helperConfig;

    ///Protocol Contracts Instances
    ERC1967Proxy public s_proxy;
    Message public s_msg;

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