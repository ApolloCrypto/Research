// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import {IInvestmentEarnings} from '../../interfaces/IInvestmentEarnings.sol';
import {IPool} from '../../interfaces/IPool.sol';
import {FTHToken} from './FTHToken.sol';

/**
 * @title FintochPool contract
 *
 * @notice Main point of interaction with an Fintoch protocol's market
 * - Users can:
 *   # Supply
 *   # Withdraw
 *   # Borrow
 *   # Repay
 *   # Swap their loans between variable and stable rate
 *   # Enable/disable their supplied assets as collateral rebalance stable rate borrow positions
 *   # Liquidate positions
 *   # Execute Flash Loans
 * @dev To be covered by a proxy contract, owned by the PoolAddressesProvider of the specific market
 * @dev All admin functions are callable by the PoolConfigurator contract defined also in the PoolAddressesProvider
 **/
 /*
和FINTOCH市场交互的主要功能：
用户可以进行：
投资
提取
借钱
还钱
在可变利率和稳定利率之间交换贷款
在抵押品重新平衡稳定利率借款头寸时启用/禁用其提供的资产？？？？？
清算头寸？？？？？？？？？
闪电贷
dev将由特定市场的PoolAddressesProvider拥有的代理合同覆盖？？？？
所有管理函数都可以由PoolConfigurator合约调用池地址提供程序？？？？
 */
contract FintochPool is FTHToken, IPool { //合约继承自FTHToken，TPool

    uint256 public constant POOL_REVISION = 0x2; //下文没有使用到的常量，忽略
    IInvestmentEarnings public immutable INVESTMENT_EARNINGS_CONTRACT; //合约类型的变量，immutable修饰，是一个不可变量
    address public immutable SRC_TOKEN; // 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE stands for ETH

    uint constant public MAX_OWNER_COUNT = 9; //最大用户数量？

    // The N addresses which control the funds in this contract. The
    // owners of M of these addresses will need to both sign a message
    // allowing the funds in this contract to be spent.
    // 对于控制本合约中资金的N个地址
    // 这些地址中的M个都需要去共同签署一个信息
    // 以便来允许使用这个合约中的资金
    mapping(address => bool) private isOwner; //地址与bool类型映射，判断是否是一个拥有者
    address[] private owners; //拥有者地址的数组
    uint private immutable required; //？？？？

    // The contract nonce is not accessible to the contract so we
    // implement a nonce-like variable for replay protection.
    // 这个临时合约是无法被访问的，所以我们实现一个非临时的变量来防止重入攻击
    uint256 private spendNonce = 0;  // ？？？？
    uint public allowInternalCall = 1; // ？？？？

    bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));//？？？？
    bytes4 private constant TRANSFER_FROM_SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));//？？？？？

    address private constant ETH_CONTRACT = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;//？？？？？？？

    // An event sent when funds are received.
    event Funded(address from, uint value);

    // An event sent when a setAllowInternalCall is triggered.
    event AllowInternalCallUpdated(uint value);

    // An event sent when a spend is triggered to the given address.
    event Spent(address to, uint transfer);

    // An event sent when a spendERC20 is triggered to the given address.
    event SpentERC20(address erc20contract, address to, uint transfer);

    modifier validRequirement(uint ownerCount, uint _required) { //函数修改器，一个错误需求
        require(ownerCount <= MAX_OWNER_COUNT
        && _required <= ownerCount
            && _required >= 1);
        _;
    }

    /**
     * @dev Constructor.
   * @param _owners List of initial owners.
   * @param _required Number of required confirmations.
   */
    constructor(//构造函数
        IInvestmentEarnings investmentEarnings, //一个合约对象
        address srcToken, //srcToken地址
        address[] memory _owners, //初始化用户的地址的数组
        uint _required  //所需要确认的数量
    ) validRequirement(_owners.length, _required) { 
        INVESTMENT_EARNINGS_CONTRACT = investmentEarnings; //初始化合约对象
        SRC_TOKEN = srcToken; //初始化srcToken的地址
        for (uint i = 0; i < _owners.length; i++) { //循环遍历用户数组
            //onwer should be distinct, and non-zero
            //owner的地址必须是不同的并且不能为0地址
            if (isOwner[_owners[i]] || _owners[i] == address(0x0)) {
                revert();
            }
            isOwner[_owners[i]] = true; //把合适的地址映射保存为true
        }
        owners = _owners; //初始化owners
        required = _required; //初始化required
    }

    /**
     * @dev Leaves the contract without owners. It will not be possible to call
   * with signature check anymore. Can only be called by the current owners.
   *
   * NOTE: Renouncing ownership will leave the contract without owners,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership(uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
        bytes32 renounceOwnershipTypeHash = keccak256("RenounceOwnership(uint256 spendNonce)");
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(renounceOwnershipTypeHash, spendNonce))
            )
        );
        require(_validMsgSignature(digest, vs, rs, ss), "invalid signatures");
        for (uint i = 0; i < owners.length; i++) {
            isOwner[owners[i]] = false;
        }
        delete owners;
    }

    // The receive function for this contract.
    receive() external payable {
        if (msg.value > 0) {
            emit Funded(msg.sender, msg.value);
        }
    }

    // @dev Returns list of owners.
    // @return List of owner addresses.
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getSpendNonce() external view returns (uint256) {
        return spendNonce;
    }

    function getRequired() external view returns (uint) {
        return required;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'FintochPool: TRANSFER_FAILED');
    }

    function _safeTransferFrom(address token, address from, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_FROM_SELECTOR, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'FintochPool: TRANSFER_FROM_FAILED');
    }

    // Generates the message to sign given the output destination address and amount.
    // includes this contract's address and a nonce for replay protection.
    // One option to independently verify: https://leventozturk.com/engineering/sha3/ and select keccak
    function generateMessageToSign(address erc20Contract, address destination, uint256 value) private view returns (bytes32) {
        require(destination != address(this));
        //the sequence should match generateMultiSigV2 in JS
        bytes32 message = keccak256(abi.encodePacked(address(this), erc20Contract, destination, value, spendNonce));
        return message;
    }

    function _messageToRecover(address erc20Contract, address destination, uint256 value) private view returns (bytes32) {
        bytes32 hashedUnsignedMessage = generateMessageToSign(erc20Contract, destination, value);
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, hashedUnsignedMessage));
    }

    /**
   * @param _allowInternalCall: the new allowInternalCall value.
   * @param vs, rs, ss: the signatures
   */
    function setAllowInternalCall(uint _allowInternalCall, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
        require(_validSignature(address(this), msg.sender, _allowInternalCall, vs, rs, ss), "invalid signatures");
        spendNonce = spendNonce + 1;
        allowInternalCall = _allowInternalCall;
        emit AllowInternalCallUpdated(allowInternalCall);
    }

    /**
     * @param destination: the ether receiver address.
   * @param value: the ether value, in wei.
   * @param vs, rs, ss: the signatures
   */
    function spend(address destination, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
        require(destination != address(this), "Not allow sending to yourself");
        require(address(this).balance >= value && value > 0, "balance or spend value invalid");
        require(_validSignature(address(0x0), destination, value, vs, rs, ss), "invalid signatures");
        spendNonce = spendNonce + 1;
        (bool success,) = destination.call{value : value}("");
        require(success, "transfer fail");
        emit Spent(destination, value);
    }

    /**
     * @param erc20contract: the erc20 contract address.
   * @param destination: the token receiver address.
   * @param value: the token value, in token minimum unit.
   * @param vs, rs, ss: the signatures
   */
    function spendERC20(address destination, address erc20contract, uint256 value, uint8[] calldata vs, bytes32[] calldata rs, bytes32[] calldata ss) external {
        require(destination != address(this), "Not allow sending to yourself");
        //transfer erc20 token
        require(value > 0, "Erc20 spend value invalid");
        require(_validSignature(erc20contract, destination, value, vs, rs, ss), "invalid signatures");
        spendNonce = spendNonce + 1;
        // transfer tokens from this contract to the destination address
        _safeTransfer(erc20contract, destination, value);
        emit SpentERC20(erc20contract, destination, value);
    }

    /**
   * @param destination: the token receiver address.
   * @param value: the token value, in token minimum unit.
   */
    function redemption(address destination, uint256 value) external {
        require(destination != address(this), "Not allow sending to yourself");
        //transfer erc20 token
        require(value > 0, "withdraw value invalid");
        _burn(msg.sender, value);
        if (SRC_TOKEN == ETH_CONTRACT) {
            // transfer ETH
            (bool success,) = destination.call{value : value}("");
            require(success, "transfer fail");
        } else {
            // transfer erc20 token
            _safeTransfer(SRC_TOKEN, destination, value);
        }
        emit Redeemed(msg.sender, destination, SRC_TOKEN, value);
    }

    function mint(address destination, uint256 value) external payable {
        require(destination != address(0), 'ERC20: mint to the zero address');
        uint256 mintAmount = msg.value;
        if (SRC_TOKEN != ETH_CONTRACT) {
            // transfer erc20 token
            mintAmount = value;
            _safeTransferFrom(SRC_TOKEN, msg.sender, address(this), mintAmount);
        }
        _mint(destination, mintAmount);
        emit Mint(msg.sender, destination, mintAmount);
    }

    function cancelReinvest(string calldata orderId) external {
        uint256 size;
        address callerAddress = msg.sender;
        assembly {
            size := extcodesize(callerAddress)
        }
        require(size == 0 || allowInternalCall == 1, "forbidden");
        INVESTMENT_EARNINGS_CONTRACT.noteCancelReinvest(orderId);
    }

    function withdrawalIncome(uint64[] calldata recordIds) external {
        uint256 size;
        address callerAddress = msg.sender;
        assembly {
            size := extcodesize(callerAddress)
        }
        require(size == 0 || allowInternalCall == 1, "forbidden");
        for (uint i = 0; i < recordIds.length; i++) {
            require(recordIds[i] > 0, "invalid record id");
            for (uint j = 0; j < i; j++) {
                if (recordIds[i] == recordIds[j]) {
                    revert("duplicate record id");
                }
            }
        }
        INVESTMENT_EARNINGS_CONTRACT.noteWithdrawal(recordIds);
    }

    // Confirm that the signature triplets (v1, r1, s1) (v2, r2, s2) ...
    // authorize a spend of this contract's funds to the given destination address.
    function _validMsgSignature(
        bytes32 message,
        uint8[] calldata vs,
        bytes32[] calldata rs,
        bytes32[] calldata ss
    ) private view returns (bool) {
        require(vs.length == rs.length);
        require(rs.length == ss.length);
        require(vs.length <= owners.length);
        require(vs.length >= required);
        address[] memory addrs = new address[](vs.length);
        for (uint i = 0; i < vs.length; i++) {
            //recover the address associated with the public key from elliptic curve signature or return zero on error
            addrs[i] = ecrecover(message, vs[i] + 27, rs[i], ss[i]);
        }
        require(_distinctOwners(addrs));
        return true;
    }

    // Confirm that the signature triplets (v1, r1, s1) (v2, r2, s2) ...
    // authorize a spend of this contract's funds to the given destination address.
    function _validSignature(
        address erc20Contract,
        address destination,
        uint256 value,
        uint8[] calldata vs,
        bytes32[] calldata rs,
        bytes32[] calldata ss
    ) private view returns (bool) {
        bytes32 message = _messageToRecover(erc20Contract, destination, value);
        return _validMsgSignature(message, vs, rs, ss);
    }

    // Confirm the addresses as distinct owners of this contract.
    function _distinctOwners(address[] memory addrs) private view returns (bool) {
        if (addrs.length > owners.length) {
            return false;
        }
        for (uint i = 0; i < addrs.length; i++) {
            if (!isOwner[addrs[i]]) {
                return false;
            }
            //address should be distinct
            for (uint j = 0; j < i; j++) {
                if (addrs[i] == addrs[j]) {
                    return false;
                }
            }
        }
        return true;
    }

}
