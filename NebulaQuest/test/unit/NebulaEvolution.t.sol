//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";

contract NebulaEvolutionTest is Helper {
    
    ///Checking Evolution Levels
        function test_levelAreSetAsExpected() public setLevels(s_admin){
            assertEq(nft.s_expPerLevel(LEVEL_ONE), EXP_ONE);
            assertEq(nft.s_expPerLevel(LEVEL_TWO), EXP_TWO);
            assertEq(nft.s_expPerLevel(LEVEL_THREE), EXP_THREE);
            assertEq(nft.s_expPerLevel(LEVEL_FOUR), EXP_FOUR);
            assertEq(nft.s_expPerLevel(LEVEL_FIVE), EXP_FIVE);
            assertEq(nft.s_expPerLevel(LEVEL_SIX), EXP_SIX);
            assertEq(nft.s_expPerLevel(LEVEL_SEVEN), EXP_SEVEN);
        }

        function test_NameIsDefinedCorrectly() public view{
            (string memory nameOne, string memory imageOne) = nft.s_starInformation(LEVEL_ONE);
            assertEq(keccak256(abi.encodePacked(nameOne)), keccak256(abi.encodePacked("Stelar Dust")));
            assertEq(keccak256(abi.encodePacked(imageOne)), keccak256(abi.encodePacked("https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/StelarDust.png")));

            (string memory nameTwo, string memory imageTwo) = nft.s_starInformation(LEVEL_TWO);
            assertEq(keccak256(abi.encodePacked(nameTwo)), keccak256(abi.encodePacked("Protostar")));
            assertEq(keccak256(abi.encodePacked(imageTwo)), keccak256(abi.encodePacked("https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Protostar.png")));

        }

    /// levelsSetter
        function test_levelSetterRevertBecauseRole() public {
            
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, address(this), ADMIN_ROLE));
            nft.levelsSetter(LEVEL_ONE, 0);
        }

        function test_levelSetterRevertBecauseOfWrongLevel() public {
            uint256 tooHighLevel = 10;
            uint256 randomEXP = 10000;

            vm.prank(s_admin);
            vm.expectRevert(abi.encodeWithSelector(NebulaEvolution_ThereAreOnlySevenLevels.selector, tooHighLevel));
            nft.levelsSetter(tooHighLevel, randomEXP);
        }

        function test_levelSetterUpdateState() public {
            vm.startPrank(s_admin);
            vm.expectEmit();
            emit NebulaEvolution_LevelUpdated(LEVEL_ONE, EXP_ONE);
            nft.levelsSetter(LEVEL_ONE, EXP_ONE);
            nft.levelsSetter(LEVEL_TWO, EXP_TWO);
            vm.stopPrank();

            assertEq(nft.s_expPerLevel(LEVEL_ONE), EXP_ONE);
            assertEq(nft.s_expPerLevel(LEVEL_TWO), EXP_TWO);
        }
    
    /// safeMint
        function test_safeMintRevertsBecauseOfRole() public setLevels(s_admin){
            
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, address(this), MINTER_ROLE));
            nft.safeMint(s_user01);
        }

        function test_safeMintSucceed() public setLevels(s_admin){
            uint256 tokenId = 0;
            
            vm.prank(address(quest));
            vm.expectEmit();
            emit NebulaEvolution_TheGasIsFreezingABirthIsOnTheWay(tokenId);
            nft.safeMint(s_user01);

            assertEq(nft.balanceOf(s_user01), 1);
            string memory tokenURI = nft.tokenURI(tokenId);
            assertTrue(keccak256(abi.encodePacked(tokenURI)).length != 0);
        }

        function test_safeMintRevertBecauseMultipleTokens() public {

            vm.startPrank(address(quest));
            nft.safeMint(s_user01);

            assertEq(nft.balanceOf(s_user01), 1);

            vm.expectRevert(abi.encodeWithSelector(NebulaEvolution_AlreadyHasAnNFT.selector));
            nft.safeMint(s_user01);

            vm.stopPrank();
        }

    /// updateNFT
        function test_updateNFTRevertBecauseOfRole() public setLevels(s_admin){
            vm.prank(address(quest));
            nft.safeMint(s_user01);

            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, address(this), MINTER_ROLE));
            nft.updateNFT(0, EXP_TWO);
        }

        function test_updateNFTRevertBecauseID() public setLevels(s_admin){
            uint256 tokenId = 10;

            vm.startPrank(address(quest));
            vm.expectRevert(abi.encodeWithSelector(NebulaEvolution_InvalidNFTId.selector));
            nft.updateNFT(tokenId, EXP_TWO);
        }
    
        function test_updateNFTSucceed() public setLevels(s_admin){
            uint256 tokenId = 0;

            //mint token
            vm.startPrank(address(quest));
            nft.safeMint(s_user01);

            //generate new uri
            string memory finalURI = helperURI(
                "Protostar",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Protostar.png",
                LEVEL_TWO,
                EXP_TWO)
            ;

            vm.expectEmit();
            emit NebulaEvolution_NFTUpdated(tokenId, LEVEL_TWO, finalURI);
            nft.updateNFT(0, EXP_TWO);

            vm.stopPrank();
        }
}