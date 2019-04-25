---
title: Redis
date: {{date}}
tags: 
- Redis
categories: 
- Redis
password: 
---

# 1. 简介
## 1.1 nosql介绍
NoSQL：一类新出现的数据库(not only sql)，特点如下：
- 不支持SQL语法
- 存储结构跟传统关系型数据库中的那种关系表完全不同，nosql中存储的数据都是KV形式
- NoSQL的世界中没有一种通用的语言，每种nosql数据库都有自己的api和语法，以及擅长的业务场景
- NoSQL中的产品种类相当多：
    - Mongodb
    - Redis
    - Hbase hadoop
    - Cassandra hadoop

## 1.2 NoSQL和SQL数据库的比较
- 适用场景不同：sql数据库适合用于关系特别复杂的数据查询场景，nosql反之
- “事务”特性的支持：sql对事务的支持非常完善，而nosql基本不支持事务
- 两者在不断地取长补短，呈现融合趋势

<escape><!-- more --></escape>

## 1.3 Redis简介
- Redis是一个开源的使用ANSI  C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。从2010年3月15日起，Redis的开发工作由VMware主持。从2013年5月开始，Redis的开发由Pivotal赞助。
- Redis是 NoSQL技术阵营中的一员，它通过多种键值数据类型来适应不同场景下的存储需求，借助一些高层级的接口使用其可以胜任，如缓存、队列系统的不同角色

## 1.4 Redis特性
- Redis 与其他 key - value 缓存产品有以下三个特点：
- Redis支持数据的持久化，可以将内存中的数据保存在磁盘中，重启的时候可以再次加载进行使用。
- Redis不仅仅支持简单的key-value类型的数据，同时还提供list，set，zset，hash等数据结构的存储。
- Redis支持数据的备份，即master-slave模式的数据备份。

## 1.5 Redis 优势
- 性能极高 – Redis能读的速度是110000次/s,写的速度是81000次/s 。
- 丰富的数据类型 – Redis支持二进制案例的 Strings, Lists, Hashes, Sets 及 Ordered Sets 数据类型操作。
- 原子 – Redis的所有操作都是原子性的，同时Redis还支持对几个操作全并后的原子性执行。
- 丰富的特性 – Redis还支持 publish/subscribe, 通知, key 过期等等特性。

## 1.6 Redis 应用场景
- 用来做缓存(ehcache/memcached)——redis的所有数据是放在内存中的（内存数据库）
- 可以在某些特定应用场景下替代传统数据库——比如社交类的应用
- 在一些大型系统中，巧妙地实现一些特定的功能：session共享、购物车
- 只要你有丰富的想象力，redis可以用在可以给你无限的惊喜…….

## 1.7 推荐阅读
- [redis官方网站] <https://redis.io/>
- [redis中文官网] <http://redis.cn/>

# 2. 安装
## 2.1 下载
Redis 版本号采用标准惯例：**主版本号.副版本号.补丁级别**,一个副版本号就标记为一个标准发行版本，例如 1.2，2.0，2.2，2.4，2.6，2.8，奇数的副版本号用来表示**非标准**版本,例如2.9.x，发行版本是Redis 3.0。最新稳定版本是5.0.4，下载链接：<http://download.redis.io/releases/redis-5.0.4.tar.gz>
- setp1：下载：wget http://download.redis.io/releases/redis-5.0.4.tar.gz

- setp2：解压：tar -zxvf redis-5.0.4.tar.gz

- setp3：进入到Redis目录： redis-5.0.4/

- step4：生成：make

- setp5：测试,这段运行时间会比较长：make test

- step6：安装：make install

- setp7：进入到默认安装目录下查看：cd /usr/local/bin && ls -al
    > - redis-server  redis服务器
    > - redis-cli redis命令行客户端
    > - redis-benchmark redis性能测试工具
    > - redis-check-aof AOF文件修复工具
    > - redis-check-rdb  RDB文件检索工具

- setp8：配置文件，移动到/etc/目录下：cp redis-5.0.4/redis.conf /etc/redis/redis

其他安装方式：
使用yum方式安装：yum -y install epel-release && yum -y install redis (3.0.6版本)
使用yum安装最新版本，如下命令安装的是最新5.0.4版本
```bash
yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi install redis
```
yum安装的配置文件路径：/etc/redis.conf 
安装路径：`ll /usr/bin/ | grep redis`

# 3. 配置
yum安装的配置文件路径：/etc/redis.conf

核心配置选项
- 绑定ip：如果需要远程访问，可将此行注释，或绑定一个真实ip，默认是本机127.0.0.1
> bind 127.0.0.1

- 端口：默认为6379
> port 6379

- 是否以守护进程运行
    - 如果以守护进程运行，则不会在命令行阻塞，类似于服务
    - 如果以非守护进程运行，则当前终端被阻塞
    - 设置为yes表示守护进程，设置为no表示非守护进程
    - 推荐设置为yes
> daemonize yes

- 数据文件
> dbfilename dump.rdb

- 数据文件存储路径
> dir /var/lib/redis

- 日志文件
> logfile /var/log/redis/redis-server.log

- 数据库，默认有16个
> database 16

- 主从复制，类似于双机备份。
> slaveof 

# 4. 服务端和客户端

## 4.1  服务器端
- 服务器端的命令为redis-server
- 可以使用help查看帮助文档
> redis-server --help

- 推荐使用服务的方式管理redis服务
`systemctl start|stop|restart|status redis.service`
- 启动
> service redis start

- 停止
> service redis stop

- 重启 
> service redis restart

- 个人习惯
> ps -ef | grep redis 查看redis服务器进程
> kill -9 pid 杀死redis服务器
> redis-server /etc/redis/redis.conf   指定加载的配置文件

## 4.2  客户端
- 客户端的命令为redis-cli
- 可以使用help查看帮助文档
> redis-server --help

- 连接redis
> redis-cli

- 测试
```bash
[root@localhost ~]# redis-cli 
127.0.0.1:6379> ping 123
"123"
```

- 切换数据库
数据库没有名称，默认有16个，通过0-15来标识，连接redis默认选择第一个数据库select n
> select n

# 5. 数据操作
## 5.1 数据结构
- redis是key-value的数据结构，每条数据都是一个键值对
- 键的类型是字符串，且不能重复
- 值的类型分为五种：
    - 字符串string
    - 哈希hash
    - 列表list
    - 集合set
    - 有序集合zset

## 5.2 数据操作行为
- 保存
- 修改
- 获取
- 删除

[中文官网命令文档]：<http://redis.cn/commands.html>

## 5.3 String类型
字符串类型是Redis中最为基础的数据存储类型，它在Redis中是二进制安全的，这便意味着该类型可以接受任何格式的数据，如JPEG图像数据或Json对象描述信息等。
在Redis中字符串类型的Value最多可以容纳的数据长度是512M。

### 保存
如果设置的键不存在则为添加，如果设置的键已经存在则修改
- 设置键值：set key value
- 设置键值及过期时间，以秒为单位：setex key seconds value
- 设置多个键值：mset key1 value1 key2 value2 ...
- 追加值：append key value

### 获取
- 获取：根据键获取值，如果不存在此键则返回nil：get key
- 根据多个键获取多个值 ：mget key1 key2...

### 其他常用命令
- 查找键，参数支持正则表达式：keys pattern
例如：
	- 查看所有键：`keys *`
	- 查看名称中含有a的键：`keys 'a*'`

- 判断键是否存在，存在返回1，不存在返回0：exists key
- 查看键对应的value的类型：type key
- 删除键及其对应的值：del key1 key2.......
- 设置过期时间，以秒为单位，如果没有指定过期时间则一直存在，直到使用DEL移除：expire key seconds
- 查看有效时间，以秒为单位：ttl key

## 5.4 hash类型
- hash用于存储对象，对象的结构为属性、值
- 值的类型为string

### 增加、删除
- 设置单个属性：hset key filed value

例如：设置键 user的属性name为itheima：hset user name hahah
错误信息：
MISCONF Redis is configured to save RDB snapshots, but is currently not able to persist on disk. Commands that may modify the data set are disabled. Please check Redis logs for details about the error.
Redis被配置为保存数据库快照，但它目前不能持久化到硬盘。用来修改集合数据的命令不能用

原因：
- 强制关闭Redis快照导致不能持久化。
解决方案：
运行`config set stop-writes-on-bgsave-error no`命令后，关闭配置项stop-writes-on-bgsave-error解决该问题

- 设置多个属性：hmset key field1 value1 field2 value2 ...

例如： 设置键u2的属性name为haha、属性age为22：hset user name hahah age 22

### 获取
- 获取指定键所有的属性：hkeys key
- 获取一个属性的值：hget key field
- 获取多个属性的值：hmget key field1 field2 ...
- 获取所有属性的值：hvals key

### 删除
- 删除整个hash键及值，使用del命令
- 删除属性，属性对应的值会被一起删除：hdel key field1 field2 ...

## 5.5 list类型
- 列表的元素类型为string
- 按照插入顺序排序

### 增加
- 在左侧插入数据：lpush key value1 value2 ...
- 在右侧插入数据：rpush key value1 value2 ...
- 在指定元素的前或后插入新元素：linsert key before或after 现有元素 新元素

### 获取
- 返回列表里指定范围内的元素：lrange key start stop
> start、stop为元素的下标索引,引从左侧开始，第一个元素为0，索引可以是负数，表示从尾部开始计数，如-1表示最后⼀个元素

- 设置指定索引位置的元素值：lset key index value
> 索引从左侧开始，第一个元素为0，索引可以是负数，表示尾部开始计数，如-1表示最后一个元素

### 删除
- 删除指定元素：lrem key count value
> 将列表中前count次出现的值为value的元素移除，count > 0: 从头往尾移除，count < 0: 从尾往头移除，count = 0: 移除所有

## 5.6 set类型
- 无序集合
- 元素为string类型
- 元素具有唯一性，不重复
- 对于集合没有修改操作

### 增加
- 添加元素：sadd key member1 member2 ...

### 获取
- 返回所有的元素：smembers key

### 删除
- 删除指定元素：srem key
- 删除指定元素中的某一个值：srem key member1

## 5.7 zset类型
- sorted set，有序集合
- 元素为string类型
- 元素具有唯一性，不重复
- 每个元素都会关联一个double类型的score，表示权重，通过权重将元素从小到大排序
- 没有修改操作

### 增加
- 添加：zadd key score1 member1 score2 member2 ...

例如： 向键'a4'的集合中添加元素'lisi'、'wangwu'、'zhaoliu'、'zhangsan'，权重分别为4、5、6、3
`zadd a4 4 lisi 5 wangwu 6 zhaoliu 3 zhangsan`

### 获取
- 返回指定范围内的元素：zrange key start stop
> start、stop为元素的下标索引， 索引从左侧开始，第一个元素为0，索引可以是负数，表示从尾部开始计数，如-1表示最后一个元素

- 返回score值在min和max之间的成员：zrangebyscore key min max
- 返回成员member的score值：zscore key member

### 删除
- 删除指定元素：zrem key member1 member2 ...
- 删除权重在指定范围的元素：zremrangebyscore key min max


# 6. 与Python交互
- python环境中安装redis模块：pip install redis
- 调用模块：from redis import *
这个模块中提供了StrictRedis对象(Strict严格)，用于连接redis服务器，并按照不同类型提供 了不同放法，进行交互操作

## 6.1 StrictRedis对象方法
- 通过init创建对象，指定参数host、port与指定的服务器和端⼝连接，host默认为localhost，port默认为6379，db默认为0
`sr = StrictRedis(host='localhost', port=6379, db=0)`
简写：sr=StrictRedis()

根据不同的类型，拥有不同的实例方法可以调用，与前面学的redis命令对应，方法需要的参数与命令的参数一致。

### 6.1.2 string

- set
- setex
- mset
- append
- get
- mget
- key

### 6.1.3 keys

- exists
- type
- delete
- expire
- getrange
- ttl

### 6.1.4 hash

- hset
- hmset
- hkeys
- hget
- hmget
- hvals
- hdel

### 6.1.5 list

- lpush
- rpush
- linsert
- lrange
- lset
- lrem

### 6.1.6 set

- sadd
- smembers
- srem

### 6.1.7 zset

- zadd
- zrange
- zrangebyscore
- zscore
- zrem
- zremrangebyscore

## 6.2 StrictRedis对象操作string类型
### 6.2.1 准备
```python
import redis

if __name__ == "__main__":
    try:
        # 创建StrictRedis对象，与redis服务器建⽴连接
        sr = redis.StrictRedis(host='192.168.0.138', port=6379, db=0, password=None)
        print('success')
    except Exception as e:
        print(e)
```

### 6.2.2 string-增加
方法set，添加键、值，如果添加成功则返回True，如果添加失败则返回False
```python
import redis

if __name__ == "__main__":
    try:
        # 创建StrictRedis对象，与redis服务器建⽴连接
        sr = redis.StrictRedis(host='127.0.0.1', port=6379, db=0, password='foobar2000')
        print('success')
        # 添加键name，值为haha
        result = sr.set('name','haha1111')
        # 输出响应结果，如果添加成功则返回True，否则返回False
        print(result)
    except Exception as e:
        print(e)
```

### 6.2.3 string-获取
方法get，添加键对应的值，如果键存在则返回对应的值，如果键不存在则返回None
```python
import redis

if __name__ == "__main__":
    try:
        # 创建StrictRedis对象，与redis服务器建⽴连接
        sr = redis.StrictRedis(host='127.0.0.1', port=6379, db=0, password='foobar2000')
        print('success')
        #获取键name的值
        result = sr.get('name')
        #输出键的值，如果键不存在则返回None
        print(result) # b'haha1111'，类型是<class 'bytes'>
    except Exception as e:
        print(e)
```

### 6.2.4 string-修改
方法set，如果键已经存在则进行修改，如果键不存在则进行添加
```python
import redis

if __name__ == "__main__":
    try:
        # 创建StrictRedis对象，与redis服务器建⽴连接
        sr = redis.StrictRedis(host='127.0.0.1', port=6379, db=0, password='foobar2000')
        print('success')
        #获取键name的值
        result = sr.set('name','hahahahhhahahh')
        #输出响应结果，如果操作成功则返回True，否则返回False
        print(result)
    except Exception as e:
        print(e)
```

### 6.2.5 string-删除
方法delete，删除键及对应的值，如果删除成功则返回受影响的键数，否则则返 回0
```python
import redis

if __name__ == "__main__":
    try:
        # 创建StrictRedis对象，与redis服务器建⽴连接
        sr = redis.StrictRedis(host='127.0.0.1', port=6379, db=0, password='foobar2000')
        print('success')
        #获取键name的值
        result = sr.delete('name')
        #输出响应结果，如果删除成功则返回受影响的键数，否则则返回0
        print(result)
    except Exception as e:
        print(e)
```

### 6.2.6 获取键
方法keys，根据正则表达式获取键
```python
import redis

if __name__ == "__main__":
    try:
        # 创建StrictRedis对象，与redis服务器建⽴连接
        sr = redis.StrictRedis(host='127.0.0.1', port=6379, db=0, password='foobar2000')
        print('success')
        #获取键name的值
        result = sr.keys()
        #输出响应结果，所有的键构成⼀个列表，如果没有键则返回空列表
        print(result)
    except Exception as e:
        print(e)
```


# 7. 主从配置(读写分离)

- 一个master可以拥有多个slave，一个slave上可以拥有多个slave，如此下去，形成了强大的多级服务器集群架构
- master用来写数据，slave用来读数据，经统计：网站的读写比率是10:1
- 通过主从配置可以实现读写分离
- master和slave都是一个redis实例(redis服务)

说明：如下的实例是主从在一台服务器上，通过端口号进行区分

## 7.1 主从配置
### 7.1.1 配置主
- 查看当前主机的ip地址：ifconfig
- 修改/etc/redis.conf文件
> bind 192.168.26.128 # 绑定主服务器IP

- 重启redis服务：`service redis stop && redis-server redis.conf`

### 7.1.2 配置从
- 设置slave.conf文件：cp redis.conf slave.conf
- 修改slave.conf文件
> bind 192.168.26.128 # 从服务器IP，因使用一台主机，所以IP同主服务器IP相同
> port 6378 # 从服务器端口
> slaveof 192.168.26.128 6379 # 关联到主信息

- 启动redis服务：`redis-server slave.conf`

- 查看主从关系：redis-cli -h 192.168.26.128 info Replication

### 7.1.2 数据操作
- 在master和slave分别执行info命令，查看输出信息 进入主客户端
> redis-cli -h 192.168.26.128 -p 6379  # 进入主客户端
> redis-cli -h 192.168.26.128 -p 6378 # 进入从客户端

- 在master上写数据：set aa aa
- 在slave上读数据：get aa


# 8. 哨兵(主从切换)

待完善......

# 9. 搭建集群
## 9.1 为什么要有集群
- 一主可以多从，如果同时的访问量过大(1000w),主服务肯定就会挂掉，数据服务就挂掉了或者发生自然灾难
- 大公司都会有很多的服务器(华东地区、华南地区、华中地区、华北地区、西北地区、西南地区、东北地区、台港澳地区机房)

## 9.2 集群的概念
- 集群是一组相互独立的、通过高速网络互联的计算机，它们构成了一个组，并以单一系统的模式加以管理。一个客户与集群相互作用时，集群像是一个独立的服务器。集群配置是用于提高可用性和可缩放性。
- 当请求到来首先由负载均衡服务器处理，把请求转发到另外的一台服务器上。

## 9.3 redis集群
- 分类
	- 软件层面：只有一台电脑，在这一台电脑上启动了多个redis服务
	- 硬件层面：存在多台实体的电脑，每台电脑上都启动了一个redis或者多个redis服务

## 9.4 搭建集群
- 当前拥有两台主机172.16.179.130、172.16.179.131，这里的IP在使用时要改为实际值

### 9.4.1 配置机器1
- 在演示中，172.16.179.130为当前ubuntu机器的ip
- 在172.16.179.130上进入Desktop目录，创建conf目录
- 在conf目录下创建文件7000.conf，编辑内容如下
```bash
port 7000
bind 172.16.179.130
daemonize yes
pidfile 7000.pid
cluster-enabled yes
cluster-config-file 7000_node.conf
cluster-node-timeout 15000
appendonly yes
```

- 在conf目录下创建文件7001.conf，编辑内容如下
```python
port 7001
bind 172.16.179.130
daemonize yes
pidfile 7001.pid
cluster-enabled yes
cluster-config-file 7001_node.conf
cluster-node-timeout 15000
appendonly yes
```
- 在conf目录下创建文件7001.conf，编辑内容如下
```python
port 7001
bind 172.16.179.130
daemonize yes
pidfile 7001.pid
cluster-enabled yes
cluster-config-file 7001_node.conf
cluster-node-timeout 15000
appendonly yes
```
- 在conf目录下创建文件7002.conf，编辑内容如下
```python
port 7002
bind 172.16.179.130
daemonize yes
pidfile 7002.pid
cluster-enabled yes
cluster-config-file 7002_node.conf
cluster-node-timeout 15000
appendonly yes
```
总结：三个文件的配置区别在port、pidfile、cluster-config-file三项

- 使用配置文件启动redis服务
```bash
redis-server 7000.conf
redis-server 7001.conf
redis-server 7002.conf
```

### 9.4.2 配置机器2
- 在演示中，172.16.179.131为当前ubuntu机器的ip
- 在172.16.179.131上进入Desktop目录，创建conf目录
- 在conf目录下创建文件7003.conf，编辑内容如下
```bash
port 7003
bind 172.16.179.131
daemonize yes
pidfile 7003.pid
cluster-enabled yes
cluster-config-file 7003_node.conf
cluster-node-timeout 15000
appendonly yes
```

- 在conf目录下创建文件7004.conf，编辑内容如下
```python
port 7004
bind 172.16.179.131
daemonize yes
pidfile 7004.pid
cluster-enabled yes
cluster-config-file 7004_node.conf
cluster-node-timeout 15000
appendonly yes
```
- 在conf目录下创建文件7005.conf，编辑内容如下
```python
port 7005
bind 172.16.179.131
daemonize yes
pidfile 7005.pid
cluster-enabled yes
cluster-config-file 7005_node.conf
cluster-node-timeout 15000
appendonly yes
```

总结：三个文件的配置区别在port、pidfile、cluster-config-file三项

- 使用配置文件启动redis服务
```bash
redis-server 7003.conf
redis-server 7004.conf
redis-server 7005.conf
```

### 9.4.3 创建集群
- redis的安装包中包含了redis-trib.rb，用于创建集群，
- 接下来的操作在172.16.179.130机器上进行
- 将命令复制，这样可以在任何目录下调用此命令
`cp /usr/share/doc/redis-tools/examples/redis-trib.rb /usr/local/bin/`
- 安装ruby环境，因为redis-trib.rb是用ruby开发的：`apt-get install ruby`
- 运行如下命令创建集群：
`redis-trib.rb create --replicas 1 172.16.179.130:7000 172.16.179.130:7001 172.16.179.130:7002 172.16.179.131:7003 172.16.179.131:7004 172.16.179.131:7005`
- 执行上面这个指令在某些机器上可能会报错,主要原因是由于安装的 ruby 不是最 新版本 
- 天朝的防火墙导致无法下载最新版本,所以需要设置 gem 的源
- 解决办法如下：
> -- 先查看自己的 gem 源是什么地址：gem source -l -- 如果是https://rubygems.org/ 就需要更换
> -- 更换指令为：gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
> -- 通过 gem 安装 redis 的相关依赖：sudo gem install redis
> -- 然后重新执行指令

### 9.4.4 数据验证
- 当前搭建的主服务器为7000、7001、7003，对应的从服务器是7004、7005、7002，在172.16.179.131机器上连接7002，加参数-c表示连接到集群
> redis-cli -h 172.16.179.131 -c -p 7002

- 写入数据： set name haha
- 自动跳到了7003服务器，并写入数据成功
- 在7003可以获取数据，如果写入数据又重定向到7000(负载均衡)

### 9.4.5 在哪个服务器上写数据：CRC16

- redis cluster在设计的时候，就考虑到了去中间化，去中间件，也就是说，集群中 的每个节点都是平等的关系，都是对等的，每个节点都保存各自的数据和整个集群的状态。每个节点都和其他所有节点连接，并且这些连接保持活跃，这样就保证了我们只需要连接集群中的任意一个节点，就可以获取到其他节点的数据
- Redis集群没有并使用传统的一致性哈希来分配数据，而是采用另外一种叫做哈希槽 (hash slot)的方式来分配的。redis  cluster 默认分配了 16384 个slot，当我们 set一个key 时，会用CRC16算法来取模得到所属的slot，然后将这个key  分到哈希槽区间的节点上，具体算法就是：CRC16(key) % 16384。所以我们在测试的 时候看到set 和 get  的时候，直接跳转到了7000端口的节点
- Redis 集群会把数据存在一个 master 节点，然后在这个 master 和其对应的salve  之间进行数据同步。当读取数据时，也根据一致性哈希算法到对应的 master 节 点获取数据。只有当一个master 挂掉之后，才会启动一个对应的  salve 节点，充当 master
- 需要注意的是：必须要3个或以上的主节点，否则在创建集群时会失败，并且当存 活的主节点数小于总节点数的一半时，整个集群就无法提供服务了

## 9.5 Python交互
- 安装包：`pip install redis-py-cluster`
- redis-py-cluster源码地址<https://github.com/Grokzen/redis-py-cluster>
- 创建文件redis_cluster.py，示例码如下
```python
from rediscluster import *

if __name__ == '__main__':
  try:
      # 构建所有的节点，Redis会使⽤CRC16算法，将键和值写到某个节点上
      startup_nodes = [
          {'host': '192.168.26.128', 'port': '7000'},
          {'host': '192.168.26.130', 'port': '7003'},
          {'host': '192.168.26.128', 'port': '7001'},
      ]
      # 构建StrictRedisCluster对象
      src=StrictRedisCluster(startup_nodes=startup_nodes,decode_responses=True)
      # 设置键为name、值为itheima的数据
      result=src.set('name','itheima')
      print(result)
      # 获取键为name
      name = src.get('name')
      print(name)
  except Exception as e:
      print(e)
```

