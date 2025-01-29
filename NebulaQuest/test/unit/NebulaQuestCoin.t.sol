// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";

contract NebulaStablecoinTest is Helper {
    
    //// Deploy Check ////
        function test_stablecoinDeploy() public view {
            assertTrue(address(coin) != address(0));
        }

    //// Stablecoin Basic Info's ////
        //Stablecoin's name check
        function test_stablecoinName() public view {
            assertEq(keccak256(abi.encodePacked("Nebula Stablecoin")), keccak256(abi.encodePacked(coin.name())));
        }

        //Stablecoin's symbol check
        function test_stablecoinSymbol() public view {
            assertEq(keccak256(abi.encodePacked("NSC")), keccak256(abi.encodePacked(coin.symbol())));
        }

        //// Access Control Roles ////
        //Default Admin Check
        function test_givenAdminRole() public view {
            assertEq(true, coin.hasRole(ADMIN_ROLE, s_admin));
        }

        //Minter Check
        function test_givenMinterRole() public view {
            assertEq(true, coin.hasRole(MINTER_ROLE, address(quest)));
        }

    //// Mint functionalities ////
        ///Mint Function Revert
        function test_accessControlRevertMint() public {
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, s_user01, MINTER_ROLE));
            coin.mint(s_user01, AMOUNT_TO_MINT);
        }

        ///Mint Function Performs Successfully
        function test_minterSuccessfullyMint() public {
            vm.prank(address(quest));
            vm.expectEmit();
            emit NebulaStablecoin_TokenMinted(s_user01, AMOUNT_TO_MINT);
            coin.mint(s_user01, AMOUNT_TO_MINT);
        }

    //// Burn Functionalities ////
        ///Burn Function Revert
        function test_accessControlRevertBurn() public mintTokens(address(quest)) {
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, s_user01, MINTER_ROLE));
            coin.burn(AMOUNT_TO_MINT);
        }

        ///Burn Function Succeed
        function test_minterSuccessfullyBurn() public mintTokens(address(quest)) {
            //Transfer the token to `s_minter`
            vm.prank(s_user01);
            coin.transfer(address(quest), AMOUNT_TO_MINT);

            assertEq(coin.balanceOf(address(quest)), AMOUNT_TO_MINT);

            //Burns the token
            vm.prank(address(quest));
            vm.expectEmit();
            emit NebulaStablecoin_TokenBurned(AMOUNT_TO_MINT);
            coin.burn(AMOUNT_TO_MINT);

            assertEq(coin.balanceOf(address(quest)), 0);
        }




}
