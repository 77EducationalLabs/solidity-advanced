///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//Foundry Stuff
import {Test, console} from "forge-std/Test.sol";

///Scripts
import {HelperConfig} from "script/HelperConfig.s.sol";

contract HelperConfigTest is Test{
    HelperConfig helperConfig;

    function setUp() public {
        helperConfig = new HelperConfig();

    }

    //getConfigByChainId - First Branch Checked
    function test_getAmoyConfig() external {
        address linkUSDFeeds = 0xc2e2848e28B9fE430Ab44F55a8437a33802a219C;
        address linkToken = 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904;
        bytes32 amoyKeyHash = 0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899;
        bytes32 root = 0x864afd4c7895ba9b3dfaafecef38453e7ccac35762c169051c99ed3412f19362;

        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(helperConfig.POL_AMOY_CHAIN_ID());

        assertEq(config.admin, helperConfig.ADMIN_TESTNET());
        assertEq(config.deployer, helperConfig.ADMIN_TESTNET());
        assertEq(config.minter, address(0));
        console.log("Data Feeds next");
        assertEq(config.dataFeedsAggregator, linkUSDFeeds);
        assertEq(config.link, linkToken);
        assertEq(config.subId, 0);
        assertEq(config.keyHash, amoyKeyHash);
        assertEq(config.vrfCoordinator, 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2);
        assertEq(config.root, root);

    }

    //getConfigByChainId - Second Branch Checked
    function test_getAnvilConfig() external {
        bytes32 root = 0x864afd4c7895ba9b3dfaafecef38453e7ccac35762c169051c99ed3412f19362;

        //First Check if the struct starts empty
        (
            address admin,
            ,
            ,
            address dataFeedsAggregator,
            ,
            ,
            ,
            ,
            bytes32 emptyRoot
        ) = helperConfig.localNetworkConfig();
        //Check it -> should be empty
        assertEq(admin, address(0));
        assertEq(dataFeedsAggregator, address(0));
        assertEq(emptyRoot, 0);

        //Create a Anvil's config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(helperConfig.LOCAL_CHAIN_ID());

        //Check it.
        assertEq(config.admin, helperConfig.ADMIN());
        assertEq(config.deployer, helperConfig.ADMIN());
        assertEq(config.minter, helperConfig.ADMIN());
        assertTrue(config.dataFeedsAggregator != address(0));
        assertEq(config.link, address(0));
        assertTrue(config.subId > type(uint248).max);
        assertEq(config.keyHash, 0);
        assertTrue(config.vrfCoordinator != address(0));
        assertEq(config.root, root);
    }

    error HelperConfig__InvalidChainId();
    function test_getConfigByChainIdShouldRevert() external {
        
        vm.expectRevert(abi.encodeWithSelector(HelperConfig__InvalidChainId.selector));
        helperConfig.getConfigByChainId(1111904);
    }
}