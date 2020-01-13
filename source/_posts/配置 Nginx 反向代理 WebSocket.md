---
title: 配置 Nginx 反向代理 WebSocket
top: 
date: 
tags: 
- Nginx
- WebSocket 
categories: 
- Nginx
- WebSocket 
password: 
---
用Nginx给网站做反向代理和负载均衡是广泛使用的一种Web服务器部署技术。不仅能够保证后端服务器的隐蔽性，还可以提高网站部署灵活性。

今天我们来讲一下，如何用Nginx给WebSocket服务器实现反向代理和负载均衡。

### 什么是反向代理和负载均衡

-   反向代理(Reverse Proxy)方式是指以代理服务器来接受Internet上的连接请求，然后将请求转发给内部网络上的服务器。并将内部服务器上得到的结果返回给Internet上请求连接的客户端，此时代理服务器对外就表现为一个服务器。
-   负载均衡(Load Balancing)建立在现有网络结构之上，它提供了一种廉价有效透明的方法扩展网络设备和服务器的带宽、增加吞吐量、加强网络数据处理能力、提高网络的灵活性和可用性。

<escape><!-- more --></escape>

### 什么是WebSocket

WebSocket协议相比较于HTTP协议成功握手后可以多次进行通讯，直到连接被关闭。但是WebSocket中的握手和HTTP中的握手兼容，它使用HTTP中的Upgrade协议头将连接从HTTP升级到WebSocket。这使得WebSocket程序可以更容易的使用现已存在的基础设施。

WebSocket工作在HTTP的80和443端口并使用前缀`ws://`或者`wss://`进行协议标注，在建立连接时使用HTTP/1.1的101状态码进行协议切换，当前标准不支持两个客户端之间不借助HTTP直接建立Websocket连接。

更多Websocket的介绍可参考「[WebSocket教程](http://t.cn/RaT8tNb)」一文。

### 创建基于Node的WebSocket服务

Nginx在官方博客上给出了一个实践样例「[Using Nginx as a Websocket Proxy](https://www.nginx.com/blog/websocket-nginx/)」，我们以这个例子来演示WebSocket的交互过程。

这个例子中将会使用到nodejs的一个WebSocket的ws模块。

#### 安装node.js和npm

-   Debian/Ubuntu

```
$ apt-get install nodejs npm
```

-   RHEL/CentOS

```
$ yum install nodejs npm
```

#### 创建nodejs软链

在Ubuntu上创建一个名叫node软链。Centos默认为node，不用在单独创建了。

```
# 如果不创建，后面运行wscat时Ubuntu环境中会报错。
$ ln -s /usr/bin/nodejs /usr/bin/node
```

#### 安装ws和wscat模块

`ws`是nodejs的WebSocket实现，我们借助它来搭建简单的WebSocket Echo Server。`wscat`是一个可执行的WebSocket客户端，用来调试WebSocket服务是否正常。

```
$ npm install ws wscat
```

如果访问官方仓库比较慢的话，可用淘宝提供的镜像服务。

```
$ npm --registry=https://registry.npm.taobao.org install ws wscat
```

#### 创建一个简单的服务端

这个简单的服务端实现的是向客户端返回客户端发送的消息。

```
$ vim server.js

console.log("Server started");
var Msg = '';
var WebSocketServer = require('ws').Server
    , wss = new WebSocketServer({port: 8010});
    wss.on('connection', function(ws) {
        ws.on('message', function(message) {
        console.log('Received from client: %s', message);
        ws.send('Server received from client: ' + message);
    });
 });
```

运行这个简单的`echo`服务

```
$ node server.js
Server started
```

验证服务端是否正常启动

```
$ netstat  -tlunp|grep 8010
tcp6       0      0 :::8010                 :::*                    LISTEN      23864/nodejs
```

#### 使用wscat做为客户端测试

`wscat`命令默认安装当前用户目录`node_modules/wscat/`目录，我这里的位置是`/root/node_modules/wscat/bin/wscat`。

输入任意内容进行测试，得到相同返回则说明运行正常。

```
$ cd /root/node_modules/wscat/bin/
$ ./wscat --connect ws://127.0.0.1:8010

connected (press CTRL+C to quit)
> Hello
< Server received from client: Hello

> Welcome to www.hi-linux.com
< Server received from client: Welcome to www.hi-linux.com
```

### 使用Nginx对WebSocket进行反向代理

#### 安装Nginx

-   下载对应软件包

Nginx从1.3.13版本就开始支持WebSocket了，并且可以为WebSocket应用程序做反向代理和负载均衡。这里Nginx选用1.9.2版本。

```
$ cd /root
$ wget 'http://nginx.org/download/nginx-1.9.2.tar.gz'
```

-   编译安装Nginx

```
$ apt-get install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential
$ tar xzvf nginx-1.9.2.tar.gz
$ cd nginx-1.9.2
$ ./configure
$ make && make install
```

#### 配置Nginx

-   修改Nginx主配置文件

```
$ vim /usr/local/nginx/conf/nginx.conf

# 在http上下文中增加如下配置，确保Nginx能处理正常http请求。

http {

  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''   close;
  }

  upstream websocket {
    #ip_hash;
    server localhost:8010;  
    server localhost:8011;
  }

# 以下配置是在server上下文中添加，location指用于websocket连接的path。

  server {
    listen       80;
    server_name localhost;
    access_log /var/log/nginx/yourdomain.log;

    location / {
      proxy_pass http://websocket;
      proxy_read_timeout 300s;

      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
		}
	}
}
```

最重要的就是在反向代理的配置中增加了如下两行，其它的部分和普通的HTTP反向代理没有任何差别。

```
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $connection_upgrade;
```

这里面的关键部分在于HTTP的请求中多了如下头部：

```
Upgrade: websocket
Connection: Upgrade
```

这两个字段表示请求服务器升级协议为WebSocket。服务器处理完请求后，响应如下报文：

```
# 状态码为101
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: upgrade
```

告诉客户端已成功切换协议，升级为Websocket协议。握手成功之后，服务器端和客户端便角色对等，就像普通的Socket一样，能够双向通信。不再进行HTTP的交互，而是开始WebSocket的数据帧协议实现数据交换。

这里使用`map`指令可以将变量组合成为新的变量，会根据客户端传来的连接中是否带有Upgrade头来决定是否给源站传递Connection头，这样做的方法比直接全部传递upgrade更加优雅。

默认情况下，连接将会在无数据传输60秒后关闭，`proxy_read_timeout`参数可以延长这个时间或者源站通过定期发送ping帧以保持连接并确认连接是否还在使用。

-   启动Nginx

Nginx会默认安装到`/usr/local/nginx`目录下。

```
$ cd /usr/local/nginx/sbin
$ ./nginx -c /usr/local/nginx/conf/nginx.conf
```

如果你想以Systemd服务的方式更方便的管理Nginx，可参考「[基于Upsync模块实现Nginx动态配置](https://www.hi-linux.com/posts/1084.html)」 一文。

-   测试通过Nginx访问WebSocket服务

上面的配置会使NGINX监听80端口，并把接收到的任何请求传递给后端的WebSocket服务器。我们可以使用`wscat`作为客户端来测试一下：

```
$ cd /root/node_modules/wscat/bin/
$ ./wscat --connect ws://192.168.2.210
connected (press CTRL+C to quit)
> Hello Nginx
< Server received from client: Hello Nginx
> Welcome to www.hi-linux.com
< Server received from client: Welcome to www.hi-linux.com
```

-   反向代理服务器在支持WebSocket时面临的挑战

WebSocket是端对端的，所以当一个代理服务器从客户端拦截一个Upgrade请求，它需要去发送它自己的Upgrade请求到后端服务器，也包括合适的头。

因为WebSocket是一个长连接，不像HTTP那样是典型的短连接，所以反向代理服务器需要允许连接保持着打开，而不是在它们看起来空闲时就将它们关闭。