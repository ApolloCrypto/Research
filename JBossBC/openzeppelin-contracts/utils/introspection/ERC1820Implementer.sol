pragma solidity ^0.8.0;
import "./IERC1820Implementer.sol";
contract ERC1820Implement is IERC1820Implementer{
    bytes32 private constant _ERC1820_ACCEPT_MAGIC=keccak256("ERC1820_ACCEPT_MAGIC");
    mapping(bytes32 =>mapping(address=>bool))private _supportedInterfaces;
    function canImplementInterfaceForAddress(bytes32 interfaceHash,address account)public view virtual override returns(bytes32){
        return _supportedInterfaces[interfaceHash][account]?_ERC1820_ACCEPT_MAGIC:bytes32(0x00);
    }
    function _registryInterfaceForAddress(bytes32 interfaceHash,address account)internal virtual{
        _supportedInterfaces[interfaceHash][account]=true;
    }
}