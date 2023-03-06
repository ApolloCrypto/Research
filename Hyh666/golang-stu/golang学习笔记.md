### 计算程序执行的时间
* time.Now.Sub
	* t1 := time.Now
	* t2 := time.Now.Sub(t2)
	* t2就是所求的程序执行时间
* time.Since
	* t3 := time.Now
	* t4 := time.Since(t3)
	* t4就是所求的程序执行时间

### 测试函数
* 文件名以xxx_test.go为名
* 函数名以Testxxx为名
* 参数选择：t *testing.T


### 双引号与单引号
"" ：字符串，为string类型
'' ：字符，不为string类型

### var、make、new
* 区别：
	* var只是声明了变量，没有为其初始化了内存地址
	* make、new既声明了变量，又初始化了内存地址
	* make适用于channel，slice，map
		* 返回的是声明变量本身
	* new适用于初始化自定义类型，如struct
		* 返回的是声明变量的指针(地址)

### channel发生死锁：
* 1、没有从channel中读取值但是一直往channel中写入值
* 1、没有往channel中写入值但是从channel中读取值