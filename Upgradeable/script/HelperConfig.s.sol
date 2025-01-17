// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig is Script{

    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig{
        address admin;
        address proxyAdmin;
        address implementation;
        address proxy;
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

    function setConfig(uint256 _chainId, NetworkConfig memory _config) public {
        s_networkConfigStorage[_chainId] = _config;
    }

    function getConfigByChain(uint256 chainId) public returns(NetworkConfig memory){

        if (s_networkConfigStorage[chainId].proxy != address(0)) {
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
        if (s_networkConfig.proxy != address(0)) {
            return s_networkConfig;
        }

        s_networkConfig = NetworkConfig({
            admin: ADMIN,
            proxyAdmin: address(0),
            implementation: address(0),
            proxy: address(0),
            data: abi.encodeWithSignature("initialize(string)", INITIAL_MESSAGE)
        });

        return s_networkConfig;
    }
}