

function executeOperation(
    address _reserve,
    uint256 _amount,
    uint256 _free,
    bytes calldata _params
)external{
    require(_amount <= getBalanceInternal(address(this),_reserve), "借款失败");
     //

    // 用借来的 ETH 去赚取更多的 ETH

    //
    uint totalDebt =_amount.add(_fee);
    transferFundsBackToPoolInternal(_reserve,totalDebt)
}

function flashloan()public onlyOwner{
    bytes memory data ="";
    uint amount = 100 ether;
    address asset =address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
    lendingPool.flashLoan(address(this), asset, amount, data);
}