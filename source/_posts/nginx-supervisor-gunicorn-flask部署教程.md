---
title: nginx+supervisor+gunicorn+flask部署教程
date: 2019-06-24 15:18:14
tags: 
- CentOS
- Nginx 
- supervisor 
- gunicorn 
- Flask 
categories: 
- CentOS
- Nginx 
- supervisor 
- gunicorn 
- Flask 
---
# 说明

本文采用虚拟环境的方式，方便部署多个项目。

# 1. 安装Python3

此步骤可以查看我的博客：<https://blog.ejubei.net/2019/03/14/CentOS%207.2%E5%AE%89%E8%A3%85Python3.7/>

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

<escape><!-- more --></escape>

# 2. 创建项目目录，安装虚拟环境

1. 创建项目目录，安装虚拟环境
[root@localhost ~]# mkdir –p /home/microblog && cd /home/microblog && python3 -m venv venv
2. 激活虚拟环境，安装项目所需的依赖包
需要事先把requirements.txt放入项目所在目录中
[root@localhost microblog]# source venv/bin/activate
(venv) [root@localhost microblog]# pip3 install -r requirements.txt
3. 上传项目代码
演示使用，本例用一个最简单的flask应用：mocroblog.py
```python
#!/usr/bin/env python
from flask import Flask
app = Flask(__name__)

@app.route('/')
@app.route('/index')
def index():
    return 'Hello World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0')
```
4. 测试
```bash
(venv) [root@localhost microblog]# python3 microblog.py
* Serving Flask app "microblog" (lazy loading)
* Environment: production
WARNING: Do not use the development server in a production environment.
Use a production WSGI server instead.
* Debug mode: off
* Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
```

再打开一个窗口，运行：
```bash
[root@localhost ~]# curl -i http://127.0.0.1:5000
HTTP/1.0 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 12
Server: Werkzeug/0.14.1 Python/3.7.0
Date: Sat, 07 Jul 2018 03:52:31 GMT
Hello World!
```

一切正常！

# 3. 安装项目使用的web服务

1. 安装nginx
[root@localhost ~]# yum install nginx
默认安装目录：/etc/nginx

2. 安装supervisor
注意：此软件要求系统Python版本不能高于3
[root@localhost ~]# yum install supervisor

3. 安装gunicorn
注意，这个要安装在项目使用的虚拟环境中
```bash
[root@localhost nginx]# cd /home/microblog/
[root@localhost microblog]# source venv/bin/activate
(venv) [root@localhost microblog]# pip3 install gunicorn
```

# 五. 相关配置文件设置
1. nginx相关配置
把/etc/nginx/nginx.conf中server{}块注释，在/etc/nginx/conf.d/目录中添加项目使用的以conf结尾的文件，比如：m.conf，内容如下：
```conf
server {
    listen 80; #nginx监听端口
    server_name 192.168.109.128; #域名或IP
    location / {
        proxy_pass http://127.0.0.1:9000; #监听代理端口
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
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

2. supervisor配置
默认配置文件：(1)/etc/supervisord.conf，在该文件最后一行有这样的信息：
```text
[include]
files = supervisord.d/*.ini
```
也就说我们在这个目录下创建一个以ini结尾的文件即可
比如：/etc/supervisord.d/m.ini
其内容如下：
```text
[program:microblog]
directory = /home/microblog
command = /home/microblog/venv/bin/gunicorn -b 127.0.0.1:9000 -w 2 microblog:app #一定要是虚拟环境中的绝对路径
user = root
autostart = true
autorestart = true
stopasgroup = true
killasgroup = true
startsecs = 5
startretries = 3
redirect_stderr = true
stdout_logfile_maxbytes = 20MB
stdout_logfile_backups = 20
stdout_logfile = /var/log/supervisord_stdout.log
```
启动：supervisord -c /etc/supervisord.conf

# 五. 测试

使用浏览器访问：ip即可得到flask响应的结果，注意防火墙放行80端口

# 六. 其他说明

nginx+gunicorn+flask:这种模式就是不使用supervisor管理gunicorn
单独执行gunicorn命令：gunicorn -b 127.0.0.1:9000 microblog:app

# 七. 扩展

1. supervisorctl的使用
    supervisorctl status # 查询进程状态
    supervisorctl stop node # 关闭 [program:node] 的进程
    supervisorctl start node # 启动 [program:node] 的进程
    supervisorctl restart node # 重启 [program:node] 的进程
    supervisorctl stop all # 关闭所有进程
    supervisorctl start all # 启动所有进程
    supervisorctl reload # 重新读取配置文件,读取有更新（增加）的配置文件，不会启动新添加的程序
    supervisorctl update # 重启配置文件修改过的程序
2. 常见的gunicorn配置
    [program:microblog]
    directory = /home/microblog; 程序的启动目录
    command = gunicorn -c gunicorn.py wsgi:app ; 启动命令，可以看出与手动在命令行启动的命令是一样的
    autostart = true ; 在 supervisord 启动的时候也自动启动
    startsecs = 5 ; 启动 5 秒后没有异常退出，就当作已经正常启动了
    autorestart = true ; 程序异常退出后自动重启
    startretries = 3 ; 启动失败自动重试次数，默认是 3
    user = leon ; 用哪个用户启动
    redirect_stderr = true ; 把 stderr 重定向到 stdout，默认 false
    stdout_logfile_maxbytes = 20MB ; stdout 日志文件大小，默认 50MB
    stdout_logfile_backups = 20 ; stdout 日志文件备份数
    ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
    stdout_logfile = /data/logs/usercenter_stdout.log
    若是项目中没有设置debug=True，则更改项目内容后想看到效果需要重载一下supervisor服务
    supervisorctl reload
3. 其他别人的配置
网址：<https://github.com/seasonstar/bibi>
This based on Ubuntu/Debian，please skip if you had set up Python 3 environment.
```bash
# 安装python3环境
sudo apt-get update
sudo apt-get install python3-pip python3-dev
sudo apt-get install build-essential libssl-dev libffi-dev python-dev

#安装virtualenv
sudo pip3 install virtualenv virtualenvwrapper
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> ~/.bashrc
echo "export WORKON_HOME=~/Env" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
source ~/.bashrc

# 现在你的home目录下有Env的文件夹，你的python虚拟环境都会创建在这里

mkvirtualenv bibi # bibi可随便改成你的项目名
workon bibi # 现在已进入项目的独立环境

# 安装 mongodb 略  (请安装mongodb 2.6版本)
# 安装 redis 略
# 安装 rabbitMQ 略

mongod &              # 启动mongodb
redis-server &        # 启动redis
rabbitmq-server &     # 启动RabbitMQ
```

安装依赖
`pip3 install -r requirements.txt`

初始化数据库
```bash
python3 manage.py shell
# into Python3 shell
>>> from application.models import User
>>> user = User.create(email="xxxx@xxx.com", password="xxx", name="xxxx")
# email, password, name改成你自己的
>>> user.roles.append("ADMIN")
>>> user.save()
```

运行
```bash
# 启动 celery
celery -A application.cel worker -l info &

python3 manage.py runserver
```
本地可以打开 http://127.0.0.1:5000/admin/

部署方式
```bash
# 安装 supervisor
sudo apt-get install supervisor
# 安装 gunicorn
pip3 install gunicorn
```

创建supervisor配置
```bash
sudo vim /etc/supervisor/conf.d/bibi.conf

[program:bibi]
command=/root/Env/bibi/bin/gunicorn
    -w 3
    -b 0.0.0.0:8080
    --log-level debug
    "application.app:create_app()"

directory=/opt/py-maybi/                                       ; 你的项目代码目录
autostart=false                                                ; 是否自动启动
autorestart=false                                              ; 是否自动重启
stdout_logfile=/opt/logs/gunicorn.log                          ; log 日志
```

PS: 上面 -w 为 开启workers数，公式：（系统内核数*2 + 1)

创建nginx配置
```bash
sudo vim /etc/nginx/sites-enabled/bibi.conf

server {
    listen 80;
    server_name bigbang.maybi.cn; # 这是HOST机器的外部域名，用地址也行

    location / {
        proxy_pass http://127.0.0.1:8080; # 这里是指向 gunicorn host 的服务地址
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

  }
```
接着启动 supervisor, nginx
```bash
sudo supervisorctl reload
sudo supervisorctl start bibi
sudo service nginx restart
```