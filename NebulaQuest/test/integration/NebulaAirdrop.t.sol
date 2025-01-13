///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Helper } from "../helpers/Helper.t.sol";
import { console2 } from "forge-std/Test.sol";

contract NebulaAirdropTest is Helper {

    ///print addresses
        function test_printAddressToConsole() public view {
            console2.log(s_admin);
            console2.log(s_user);
            console2.log(s_user01);
            console2.log(s_user02);
            console2.log(s_user03);
        }

    ///User can claim by himself
        function test_userCanClaim() public {
            uint256 userBalanceBefore = token.balanceOf(s_user);
            assertEq(userBalanceBefore, 0);

            vm.prank(s_user);
            drop.claimNebulaQuestToken(
                AMOUNT,
                s_proof
            );

            uint256 userBalanceAfter = token.balanceOf(s_user);
            assertEq(userBalanceAfter - userBalanceBefore , AMOUNT);
            console2.log("Test Succeed:", userBalanceAfter);
        }


    ///Sponsor claim with EIP712 signature
        function test_admCanSponsorClaimForUser() public {
            uint256 userBalanceBefore = token.balanceOf(s_user);
            assertEq(userBalanceBefore, 0);

            //get the s_user signature
            (
                uint8 v,
                bytes32 r,
                bytes32 s
            ) = helperSignMessage(
                s_userPrivateKey,
                s_user,
                s_deadline,
                s_nonce
            );

            vm.prank(s_admin);
            drop.claimNebulaQuestTokenWithSignature(
                s_user,
                AMOUNT,
                s_proof,
                s_deadline,
                v,
                r,
                s
            );

            uint256 userBalanceAfter = token.balanceOf(s_user);
            assertEq(userBalanceAfter - userBalanceBefore , AMOUNT);
            console2.log("Test Succeed: %d", userBalanceAfter);
        }
    
}