// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity 0.8.26;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract NebulaQuestToken is ERC20, ERC20Burnable, AccessControl, ERC20Permit {

    ///// State Variables /////
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    ///// Functions /////

    /**
        *@notice constructor to initialize contract variables
        *@param _owner the owner and administrator of the contract
        *@param _minter the address allowed to mint tokens
    */
    constructor(address _owner, address _minter)
        ERC20("NebulaQuestToken", "NQT")
        ERC20Permit("NebulaQuestToken")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(MINTER_ROLE, _minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
