// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";

//Merkle Tree Scripts
import { GenerateInput } from "script/MerkleTree/GenerateInput.s.sol";
import { BuildMerkle } from "script/MerkleTree/BuildMerkle.s.sol";

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
    uint96 public constant MOCK_BASE_FEE = 5*10**16; //0.05 ether
    uint96 public constant MOCK_GAS_PRICE = 1*10**9; //1 gwei
    int256 public constant MOCK_WEI_PER_UNIT_LINK = 1*10**15;

    ///@notice it is the result of s_admin = makeAddress("s_admin"); on test file
    address public constant ADMIN = 0x18eC188C111868ed5eE6297dC4e92371BA68D468;
    address public constant ADMIN_TESTNET = 0x5FA769922a6428758fb44453815e2c436c57C3c7;
    bytes32 public constant ROOT = 0x864afd4c7895ba9b3dfaafecef38453e7ccac35762c169051c99ed3412f19362;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant AVALANCHE_FUJI_CHAIN_ID = 43113;
    uint256 public constant POL_AMOY_CHAIN_ID = 80002;
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
        bytes32 root;
    }
    // Local network state variables
    NetworkConfig public localNetworkConfig;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = _getSepoliaEthConfig();
        networkConfigs[AVALANCHE_FUJI_CHAIN_ID] = _getAvalancheFujiConfig();
        networkConfigs[POL_AMOY_CHAIN_ID] = _getPolygonAmoyConfig();
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

    function _getOrCreateAnvilEthConfig() private returns(NetworkConfig memory) {
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
            admin: ADMIN, //e.g anvil key 1
            deployer: ADMIN, //e.g anvil key 2
            minter: ADMIN, //e.g anvil key 3
            dataFeedsAggregator: address(feeds),
            link: address(0)/*link*/,
            subId: subId,
            keyHash: 0,
            vrfCoordinator: address(vrf),
            root: ROOT
        });

        return localNetworkConfig;
    }

    function _getSepoliaEthConfig() private pure returns(NetworkConfig memory sepoliaNetworkConfig_) {
        sepoliaNetworkConfig_ = NetworkConfig({
            admin: ADMIN_TESTNET, //Need to update it with your wallet address
            deployer: ADMIN_TESTNET, // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0xc59E3633BAAC79493d908e63626716e204A45EdF,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            subId: 58086061567021059456155470586811951315166220923014065007102875737901351044149,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, //needs to updated with the real one
            root: ROOT
        });
    }

    function _getAvalancheFujiConfig() private pure returns(NetworkConfig memory fujiNetworkConfig_) {
        fujiNetworkConfig_ = NetworkConfig({
            admin: ADMIN_TESTNET, //Need to update it with
            deployer: ADMIN_TESTNET, // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470,
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            subId: 0,
            keyHash: 0xc799bd1e3bd4d1a41cd4968997a4e03dfd2a3c7c04b695881138580163f42887,
            vrfCoordinator: address(0), //needs to updated with the real one
            root: ROOT
        });
    }

    function _getPolygonAmoyConfig() private pure returns(NetworkConfig memory amoyNetworkConfig_){
        amoyNetworkConfig_ = NetworkConfig({
            admin: ADMIN_TESTNET, //BURNER
            deployer: ADMIN_TESTNET, // your wallet address
            minter: address(0), // once you decided to deploy on testnet
            dataFeedsAggregator: 0xc2e2848e28B9fE430Ab44F55a8437a33802a219C,
            link: 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904,
            subId: 0,
            keyHash: 0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899,
            vrfCoordinator: 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2, //needs to updated with the real one
            root: ROOT
        });
    }
}