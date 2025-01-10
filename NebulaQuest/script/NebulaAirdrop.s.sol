// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { NebulaQuestToken } from "../src/NebulaQuestToken.sol";
import { NebulaAirdrop } from "../src/NebulaAirdrop.sol";

contract NebulaAirdropScript is Script {
    bytes32 public s_root = 0x864afd4c7895ba9b3dfaafecef38453e7ccac35762c169051c99ed3412f19362;
    address public s_admin = 0x18eC188C111868ed5eE6297dC4e92371BA68D468; //s_admin address from NebulaAirdrop.t.sol

    // Deploy the airdrop contract and nebula token contract
    function deployNebulaAirdropSystem() public returns (NebulaAirdrop drop, NebulaQuestToken token) {
        vm.startBroadcast();

        token = new NebulaQuestToken(s_admin, s_admin);
        drop = new NebulaAirdrop(s_root, token);

        vm.stopBroadcast();
    }

    function run() external returns (NebulaAirdrop, NebulaQuestToken) {
        return deployNebulaAirdropSystem();
    }
}