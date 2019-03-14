---
title: CentOS 7.2安装redis
date: {{date}}
tags:
- CentOS
- Redis
categories:
- CentOS
---
#### 安装
	# yum -y install redis
#### 常用命令
##### (1)查看安装版本:
	使用服务端命令：redis-server --version 和 redis-server -v
	使用客户端命令：redis-cli --version 和 redis-cli -v
	因为redis 的server 与 cli 同时安装，所以二者查出的结果基本一致
##### (2)启动，停止，重启
	service redis start|stop|restart
##### (3)开启远程连接
	修改redis.conf配置文件，把bind=127.0.0.1注释掉(如果想设置密码在redis.conf中加上requirepass:密码即可)

<escape><!-- more --></escape>

#### 安全建议
##### 1、Redis本身防护
       (1)修改Redis默认端口，将默认的6379端口修改为其他端口；
       (2)增加Redis用户名和密码，Redis使用普通用户权限，禁止使用 root 权限启动Redis 服务，这样可以保证在存在漏洞的情况下攻击者也只能获取到普通用户权限，无法获取root权限；设置密码访问认证，可通过修改redis.conf配置文件中的"requirepass" 设置复杂密码 （需要重启Redis服务才能生效）；
       (3)在Redis绑定指定IP访问(位置配置文件[redis.config]中的bind节点)
       (4)禁用config指令避免恶意操作，在Redis配置文件redis.conf中配置rename-command项"RENAME_CONFIG"，这样即使存在未授权访问，也能够给攻击者使用config 指令加大难度；
##### 2、Linux服务器
       (1)Redis服务器不要暴露在外网，禁止Redis服务对公网开放，可通过修改redis.conf配置文件中的"#bind 127.0.0.1" ，去掉前面的"#"即可（Redis本来就是作为内存数据库，只要监听在本机即可）；
       (2)开启防火墙，限制IP可以访问(iptables命令)，对访问源IP进行访问控制，可在防火墙限定指定源ip才可以连接Redis服务器；
       (3)用容器（如Docker等）管理起服务器，这样中病毒后排查不出原因需要重新装环境的时候影响小并且可以快速恢复。

#### redis客户端
	Redis桌面管理工具：Redis Desktop Manager，下载地址：http://down-www.newasp.net/pcdown/soft/dys/redis.desktop.manager.exe