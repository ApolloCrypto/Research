pragma solidity ^0.8.0;
import "./StorageSlot.sol";
type ShortString is bytes32;
library ShortStrings{
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;
    error StringTooLong(string str);
    error InvalidShortString();

    function toShortString(string memory str)internal pure returns(ShortString){
        bytes memory bstr =bytes(str);
        if (bstr.length>31){
             revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr))|bstr.length));
    }
    //TODO 有什么作用
    function toString(ShortString sstr)internal pure returns(string memory){
        uint256 len=length(sstr);
        string memory str=new string(32);
        assembly{ 
            mstore(str,len)
            mstore(add(str,0x20),sstr)
        }
        return str;
    }
    function length(ShortString sstr)internal pure returns(uint256){
        uint256 result =uint256(ShortString.unwrap(sstr))& 0xFF;
        if(result>31){
            revert InvalidShortString();
        }
        return result;
    }
    function toShortStringWithFallback(string memory value,string storage store)internal returns (ShortString){
        if(bytes(value).length<32){
            return toShortString(value);
        }else{
            StorageSlot.getStringSlot(store).value=value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }
    function toStringWithFallback(ShortString value,string storage store)internal pure returns(string memory){
        if (ShortString.unwrap(value)!=_FALLBACK_SENTINEL){
            return toString(value);
        }else{
            return store;
        }
    }

}