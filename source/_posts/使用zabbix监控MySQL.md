---
title: 使用zabbix监控MySQL
date: 2019-06-17 16:30:44
tags: 
- CentOS
- Zabbix
- MySQL 
categories: 
- CentOS 
- Zabbix 
- MySQL 
---
# 说明

zabbix-agent和MySQL都是使用yum方式进行安装的，所有路径都使用默认的。

# 配置.my.cnf文件

.my.cnf这个文件是zabbix要求的用于存放连接mysql数据库的账户信息的隐藏文件，需要手动创建，其存放位置可以自定义，此时该文件保存路径如下：/etc/zabbix/etc/.my.cnf
内容如下：

<escape><!-- more --></escape>

```bash
[root@localhost etc]# vim /etc/zabbix/etc/.my.cnf
[mysql] #mysql程序要使用的账户信息
host=localhost
user=zabbix
password="xxxxx" #此处的密码强烈建议加上引号
socket=/var/lib/mysql/mysql.sock #确认mysql的sock文件路径
[mysqladmin]
host=localhost
user=zabbix
password="xxxxxx"
socket=/var/lib/mysql/mysql.sock
```

# 提供mysql的userparameter配置文件

zabbix-agent已经自带的有该模板文件了，路径：/etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf

查看zabbix-agent配置文件(zabbix_agentd.conf)中是否包含该文件：
```bash
[root@localhost zabbix]# cat zabbix_agentd.conf | grep 'Include'
Include=/etc/zabbix/zabbix_agentd.d/*.conf
```

# 修改mysql的userparameter配置文件

将文件中HOME=/var/lib/zabbix改成HOME=/etc/zabbix/etc，表示的是.my.cnf文件所在路径
将其中的指令部分mysql和mysqladmin改成绝对路径，分别是/usr/bin/mysql和/usr/bin/mysqladmin，最终效果如下：

```text
UserParameter=mysql.status[*],echo "show global status where Variable_name='$1';" | HOME=/etc/zabbix/etc /usr/bin/mysql -N | awk
'{print $$2}'

UserParameter=mysql.size[*],bash -c 'echo "select sum($(case "$3" in both|"") echo "data_length+index_length";; data|index) echo 
"$3_length";; free) echo "data_free";; esac)) from information_schema.tables$([[ "$1" = "all" || ! "$1" ]] || echo " where table_
schema=\"$1\"")$([[ "$2" = "all" || ! "$2" ]] || echo "and table_name=\"$2\"");" | HOME=/etc/zabbix/etc /usr/bin/mysql -N'

UserParameter=mysql.ping,HOME=/etc/zabbix/etc /usr/bin/mysqladmin ping | grep -c alive

UserParameter=mysql.version,/usr/bin/mysql -V
```

重启zabbix_agentd服务

# zabbix web给主机添加MySQL模板

配置，主机，点击主机名称，模板，添加模板：Template DB MySQL