// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

///@notice Forge Tools
import { Script, console2 } from "forge-std/Script.sol";

///@notice Protocol Contracts
import { Message } from "../src/Message.sol";
import { SecondMessage } from "../src/SecondMessage.sol";

///@notice Config Helper Script
import { HelperConfig } from "./HelperConfig.s.sol";

///@notice OZ Contracts
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UpgradeInit is Script {
    SecondMessage public s_msg;

    function run(HelperConfig _helperConfig) public returns(SecondMessage message_){
        //Get helpers infos
        HelperConfig.NetworkConfig memory config = _helperConfig.getConfig();
				
		//start broadcasting using the admin address
        vm.startBroadcast(config.admin);

        console2.log("Deploy SecondMessage");
        message_ = new SecondMessage();

        console2.log("Calls upgradeContract function");
        //Input the proxyAdmin, the proxy address and the newImplementation
        upgradeContract(config.proxy, address(message_));

        console2.log("End of process");
        vm.stopBroadcast();
    }

    function upgradeContract(address _proxy, address _implementation) public {
        ///Cast the proxy address as Message, so we can call the upgrade function.
        Message proxyInterface = Message(_proxy);

        console2.log("Calling `upgradeToAndCall");
        //Calls the upgradeToAndCall function on ProxyAdmin
        proxyInterface.upgradeToAndCall(_implementation, bytes(""));
    }
}
