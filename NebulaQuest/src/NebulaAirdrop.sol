///SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { NebulaQuestToken } from "./NebulaQuestToken.sol";

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NebulaAirdrop is EIP712{
    ///// Type Declarations /////
    using ECDSA for bytes32;

    ///// Variables /////
    ///@notice Struct to hold the message struct
    struct AirdropInfo{
        address user;
        uint256 amount;
    }

    ///@notice constant variable to hold the message typehash
    bytes32 constant MESSAGE_TYPEHASH = keccak256("AirdropInfo(address user, uint256 amount)");
    ///@notice constant variable to control user claims
    uint8 constant ONE = 1;

    ///@notice immutable variable to store the token address
    NebulaQuestToken immutable i_coin;
    ///@notice immutable variable to store the merkleRoot
    bytes32 immutable i_merkleRoot;

    ///// Storage /////
    ///@notice storage variable to keep track of address that already claimed. ONE == true
    mapping(address => uint8) private s_hasClaimed;

    ///// Events /////
    ///@notice event emitted when a claim successfully happens
    event NebulaAirdrop_SuccessfulClaimed(address user, uint256 amountClaimed);

    ///// Errors /////
    ///@notice error emitted when an user is not allowed
    error NebulaAirdrop_UserNotAllowed();
    ///@notice error emitted when an user already claimed
    error NebulaAirdrop_UserAlreadyClaimed();
    ///@notice error emitted when the provided signature is invalid
    error NebulaAirdrop__InvalidSignature();

    ///// Functions /////
    constructor(
        bytes32 _root,
        NebulaQuestToken _coin
        ) EIP712("Nebula Airdrop", "1"){
        i_merkleRoot = _root;
        i_coin = _coin;
    }

    function claimNebulaQuestTokenWithSignature(
        address _claimer,
        uint256 _amount,
        bytes32[] calldata _proofs,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if(s_hasClaimed[_claimer] == ONE) revert NebulaAirdrop_UserAlreadyClaimed();

        //Recover the signer e check against the claimer address.
        if (!_isValidSignature(_claimer, getMessageHash(_claimer, _amount), _v, _r, _s)) revert NebulaAirdrop__InvalidSignature();

        //TODO
        //Verify the Merkle Proof calculating the lead node hash
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_claimer, _amount))));

        //Checks if the user is allowed by reconstructing the merkle root using proofs and the specific leaf
        if(!MerkleProof.verify(_proofs, i_merkleRoot, leaf)) revert NebulaAirdrop_UserNotAllowed();

        //Update user status
        s_hasClaimed[_claimer] = ONE;

        emit NebulaAirdrop_SuccessfulClaimed(_claimer, _amount);

        //Mint tokens
        i_coin.mint(_claimer, _amount);
    }

    function claimNebulaQuestToken(
        address _claimer,
        uint256 _amount,
        bytes32[] calldata _proofs
    ) external {
        if(s_hasClaimed[_claimer] == ONE) revert NebulaAirdrop_UserAlreadyClaimed();

        //TODO
        //Verify the Merkle Proof calculating the lead node hash
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_claimer, _amount))));

        //Checks if the user is allowed by reconstructing the merkle root using proofs and the specific leaf
        if(!MerkleProof.verify(_proofs, i_merkleRoot, leaf)) revert NebulaAirdrop_UserNotAllowed();

        //Update user status
        s_hasClaimed[_claimer] = ONE;

        emit NebulaAirdrop_SuccessfulClaimed(_claimer, _amount);

        //Mint tokens
        i_coin.mint(_claimer, _amount);
    }

    /**
        *@notice private function to build the message type hash based in the AirdropInfo structure
        *@param _claimer the user to build the type hash for
        *@param _amount the amount of tokens to claim
    */
    function getMessageHash(address _claimer, uint256 _amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropInfo({user: _claimer, amount: _amount})))
        );
    }

    /**
        *@notice function used to validate signatures using ECDSA
        Be aware that only EOA's can be validated
        *@dev To also verify smart contract wallets signatures, refer to OZ SignatureChecker
        *@param _claimer the user to check against the signature
        *@param _digest the message type hash built with airdrop information
        *@param _v -
        *@param _r -
        *@param _s -
        *@return _isValid true or false
    */
    function _isValidSignature(
        address _claimer,
        bytes32 _digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (bool){
        (
            address actualSigner,
                                ,
        ) = ECDSA.tryRecover(_digest, _v, _r, _s);
        return (actualSigner == _claimer);
    }
}