---
title: 网络_tcp
date: {{date}}
tags: 
- Python
- tcp
categories: 
- Python
password: 
---

# TCP简介
## TCP介绍
TCP协议，传输控制协议（英语：Transmission Control Protocol，缩写为 TCP）是一种面向连接的、可靠的、基于字节流的传输层通信协议，由IETF的RFC 793定义。
TCP通信需要经过创建连接、数据传送、终止连接三个步骤。
TCP通信模型中，在通信开始之前，一定要先建立相关的链接，才能发送数据，类似于生活中，"打电话""

## TCP特点
### 面向连接
通信双方必须先建立连接才能进行数据的传输，双方都必须为该连接分配必要的系统内核资源，以管理连接的状态和连接上的传输。
双方间的数据传输都可以通过这一个连接进行。
完成数据交换后，双方必须断开此连接，以释放系统资源。
这种连接是一对一的，因此TCP不适用于广播的应用程序，基于广播的应用程序请使用UDP协议。

### 可靠传输
1. TCP采用发送应答机制
TCP发送的每个报文段都必须得到接收方的应答才认为这个TCP报文段传输成功
2. 超时重传
发送端发出一个报文段之后就启动定时器，如果在定时时间内没有收到应答就重新发送这个报文段。
TCP为了保证不发生丢包，就给每个包一个序号，同时序号也保证了传送到接收端实体的包的按序接收。然后接收端实体对已成功收到的包发回一个相应的确认（ACK）；如果发送端实体在合理的往返时延（RTT）内未收到确认，那么对应的数据包就被假设为已丢失将会被进行重传。

<escape><!-- more --></escape>

### 错误校验
TCP用一个校验和函数来检验数据是否有错误；在发送和接收时都要计算校验和。

### 流量控制和阻塞管理
流量控制用来避免主机发送得过快而使接收方来不及完全收下。

## TCP与UDP的不同点
- 面向连接（确认有创建三方交握，连接已创建才作传输。）
- 有序数据传输重发丢失的数据包
- 舍弃重复的数据包
- 无差错的数据传输
- 阻塞/流量控制

## udp通信模型
udp通信模型中，在通信开始之前，不需要建立相关的链接，只需要发送数据即可，类似于生活中，"写信""
![](/images_tcp/001.png)

## TCP通信模型
tcp通信模型中，在通信开始之前，一定要先建立相关的链接，才能发送数据，类似于生活中，"打电话""
![](/images_tcp/002.png)

# tcp客户端
所谓的服务器端：就是提供服务的一方，而客户端，就是需要被服务的一方

## tcp客户端构建流程
tcp的客户端要比服务器端简单很多，如果说服务器端是需要自己买手机、查手机卡、设置铃声、等待别人打电话流程的话，那么客户端就只需要找一个电话亭，拿起电话拨打即可，流程要少很多
示例代码：
```python
from socket import *

# 创建socket
tcp_client_socket = socket(AF_INET, SOCK_STREAM)

# 目的信息
server_ip = input("请输入服务器ip:")
server_port = int(input("请输入服务器port:"))

# 链接服务器
tcp_client_socket.connect((server_ip, server_port))

# 提示用户输入数据
send_data = input("请输入要发送的数据：")

tcp_client_socket.send(send_data.encode("gbk"))

# 接收对方发送过来的数据，最大接收1024个字节
recvData = tcp_client_socket.recv(1024)
print('接收到的数据为:', recvData.decode('gbk'))

# 关闭套接字
tcp_client_socket.close()
```
### 运行流程
1. tcp客户端
```
请输入服务器ip:10.10.0.47
请输入服务器port:8080
请输入要发送的数据：你好啊
接收到的数据为: 我很好，你呢
```
2. 网络调试助手
![](/images_tcp/003.png)

## tcp服务器
在程序中，如果想要完成一个tcp服务器的功能，需要的流程如下：
1. socket创建一个套接字
2. bind绑定ip和port
3. listen使套接字变为可以被动链接
4. accept等待客户端的链接
5. recv/send接收发送数据
一个很简单的tcp服务器如下：
```python
from socket import *

# 创建socket
tcp_server_socket = socket(AF_INET, SOCK_STREAM)

# 本地信息
address = ('', 7788)

# 绑定
tcp_server_socket.bind(address)

# 使用socket创建的套接字默认的属性是主动的，使用listen将其变为被动的，这样就可以接收别人的链接了
tcp_server_socket.listen(128)

# 如果有新的客户端来链接服务器，那么就产生一个新的套接字专门为这个客户端服务
# client_socket用来为这个客户端服务
# tcp_server_socket就可以省下来专门等待其他新客户端的链接
client_socket, clientAddr = tcp_server_socket.accept()

# 接收对方发送过来的数据
recv_data = client_socket.recv(1024)  # 接收1024个字节
print('接收到的数据为:', recv_data.decode('gbk'))

# 发送一些数据到客户端
client_socket.send("thank you !".encode('gbk'))

# 关闭为这个客户端服务的套接字，只要关闭了，就意味着为不能再为这个客户端服务了，如果还需要服务，只能再次重新连接
client_socket.close()
```
### 运行流程
1. tcp服务器
```
接收到的数据为: 你在么？
```
2. 网络调试助手
![](/images_tcp/004.png)

# tcp注意点

1. tcp服务器一般情况下都需要绑定，否则客户端找不到这个服务器
2. tcp客户端一般不绑定，因为是主动链接服务器，所以只要确定好服务器的ip、port等信息就好，本地客户端可以随机
3. tcp服务器中通过listen可以将socket创建出来的主动套接字变为被动的，这是做tcp服务器时必须要做的
4. 当客户端需要链接服务器时，就需要使用connect进行链接，udp是不需要链接的而是直接发送，但是tcp必须先链接，只有链接成功才能通信
5. 当一个tcp客户端连接服务器时，服务器端会有1个新的套接字，这个套接字用来标记这个客户端，单独为这个客户端服务
6. listen后的套接字是被动套接字，用来接收新的客户端的链接请求的，而accept返回的新套接字是标记这个新客户端的
7. 关闭listen后的套接字意味着被动套接字关闭了，会导致新的客户端不能够链接服务器，但是之前已经链接成功的客户端正常通信。
8. 关闭accept返回的套接字意味着这个客户端已经服务完毕
9. 当客户端的套接字调用close后，服务器端会recv解堵塞，并且返回的长度为0，因此服务器可以通过返回数据的长度来区别客户端是否已经下线

# 案例:文件下载器
## 服务器 参考代码如下:
```python
from socket import *
import sys

def get_file_content(file_name):
    """获取文件的内容"""
    try:
        with open(file_name, "rb") as f:
            content = f.read()
        return content
    except:
        print("没有下载的文件:%s" % file_name)

def main():

    if len(sys.argv) != 2:
        print("请按照如下方式运行：python3 xxx.py 7890")
        return
    else:
        # 运行方式为python3 xxx.py 7890
        port = int(sys.argv[1])

    # 创建socket
    tcp_server_socket = socket(AF_INET, SOCK_STREAM)
    # 本地信息
    address = ('', port)
    # 绑定本地信息
    tcp_server_socket.bind(address)
    # 将主动套接字变为被动套接字
    tcp_server_socket.listen(128)

    while True:
        # 等待客户端的链接，即为这个客户端发送文件
        client_socket, clientAddr = tcp_server_socket.accept()
        # 接收对方发送过来的数据
        recv_data = client_socket.recv(1024)  # 接收1024个字节
        file_name = recv_data.decode("utf-8")
        print("对方请求下载的文件名为:%s" % file_name)
        file_content = get_file_content(file_name)
        # 发送文件的数据给客户端
        # 因为获取打开文件时是以rb方式打开，所以file_content中的数据已经是二进制的格式，因此不需要encode编码
        if file_content:
            client_socket.send(file_content)
        # 关闭这个套接字
        client_socket.close()

    # 关闭监听套接字
    tcp_server_socket.close()

if __name__ == "__main__":
    main()
```
## 客户端 参考代码如下:
```python
from socket import *

def main():

    # 创建socket
    tcp_client_socket = socket(AF_INET, SOCK_STREAM)

    # 目的信息
    server_ip = input("请输入服务器ip:")
    server_port = int(input("请输入服务器port:"))

    # 链接服务器
    tcp_client_socket.connect((server_ip, server_port))

    # 输入需要下载的文件名
    file_name = input("请输入要下载的文件名：")

    # 发送文件下载请求
    tcp_client_socket.send(file_name.encode("utf-8"))

    # 接收对方发送过来的数据，最大接收1024个字节（1K）
    recv_data = tcp_client_socket.recv(1024)
    # print('接收到的数据为:', recv_data.decode('utf-8'))
    # 如果接收到数据再创建文件，否则不创建
    if recv_data:
        with open("[接收]"+file_name, "wb") as f:
            f.write(recv_data)

    # 关闭套接字
    tcp_client_socket.close()

if __name__ == "__main__":
    main()
```

# tcp的3次握手
![](imges_tcp/005.png)

# tcp的4次挥手
![](imges_tcp/006.png)

# tcp长连接和短连接
TCP在真正的读写操作之前，server与client之间必须建立一个连接，当读写操作完成后，双方不再需要这个连接时它们可以释放这个连接，连接的建立通过三次握手，释放则需要四次握手，所以说每个连接的建立都是需要资源消耗和时间消耗的。

TCP通信的整个过程，如下图:
![](/images_tcp/006.png)

## TCP短连接
模拟一种TCP短连接的情况:
    1. client 向 server 发起连接请求
    2. server 接到请求，双方建立连接
    3. client 向 server 发送消息
    4. server 回应 client
	5. 一次读写完成，此时双方任何一个都可以发起 close 操作
在步骤5中，一般都是 client 先发起 close 操作。当然也不排除有特殊的情况。
从上面的描述看，短连接一般只会在 client/server 间传递一次读写操作！

## TCP长连接
再模拟一种长连接的情况:
    1. client 向 server 发起连接
    2. server 接到请求，双方建立连接
    3. client 向 server 发送消息
    4. server 回应 client
    5. 一次读写完成，连接不关闭
    6. 后续读写操作...
    7. 长时间操作之后client发起关闭请求

## TCP长/短连接操作过程
### 短连接的操作步骤是：
建立连接——数据传输——关闭连接...建立连接——数据传输——关闭连接
![](/images_tcp/007.png)

### 长连接的操作步骤是：
建立连接——数据传输...（保持连接）...数据传输——关闭连接
![](/images_tcp/008.png)

## TCP长/短连接的优点和缺点
- 长连接可以省去较多的TCP建立和关闭的操作，减少浪费，节约时间。
- 对于频繁请求资源的客户来说，较适用长连接。
- client与server之间的连接如果一直不关闭的话，会存在一个问题，
- 随着客户端连接越来越多，server早晚有扛不住的时候，这时候server端需要采取一些策略，
- 如关闭一些长时间没有读写事件发生的连接，这样可以避免一些恶意连接导致server端服务受损；
- 如果条件再允许就可以以客户端机器为颗粒度，限制每个客户端的最大长连接数，
- 这样可以完全避免某个蛋疼的客户端连累后端服务。
- 短连接对于服务器来说管理较为简单，存在的连接都是有用的连接，不需要额外的控制手段。
- 但如果客户请求频繁，将在TCP的建立和关闭操作上浪费时间和带宽。

## TCP长/短连接的应用场景
- 长连接多用于操作频繁，点对点的通讯，而且连接数不能太多情况。
	每个TCP连接都需要三次握手，这需要时间，如果每个操作都是先连接，
	再操作的话那么处理速度会降低很多，所以每个操作完后都不断开，
	再次处理时直接发送数据包就OK了，不用建立TCP连接。
	例如：数据库的连接用长连接，如果用短连接频繁的通信会造成socket错误，
	而且频繁的socket 创建也是对资源的浪费。
- 而像WEB网站的http服务一般都用短链接，因为长连接对于服务端来说会耗费一定的资源，
	而像WEB网站这么频繁的成千上万甚至上亿客户端的连接用短连接会更省一些资源，
	如果用长连接，而且同时有成千上万的用户，如果每个用户都占用一个连接的话，
	那可想而知吧。所以并发量大，但每个用户无需频繁操作情况下需用短链接好。

# tcp-ip简介
## 什么是协议
为了解决不同种族人之间的语言沟通障碍，现规定国际通用语言是英语，这就是一个规定，这就是协议

## 计算机网络沟通用什么
不同的计算机只需要能够联网（有线无线都可以）那么就可以相互进行传递数据
就像说不同语言的人沟通一样，只要有一种大家都认可都遵守的协议即可，那么这个计算机都遵守的网络通信协议叫做TCP/IP协议

## TCP/IP协议(族)
为了把全世界的所有不同类型的计算机都连接起来，就必须规定一套全球通用的协议，为了实现互联网这个目标，互联网协议族（Internet Protocol Suite）就是通用协议标准。
因为互联网协议包含了上百种协议标准，但是最重要的两个协议是TCP和IP协议，所以，大家把互联网的协议简称TCP/IP协议(族)
常用的网络协议如下图所示：
![](/images_tcp/009.png)

![](/images_tcp/010.png)

说明：
- 网际层也称为：网络层
- 网络接口层也称为：链路层

另外一套标准:
![](/images_tcp/011.png)