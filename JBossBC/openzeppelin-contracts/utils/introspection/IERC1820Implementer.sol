
pragma solidity ^0.8.0;

interface IERC1820Implementer{
    function canImplementInterfaceForAddress(bytes32 interfaceHash,address account)external view returns(bytres32);
    
}