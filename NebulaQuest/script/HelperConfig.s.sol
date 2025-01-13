// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";

///@notice Chainlink Imports
import {LinkToken} from "@chainlink/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";
import {MockV3Aggregator} from "@local/src/data-feeds/MockV3Aggregator.sol";

contract HelperConfig is Script {

    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 20*10**8;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant AVALANCHE_FUJI_CHAIN_ID = 43113;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;
    
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig {
        address admin;
        address deployer;
        address minter;
        address dataFeedsAggregator;
        address link;
    }
    // Local network state variables
    NetworkConfig public localNetworkConfig;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = _getSepoliaEthConfig();
        networkConfigs[AVALANCHE_FUJI_CHAIN_ID] = _getAvalancheFujiConfig();
    }

    function getConfig() external returns (NetworkConfig memory config_) {
        config_ = _getConfigByChainId(block.chainid);
    }

    /*////////////////////////////////////////////////////
                            Setter
    ////////////////////////////////////////////////////*/
    function setConfig(uint256 chainId, NetworkConfig memory networkConfig) external {
        networkConfigs[chainId] = networkConfig;
    }

    /*////////////////////////////////////////////////////
                            PRIVATE
    ////////////////////////////////////////////////////*/
    function _getConfigByChainId(uint256 chainId) private returns (NetworkConfig memory) {
        //Checks if it's a live chain or local environment
        if (networkConfigs[chainId].dataFeedsAggregator != address(0)) {
            //returns the live chain address
            return networkConfigs[chainId];
            //ensure that is the local environment
        } else if (chainId == LOCAL_CHAIN_ID) {
            //create the necessary values
            return _getOrCreateAnvilEthConfig();
        } else {
            //revert because something is wrong. It's not local or live environment
            revert HelperConfig__InvalidChainId();
        }
    }

    function _getOrCreateAnvilEthConfig() private returns (NetworkConfig memory) {
        // Check to see if we set an active network config
        if (localNetworkConfig.dataFeedsAggregator != address(0)) {
            return localNetworkConfig;
        }

        console2.log(unicode"⚠️ Mock contract Deployed");
        console2.log("It should've happened?");

        //Initiate the process
        vm.startBroadcast();
        MockV3Aggregator feeds =
            new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            admin: 0x18eC188C111868ed5eE6297dC4e92371BA68D468, //anvil key 1
            deployer: 0x18eC188C111868ed5eE6297dC4e92371BA68D468, // anvil key 2
            minter: address(0), // anvil key 3
            dataFeedsAggregator: address(feeds),
            link: address(0)/*link*/
        });
        return localNetworkConfig;
    }

    function _getSepoliaEthConfig() private pure returns (NetworkConfig memory mainnetNetworkConfig) {
        mainnetNetworkConfig = NetworkConfig({
            admin: address(0), //Need to update it with your wallet address
            deployer: address(0), // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0xc59E3633BAAC79493d908e63626716e204A45EdF,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function _getAvalancheFujiConfig() private pure returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            admin: address(0), //Need to update it with
            deployer: address(0), // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470,
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
        });
    }
}