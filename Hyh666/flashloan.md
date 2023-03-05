### 概念：
* 字面意思：快速贷款，闪电贷
* 分为：
	* base：
		* FlashLoanReceiverBase.sol
		* FlashLoanSimpleReceiverBase.sol
	* interfaces：
		* IFlashLoanReceiver.sol
		* IFlashLoanSimpleReceiver.sol
		
### 合约之间的层级关系
* IFlashLoanReceiver.sol 
	* IPoolAddressesProvider.sol
	* IPool.sol

### IFlashLoanReceiver.sol 
* 简介：
	* 闪电贷借款人合约接口（借钱的那个）
* interface IFlashLoanReceiver{}
* function executeOperation
	* 参数：
	    * address[] calldata assets,
		    * 借款人的地址
    	* uint256[] calldata amounts,
	    	* 借款金额
    	* uint256[] calldata premiums,
	    	* 借款费用
    	* address initiator,
	    	* 初始化闪电贷的地址
    	* bytes calldata params
	    	* 启动闪电贷时传递的字节编码参数
	* 代码体：
		*  function ADDRESSES_PROVIDER() external view returns (IPoolAddressesProvider);
			*  返回一个接口IPoolAddressesProvider
		*  function POOL() external view returns (IPool);
			*  返回一个接口IPool
	* 返回值：
		*  bool

### IPoolAddressesProvider.sol
* 简介：
	* 为借贷交易池提供基本的接口
* function getMarketId
	* 功能：
		* 返回此合约所指向的FINTOCH市场的id
	* 返回值：
		* string memory
* function setMarketId
	* 功能：
		* 为一个新的FINTOCH市场创建id
	* 参数：
		* string calldata newMarketId
* function getAddress
	* 功能：
		* 根据标识符返回地址
		* 如果这个地址没有注册会返回0地址
		* 返回值可以是合约地址、EOA地址、代理地址
	* 参数：
		* bytes32 id
	* 返回值：
		* address
* function setAddressAsProxy
	* 功能：
		* 更新指定地址的代理
		* 如果指定地址没有代理则为其设置代理
	* 参数：
		* bytes32 id
		* address newImplementationAddress
* function setAddress
	* 功能：
		* 为id设置一个地址来替换mapping中保存的地址
		* 注意是强硬性质的替换
	* 参数：
		* bytes32 id
		* address newAddress
* func getPool
	* 功能：
		* 返回地址对应的代理池？
	* 返回值：
		* address
* function setPoolImpl  
	* 功能：
		* 更新池子的实现或者创建代理
		* 当第一次调用此函数时设置新的池子
	* 参数：
		* address newPoolImpl
* function getPoolConfigurator
	* 功能：
		* 返回池子的配置者的地址
	* 返回值：
		* address
* function setPoolConfiguratorImpl
	* 功能：
		* 更新池子的配置者或者创建代理
		* 当第一次调用此函数时设置新的代理者
	* 参数：
		* address newPoolConfiguratorImpl
* function getPriceOracle
	* 功能：
		* 返回地址的价格xx
	* 返回值：
		* address
* function setPriceOracle
	* 功能：
		* 更新地址的价格xx
	* 参数：
		* address newPriceOracle
* function getACLManage
	* 功能：
		* 返回ACL经理者的地址
	* 返回值：
		* address
* function setACLManager
	* 功能：
		* 设置ACL经理者的地址
	* 参数：
		* address newAclManager
* function getACLAdmin
	* 功能：
		* 获取ACL管理者的地址
	* 返回值：
		* address
* function setACLAdmin
	* 功能：
		* 设置ACL管理者的地址
	* 参数：
		* address newAclAdmin
* function getPriceOracleSentinel
	* 功能：
		* 返回价格xx的xx
	* 返回值：
		* address
* function setPriceOracleSentinel
	* 功能：
		* 设置价格xx的xx
	* 参数：
		* address newPriceOracleSentinel
* function getPoolDataProvider
	* 功能：
		* 返回池子数据的提供者
	* 返回值：
		* address
* function setPoolDataProvider
	* 功能：
		* 设置池子数据的提供者
	* 参数：
		* address newDataProvider
	