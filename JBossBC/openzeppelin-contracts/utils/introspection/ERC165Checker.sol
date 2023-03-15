pragma solidity ^0.8.0;
import "./IERC165.sol";


library ERC165Checker{
    bytes4 private constant _INTERFACE_ID_INVALID= 0xffffffff;
    function supportsERC165(address account)internal view returns(bool){
        return supportsERC165InterfaceUnchecked(account,type(IERC165).interfaceId)&&!supportsERC165InterfaceUnchecked(account,_INTERFACE_ID_INVALID);
    }
    function supportsInterface(address account,bytes4 interfaceId)internal view returns(bool){
        return supportsERC165(account)&&supportsERC165InterfaceUnchecked(account,interfaceId);
    }
    function getSupportedInterfaces(address account,bytes4[]memory interfaceIds)internal view returns(bool[] memory){
        bool[] memory interfaceIdsSupported =new bool[](interfaceIds.length);
        if(supportsERC165(account)){
            for(uint256 i=0;i<interfaceIds.length;i++){
                interfaceIdsSupported[i]=supportsERC165InterfaceUnchecked(account,interfaceIds[i]);
            }
        }
        return interfaceIdsSupported;
    }
    function supportsERC165InterfaceUncheked(address account,bytes4 interfaceId)internal view returns (bool){
        bytes memory encodedParams=abi.encodeWithSelector(IERC165.supportsInterface.selector,interfaceId);
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly{
            success :=staticcall(30000,account,add(encodedParams,0x20),mload(encodedParams),0x00,0x20)
            returnSize:=returndatasize()
            returnValue:=mload(0x00)
        }
        return success &&returnSize>=0x20&&returnValue>0;
    }
    function supportsAllInterfaces(address account,bytes4[]memory interfaceIds)internal view returns(bool){
      if(!supportsERC165(account)){
        return false;
      }
      for(uint256 i=0;i<interfaceIds.length;i++){
        if(!supportsERC165InterfaceUncheked(account, interfaceIds[i])){
            return false;
        }
      }
      return true;
    }
}