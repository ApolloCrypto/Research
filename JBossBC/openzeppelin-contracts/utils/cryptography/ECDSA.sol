pragma solidity ^0.8.0;


library ECDSA{
    enum RecoverError{
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatrueS,
        InvalidSignatrueV// Deprecated in v4.8
    }
    function _throwError(RecoverError error)private pure{
        if (error == RecoverError.NoError){
            return;
        }else if(error== RecoverError.InvalidSignature){
            revert("ECDSA: invalid signature");
        }else if(error == RecoverError.InvalidSignatureLength){
            revert("ECDSA: invalid signatrue length");
        }else if(error ==RecoverError.InvalidSignatrueS){
            revert("ECDSA: invalid signature 's value");
        }
    }
    function tryRecover(bytes32 hash,bytes memory signature)internal pure returns(address,RecoverError){
        if (signature.length==65){
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly{
                r:=mload(add(signature,0x20))
                s:=mload(add(signature,0x40))
                v:=byte(0,mload(add(signature,0x60)))
            }
            return tryRecover(hash,v,r,s);
        }else{
           return(address(0),RecoverError.InvalidSignatureLength);
        }
    }
    function recover(bytes32 hash,bytes memory signature)internal pure returns(address){
        (address recovered,RecoverError error)=tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash,bytes32 r,bytes32 vs)internal pure returns(address,RecoverError){
        bytes32 s= vs &bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v=uint8((uint256(vs)>>255)+27);
        return tryRecover(hash,v,r,s);
    }
    function recover(bytes32 hash,bytes32 r,bytes32 vs)internal pure returns(address){
        (address recovered,RecoverError error)=tryRecover(hash, r,vs);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash,uint8 v,bytes32 r,bytes32 s)internal pure returns(address,RecoverError){
        if (uint256(s)>0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0){
            return (address(0),RecoverError.InvalidSignatrueS);
        }
        address signer =ecrecover(hash, v, r, s);
        if(signer ==address(0)){
            return (address(0),RecoverError.InvalidSignature);
        }
        return(signer,RecoverError.NoError);
    }
}