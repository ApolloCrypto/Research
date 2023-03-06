pragma solidity ^0.8.0;


abstract contract PullPayment{
    Escrow private immutable _escrow;
    constructor(){
        _escrow=new Escrow();
    }
    function withdrawPayments(address payable payee)public virtual{
        _escrow.withdraw( payee);
    }
    function payments(address dest)public view returns(uint256){
        return _escrow.depositsOf(dest);
    }
    function _asynTransfer(address dest,uint256 amount)internal virtual{
        _escrow.deposit(value: amount)(dest);
    }
}