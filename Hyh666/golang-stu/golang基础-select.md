### 使用：
* 需要接收多个goroutine中的消息时可以使用select
* 当多个case同时到达select将会运行一个伪随机算法随机选择一个case
* select于switch的区别：
	* select的每个case必须是io操作
	* select后边不带判断条件
	* select中如果多个case同时到达select将会运行一个伪随机算法随机选择一个case