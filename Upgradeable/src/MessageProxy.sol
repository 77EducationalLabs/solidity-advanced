///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { MessageStorage } from "../storage/MessageStorage.sol";

contract MessageProxy is TransparentUpgradeableProxy, MessageStorage{

    /*///////////////////////////////////
                Functions
    ///////////////////////////////////*/
    constructor(
        address _logic,
        address _initialOwner,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, _initialOwner, _data){}
}