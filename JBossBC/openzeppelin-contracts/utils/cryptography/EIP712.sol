
pragma solidity ^0.8.0;

import "../../interfaces/IERC5267.sol";
import "../ShortStrings.sol";
import "./ECDSA.sol";
abstract contract EIP712 is IERC5267{
    using ShortStrings for *;

    bytes32 private constant _TYPE_HASH=keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private immutable _cachedDonmainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;
    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;
    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;
    constructor(string memory name,string memory version){
        _name=name.toShortStringWithFallback(_nameFallback);
        _version=version.toShortStringWithFallback(_versionFallback);
        _hashedName=keccak256(bytes(name));
        _hashedVersion=keccak256(bytes(version));
        _cachedChainId=block.chainid;
        _cachedDonmainSeparator=_buildDomainSeparator();
        _cachedThis=address(this);
    }
    function _domainSeparatorV4()internal view returns(bytes32){
        if(address(this)==_cachedThis && block.chainid==_cachedChainId){
            return _cachedDonmainSeparator;
        }else{
            return _buildDomainSeparator();
        }
    }
    function _buildDomainSeparator()private view returns(bytes32){
        return keccak256(abi.encode(_TYPE_HASH,_hashedName,_hashedVersion,block.chainid,address(this)));
    }
    function _hashTypedDataV4(bytes32 structHash)internal view virtual returns(bytes32){
        return ECDSA.toTypedDataHash(_domainSeparatorV4,structHash);
    }
    function eip712Domain()public view virtual override returns(bytes1 fields,string memory name,string memory version,uint256 chainId,address verifyingContract,bytes32 salt,uint256[]memory extensions){
        return(hex"0f",_name.toStringWithFallback(_nameFallback),_version.toStringWithFallback(_versionFallback),block.chainid,address(this),bytes32(0),new uint256 [](0));
    }
}