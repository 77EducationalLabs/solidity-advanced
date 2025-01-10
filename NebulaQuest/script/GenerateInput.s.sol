// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

// Merkle tree input file generator script
contract GenerateInput is Script {
    ///Variable to define de value to be distributed
    uint256 private constant AMOUNT = 5 * 1e18;
    ///the types of data to be encrypted on Merkle Tree's base
    string[] types = new string[](2);
    ///the amount of users to be whitelisted
    uint256 numberOfUsersWhitelisted;
    /// array to store the user's addresses
    string[] whitelist = new string[](4);
    /// the path to get the data
    string private constant  INPUT_PATH = "/script/target/input.json";
    
    function run() public {
        // Initialize Types
        types[0] = "address";
        types[1] = "uint";

        // Initialize Whitelisted Users
        whitelist[0] = "0x5D032C53E7eeB550EBff87A0EF04f16caDB58845";
        whitelist[1] = "0x0000000000000000000000000000000000000001";
        whitelist[2] = "0x0000000000000000000000000000000000000002";
        whitelist[3] = "0x0000000000000000000000000000000000000003";

        // Get the length to iterate over the array
        numberOfUsersWhitelisted = whitelist.length;

        // calls the function to create the Merkle Root Structure
        string memory input = _createJSON();

        // write to the output file the stringified output json tree
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        // convert numberOfUsersWhitelisted to string
        string memory numberOfUsersWhitelistedString = vm.toString(numberOfUsersWhitelisted);
        // convert amount to string
        string memory amountString = vm.toString(AMOUNT); 

        string memory json = string.concat(
            '{ "types": ["address", "uint"], "numberOfUsersWhitelisted":', numberOfUsersWhitelistedString, ',"values": {'
        );

        //Iterate over the json string, adding all the whitelisted users one after another.
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',amountString,'"', ' }');
            } else {
            json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',amountString,'"', ' },');
            }
        }

        //closes the json structure
        json = string.concat(json, '} }');
        
        //returns the complete json to be used.
        return json;
    }
}