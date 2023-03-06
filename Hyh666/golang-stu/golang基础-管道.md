### channel：
* 概念：
	* channel是golang在语言级别提供的goroutine间的通信方式，我们可以使用channel在多个goroutine之间传递消息。
	* channel是进程内的通信方式，因此通过channel传递对象的过程和调用函数时的参数传递行为比较一致，比如也可以传递指针
	* channel是类型相关的，一个channel只能传递一种类型的值，这个类型需要在声明channel时指定
* 使用：
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

* 使用2：
	* make(chan type) 
		* 等价于make(chan type, 0)
	* make(chan type,capacity) 
		* capacity是容量
	* ch := make(chan int)
		* 创建一个int类型管道
	* ch <- value
		* 发送value到ch
	* <-ch
		* 接收并丢弃
	* num := <-ch
		* 从ch中接收数据，并赋值给num
	* num,ok := <- ch
		* 和上面一样的功能，但是他还同时检查是否已经关闭或为空
	* var ch1 chan int
		* 普通channel
	* var ch2 chan <- int
		* 只用于写int数据
	* var ch3 <-chan int
		* 只用于读int数据

* channel的发送和接收
	* channel作为一个队列，会保证数据收发顺序总是遵循先入先出FIFO的原则进行
	* 也会保证同一时刻有且仅有一个goroutine访问channel来发送和获取数据
	* channel发送数据的格式：
		* channel <- value
	* channel接收数据的格式：
		* value := <- channel
		* value, ok := <- channel
	* 创建channel的格式：
		* ch := make(chan T, sizeOfChannel)
		* ch := make(chan string , 10)
* 使用value, ok := <- channel的场景示例：

		func main() {
			ch := make(chan string)
			go test1(ch)
			for {
				value := <- ch
				fmt.Println("Value is", value)
		}
		func test1(ch chan string) {
			GOTIME := "2006-01-02:15:04:05"
			defer close(ch)
			for i:=1; i<=5 ; i++ {
				ch <- time.Now().Format(GOTIME)
			}
		}
	* 解析：
		* 当输出五次结果后，就会出现一直输出value is的刷屏结果
		* 因为输出五次结果之后，管道已经关闭了，但是for循环打印那里不知道
		* 所以需要使用value ok := <-ch来判断管道是否已经关闭