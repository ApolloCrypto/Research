### goroutine概念：
* 协程
* 与并发和并行有关
* 与进程和线程有关
* 注意：
	* 如果这个函数有返回值，那么这个返回值会被丢弃。
	* 但是我们可以使用channel去读取函数运行的值
		* ch := make(chan int, 2)
		* go test1(ch)
		* value := <- ch



### 进程和线程说明：
* 概念：
	* 进程就是程序在操作系统中的一次执行过程，是系统进行资源分配和调度的基本单位
	* 线程就是进程的一个执行实例，是程序执行的最小单位，它是比进程更小的能独立运行的基本单位
	
* 总结：
	* 进程=线程他爹
	* 一个程序至少有一个进程，一个进程至少有一个线程
	* 同一个进程中的线程可以并发执行
	
* 实例：“使用迅雷下载一部电影”
	* 可以在资源管理器看到迅雷的一个进程
	* 但是实际上在进行下载的时候，迅雷这个进程会创建出几个线程去完成下载操作的
	* 线程就相当于子任务，不会影响到进程的运行，并且同时运行多个线程会使效率提升

### 进程、线程、协程的区别：
* 进程和线程
	* 都有内核进行调度的，有CPU时间片的概念，进行抢占式调度(有多种调度算法)
* 协程
	* 是用户级线程，是堆内核透明的，系统并不知道有协程的存在，完全由用户自己的程序进行调度
	* 不能做到抢占式调度，需要协程自己把控制权转让出去之后，其他协程才能被执行

### 并发和并行说明：
* 并发概念：
	* 我们同时启动多个线程，这些线程运行在一个CPU上就是并发
* 并行概念：
	* 我们同时启动多个线程，这些线程在多个CPU上运行就是并行

### goroutine底层实现原理：
* 为什么选择协程：
	* 线程是操作系统的内核对象，多线程编程时，如果线程数过多，就会导致频繁的上下文切换，这些CPU时间是一个额外的耗费。
	* 所以在一些高并发的网络服务器编程模型中，使用一个线程服务一个socket链接是不明智的
	* 为此操作系统提供了基于事件模式的异步编程模型，用少量的线程来服务大量的网络链接和I/O操作
	* 但是采用异步和基于事件模式的异步编程，复杂化了程序代码的编写，因为线程穿插，也提高了排错的难度
* 协程的原理：
	* 协程是在应用层模拟的线程，其避免了上下文切换的额外耗费，兼顾了多线程的优点。简化了高并发程序的复杂程度
* 从线程的角度理解协程的原理：
	* 当a线程切换到b线程的时候，需要将a线程的相关执行进度压入栈，然后将b线程的执行进度出栈，进入b线程的执行序列
	* 协程只不过是在应用层实现上述功能，但是协程并不是由操作系统调度的，而且程序也没有能力和权限执行CPU调度
	* 协程是基于线程的，内部实现上，维护了一组数据结构的n个线程，真正的执行者还是线程。协程执行的代码会被扔进一个待执行队列中，由这n个线程从队列中拉出来执行，这就解决了协程的执行问题
	* 协程的切换：golang对各种io函数进行了封装，这些封装的函数提供给应用程序使用，而其内部调用了操作系统的异步io函数。当这些异步函数返回busy或bloking时，golang利用这个时机将现有的执行序列压栈，让线程区拉另外一个协程的代码来执行

### goroutine使用：
* 协程的使用是并行执行的，即协程会和主进程/主线程分别在多个CPU上运行
* 完整流程：
	* 1、程序开始，主线程/主进程开始执行
	* 2、go funcname()开启协程
	* 3、主线程/主进程和协程并行执行
	* 4、如果主线程/主进程推出了，那么即使协程还没有执行完毕，也会退出
	* 5、主线程/主进程执行结束退出
* 注意：
	* 一般都是主线程
	* 主线程是一个物理线程，直接作用在CPU上，是重量级的，非常耗费CPU资源
	* 协程是从主线程开启的，是轻量级的逻辑态，堆资源消耗资源较小
	
### 使用channel同步goroutine
* 概念：
	* 消息机制认为每个并发单元是自包含的，独立的个体，并且都有自己的变量
	* 但在不同并发单元间这些变量不共享，每个并发单元的输入和输出都只有一种，那就是消息
* channel概念：
	* channel是golang在语言级别提供的goroutine间的通信方式，我们可以使用channel在多个goroutine之间传递消息。
	* channel是进程内的通信方式，因此通过channel传递对象的过程和调用函数时的参数传递行为比较一致，比如也可以传递指针
	* channel是类型相关的，一个channel只能传递一种类型的值，这个类型需要在声明channel时指定
* channel使用：
	* channel的声明形式为：
		* var chanName chan ElementType
		* var a chan int
	* 使用内置函数make()定义一个channel
		* ch ：= make(chan int)
	* chan的核心——写入：
		* ch <- value
		* 将一个数据value写入至channel，这会导致阻塞，直到有其他goroutine从这个channel中读取数据
	* chan的核心——读出：
		* value := <-ch
		* 从channel中读取数据，如果channel之前没有写入数据，也会导致阻塞，直到channel中被写入数据为止
	* 默认情况下，channel的接收和发送都是阻塞的，除非另外一端已经准备好了
	* 可以创建一个带缓冲的channel：
		* c := make(chan int, 1024)
		* 创建一个大小为1024的int类型的channel，即使没有读取方，写入方也可以一直往channel里面写入
		* 在缓冲区被填满之前都不会发生阻塞
	* 可以关闭不再使用的channel
		* close(ch)
		* 注意关闭channel应该是在往channel写入的地方关闭，而不是读取的地方关闭，否则容易引起panic

### 使用select来监控通道和切换协程
* golang在语言级别支持select关键字，用于处理异步IO问题
* 使用示例：
	
		select {
			case <- chan1:
			//如果chan1成功读取到数据
		
			case chan2 <- 1:
			//如果成功向chan2写入数据1

			default:
			//默认分支
* 注意：
	* select默认是阻塞的，只有当监听的channle中有发送或者接收可以进行时才会运行
	* 当多个channel都准备好的时候，select是随机的选择一个执行的
	* golang没有对channel提供直接的超时处理机制，我们可以使用select来间接实现


			timeout := make(chan bool, 1)
			go func() {
			    time.Sleep(1e9)
			    timeout <- true
			}()
			switch {
			    case <- ch:
			    // 从ch中读取到数据
			 
			    case <- timeout:
			    // 没有从ch中读取到数据，但从timeout中读取到了数据
			}
	* 解析：
		* 这样使用select就可以避免永久等待的问题，
		* 因为程序会在timeout中获取到一个数据后继续执行，而无论对ch的读取是否还处于等待状态

### 使用sync来管理goroutine
* sync.WaitGroup
	* 用来设置计数器等待线程完成之后再继续进行主执行流
	* func (wg *WaitGroup) Add(delta int)
		* 设置一个计数器，delta表明该计数器用来管理协程的数量
		* 计数器的设置应该位于主执行流中
	* func (wg *WaitGroup) Done()
		* 对计数器进行减操作，该操作应该位于协程自身的执行流的末尾
	* func (wg *WaitGroup) Wait()
		* 等待计数器所管理的协程执行完毕，也就是在等待计数器的值变为0
		* 如果计数器的值不为0，则主执行流会阻塞在此处
		* 计数器变为负数：会发生panic，位置在sync包
* sync.Once
	* 用来控制函数只能被调用一次
	* func (o *Once) Do(f func())
		* 保证f函数只会被执行一次
		* f通常是一个没有参数没有返回值的函数
* sync.Pool
	* 用来使程序更加高效，减少高并发情况下的GC过载导致的问题
	* func (p *Pool) Get() interface{}
		* 返回Pool中任意一个对象，如果Pool为空，则New一个新创建的对象
	* func (p *Pool) Put(x interface{})
		* 将对象放入Pool中
	* 在创建sync.Pool对象时，需要初始化New()函数，作用是当Pool中没有临时对象时，应该返回一个什么样的对象
	* 注意：
		* 放入Pool中的对象，会在不一定的时间被清除掉，清理过程是在每次垃圾回收之前做的，垃圾回收是固定两分钟触发一次

### 使用Context来管理协程
* 概念：
	* 使用golang开发服务器的时候，通常处理一个请求都是在一个单独的协程中进行的，
	* 处理一个请求可能会需要多个协程之间的交互，Context可以使开发者方便协程之间的信息/信号传递
* func Backgroud():
	* 该接口会返回一个空的context对象，通常由该接口来产生根context
	* 通常会搭配WithCancel或WithTimeOut或WithDeadline来使用
* func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
	* 该接口的作用是产生一个新的ctx与cancel函数，当调用cancel函数或者ctx存在时间超过超时时长时该ctx会被取消
* func WithDeadline(parent Context, d time.Time) (ctx Context, cancel CancelFunc)
	* 该接口的作用是产生一个新的ctx与cancel函数，当调用cancel函数或者到达超时时间时该ctx会被取消
* func WithValue(parent Context, key, value interface{})
	* WithValue函数与取消ctx无关，它是为了生成一个绑定了一个键值对数据的ctx，该数据可以通过ctx.Value()访问到，通过ctx来传递数据
* context.Context接口的方法：
	* [ctx对象].Done() <- chan struct{}
		* 用来判断当前的ctx是否已经被取消
	* Deadline() (deadline time.Time， ok bool)
		* 用来判断当前ctx对象是否设置超时时间
	* Err() error
		* 返回当前ctx的error
	* Value(key interface{}) interface{}
		* 获取绑定在ctx上的键值对，仅有通过WithValue创建的与键值对绑定的ctx时才有意义


		
### goroutine引出
* 需求：要求统计1-20000的数字中，哪些是素数？

* 分析思路：
	* 1、传统方法：使用一个循环，循环判断各个数是不是素数
	* 2、golang方法：使用并发或并行的方式，将统计素数的任务分配给多个goroutine去完成
	
* 解析：
	* 传统方法等于是交给一个人去做
	* golang方法等于是交给一群人去做
		