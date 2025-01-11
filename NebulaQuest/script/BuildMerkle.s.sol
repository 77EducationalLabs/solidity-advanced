// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {Merkle} from "@murky/src/Merkle.sol";
import {ScriptHelper} from "@murky/script/common/ScriptHelper.sol";

// Merkle proof generator script
// To use:
// 1. Run `forge script script/GenerateInput.s.sol` to generate the input file
// 2. Run `forge script script/BuildMerkle.s.sol`
// 3. The output file will be generated in /script/target/output.json

/** 
 * @title BuildMerkle
 * @author Barba
 * @author 77 Innovation Labs
 * @notice added documentation and renamed variables for a clear understanding
 *
 * @title MakeMerkle
 * @author Ciara Nightingale
 * @author Cyfrin
 *
 * Original Work by:
 * @author kootsZhin
 * @notice https://github.com/dmfxyz/murky
 */

contract BuildMerkle is Script, ScriptHelper {
    // enables us to use the json cheatcodes for strings
    using stdJson for string;

    // instance of the merkle contract from Murky to do stuff
    Merkle private m = new Merkle();

    //The path to the file holding the input users and amounts stored
    string private s_inputPath = "/script/target/input.json";
    //The path to the output file in which the merkle root will be written to
    string private s_outputPath = "/script/target/output.json";

    // get the absolute path 
    string private s_elements = vm.readFile(string.concat(vm.projectRoot(), s_inputPath));
    // gets the merkle tree leaf types from json using forge standard lib cheatcode 
    string[] private s_types = s_elements.readStringArray(".types");
    // get the number of leaf nodes
    uint256 private s_numberOfUsersWhitelisted = s_elements.readUint(".numberOfUsersWhitelisted");

    // make three arrays the same size as the number of leaf nodes
    bytes32[] private s_leafs = new bytes32[](s_numberOfUsersWhitelisted);
    string[] private s_inputs = new string[](s_numberOfUsersWhitelisted);
    string[] private s_outputs = new string[](s_numberOfUsersWhitelisted);

    //define the variable to hold the output that must be written to the json file.
    string private s_output;

    /// @dev Read the input file and generate the Merkle proof, then write the output file
    function run() public {
        console.log("Generating Merkle Proof for %s", s_inputPath);

        //Iterate over the allowlisted participants
        for (uint256 i = 0; i < s_numberOfUsersWhitelisted; ++i) {
            // Creates an memory array to stringified data (address and string both as strings)
            string[] memory input = new string[](s_types.length);
            // Crates an array to the actual data as a bytes32
            bytes32[] memory data = new bytes32[](s_types.length);

            //iterates over the types
            for (uint256 j = 0; j < s_types.length; ++j) {
                //if type is address
                if (compareStrings(s_types[j], "address")) {
                    //get the address from the input json file
                    address value = s_elements.readAddress(getValuesByIndex(i, j));
                    // you can't immediately cast straight to 32 bytes
                    // as an address is 20 bytes so first cast to uint160 (20 bytes)
                    // cast up to uint256 which is 32 bytes and finally to bytes32
                    data[j] = bytes32(uint256(uint160(value)));
                    //Convert the address back to string and add to the string array.
                    input[j] = vm.toString(value);
                } else if (compareStrings(s_types[j], "uint")) {
                    //get the uint256 amount from the input json file
                    uint256 value = vm.parseUint(s_elements.readString(getValuesByIndex(i, j)));
                    //convert to bytes32 and add to the bytes32[]
                    data[j] = bytes32(value);
                    //convert to string and add to the string[]
                    input[j] = vm.toString(value);
                }
            }
            // Create the hash for the merkle tree leaf node
            // 1. abi encode the data array (each element is a bytes32 representation for the address and the amount)
            // 2. ltrim64 ia helper from Murky (ltrim64) that returns the bytes with the first 64 bytes removed 
            // 3. It removes the offset and additional length from the encoded bytes.
                //There is an offset because the array is declared in memory 
            // 4. hash the encoded address and amount 
            // 5. bytes.concat turns from bytes32 to bytes 
            // 6. hash again to avoid preimage attack
            // 7. add it to the leads array
            s_leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
            // Converts a string array into a JSON array string.
            // store the corresponding values/inputs for each leaf node
            s_inputs[i] = stringArrayToString(input);
        }

        //Iterate over the allowlisted participants
        for (uint256 i = 0; i < s_numberOfUsersWhitelisted; ++i) {
            // getProof takes leafs and position and gets the nodes needed for the proof & stringify (from helper lib)
            string memory proof = bytes32ArrayToString(m.getProof(s_leafs, i));
            // get the root hash and stringify
            string memory root = vm.toString(m.getRoot(s_leafs));
            // get the specific leaf we are working on
            string memory leaf = vm.toString(s_leafs[i]);
            // get the signified input (address, amount)
            string memory input = s_inputs[i];

            // generate the Json output file (tree dump)
            s_outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        // stringify the array of strings to a single string
        s_output = stringArrayToArrayString(s_outputs);
        // write to the output file the stringified output json tree dumpus 
        vm.writeFile(string.concat(vm.projectRoot(), s_outputPath), s_output);

        console.log("DONE: The output is found at %s", s_outputPath);
    }

    /// @dev Generate the JSON entries for the output file
    function generateJsonEntries(
        string memory _inputs,
        string memory _proof,
        string memory _root,
        string memory _leaf
    )
        internal
        pure
        returns (string memory)
    {
        //Creates one string with all dynamic data together
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );

        return result;
    }

    /// @dev Returns the JSON path of the input file
    // output file output ".values.some-address.some-amount"
    function getValuesByIndex(uint256 i, uint256 j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }
}