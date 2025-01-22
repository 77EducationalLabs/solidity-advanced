///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

///Protocol Imports
import { NebulaEvolution } from "./NebulaEvolution.sol";

///Chainlink Imports
import { VRFConsumerBaseV2Plus } from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import { VRFV2PlusClient } from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract NebulaQuestPulsar is VRFConsumerBaseV2Plus{
    
    /*////////////////////////////////////////////////
                    STATE VARIABLES
    ////////////////////////////////////////////////*/
    ///@notice struct to format the requests info
    struct Requests {
        bool exists;
        bool fulfilled;
        bool finished;
        uint48 participants;
        uint256[] randomWords;
    }

    ///@notice immutable variable to hold the Chainlink VRF sub Id.
    uint256 immutable i_subscriptionId;
    ///@notice immutable variable to specify the chosen lane/max gas price
    bytes32 immutable i_keyHash;

    ///@notice immutable variable to hold the NebulaEvolution address
    NebulaEvolution immutable i_evolution;

    ///@notice constant variable to store the cost to store each random word
    uint32 constant COST_BY_WORD = 100_000;
    ///@notice constant variable to store the number of confirmations
    uint16 constant NUM_CONFIRMATIONS = 3; //@audit - UPDATE ACCORDINGLY TO THE NETWORK USED

    ///@notice mapping to store VRF requests
    mapping(uint256 requestId => Requests) s_requests;

    /*////////////////////////////////////////////////
                        EVENTS
    ////////////////////////////////////////////////*/
    ///@notice event emitted when a new request is sent
    event NebulaQuestPulsar_RequestSent(uint256 requestId, uint256 numWords);
    ///@notice event emitted when a new request is fulfilled
    event NebulaQuestPulsar_RequestFulfilled(uint256 requestId, uint256[] randomWords);
    ///@notice event emitted when a new request is finalized
    event NebulaQuestPulsar_WinnersSelected(uint256 requestId, address[] winnerAddresses);

    /*////////////////////////////////////////////////
                        ERRORS
    ////////////////////////////////////////////////*/
    ///@notice error emitted when the num of words is bigger than the num. of participants
    error NebulaQuestPulsar_NotEnoughParticipants(uint256 numOfWords, uint256 participants);
    ///@notice error emitted when a non existent request is provided
    error NebulaQuestPulsar_NonExistentRequest(uint256 requestId);
    ///@notice error emitted when an already fulfilled requestId is provided
    error NebulaQuestPulsar_RequestAlreadyFulfilled(uint256 requestId);
    ///@notice error emitted when the `processWinners`function receive a non fulfilled requestId
    error NebulaQuestPulsar_RequestNotFulfilledYet(uint256 requestId, bool fulfilled);
    ///@notice error emitted when the `processWinners` function receive an already processed requestId
    error NebulaQuestPulsar_RequestAlreadyProcessed(uint256 requestId, bool finished);

    /*////////////////////////////////////////////////
                        FUNCTIONS
    ////////////////////////////////////////////////*/
    constructor(
        uint256 _subId,
        bytes32 _keyHash,
        address _vrfCoordinator,
        address _evolution
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_subscriptionId = _subId;
        i_keyHash = _keyHash;
        i_evolution = NebulaEvolution(_evolution);
    }

    /*////////////////////////////////////////////////
                        External
    ////////////////////////////////////////////////*/
    /**
        *@notice external access controlled function to start Chainlink VRF requests
        *@param _numOfWords the amount of random numbers to be generated
        *@dev the _numOfWords must not be bigger than the amount of participants. Otherwise, revert.
    */
    function requestRandomWords(
        uint32 _numOfWords
    ) external onlyOwner returns (uint256 requestId_) {
        uint256 participants = i_evolution.getLastNFTId();
        if(_numOfWords > participants) revert NebulaQuestPulsar_NotEnoughParticipants(_numOfWords, participants);

        requestId_ = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: NUM_CONFIRMATIONS,
                callbackGasLimit: _numOfWords * COST_BY_WORD,
                numWords: _numOfWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: false
                    })
                )
            })
        );

        s_requests[requestId_] = Requests({
            exists: true,
            fulfilled: false,
            finished: false,
            participants: uint48(participants -1),
            randomWords: new uint256[](0)
        });

        emit NebulaQuestPulsar_RequestSent(requestId_, _numOfWords);
    }

    /**
        *@notice external access controlled function to process winners
        *@param _requestId the Id to process the results
        *@dev this functions can be called only once by valid ID.
        *@dev the ID must exists and be fulfilled previously
        *@dev the winners will be shared through an event for off-chain listeners
    */
    function processWinners(uint256 _requestId) external onlyOwner{
        Requests memory request = s_requests[_requestId];
        if(!request.exists) revert NebulaQuestPulsar_NonExistentRequest(_requestId);
        if(!request.fulfilled) revert NebulaQuestPulsar_RequestNotFulfilledYet(_requestId, request.fulfilled);
        if(request.finished) revert NebulaQuestPulsar_RequestAlreadyProcessed(_requestId, request.finished);

        uint256 randomNumberAmount = request.randomWords.length;
        address[] memory winnersAddresses = new address[](randomNumberAmount);

        for(uint256 i; i < randomNumberAmount; ++i){
            winnersAddresses[i] = i_evolution.ownerOf(request.randomWords[i] % request.participants);
        }

        s_requests[_requestId].finished = true;

        emit NebulaQuestPulsar_WinnersSelected(_requestId, winnersAddresses);
    }

    /*////////////////////////////////////////////////
                        Internal
    ////////////////////////////////////////////////*/
    /**
        *@notice internal function required by Chainlink VRF.
        *@param _requestId the number of the request being fulfilled
        *@param _randomWords the cryptographically provable random numbers generated
        *@dev This functions should only revert if: Request doesn`t exists or is already fulfilled
    */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        Requests storage request = s_requests[_requestId];

        if(!request.exists) revert NebulaQuestPulsar_NonExistentRequest(_requestId);
        if(request.fulfilled) revert NebulaQuestPulsar_RequestAlreadyFulfilled(_requestId);

        request.fulfilled = true;
        request.randomWords = _randomWords;

        emit NebulaQuestPulsar_RequestFulfilled(_requestId, _randomWords);
    }

    /*////////////////////////////////////////////////
                        View & Pure
    ////////////////////////////////////////////////*/
    /**
        *@notice getter function to access requests data
        *@dev anyone can verify the received info
    */
    function getRequestStatus(
        uint256 _requestId
    ) external view returns (Requests memory request_) {
        if(!s_requests[_requestId].exists) revert NebulaQuestPulsar_NonExistentRequest(_requestId);

        request_ = s_requests[_requestId];
    }
}