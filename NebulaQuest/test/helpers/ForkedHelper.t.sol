// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

//Foundry Tools
import {console2} from "forge-std/Console2.sol";

//Protocol Contracts
import {NebulaQuest} from "../../src/NebulaQuest.sol";

//Scripts
import {DeployInit} from "script/DeployInit.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

//Helpers
import {Helper} from "./Helper.t.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

//Chainlink contracts
///@notice Chainlink Imports
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

abstract contract ForkedHelper is Helper {

    //Fork Utils
    uint256 polygonFork;
    string POL_RPC = vm.envString("POL_RPC");
    address s_forkedAdmin;

    //Struct Instances
    NebulaQuest.Student student;

    function setUp() external override {
        //Create Fork
        polygonFork = vm.createFork(POL_RPC);
        vm.selectFork(polygonFork);

        //Deploy Script
        deployQuest = new DeployInit();
        (quest, pulsar, token, drop, helperConfig)= deployQuest.run();

        //Instantiate Tokens
        coin = quest.i_coin();
        nft = quest.i_nft();

        //recover Admin
        s_forkedAdmin = helperConfig.getConfig().admin;
                    
        //Grant minting powers to NebulaAirdrop
        vm.prank(s_forkedAdmin);
        token.grantRole(MINTER_ROLE, address(drop));
    }

    /// HELPER FUNCTIONS

    function interfaceReturnsTrue() public view returns(bool isInterface){
        isInterface = nft.supportsInterface(IERC721Receiver.onERC721Received.selector);
    }

    /**
        *@notice private function to query Prices Feeds data
        *@return _feedAnswer the value received from the AggregatorV3 contract
        *@dev the _feedAnswer has 8 decimals for this feed.
    */
    function getChainlinkDataFeed() public returns(int _feedAnswer) {
        (
            /* uint80 roundID */,
            _feedAnswer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(helperConfig.getConfig().dataFeedsAggregator).latestRoundData();
    }

    function getNameAndImageOfNFT(uint256 _level, uint256 _exp) public pure returns(string memory star_){
        if(_level == LEVEL_ONE){
            star_ = helperURI(
                "Stelar Dust",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/StelarDust.png",
                LEVEL_ONE,
                _exp
            );
        } else if( _level == LEVEL_TWO) {
            star_ = helperURI(
                "Protostar",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Protostar.png",
                LEVEL_TWO,
                _exp
            );
        } else if (_level == LEVEL_THREE) {
            star_ = helperURI(
                "Principal Sequence",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/PrincipalSequence.png",
                LEVEL_THREE,
                _exp
            );
        } else if (_level == LEVEL_FOUR) {
            star_ = helperURI(
                "Red Giant",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/RedGiant.png",
                LEVEL_FOUR,
                _exp
            );
        } else if (_level == LEVEL_FIVE) {
            star_ = helperURI(
                "White Dwarf",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/WhiteDwarf.png",
                LEVEL_FIVE,
                _exp
            );
        } else if (_level == LEVEL_SIX) {
            star_ = helperURI(
                "Supernova",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Supernova.png",
                LEVEL_SIX,
                _exp
            );
        } else if (_level == LEVEL_SEVEN) {
            star_ = helperURI(
                "BlackHole",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/Black%20Hole.png",
                LEVEL_SEVEN,
                _exp
            );
        }
    }
}
