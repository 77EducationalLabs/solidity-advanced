///SPDX-License_Identifier: MIT
pragma solidity 0.8.26;


///@notice Open Zeppelin Imports
import { UUPSUpgradeable } from "@openzeppelin/up-contracts/proxy/utils/UUPSUpgradeable.sol";

/**
	*@notice Doc's Example
	*@notice Forneça contexto sobre o seu contrato.
	*@dev Passe informações sobre caracteristicas peculiares do seu contrato para outros Devs
    *@author Seu nome.
*/
contract Message is UUPSUpgradeable {

	/// State Variables ///
	string public s_message;
	
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

	/**
		*@notice function to enable upgradability
		*@dev in production it must have access control. Otherwise anyone can upgrade it.
	*/
	function _authorizeUpgrade(address newImplementation) internal override{}
}