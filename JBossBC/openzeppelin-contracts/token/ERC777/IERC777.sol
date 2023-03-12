pragma solidity ^0.8.0;

interface IERC777{
    event Minted(address indexed operator,address indexed to,uint256 amount,bytes data,bytes operatorData);
    event Burned(address indexed operator,address indexed from,uint256 amount,bytes data,bytes operatorData);
    event AuthorizedOperator(address indexed operator,address indexed tokenHolder);
    event RevokedOperator(address indexed operator,address indexed tokenHolder);
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function granularity()external view returns(uint256);
    function totalSupply()external view returns(uint256);
    function balanceOf(address owner)external view returns(uint256);
    function send(address recipient,uint256 amount,bytes calldata data)external;
    function burn(uint256 amount,bytes calldata data)external;
    function isOperatorFor(address operator,address tokenHolder)external view returns(bool);
    function authorizeOperator(address operator)external;
    function revokeOperator(address operator)external;
    function defaultOperator()external view returns(address[]memory);
}