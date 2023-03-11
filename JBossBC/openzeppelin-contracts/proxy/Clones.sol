pragma solidity ^0.8.0;
//TODO
library Clones{
    function clone(address implementation)internal returns(address instance){
        assembly{
            mstore(0x00,or(shr(0xe8,shl(0x60,implementation)),0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            mstore(0x20,or(shl(0x78,implementation),0x5af43d82803e903d91602b57fd5bf3))
            instance:=create(0,0x09,0x37)
        }
        require(instance!=address(0),"ERC1167: create failed");
    }
    function cloneDeterministic(address implementation,bytes32 salt)internal returns(address instance){
        assembly{
            mstore(0x00,or(shr(0xe8,shl(0x60,implementation)),0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }
    function predictDeterministicAddress(address implementation,bytes32 salt,address deployer) internal pure returns(address predicted){
        assembly {
            let ptr:=mload(0x40)
            mstore(add(ptr,0x38),deployer)
            mstore(add(ptr,0x24),0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr,0x14),implementation)
            mstore(ptr,0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr,0x58),salt)
            mstore(add(ptr,0x78),keccak256(add(ptr,0x0c),0x37))
            predicted:=keccak256(add(ptr,0x43),0x55)
        }
    }
    function predictDeterministicAddress(address implementation,bytes32 salt)internal view returns(address predicted){
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}