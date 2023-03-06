### sync包工具：
* Mutex：互斥锁
* RWMutex：读写锁
* WaitGroup：并发等待组
* Map：并发安全字典
* Once：单例模式
* Cond：同步等待条件
* Pool：临时对象池

### Mutex：
* 保证了同一时间内有且仅有一个goroutine持有锁
* 保证了某一时间段内有且仅有一个goroutine访问共享资源，其他申请锁的goroutine将会被阻塞直达锁被释放

### RWMutex：
* 在同一时间段内只能有一个goroutine获取到写锁
* 在同一时间段内可以有多个goroutine获取到读锁
* 在同一时间段内只能存在读锁或者写锁（读锁和写锁互斥）

### WaitGroup：
* 使用WaitGroup的goroutine会当提前预设好数量的goroutine都提交执行结束后，才会继续往下执行代码
* 在goroutine调用WaitGroup之前我们需要保证WaitGroup中等待数据大于1
* 保证WaitGroup.Done()执行的次数与WaitGroup.Add()相同，过少会导致goroutine死锁，过多导致panic