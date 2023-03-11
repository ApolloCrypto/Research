---
title: Rollup学习
date: 2023-03-11 16:45:29
tags: blockchain layer2
categories: blockchain 
---



## 什么是Rollup?

在以太坊主链布置一个DeFi合约需要$25以上的gas费，这无疑是高昂的。所以像rollup这种layer2网络出现了，rollup的主要原理就是将大量的交易在一个快速的区块链网络上进行处理，再以将交易结果打包传回主网或layer1,传回主网产生的费用均摊，这样成本就降下来了。并且rollup网络的安全性更好。

## 两种主要的rollup网络

### optimistic rollups

optimistic，乐观的，叫这个名字是因为它假设一个rollup中的交易都是被验证过的。这样做的好处是optimistic rollup网络的速度特别快，因为它省略了confirm的时间。缺点是它大约需要从交易发起一周时间才能从网络中提取资金，因为需要审查是否有欺诈性交易。

### ZK-rollups

零知识证明rollup，通过利用零知识证明技术，可以使用交易中的极少信息便验证交易是否通过。这种方式保护了隐私，流畅、快速并便宜。相比optimistic rollup，ZK-rollup几乎不用忍受资金延迟提取，它更快更安全，但它的实现更复杂。至今它只能专用于某些服务如交换NFT或者转账crypto，但是最近有了新突破--zkEVM，它是一个类似optimistic rollup的通用网络。

## rollup的风险

rollup网络中的合约可能存在风险，因为它缺少以太坊一样的故障保护和安全审计。rollup网络还处于初期，开发团队权限偏高，在一些案例中他们可以随时暂停或者关掉网络。很多rollup网络仍然依赖于一个中心化的"定序者"去给L2网络上的交易排序，"定序者"不能欺骗或者替代交易，但是他们可以从给交易重新定序中获益。

## 如何使用rollup网络

首先通过跨链桥将主网资金转移到rollup网络（需要支付一笔主网gas费），然后在l2网络进行你所有的交易，所有交易完成后再使用跨链桥将rollup网络中的资金提回主网。L2网络如optimisim会收取交易手续费，但那远远低于主网的gas费，有些L2如Loopring几乎不收取手续费。