///SPDX-License_Identifier: MIT
pragma solidity 0.8.26;

import { MessageStorage } from "./storage/MessageStorage.sol";

/**
	*@notice Doc's Example
	*@notice Forneça contexto sobre o seu contrato.
	*@dev Passe informações sobre caracteristicas peculiares do seu contrato para outros Devs
    *@author Seu nome.
*/
contract Message is MessageStorage{
	
    /// Events ///
	event Message_UpdatedMessage();
		
    /// Functions ///
	function initialize(string memory _message) external {
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