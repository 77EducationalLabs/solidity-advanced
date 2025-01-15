// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig is Script{

    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig{
        address admin;
        address implementation;
        bytes data;
    }

    NetworkConfig public s_networkConfig;

    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant public ADMIN = address(1);
    string constant public INITIAL_MESSAGE = "77 Innovation Labs";

    mapping(uint256 chainId => NetworkConfig) public s_networkConfigStorage;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function getConfig() public returns(NetworkConfig memory config_){
        config_ = getConfigByChain(block.chainid);
    }

    function getConfigByChain(uint256 chainId) public returns(NetworkConfig memory){

        if (s_networkConfigStorage[chainId].admin != address(0)) {
            //returns the live chain address
            return s_networkConfigStorage[chainId];
            //ensure that is the local environment
        } else if (chainId == LOCAL_CHAIN_ID) {
            //create the necessary values
            return _getOrCreateAnvilEthConfig();
        } else {
            //revert because something is wrong. It's not local or live environment
            revert HelperConfig__InvalidChainId();
        }
    }

    function _getOrCreateAnvilEthConfig() private returns(NetworkConfig memory){
        // Check to see if we set an active network config
        if (s_networkConfig.admin != address(0)) {
            return s_networkConfig;
        }

        console2.log(unicode"⚠️ Mock contract Deployed");
        console2.log("It should've happened?");

        s_networkConfig = NetworkConfig({
            admin: ADMIN,
            implementation: address(0),
            data: abi.encodeWithSignature("initialize(string)", INITIAL_MESSAGE)
        });

        return s_networkConfig;
    }
}