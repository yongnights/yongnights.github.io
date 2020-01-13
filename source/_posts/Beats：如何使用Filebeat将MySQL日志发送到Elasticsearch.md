---
title: Beats：如何使用Filebeat将MySQL日志发送到Elasticsearch
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在今天的文章中，我们来详细地描述如果使用Filebeat把MySQL的日志信息传输到Elasticsearch中。为了说明问题的方便，我们的测试系统的配置是这样的：

![](https://img-blog.csdnimg.cn/20200113112001771.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70) 

我有一台MacOS机器。在上面我安装了Elasticsearch及Kibana。在这个机器里，我同时安装了一个Ubuntu 18.04的虚拟机。在这个Ubunutu机器上，我安装了MySQL及Filebeat。它们的IP地址分别显示如上。针对你们自己的测试环境，你们的IP地址可能和我的不太一样。

# 准备工作

## 安装Elasticsearch
如果大家还没安装好自己的Elastic Stack的话，那么请按照我之前的教程“如何在Linux，MacOS及Windows上进行安装Elasticsearch” 安装好自己的Elasticsearch。由于我们的Elastic Stack需要被另外一个Ubuntu VM来访问，我们需要对我们的Elasticsearch进行配置。首先使用一个编辑器打开在config目录下的elasticsearch.yml配置文件。我们需要修改network.host的IP地址。在你的Mac及Linux机器上，我们可以使用:

`$ ifconfig`
来查看到我们的机器的IP地址。针对我的情况，我的机器的IP地址是：192.168.0.100。

![](https://img-blog.csdnimg.cn/2020011108244570.png)

我们也必须在elasticsearch.yml的最后加上discovery.type: single-node，表明我们是单个node。

等修改完我们的IP地址后，我们保存elasticsearch.yml文件。然后重新运行我们的elasticsearch。我们可以在一个浏览器中输入刚才输入的IP地址并加上端口号9200。这样可以查看一下我们的elasticsearch是否已经正常运行了。

![](https://img-blog.csdnimg.cn/20200111082557138.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

## 安装Kibana
我们可以按照“如何在Linux，MacOS及Windows上安装Elastic栈中的Kibana”中介绍的那样来安装我们的Kibana。由于我们的Elasticsearch的IP地址已经改变，所以我们必须修改我们的Kibana的配置文件。我们使用自己喜欢的编辑器打开在config目录下的kibana.yml文件，并找到server.host。把它的值修改为自己的电脑的IP地址。针对我的情况是：

![](https://img-blog.csdnimg.cn/20200111082858750.png)

同时找到elasticsearch.hosts，并把自己的IP地址输入进去：

![](https://img-blog.csdnimg.cn/20200111082940393.png)

保存我们的kibana.yml文件，并运行我们的Kibana。同时在浏览器的地址中输入自己的IP地址及5601端口：

![](https://img-blog.csdnimg.cn/20200111083033160.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

如果配置成功的话，我们就可以看到上面的画面。


## 安装Ubuntu虚拟机
这个不在我的这个教程之内。在网上我们可以找到许多的教程教我们如何安装Ubuntu虚拟机。

## 在Ubuntu上安装MySQL
我们可以按照链接https://vitux.com/how-to-install-and-configure-mysql-in-ubuntu-18-04-lts/来安装我们的MySQL。简单地说，安装步骤如下:

如果尚未安装MySQL，则可以使用以下步骤安装和配置它。 您需要做的第一件事就是更新系统。
`sudo apt-get update`

然后像这样安装MySQL：`sudo apt-get install mysql-server`
在安装过程中，系统将提示您设置root密码。 记下它，因为管理MySQL数据库将需要它。或者，你通过如下的方法来设置MySQL的密码：
`sudo mysql`

等进入到MySQL后，打入如下的指令来创建你的root用户的密码：
```mysql
mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```
在上面的句子里，使用自己喜欢的密码来代替password。

下一步是配置MySQL以写入常规查询日志文件和慢速查询日志文件，因为默认情况下会禁用这些配置。 要更改配置，您将需要编辑包含用户数据库设置的my.cnf文件。
```
sudo vi /etc/mysql/my.cnf
```
常规查询和慢速查询的有效配置应如下所示：
```
[mysqld]
general_log = 1
general_log_file = /var/log/mysql/mysql.log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time = 1
log_queries_not_using_indexes = 1
```
我们可以把上面的配置添加到我们的my.cnf文件当中去：

![](https://img-blog.csdnimg.cn/20200113113204124.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

请注意，在低于5.1.29的MySQL版本中，使用了变量log_slow_queries而不是slow_query_log。

进行以下更改后，请确保重新启动MySQL：
```
sudo service mysql restart
```
现在，您的MySQL已准备好编写慢速查询，这些查询将通过Filebeat传送到您的Elasticsearch集群中。我们可以检查一下我们的MySQL是否已经成功运行：`systemctl status mysql.service`

等我们成功配置后我们的MySQL，我们可以开始对我们的MySQL进行一些操作，然后你可以在如下的目录中查看到相应的log文件：
```
ls /var/log/mysql/
```

![](https://img-blog.csdnimg.cn/20200113113637953.png)

## 安装Filebeat
在Ubuntu上安装Filebeat也是非常直接的。我们可以先打开我们的Kibana。

![](https://img-blog.csdnimg.cn/20200113113931296.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

点击上面的“Add log data”按钮:

![](https://img-blog.csdnimg.cn/20200113114043534.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

点击上面的“MySQL logs”按钮：

![](https://img-blog.csdnimg.cn/20200113114151618.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)


选择上面的操作系统。针对我们的Ubuntu系统，它是一个DEB格式的安装文件。我们按照上面的要求一步一步地进行安装和修改。在修改filebeat.yml文件时，我们需要注意的三点：

1）修改MySQL的log路径：

![](https://img-blog.csdnimg.cn/20200113114441487.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

2）填入Kibana的地址：

![](https://img-blog.csdnimg.cn/20200113114538152.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

3）填入Elasticsearch的地址及端口号：

![](https://img-blog.csdnimg.cn/20200113114716773.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们需要运行如下的命令来把相应的dashboard，pipeline及template信息上传到Elasticsearch和Kibana中。
```
sudo filebeat modules enable mysql
sudo filebeat setup
sudo service filebeat start
```

等我们启动我们的filebeat后，我们可以通过如下的命令来检查filebeat服务是否运行正常：
```
sudo systemctl status filebeat
```

# Kibana查看
我们可以打开Kibana，并在Kibana中查看由filebeat发送过来的MySQL的数据：

![](https://img-blog.csdnimg.cn/20200113115325246.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

在上面，我们可以看到MySQL的dashboard：

![](https://img-blog.csdnimg.cn/2020011311545031.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

至此，我们可以看到所有的关于MySQL的信息，这里包括以下queries及error logs等。

上面我们显示了如何直接把MySQL的信息发送到Elasticsearch，并对数据进行分析。当然，我们也可以把数据发送到logstash来对数据进行处理，然后再发送到Elasticsearch中。我们的filebeat.yml文件的配置文件可以这么写：
```
filebeat.prospectors:
- input_type: log
 paths:
 - /var/log/mysql/*.log
 document_type: syslog
 registry: /var/lib/filebeat/registry
output.logstash:
 hosts: ["mylogstashurl.example.com:5044"]

```

# 总结
如本教程所示，Filebeat是用于MySQL数据库和Elasticsearch集群的出色日志传送解决方案。 与以前的版本相比，它非常轻巧，可以有效地发送日志事件。 Filebeat支持压缩，并且可以通过单个yaml文件轻松配置。 使用Filebeat，您可以轻松地管理日志文件，跟踪日志注册表，创建自定义字段以在日志中启用细化过滤和发现，以及使用Kibana可视化功能立即为日志数据供电。
------------------------------------------------
版权声明：本文为CSDN博主「Elastic 中国社区官方博客」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/UbuntuTouch/article/details/103954935