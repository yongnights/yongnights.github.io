---
title: Elastic：使用ElastAlert发送通知
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
ElastAlert是一个简单的框架，用于从Elasticsearch中的数据中发出异常，尖峰或其他感兴趣模式的警报。我们可以在地址https://elastalert.readthedocs.io/en/latest/elastalert.html找到它的使用说明。在今天的教程中，我将一步一步地介绍如何搭配环境，并从Elasticsearch发送通知给Slack。

为了说明问题的方便，我的环境如下：

![](https://img-blog.csdnimg.cn/20200103151218333.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)


在我的环境中，我使用iMac电脑运行Elasticsearch及Kibana，而在另外一个虚拟机上运行我们的filebeat。filebeat把Ubuntu机器里的syslog传入到Elasticsearch中供分析，同时ElastAlert周期性地从Elasticsearch中获取数据，并依据制定的规则来发送通知。


# 准备工作
## 创建Slack账号
我们首先需要创建一个自己的Slack账号，并具有自己的管理员权限。你可以参考链接 “Configuring Slack Account”来配置自己的Slack账号，并生成一个相应的一个Webhook URL。这个URL将会在Elasticsearch里进行使用。

![](https://img-blog.csdnimg.cn/20200103151546187.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20191127195419804.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们先把上面创建的webhook url记下来供下面的配置使用。

<escape><!-- more --></escape>

安装Elasticsearch
我们可以按照“如何在Linux，MacOS及Windows上进行安装Elasticsearch”介绍的那样安装好我们的Elasticsearch。不过由于我们需要使我们的Elasticsearch被另外一个虚拟机所见，在这里我们需要对我们的Elasticsearch进行配置。首先使用一个编辑器打开在config目录下的elasticsearch.yml配置文件。我们需要修改network.host的IP地址。在你的Mac及Linux机器上，我们可以使用:

`$ ifconfig`
来查看到我们的机器的IP地址。针对我的情况，我的机器的IP地址是：10.211.55.2。

![](https://img-blog.csdnimg.cn/20200103152501838.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

等修改完我们的IP地址后，我们保存elasticsearch.yml文件。然后重新运行我们的elasticsearch。我们可以在一个浏览器中输入刚才输入的IP地址并加上端口号9200。这样可以查看一下我们的elasticsearch是否已经正常运行了。

![](https://img-blog.csdnimg.cn/20200103152848576.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

## 安装Kibana
我们可以按照“如何在Linux，MacOS及Windows上安装Elastic栈中的Kibana”中介绍的那样来安装我们的Kibana。由于我们的Elasticsearch的IP地址已经改变，所以我们必须修改我们的Kibana的配置文件。我们使用自己喜欢的编辑器打开在config目录下的kibana.yml文件，并找到server.host。把它的值修改为自己的电脑的IP地址。针对我的情况是：

![](https://img-blog.csdnimg.cn/20200103153317936.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

同时找到elasticsearch.hosts，并把自己的IP地址输入进去：

![](https://img-blog.csdnimg.cn/20200103153457809.png)

保存我们的kibana.yml文件，并运行我们的Kibana。同时在浏览器的地址中输入自己的IP地址及5601端口：

![](https://img-blog.csdnimg.cn/20200103153705326.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

如果配置成功的话，我们就可以看到上面的画面。

## 安装Ubuntu虚拟机
这个不在我的这个教程之内。在网上我们可以找到许多的教程教我们如何安装Ubuntu虚拟机。


## 安装filebeat
我们想在Ubuntu机器上安装我们的filebeat来手机system log信息。我们首先打开我们的Kibana。点击左上角的Kibana图标：

![](https://img-blog.csdnimg.cn/20200103154143844.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

点击“Add log data”按钮：

![](https://img-blog.csdnimg.cn/20200103154248881.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

然后点击“System logs”

![](https://img-blog.csdnimg.cn/20200103154358461.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

由于Ubuntu是debian系统，我们选择DEB。安装上面的步骤一步一步地进行安装。在配置filebeat.yml时，我们需要把我们的IP地址输入到相应的地方：
```
output.elasticsearch:
  hosts: ["http://10.211.55.2:9200"]
  username: "elastic"
  password: "123456"
setup.kibana:
  host: "10.211.55.2:5601"
```
上面是我的配置情况。你可以根据自己的实际的IP地址进行配置。当我们成功地启动filebeat服务后，我们可以通过如下的命令来检查我们的服务是否已经成功运行：

`sudo systemctl status filebeat`


## 安装ElastAlert
我们可以参考链接https://elastalert.readthedocs.io/en/latest/running_elastalert.html来安装我们的ElastAlert。在这里我们使用python3来运行ElastAlert。首先我们需要在我们的Ubuntu上安装python3。

我们安装如下的步骤进行安装：

1） 下载elastalert源码：

`git clone https://github.com/Yelp/elastalert.git`
2）安装模块：
```
sudo pip3 install "setuptools>=11.3"
sudo python3 setup.py install
sudo pip3 install -U PyYAML
```
根据Elasticsearch的版本，您可能需要手动安装正确版本的elasticsearch-py。

Elasticsearch 5.0+:
`sudo pip3 install "elasticsearch>=5.0.0"`

Elasticsearch 2.X:
`sudo pip3 install "elasticsearch<3.0.0"`
这样我们的安装工作就完成了。

# 配置ElastAlert
## 配置文件
我们可以在ElastAlert源码文件的根目录下找到一个叫做config.yaml.example的文件：

![](https://img-blog.csdnimg.cn/20200103160412856.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以把这个文件修改为config.yaml文件：

`mv config.yaml.example config.yaml`
我们使用我们喜欢的编辑器打开这个文件，并修改这个文件：

![](https://img-blog.csdnimg.cn/20200103161036498.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以根据自己的IP地址来进行修改。如果我们对Elasticsearch做了安全设置，我们同时也需要填写用户名及密码：

![](https://img-blog.csdnimg.cn/202001031613262.png)

做完上面的修改后，我们保存config.yaml文件。

## 配置Elasticsearch
ElastAlert将有关其查询和警报的信息和元数据保存回Elasticsearch。 这对于审核和调试很有用，它使ElastAlert可以重新启动并完全从中断处恢复。 ElastAlert不需要运行，但强烈建议使用。

首先，我们需要通过运行elastalert-create-index并按照说明为ElastAlert创建要写入的索引。我们进入到ElastAlert的源码根目录，并打入如下的命令：

`elastalert-create-index`


## 创建rule
每个规则都定义要执行的查询，触发匹配的参数以及每个匹配要触发的警报列表。 我们将使用example_rules/example_frequency.yaml作为模板。我们删除其中一些不需要的项目，最终的文件是这样的：

example_frequency.yaml
```
# Alert when the rate of events exceeds a threshold
 
# Elasticsearch host
es_host: 10.211.55.2
 
# Elasticsearch port
es_port: 9200
 
# (OptionaL) Connect with SSL to Elasticsearch
#use_ssl: True
 
# (Optional) basic-auth username and password for Elasticsearch
es_username: "elastic"
es_password: "123456"
 
# (Required)
# Rule name, must be unique
name: Slack demo
 
# (Required)
# Type of alert.
# the frequency rule type alerts when num_events events occur with timeframe time
type: frequency
 
# (Required)
# Index to search, wildcard supported
index: filebeat-*
 
# (Required, frequency specific)
# Alert when this many documents matching the query occur within a timeframe
num_events: 3
 
# (Required, frequency specific)
# num_events must occur within this amount of time to trigger an alert
timeframe:
  hours: 1
 
# (Required)
# A list of Elasticsearch filters used for find events
# These filters are joined with AND and nested in a filtered query
# For more info: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl.html
filter:
- term:
    process.name: "JUSTME"
 
# (Required)
# The alert is use when a match is found
alert:
- "slack"
 
# (required, email specific)
# a list of email addresses to send alerts to
slack:
slack_webhook_url: Your_Webhook_Url
slack_username_override: "liuxg"
```
在上面请修改es_host为自己的IP地址，同时也需要把自己的webhook url写入到slack_webhook_url中去。在上面我们使用index为`filebeat-*`作为查询的索引，同时我们使用一个filter。它检查process.name是否为JUSTME字符串。如果是，并且在1个小时（timeframe）里出现3次（num_events），那么将触发通知。

## 测试rule
运行elastalert-test-rule工具将测试您的配置文件是否成功加载并在过去的24小时内以调试模式运行它：

`elastalert-test-rule example_rules/example_frequency.yaml`

![](https://img-blog.csdnimg.cn/20200103162940882.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

## 运行ElastAlert
我们使用Python来直接运行Elastalert：

`python3 -m elastalert.elastalert --verbose --rule example_frequency.yaml `

![](https://img-blog.csdnimg.cn/20200103163151722.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

这样我们的Elastalert已经被成功运行起来了。我们在这个时候可以打开我们的Kibana来监视`filebeat-*`索引，如果在一个小时内有三次process.name信息有JUSTME字样，那么我们就会在我们的Slack里收到一个通知。

我们在Ubuntu中打开另外的一个terminal，并输入如下的命令：
```
sudo logger -t JUSTME this is message 1
sudo logger -t JUSTME this is message 2
sudo logger -t JUSTME this is message 3
```


那么我们可以打开Kibana查看这些消息：

![](https://img-blog.csdnimg.cn/20200103163834845.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

那么这个时候，在我们的Slack中，我们可以看到如下的消息：

![](https://img-blog.csdnimg.cn/20200103163953566.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们收到了我们所需要的通知信息。我们也可以把通知写入到我们的邮件中去。这个由你们自己来实践了。在Elastalert的官方网站上，我们可以看到很多的通知类型。详细地址为https://elastalert.readthedocs.io/en/latest/ruletypes.html

![](https://img-blog.csdnimg.cn/20200103164257973.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

————————————————
版权声明：本文为CSDN博主「Elastic 中国社区官方博客」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/UbuntuTouch/article/details/103820572