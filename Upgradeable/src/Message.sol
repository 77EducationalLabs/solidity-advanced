///SPDX-License_Identifier: MIT
pragma solidity 0.8.26;

///Protocol Contracts
import { MessageStorage } from "./storage/MessageStorage.sol";
///Open Zeppelin Imports
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
	*@notice Doc's Example
	*@notice Forneça contexto sobre o seu contrato.
	*@dev Passe informações sobre caracteristicas peculiares do seu contrato para outros Devs
    *@author Seu nome.
*/
contract Message is MessageStorage, Initializable {
	
    /// Events ///
	event Message_UpdatedMessage();
		
    /// Functions ///
	constructor() {
		_disableInitializers();
	}

	function initialize(string memory _message) external initializer {
		setMessage(_message);
	}

	function setMessage(string memory _message) public {
		s_message = _message;
			
		emit Message_UpdatedMessage();
	}
		
	function getMessage() public view returns(string memory _message){
		_message = s_message;
	}
}