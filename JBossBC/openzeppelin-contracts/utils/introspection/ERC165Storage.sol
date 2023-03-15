pragma solidity ^0.8.0;
import "./ERC165.sol";

abstract contract ERC165Storage is ERC165{
    mapping(bytes4 =>bool)private _supportedInterfaces;
    function supportsInterface(bytes4 interfaceId)public view virtual override returns(bool){
        return super.supportsInterface(interfaceId)||_supportedInterfaces[interfaceId];
    }
    function _registrerInterface(bytes4 interfaceId)internal virtual{
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}