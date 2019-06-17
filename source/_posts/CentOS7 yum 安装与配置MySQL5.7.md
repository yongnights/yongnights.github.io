---
title: CentOS7 yum 安装与配置MySQL5.7
date: 2019-06-14 08:54:39
tags: 
- CentOS
- MySQL
categories: 
- CentOS 
- MySQL 
---

## 1、配置YUM源
```bash
# 安装yum源
# yum install  http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
# 检查mysql源是否安装成功
# yum repolist enabled | grep "mysql.*-community.*"
```

<escape><!-- more --></escape>

## 2. 安装MySQL
```bash
# 安装MySQL
# yum install mysql-community-server
# 启动
# systemctl start mysqld
# 查看状态
# systemctl status mysqld
```

## 3. 开机启动
```bash
# systemctl enable mysqld
# systemctl daemon-reload
```

## 4. 修改root本地登录密码
mysql安装完成之后，在/var/log/mysqld.log文件中给root生成了一个默认密码。通过下面的方式找到root默认密码，然后登录mysql进行修改：
```bash
# 查看root密码
# grep 'temporary password' /var/log/mysqld.log
# 登录修改密码
# mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'nicaimima!@#123';
# 修改密码或者使用
set password for 'root'@'localhost'=password('nicaimima!@#123'); 
```

注意：mysql5.7默认安装了密码安全检查插件（validate_password），默认密码检查策略要求密码必须包含：大小写字母、数字和特殊符号，并且长度不能少于8位。否则会提示ERROR 1819 (HY000): Your password does not satisfy the current policy requirements错误。
通过msyql环境变量可以查看密码策略的相关信息：
```bash
show variables like '%password%';
```

## 5. 修改密码策略
在/etc/my.cnf文件添加validate_password_policy配置，指定密码策略
```text
# 选择0（LOW），1（MEDIUM），2（STRONG）其中一种，选择2需要提供密码字典文件
validate_password_policy=0
```

如果不需要密码策略，添加my.cnf文件中添加如下配置禁用即可：
```text
validate_password = off
```
重新启动mysql服务使配置生效：
```bash
# systemctl restart mysqld
```

## 6. 文件相关
默认配置文件路径：
配置文件：/etc/my.cnf
日志文件：/var/log//var/log/mysqld.log
服务启动脚本：/usr/lib/systemd/system/mysqld.service
socket文件：/var/run/mysqld/mysqld.pid

## 7. 忘记root密码
如果忘记root密码，则按如下操作恢复：
编辑/etc/my.cnf文件，在[mysqld]的段中加上一句：skip-grant-tables 保存并且退出。
```bash
# mysql  -u root -p #此时登录不需要密码
>>> update mysql.user set authentication_string=password('nicaimima!@#123') where user='root' and Host = 'localhost';
>>> flush privileges;
```

