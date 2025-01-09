///SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NebulaAirdrop{

    /// Type Declaration ///
    using SafeERC20 for IERC20;

    ///// Variables /////
    ///@notice immutable variable to store the token address
    IERC20 immutable i_coin;
    ///@notice immutable variable to store the merkleRoot
    bytes32 immutable i_merkleRoot;
    ///@notice constant variable to control user claims
    uint8 constant ONE = 1;

    ///// Storage /////
    ///@notice storage variable to keep track of address that already claimed
    mapping(address => uint8) private s_claimed;

    ///// Events /////
    ///@notice event emitted when a claim successfully happens
    event NebulaAirdrop_SuccessfulClaimed(uint256 amountClaimed);

    ///// Errors /////
    ///@notice error emitted when an user is not allowed
    error NebulaAirdrop_UserNotAllowed();
    ///@notice error emitted when an user already claimed
    error NebulaAirdrop_UserAlreadyClaimed();

    ///// Functions /////
    constructor(bytes32 _root, IERC20 _coin){
        i_merkleRoot = _root;
        i_coin = _coin;
    }

    function claimNebulaQuestToken(uint256 _amount, bytes32[] calldata _proofs) external {

        // if(s_claimed[user] == ONE) revert NebulaAirdrop_UserAlreadyClaimed();
        //TODO
        //get the identity of user, plus the amount, to calculate the leaf.
        bytes32 leaf;

        if(!MerkleProof.verify(_proofs, i_merkleRoot, leaf)) revert NebulaAirdrop_UserNotAllowed();


        // s_claimed[user] = ONE;
        emit NebulaAirdrop_SuccessfulClaimed(_amount);

        // i_coin.mint(user, _amount);
    }
}