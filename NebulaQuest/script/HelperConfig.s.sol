// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";

///@notice Chainlink Imports
import { LinkToken } from "@chainlink/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";
import { MockV3Aggregator } from "@local/src/data-feeds/MockV3Aggregator.sol";
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script {

    /*//////////////////////////////////////////////////////////////
                                VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 20*10**8;
    uint96 public constant MOCK_BASE_FEE = 25*10**16; //0.25 ether
    uint96 public constant MOCK_GAS_PRICE = 1*10**9; //1 gwei
    int256 public constant MOCK_WEI_PER_UNIT_LINK = 4*10**15;

    ///@notice it is the result of s_admin = makeAddress("s_admin"); on test file
    address public constant ADMIN = 0x18eC188C111868ed5eE6297dC4e92371BA68D468;

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
        uint256 subId;
        bytes32 keyHash;
        address vrfCoordinator;
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
        config_ = getConfigByChainId(block.chainid);
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
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
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
        vm.startBroadcast(ADMIN);
        //Data Feeds Mock
        MockV3Aggregator feeds =
            new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);

        //VRF Mock
        VRFCoordinatorV2_5Mock vrf=
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE, MOCK_WEI_PER_UNIT_LINK);

        uint256 subId = vrf.createSubscription();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            admin: ADMIN, //anvil key 1
            deployer: ADMIN, // anvil key 2
            minter: address(0), // anvil key 3
            dataFeedsAggregator: address(feeds),
            link: address(0)/*link*/,
            subId: subId,
            keyHash: 0x0,
            vrfCoordinator: address(vrf)
        });

        return localNetworkConfig;
    }

    function _getSepoliaEthConfig() private pure returns (NetworkConfig memory mainnetNetworkConfig) {
        mainnetNetworkConfig = NetworkConfig({
            admin: address(0), //Need to update it with your wallet address
            deployer: address(0), // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0xc59E3633BAAC79493d908e63626716e204A45EdF,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            subId: 0,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            vrfCoordinator: address(0) //needs to updated with the real one
        });
    }

    function _getAvalancheFujiConfig() private pure returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            admin: address(0), //Need to update it with
            deployer: address(0), // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470,
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            subId: 0,
            keyHash: 0xc799bd1e3bd4d1a41cd4968997a4e03dfd2a3c7c04b695881138580163f42887,
            vrfCoordinator: address(0) //needs to updated with the real one
        });
    }
}