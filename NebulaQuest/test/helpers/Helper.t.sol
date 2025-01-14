// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

//Foundry Tools
import { Test, console2 } from "forge-std/Test.sol";

//Protocol Contracts
import { NebulaStablecoin } from "../../src/NebulaStablecoin.sol";
import { NebulaQuest } from "../../src/NebulaQuest.sol";
import { NebulaEvolution } from "../../src/NebulaEvolution.sol";
import { NebulaAirdrop  } from "../../src/NebulaAirdrop.sol";
import { NebulaQuestToken } from "../../src/NebulaQuestToken.sol";
import { NebulaQuestPulsar } from "../../src/NebulaQuestPulsar.sol";

//Scripts
import { DeployInit } from "../../script/DeployInit.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";

//Helpers
import { Strings } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

abstract contract Helper is Test {

    //Type Declarations
        using Strings for uint256;

    //Scripts Instances
        DeployInit deployQuest;
        HelperConfig helperConfig;

    //Contracts Instances
        NebulaStablecoin stablecoin;
        NebulaQuest quest;
        NebulaEvolution evolution;
        NebulaAirdrop drop;
        NebulaQuestToken token;
        NebulaQuestPulsar pulsar;

    //NebulaQuest variables
        NebulaStablecoin coin;
        NebulaEvolution nft;

    //Stablecoin variables
        bytes32 ADMIN_ROLE;
        bytes32 MINTER_ROLE;

    //State Variables ~ Utils
        address s_admin = makeAddr("s_admin");
        address s_minter = makeAddr("s_minter");
        address s_user;
        uint256 s_userPrivateKey;
        address s_user01 = address(1);
        address s_user02 = address(2);
        address s_user03 = address(3);
        address s_user04 = address(4);
        uint48 s_deadline = uint48(block.timestamp + 60);
        uint48 s_nonce;
    
    //MAGIC NUMBERS
        uint256 constant AMOUNT_TO_MINT = 10*10**18;
        uint256 constant SCORE_TEN_OF_TEN = 1000;
        uint256 constant AMOUNT = 5 * 1e18; ///Variable to define de value to be distributed through the airdrop
        uint256 constant LINK_VALUE = 20*10**18;
        uint256 constant DECIMALS = 10**18;

    //Testing Utils
        uint256 constant LEVEL_ONE = 1;
        uint256 constant LEVEL_TWO = 2;
        uint256 constant LEVEL_THREE = 3;
        uint256 constant LEVEL_FOUR = 4;
        uint256 constant LEVEL_FIVE = 5;
        uint256 constant LEVEL_SIX = 6;
        uint256 constant LEVEL_SEVEN = 7;
        uint256 constant EXP_ONE = 0;
        uint256 constant EXP_TWO = 1000;
        uint256 constant EXP_THREE = 2000;
        uint256 constant EXP_FOUR = 3000;
        uint256 constant EXP_FIVE = 4000;
        uint256 constant EXP_SIX = 5000;
        uint256 constant EXP_SEVEN = 6000;

    //Merkle Stuff
        bytes32 constant MERKLE_ROOT = 0x864afd4c7895ba9b3dfaafecef38453e7ccac35762c169051c99ed3412f19362;
    //The proofs for the "first branch" of the tree
        bytes32 constant PROOF_ONE = 0x80f2a786286ac1b15e44029c244b0148c6e5140530d0b48c678235945822c1f6; //l8
        bytes32 constant PROOF_TWO = 0x443568f55ac26d0b2805f40148bc2a7bc63847a4e84bcf6e3154b239463f9e13; //l9
        bytes32[] s_proof = [PROOF_ONE, PROOF_TWO];

    //Events
        event NebulaStablecoin_TokenMinted(address _to, uint256 _amount);
        event NebulaStablecoin_TokenBurned(uint256 _amount);
        event NebulaQuest_AnswersUpdated(uint8 examIndex);
        event NebulaQuest_ExamFailed(address user, uint8 examIndex, uint16 score);
        event NebulaQuest_ExamPassed(address user, uint8 examIndex, uint16 score);
        event NebulaEvolution_LevelUpdated(uint256 level,  uint256 amountOfExp);
        event NebulaEvolution_TheGasIsFreezingABirthIsOnTheWay(uint256 tokenId);
        event NebulaEvolution_NFTUpdated(uint256 tokenId, uint256 level, string finalURI);

    // Errors
        error AccessControlUnauthorizedAccount(address account, bytes32 role);
        error OwnableUnauthorizedAccount(address caller);
        error NebulaQuest_WrongAmountOfAnswers(uint256 numberOfAnswers, uint8 expectedNumberOfAnswers);
        error NebulaQuest_MustAnswerAllQuestions(uint256,uint256);
        error NebulaQuest_NonExistentExam(uint8);
        error NebulaEvolution_ThereAreOnlySevenLevels(uint256 level);
        error NebulaEvolution_AlreadyHasAnNFT();
        error NebulaEvolution_InvalidNFTId();
        error NebulaQuestPulsar_NotEnoughParticipants(uint256 numOfWords, uint256 participants);


    //Setup
        function setUp() external {
            deployQuest = new DeployInit();
            (quest, pulsar, helperConfig)= deployQuest.run();

            stablecoin = new NebulaStablecoin("Nebula Stablecoin","NSN", s_admin, s_minter);
            evolution = new NebulaEvolution("Nebula Evolution","NET", s_admin, s_minter);
            token = new NebulaQuestToken(s_admin, s_admin);
            drop = new NebulaAirdrop(MERKLE_ROOT, token);

            (s_user, s_userPrivateKey) = makeAddrAndKey("s_user");

            //Getters
            coin = quest.i_coin();
            nft = quest.i_nft();
            ADMIN_ROLE = stablecoin.DEFAULT_ADMIN_ROLE();
            MINTER_ROLE = stablecoin.MINTER_ROLE();
            
            //Grant minting powers to NebulaAirdrop
            vm.prank(s_admin);
            token.grantRole(MINTER_ROLE, address(drop));
        }

    //Modifiers
        modifier mintTokens(){
            //Mint tokens
            vm.prank(s_minter);
            vm.expectEmit();
            emit NebulaStablecoin_TokenMinted(s_user01, AMOUNT_TO_MINT);
            stablecoin.mint(s_user01, AMOUNT_TO_MINT);
            _;
        }

        modifier setAnswers(){
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("test1"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("test8"));
            correctAnswers[8] = keccak256(abi.encodePacked("test9"));
            correctAnswers[9] = keccak256(abi.encodePacked("test10"));

            //Test
            vm.prank(s_admin);
            vm.expectEmit();
            emit NebulaQuest_AnswersUpdated(examNumber);
            quest.answerSetter(examNumber, correctAnswers);
            _;
        }

        modifier setLevels(){
            vm.startPrank(s_admin);
            evolution.levelsSetter(LEVEL_ONE, EXP_ONE);
            evolution.levelsSetter(LEVEL_TWO, EXP_TWO);
            evolution.levelsSetter(LEVEL_THREE, EXP_THREE);
            evolution.levelsSetter(LEVEL_FOUR, EXP_FOUR);
            evolution.levelsSetter(LEVEL_FIVE, EXP_FIVE);
            evolution.levelsSetter(LEVEL_SIX, EXP_SIX);
            evolution.levelsSetter(LEVEL_SEVEN, EXP_SEVEN);
            vm.stopPrank();
            _;
        }

    //Nebula Quest helpers
        ///@notice Function to create Two exams at same time.
        function multipleExams() public setAnswers{
            uint8 examNumber = 2;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("secondTest1"));
            correctAnswers[1] = keccak256(abi.encodePacked("secondTest2"));
            correctAnswers[2] = keccak256(abi.encodePacked("secondTest3"));
            correctAnswers[3] = keccak256(abi.encodePacked("secondTest4"));
            correctAnswers[4] = keccak256(abi.encodePacked("secondTest5"));
            correctAnswers[5] = keccak256(abi.encodePacked("secondTest6"));
            correctAnswers[6] = keccak256(abi.encodePacked("secondTest7"));
            correctAnswers[7] = keccak256(abi.encodePacked("secondTest8"));
            correctAnswers[8] = keccak256(abi.encodePacked("secondTest9"));
            correctAnswers[9] = keccak256(abi.encodePacked("secondTest10"));

            //Test
            vm.prank(s_admin);
            vm.expectEmit();
            emit NebulaQuest_AnswersUpdated(examNumber);
            quest.answerSetter(examNumber, correctAnswers);
        }

    //Nebula Evolution Helper
        ///@notice Function to create the URI to compare to updated NFT
        function helperURI(string memory _name, string memory _image, uint256 _nftLevel, uint256 _exp) public pure returns(string memory finalURI){
            string memory uri = Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "', _name, '",'
                            '"description": "Nebula Evolution",',
                            '"image": "', _image, '",'
                            '"attributes": [',
                                '{"trait_type": "Level",',
                                '"value": ', _nftLevel.toString(),'}',
                                ',{"trait_type": "Exp",',
                                '"value": ', _exp.toString(),'}',
                            ']}'
                        )
                    )
                )
            );

            // Create token URI
            finalURI = string(
                abi.encodePacked("data:application/json;base64,", uri)
            );
        }

    /// EIP712 Helpers testing
        ///@notice function to get the `v, r, s` and test the Airdrop With Signature Claim
        function helperSignMessage(
            uint256 _privKey, 
            address _account, 
            uint48 _deadline, 
            uint48 _nonce
        ) public view returns(uint8 _v, bytes32 _r, bytes32 _s) {
            bytes32 digest = drop.getMessageHash(_account, _deadline, _nonce, AMOUNT);
            (_v, _r, _s) = vm.sign(_privKey, digest);
        }

    /// VRF Testing Helpers
        ///@notice function to create the array of answers
        function getAnswersForExamOne() public pure returns(bytes32[] memory){
            bytes32[] memory answers = new bytes32[](10);
            answers[0] = keccak256(abi.encodePacked("test1"));
            answers[1] = keccak256(abi.encodePacked("test2"));
            answers[2] = keccak256(abi.encodePacked("test3"));
            answers[3] = keccak256(abi.encodePacked("test4"));
            answers[4] = keccak256(abi.encodePacked("test5"));
            answers[5] = keccak256(abi.encodePacked("test6"));
            answers[6] = keccak256(abi.encodePacked("test7"));
            answers[7] = keccak256(abi.encodePacked("test8"));
            answers[8] = keccak256(abi.encodePacked("test9"));
            answers[9] = keccak256(abi.encodePacked("test10"));

            return answers;
        }

        ///@notice function to submit answers for multiple users
        function prepareEnvironmentToVRFRequest() public{
            uint8 examId = 1;
            bytes32[] memory answersOne = new bytes32[](10);
            answersOne = getAnswersForExamOne();

            vm.prank(s_user01);
            quest.submitAnswers(examId, answersOne);//0,
            vm.prank(s_user02);
            quest.submitAnswers(examId, answersOne);//0,1
            vm.prank(s_user03);
            quest.submitAnswers(examId, answersOne);//0,1,2
            vm.prank(s_user04);
            quest.submitAnswers(examId, answersOne);//0,1,2,3
        }

}
