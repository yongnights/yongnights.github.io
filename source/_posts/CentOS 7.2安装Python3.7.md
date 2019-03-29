---
title: CentOS 7.2安装Python3.7
date: {{date}}
tags: 
- CentOS
- Python
categories: 
- CentOS
---
### 系统环境
	• CentOS 7.3 x86_64
### 操作步骤
####  安装依赖包
	# yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make libffi-devel 
#### 下载 Python 3.7.1源码包
	# wget https://www.python.org/ftp/python/3.7.1/Python-3.7.1.tar.xz
#### 解压到指定目录
	# tar xf Python-3.7.1.tar.xz -C /usr/local/src/ (yum -y install xz  #若失败,重建yum缓存.yum clean all ,yum makecache)

<escape><!-- more --></escape>

#### 开始安装
	# cd /usr/local/src/Python-Python-3.7.1
	# ./configure --prefix=/usr/local/python3
	# make && make install
	说明：从 Python 3.4 开始就已经自带了 pip 和 easy_install（setuptools 包带的命令） 包管理命令，可以在 /usr/local/python3/bin/ 目录下看到，查看一下已经安装的扩展包：
	#/usr/local/python3/bin/pip3 list
	pip (8.1.1)
	setuptools (20.10.1)
	You are using pip version 8.1.1, however version 8.1.2 is available.
	You should consider upgrading via the 'pip install --upgrade pip' command.
	更新pip
	#/usr/local/python3/bin/pip3 install --upgrade pip
#### 添加软连接
	#ln -s /usr/local/python/python3/bin/python3 /usr/bin/python3
	#ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
#### 验证
	# python3 -V
	# pip3 list

