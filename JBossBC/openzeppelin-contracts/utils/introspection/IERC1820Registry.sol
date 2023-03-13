pragma solidity ^0.8.0;

interface IERC1820Registry{
    event InterfaceImplementerSet(address indexed account,bytes32 indexed interfaceHash,address indexed implementer);
     event ManagerChanged(address indexed account, address indexed newManager);
       function setManager(address account, address newManager) external;
       function getManager(address account) external view returns (address);
       function setInterfaceImplementer(address account, bytes32 _interfaceHash, address implementer) external;
       function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);
        function interfaceHash(string calldata interfaceName) external pure returns (bytes32);
        function updateERC165Cache(address account, bytes4 interfaceId) external;
         function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);
         function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);
}