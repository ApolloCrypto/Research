

pragma solidity ^0.8.0;

contract Escrow is Ownable{
  using Address for address payable;
  event Deposited(address indexed payee,uint256 weiAmount);
  event Withdrawn(address indexed payee,uint256 weiAmount);
  mapping(address =>uint256)private _deposits;
  function depositsOf(address payee)public view returns (uint256){
    return _deposits[payee];
  }
  function deposit(address payee)public payable virtual onlyOwner{
    uint256 amount =msg.value;
    _deposits[payee]+=amount;
    emit Deposited(payee,amount);
  }
  function withdraw(address payable payee)public virtual onlyOwner{
    uint256 payment =_deposits[payee];
    _deposits[payee]=0;
    payee.sendValue(payment);
    emit Withdrawn(payee, payment);
  }
}