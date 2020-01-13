---
title: Linux yum安装PostgreSQL9.6
top: 
date: 
tags: 
- PostgreSQL
categories: 
- PostgreSQL
password: 
---
PostgreSQL10版本的主从安装配置在 https://www.cnblogs.com/virtulreal/p/11675841.html

## 一、下载安装

### 1、创建PostgreSQL9.6的yum源文件

```
$ yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
```

### 2、安装PostgreSQL客户端

```
$ yum install postgresql96  
```

<escape><!-- more --></escape>

### 3、安装PostgreSQL服务端

```
$ yum install postgresql96-server
```

### 4、安装PostgreSQL拓展包(可选)

```
$ yum install postgresql96-devel.x86_64 
```

### 5、安装PostgreSQL的附加模块（可选）

```
$ yum install postgresql96-contrib.x86_64 
```

## 二、配置初始化

### 初始化数据库

```
$ /usr/pgsql-9.6/bin/postgresql96-setup initdb
```

### 启动postgresql服务，并设置为开机自动启动

```
$ systemctl enable postgresql-9.6
$ systemctl start postgresql-9.6
```

## postgres用户初始配置

### 安装完成后，操作系统会自动创建一个postgres用户用来管理数据库，为其初始化密码(输入命令后连输2次密码)：

```
$ passwd postgres
```

## 数据库初始配置

### 使用数据库自带的postgres用户登录数据库,并为其赋予密码

```
$ su - postgres
$ psql -U postgres
alter user postgres with password '你的密码';
```

## 配置远程连接

>   可能在/var/lib/pgsql/9.6/data下，可以

### 1、使用find / -name 'pg_hba.conf'查找到pg_hba.conf，修改pg_hba.conf

>   在最后添加允许访问IP段（全网段可访问）
>   host all all 0.0.0.0/0 md5

### 2、使用find / -name 'postgresql.conf'找到 postgresql.conf

>   找到用户参数listen_address(取消掉注释),改成下面样式:

```
listen_address = '*'  
```

>   启用密码验证

```
#password_encryption = on 修改为 password_encryption = on  
```

### 3、重启数据库

```
$ systemctl restart postgresql-9.6  
```

>   备注:使用Navicat For PostgreSql来连接