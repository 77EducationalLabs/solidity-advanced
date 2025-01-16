// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

import { SecondMessage } from "../src/SecondMessage.sol";
import { MessageProxy } from "../src/proxy/MessageProxy.sol";

import { HelperConfig } from "./HelperConfig.s.sol";

import { ITransparentUpgradeableProxy, ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeInit is Script {
    SecondMessage public s_msg;
    HelperConfig s_helperConfig;

    function run(HelperConfig _helperConfig) public returns(SecondMessage message_){
		    //recover the information from the HelperConfig previously created
        HelperConfig.NetworkConfig memory config = _helperConfig.getConfig();
				
				//start breadcasting using the admin address
        vm.startBroadcast(config.admin);

        console2.log("Deploy SecondMessage");
        message_ = new SecondMessage();

        console2.log("Calls upgradeContract function");
        //Input the proxyAdmin, the proxy address and the newImplementation
        upgradeContract(config.proxyAdmin, config.proxy, address(message_));

        console2.log("End of process");
        vm.stopBroadcast();
    }

    function upgradeContract(address _proxyAdmin, address _proxy, address _implementation) public {
        console2.log("Cast the proxy with Transparent Interface");
        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(_proxy);
        
        //Instantiate the ProxyAdmin contracyt and cast the proxyAdmin address as a ProxyAdmin contract
        ProxyAdmin proxyAdmin = ProxyAdmin(_proxyAdmin);

        console2.log("Calls `upgradeAndCall");
        //Calls the upgradeAndCall function on ProxyAdmin
        proxyAdmin.upgradeAndCall(proxy, _implementation, bytes(""));
    }
}
