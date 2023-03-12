pragma solidity ^0.8.0;


contract ERC777 is Context,IERC777,IERC20{
    using Address for address;
    //TODO
     IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
     mapping(address=>uint256)private _balances;
     uint256 private _totalSupply;
     string private _name;
     string private _symbol;
     bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    address[]private _defaultOperatorsArray;
    mapping(address=>bool)private _defaultOperators;
    mapping(address=>mapping(address=>bool))private _operators;
    mapping(address=>mapping(address=>bool))private _revokedDefaultOperators;
    mapping(address => mapping(address => uint256)) private _allowances;
    constructor(string memory name_,string memory symbol_,address []memory defaultOperators_){
        _name=name_;
        _symbol=symbol_;
        _defaultOperators=defaultOperators_;
        for(uint256 i=0;i<defaultOperators_.length;i++){
            _defaultOperators[defaultOperators_[i]]=true;
        }
        //TODO register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }
}