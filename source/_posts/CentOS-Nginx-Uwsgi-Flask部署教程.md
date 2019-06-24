---
title: CentOS+Nginx+Uwsgi+Flask部署教程
date: 2019-06-24 13:29:21
tags: 
- CentOS
- Nginx 
- uwsgi 
- Flask 
categories: 
- CentOS
- Nginx 
- uwsgi 
- Flask 
---
# 说明

本文没有采用虚拟环境的方式，若需要部署多个项目，则需要考虑使用虚拟环境的方式部署。

# 1. 安装Python3

此步骤可以查看我的博客：<https://blog.ejubei.net/2019/03/14/CentOS%207.2%E5%AE%89%E8%A3%85Python3.7/>

<escape><!-- more --></escape>

最终的效果：
```bash
[root@localhost ~]# python3 -V
Python 3.7.1
[root@localhost ~]# pip3 -V
pip 19.1.1 from /usr/local/python3/lib/python3.7/site-packages/pip (python 3.7)
[root@localhost ~]# python -V
Python 2.7.5
[root@localhost ~]# pip -V  # 默认python2.7未安装pip
-bash: pip: command not found
# 安装方法
[root@localhost ~]# yum install epel-release
[root@localhost ~]# yum install python-pip
```

# 2. 上传项目代码到服务器

这里采用最简单的Flask程序：
```python
#!/usr/bin/env python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
```

```bash
[root@localhost ~]# cd /home/
[root@localhost home]# mkdir ysb
[root@localhost home]# cd ysb/
[root@localhost ysb]# cat ysb.py
#!/usr/bin/env python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
```

程序文件放在/home/ysb目录下。
安装依赖包：`pip3 install flask`
检查程序是否正常运行：`python3 ysb.py`

# 3. 安装配置uwsgi

注意：采用pip的方式安装，不采用yum方式安装。

```bash
# 安装uswgi
[root@localhost ysb]# pip3 install uwsgi
# 查看uwsgi安装路径，创建软连接
[root@localhost ysb]# find / -name uwsgi
/usr/local/python3/bin/uwsgi
[root@localhost ysb]# ln -s /usr/local/python3/bin/uwsgi /usr/bin/uwsgi
[root@localhost ysb]# uwsgi --version
2.0.18
# 创建并配置uwsgi配置文件，新建专门的一个uwsgi目录用来存放相关文件
[root@localhost ysb]# mkdir /etc/uwsgi
[root@localhost uwsgi]# cat uwsgi.ini 
[uwsgi]
socket = 127.0.0.1:5000
chdir = /home/ysb/
wsgi-file = app.py
callable = app
processes = 4
daemonize = /tmp/uwsgiServer.log
vacuum = true
log-maxsize = 5000
disable-logging = true
master=true
uid=nginx
gid=nginx
py-autoreload=1
stats=/etc/uwsgi/uwsgi.status
pidfile=/etc/uwsgi/uwsgi.pid
```

uwsgi.ini配置文件参数解析：
- socket：uwsgi监听的socket，可以为socket文件或ip地址+端口号，在这里指定为127.0.0.1:5000，这样就会监听到网络套接字，跟Nginx配置文件中监听的保持一致。若是使用socket文件，比如socket =/web/script/uwsgi.sock，还需要设置chmod-socket = 755(socket权限设置)
- chdir：在app加载前切换到当前目录， 指定运行目录
- wsgi-file：主程序文件
- callable：主程序中的变量名
- processes：开启的进程数量（和worker作用相同）
- daemonize：使进程在后台运行，并将日志打到指定的日志文件或者udp服务器（不会影响nginx日志的输出）
- vacuum：当服务停止的时候自动移除unix Socket 和 Pid 文件
- log-maxsize：设置最大日志文件大小
- disable-logging：禁用请求日志记录
- master：启动一个master进程来管理其他进程，以上述配置为例，其中的4个uwsgi进程都是这个master进程的子进程，如果kill这个master进程，相当于重启所有的uwsgi进程
- uid：uwsgi启动用户名
- gid：uwsgi启动用户组
- py-autoreload：监控python模块mtime来触发重载 (只在开发时使用)
- stats：状态文件
- pidfile：指定pid文件

其他参数：
- thunder-lock：序列化接受的内容(thunder-lock = true)
- enable-threads：允许用内嵌的语言启动线程。这将允许你在app程序中产生一个子线程（enable-threads = true）
- post-buffering：设置缓冲(post-buffering = 4096)
- static-map：设置静态文件路径（static-map = /static=//www/wwwroot/mysite/static）
- socket-timeout：为所有的socket操作设置内部超时时间（默认4秒），这个配置会结束那些处于不活动状态超过10秒的连接。
- harakiri：一个请求花费的时间超过了这个harakiri超时时间，那么这个请求都会被丢弃，并且当前处理这个请求的工作进程会被回收再利用（即重启）(harakiri = 30)
- buffer-size：设置用于uwsgi包解析的内部缓存区大小为64k。默认是4k。(buffer-size = 32768)
- listen：设置socket的监听队列大小（默认：100）(listen = 120)
- reload-mercy：设置在平滑的重启（直到接收到的请求处理完才重启）一个工作子进程中，等待这个工作结束的最长秒数。这个配置会使在平滑地重启工作子进程中，如果工作进程结束时间超过了8秒就会被强行结束（忽略之前已经接收到的请求而直接结束）(reload-mercy = 8)
- max-requests：为每个工作进程设置请求数的上限。当一个工作进程处理的请求数达到这个值，那么该工作进程就会被回收重用（重启）。你可以使用这个选项来默默地对抗内存泄漏(max-requests = 5000)
- limit-as：通过使用POSIX/UNIX的setrlimit()函数来限制每个uWSGI进程的虚拟内存使用数。这个配置会限制uWSGI的进程占用虚拟内存不超过256M。如果虚拟内存已经达到256M，并继续申请虚拟内存则会使程序报内存错误，本次的http请求将返回500错误。(limit-as = 256 )



# 4. 安装配置Nginx

```bash
# 安装Nginx
[root@localhost ~]# yum install nginx
# 修改nginx.conf配置文件
# 把自带的server{}块注释掉，然后在/etc/nginx/conf.d/目录下新建一个以conf结尾的文件，比如ysb.conf
[root@localhost conf.d]# cat ysb.conf 
server {
    listen       80;
    server_name  192.168.0.139;
    
    location / {
        include uwsgi_params;
        uwsgi_pass 127.0.0.1:5000;
    }
}

# 检测Nginx配置是否正确
[root@localhost conf.d]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
# 启动Nginx
[root@localhost conf.d]# systemctl start nginx.service 
# 查看Nginx状态
[root@localhost conf.d]# systemctl status nginx.service
```

# 5. uwsgi操作相关

```bash
# 启动
[root@localhost ysb]# uwsgi --ini uwsgi.ini
# 重启
[root@localhost ysb]# uwsgi --reload uwsgi.pid
# 关闭
[root@localhost ysb]# uwsgi --stop uwsgi.pid            
```
但是uwsgi启动后报错，通过查看log日志文件可知：
```text
*** uWSGI is running in multiple interpreter mode ***
spawned uWSGI master process (pid: 20234)
spawned uWSGI worker 1 (pid: 20235, cores: 1)
spawned uWSGI worker 2 (pid: 20236, cores: 1)
spawned uWSGI worker 3 (pid: 20237, cores: 1)
spawned uWSGI worker 4 (pid: 20238, cores: 1)
bind(): Permission denied [core/socket.c line 230]
...brutally killing workers...
unlink(): No such file or directory [core/uwsgi.c line 1673]
```

经排查，是因为nginx用户对/etc/uwsgi/目录没有相关权限造成的。(前提条件：已关闭SElinux)
所以进行如下操作：
```bash
[root@localhost ~]# chown -R nginx:nginx /etc/uwsgi/
[root@localhost ~]# chown -R nginx:nginx /home/ysb/
```

然后再运行：`[root@localhost ~]# uwsgi --ini /etc/uwsgi/uwsgi.ini`
查看状态：
```bash
[root@localhost etc]# netstat -tulnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address       Foreign Address       State       PID/Program name    
tcp        0      0 127.0.0.1:5000      0.0.0.0:*             LISTEN      20970/uwsgi         
tcp        0      0 0.0.0.0:80          0.0.0.0:*             LISTEN      19713/nginx: master 
```

然后用浏览器访问ip地址，就能出现'Hello World!'

# 6. 常见问题
## 1. 访问浏览器出现502错误，查看nginx错误日志提示权限禁止
考虑关闭SElinux
## 2. 运行uwsgi出现错误：bind(): Permission denied [core/socket.c line 230]
这是因为nginx用户对uwsgi文件没有相关权限，修改其所属用户和用户组为nginx即可

