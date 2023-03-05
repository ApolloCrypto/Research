### interface IBEP20
* 主要是一些token代币常用的接口，如name，symbol，decimals等

### contract Context
* 主要是返回msg.sender和msg.data
* 以及防止合约部署错误的空构造函数

### library SafeMath
* 运算库，主要是为了在可以避免溢出错误的前提下进行基础数学运算

### contract Fintoch
* FTH主合约
* 继承自Context和IBEP20
* 就是一个非常基础的ERC20合约
* 发行代币、用户之间转移代币、授权用户使用自己一定额度的代币