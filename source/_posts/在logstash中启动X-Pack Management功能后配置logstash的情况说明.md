---
title: 在logstash中启动X-Pack Management功能后配置logstash的情况说明
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
开启X-Pack Management功能后，启动logstsh的时候就不用再配置logstash.conf文件了，启动的时候也不用再使用`-f`指定这个文件进行启动了

**一旦启动了logstash的集中管理，我们就可以直接启动logstash，而不用跟任何的参数**

Logstash集中管理，先启动logstash，然后再设置相关配置。(感觉这种方式比较节省内存)

之前的是先进行相关配置，再启动的时候指定相关配置

大致步骤如图：
1.创建用户角色
2.创建用户
3.在logstash.yml文件里做相应的配置
4.启动logstash,不用加任何参数
5.在kibana web界面，找到logstash管道管理，创建管道
管道id是在logstash.yml文件里设置的`xpack.management.pipeline.id: ["main", "apache_logs","my_apache_logs"] `中的任意一个
管道内容就是之前logstash.conf文件中的内容，主要是`input{} out{}`之类的
最后点击创建并部署管道.

<escape><!-- more --></escape>

首先我们来创建一个叫做logstash_writer的role:

![](https://img-blog.csdnimg.cn/2019123109503590.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20191231094740244.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20191231094855476.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)


点击“Create role”来创建我们的role。

首先让我们来创建一个具有logstash_user的用户账号：

![](https://img-blog.csdnimg.cn/20191231093503344.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

点击上面的“Create user”按钮来创建一个用户：

![](https://img-blog.csdnimg.cn/20191231095922807.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
点击“Create user”来创建一个叫做logstash_user的账号。它具有logstash_admin及logstash_system的权限。

为了启动集中管理，我们必须在logstash.yml文件里做相应的配置：
```
xpack.management.enabled: true
xpack.management.pipeline.id: ["main", "apache_logs", "my_apache_logs"]
xpack.management.elasticsearch.username: "logstash_user"
xpack.management.elasticsearch.password: "123456"
xpack.management.elasticsearch.hosts: ["${ES_HOST}"]
```
我们可以在链接`https://www.elastic.co/guide/en/logstash/current/logstash-centralized-pipeline-management.html`
找到更多的描述。在这里，我们启动logstash的管理，同时也把我们刚才创建的logstash_user的账号填入进来，并同时取了一个叫做my_apache_logs的pipeline id。

**一旦启动了logstash的集中管理，我们就可以直接启动logstash，而不用跟任何的参数**
```
sudo ./bin/logstash
```
这样我们的logstash已经被成功运行起来了。我们接下来可以在Kibana中创建自己的pipeline。

![](https://img-blog.csdnimg.cn/20191231103500951.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

点击上面的“Create pipeline”按钮，我们可以看到如下的画面：

![](https://img-blog.csdnimg.cn/20191231103916969.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

接下来我们点击“Create and Deploy”按钮：

![](https://img-blog.csdnimg.cn/20191231104044783.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

这样我们的my_apache_logs就被创建好了，而且已经被成功执行了。我们可以在Kibana中创建一个叫apache_log的index pattern，然后打开Discover，你可以看到刚刚被Logstash导入的数据：

![](https://img-blog.csdnimg.cn/2019123110445491.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)