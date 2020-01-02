---
title: X-Pack：创建阈值检查警报
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
简单的事情应该简单(Simple things should be simple)，这是Elastic {ON} ‘17的主题之一，Elastics收到了许多关于使用简单易用的UI创建警报的请求。事实证明，创建单个UI以对所有类型的警报均有效地工作非常困难。例如，可以在平均CPU使用率超过50％时创建警报的UI与可以在同一IP地址上有许多并发登录的情况下创建警报的UI看起来截然不同。

由于很难为所有类型的警报构建通用的UI，因此Elastic决定首先针对最常请求的警报处理UI：当指标超过或低于给定阈值时触发的简单阈值警报。

在开始示例之前，请确保您具有最低版本的Elasticsearch和Kibana的6.0.0版本，并且两者都安装了X-Pack。在最新的7.x版本里，X-Pack已经是发布版的一部分，不需要安装。另外，请确保您为Elasticsearch配置了具有足够权限的用户。现在，我们需要一些有趣的数据来构建警报。 Metricbeat是监视机器上的系统和用户进程的绝佳拍子。

在今天的练习里，我们来展示如何通过阈值检查，并发送通知到Slack。大家也可以尝试发送到电子邮件等方式。

# 创建Slack账号

我们首先需要创建一个自己的Slack账号(https://slack.com/)，并具有自己的管理员权限。你可以参考链接 “Configuring Slack Account”(https://www.elastic.co/guide/en/elasticsearch/reference/7.5/actions-slack.html#configuring-slack)来配置自己的Slack账号，并生成一个相应的一个Webhook URL。这个URL将会在Elasticsearch里进行使用。

![](https://img-blog.csdnimg.cn/20191127195419804.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

# 配置elasticsearch.yml

首先watcher必须是在有账号的情况下才可以工作的。如果你还不知道如何开通一个Elasticsearch的安全，那么请参阅我之前的文章“Elasticsearch：设置Elastic账户安全”。

因为这是一个付费的功能，你需要接受30天试用的条件才可以看到这个功能。为了能够使得watcher能够正常工作，我们必须配置elasticsearch.yml文件。打开elasticsearch安装目录下的config/elasticsearch.yml文件，并加入如下的配置：
```
    xpack.security.enabled: true
    discovery.type: single-node
     
    xpack.notification.slack:
      account:
        monitoring:
          message_defaults:
            from: x-pack
            to: notifications
            icon: http://example.com/images/watcher-icon.jpg
            attachment:
              fallback: "X-Pack Notification"
              color: "#36a64f"
              title: "X-Pack Notification"
              title_link: "https://www.elastic.co/guide/en/x-pack/current/index.html"
              text: "One of your watches generated this notification."
              mrkdwn_in: "pretext, text"
```
前面的两行是为了启动安全功能才进行加入的。后面的关于xpack的配置才是为watcher而设置的。

配置好我们的elasticsearch.yml文件后，我们在命令行中打入如下的命令：
```
./bin/elasticsearch-keystore add xpack.notification.slack.account.monitoring.secure_url
```
![](https://img-blog.csdnimg.cn/20191127200617521.png)

在这里，我们选择y。如果你是第一次运行这个命令的话，就不会有这样的一个提示了。你可以把你从Slack中配置的那个Webhook URL复制并粘贴到这里。这样我们的配置就完成了。然后，我们启动Elasticsearch。

# 安装及配置Metricbeat

只启动system模块即可。等安装好Metricbeat后，就可启动我们的metricbeat了。
 
# 配置Watcher

打开浏览器并导航到Kibana。单击侧面导航栏中的“Management”应用程序，然后单击Elasticsearch标题下的Watcher。

![](https://img-blog.csdnimg.cn/20191127201722518.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们点击Create，然后，我们就可以开始配置我们的一个watcher了。我们选择Create threashold alert:

![](https://img-blog.csdnimg.cn/2019112720205415.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

然后，我们可以按照上面的配置进行设置。再点击“Add action”：
![](https://img-blog.csdnimg.cn/20191127202236826.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们选择Slack作为我们的通知方法。里面还有其它的几种方式，你们可以自己去尝试。

![](https://img-blog.csdnimg.cn/20191127202534897.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以选择Send a sample message按钮来测试一下我们的Slack配置是否成功。最后，我们选择Create alert。这样就创建了一个Watcher。

![](https://img-blog.csdnimg.cn/20191127202744758.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以在Watcher页面看到我们配置的每个Watcher。上面显示我们的其中的一个watcher已经发送通知了，而且是4分钟之前发送的。我们可以在我们的Slack界面看到如下的消息：

![](https://img-blog.csdnimg.cn/20191127203110256.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以看到许多的通知信息不断地进来。它表明我们的配置是已经成功了。

上面我们通过Kibana的界面配置了Watcher。事实上，我们也可以通过API的方式来配置。请详细阅读我们的文档(https://www.elastic.co/guide/en/elasticsearch/reference/7.5/how-watcher-works.html)。

参考：

【1】https://www.elastic.co/guide/en/elasticsearch/reference/7.5/how-watcher-works.html
