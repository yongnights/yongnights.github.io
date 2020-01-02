---
title: Logstash 启动监控及集中管理
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在本篇文章里，我将详细介绍如果启动Logstash的监控及集中管理。

# 前提条件
安装好Logstash，设置Elasticsearch及Kibana的安全密码。

# 如何监控Logstash?
我们安装如下的步骤来实现监控Logstash的目的：

## Step 1: 在Kibana中启动监控：

![](https://img-blog.csdnimg.cn/20191230151037892.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

然后，我们可以看到如下的画面：
![](https://img-blog.csdnimg.cn/20191230151316339.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

## Step 2：配置Logstash
如果我们在没有配置Logstash的情况下直接运行Logstash，我们会发现如下的错误：
```
liuxg-2:logstash-7.5.0 liuxg$ ./bin/logstash
Java HotSpot(TM) 64-Bit Server VM warning: Option UseConcMarkSweepGC was deprecated in version 9.0 and will likely be removed in a future release.
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by com.headius.backport9.modules.Modules (file:/Users/liuxg/elastic5/logstash-7.5.0/logstash-core/lib/jars/jruby-complete-9.2.8.0.jar) to field java.io.FileDescriptor.fd
WARNING: Please consider reporting this to the maintainers of com.headius.backport9.modules.Modules
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
Thread.exclusive is deprecated, use Thread::Mutex
Sending Logstash logs to /Users/liuxg/elastic5/logstash-7.5.0/logs which is now configured via log4j2.properties
ERROR: Pipelines YAML file is empty. Location: /Users/liuxg/elastic5/logstash-7.5.0/config/pipelines.yml
usage:
  bin/logstash -f CONFIG_PATH [-t] [-r] [] [-w COUNT] [-l LOG]
  bin/logstash --modules MODULE_NAME [-M "MODULE_NAME.var.PLUGIN_TYPE.PLUGIN_NAME.VARIABLE_NAME=VALUE"] [-t] [-w COUNT] [-l LOG]
  bin/logstash -e CONFIG_STR [-t] [--log.level fatal|error|warn|info|debug|trace] [-w COUNT] [-l LOG]
  bin/logstash -i SHELL [--log.level fatal|error|warn|info|debug|trace]
  bin/logstash -V [--log.level fatal|error|warn|info|debug|trace]
  bin/logstash --help
[2019-12-30T15:32:49,899][ERROR][org.logstash.Logstash    ] java.lang.IllegalStateException: Logstash stopped processing because of an error: (SystemExit) exit
```
首先在Logstash的安装目录中找到logstash的配置文件logstash.yml：
![](https://img-blog.csdnimg.cn/20191230153525794.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以在Logstash的根目录下运行一下的命令：
```
./bin/logstash-keystore create
```
上面的命令将创建一个Created Logstash keystore：

![](https://img-blog.csdnimg.cn/20191230154744343.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们可以利用如下的命令来创建一些key: ES_HOST及ES_PWD。
```
./bin/logstash-keystore add ES_HOST
```
当我们运行时，可以把我们的Elasticsearch的host地址粘贴过来：

![](https://img-blog.csdnimg.cn/20191230155046921.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

比如针对我们的情况，我们粘贴的地址是http://localhost:9200/。按照同样的方法，我们可以创建另外一个ES_PWD key：
```
./bin/logstash-keystore add ES_PWD
```
![](https://img-blog.csdnimg.cn/20191230155258272.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)
这些key可以在logstash的配置文件中所使用。这样我们可以不暴露我们的密码给别人看到。

我们打开logstash.yml文件，并同时使用如下的配置：
```
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.username: logstash_system
xpack.monitoring.elasticsearch.password: "${ES_PWD}"
xpack.monitoring.elasticsearch.hosts: ["${ES_HOST}"]
```
这里，我们打开monitoring的开关，并同时使用我们在创建安全账户已经创建好的用户名logstash_system:

![](https://img-blog.csdnimg.cn/20191230162130228.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

现在我们下载一个我之前做个的一个练习：
```
git clone https://github.com/liu-xiao-guo/logstash_multi-pipeline
```
我们可以下载到我们指定的目录里。但是记得修改在apache.conf中的path路径，否则我们会错的。
```
apache.conf

input {
  file {
    path => "/Users/liuxg/data/multi-pipeline/apache.log"
  	start_position => "beginning"
    sincedb_path => "/dev/null"
    # ignore_older => 100000
    type => "apache"
  }
}

filter {
  	grok {
    	match => {
      		"message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
    	}
  	}
}


output {
	stdout {
		codec => rubydebug
	}

  	elasticsearch {
        hosts => ["${ES_HOST}"]
        user => "elastic"
        password => "${ES_PWD}"
    	index => "apache_log"
    	template => "/Users/liuxg/data/multi-pipeline/apache_template.json"
    	template_name => "apache_elastic_example"
    	template_overwrite => true
  }	
}
```
同时，我们需要添加hosts, user及password的定义。这是因为我们现在我们是需要有用户名及密码才可以连接到Elasticsearch。这个和之前的练习是不一样的。同时我们可以创建自己的用户名及密码。我们可以参考“Elasticsearch：用户安全设置”来创建自己喜欢的账号。在这里，为了方便，我们使用elastic账号。在这里，我们是用${ES_HOST}及${ES_PWD}来代表我们的Elasticsearch地址及密码。这样的好处是我们不暴露我们的密码在配置文件中。

一旦上面的配置已经做好了，我们可以使用如下的命令来把我们的apache log文件上传到Elasticsearch之中：
```
sudo ./bin/logstash -f ~/data/multi-pipeline/apache.conf
```
## Step3：打开Stack Monitoring UI
 我们安装如下的步骤来查看Logstash的monitoring：

![](https://img-blog.csdnimg.cn/20191230172352315.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们会发现在Logstash运行的情况下，有一个Logstash的类别出现了。这在之前是没有的。我们点击Nodes 1：

![](https://img-blog.csdnimg.cn/20191230172716630.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们看到一个Logstash的运行实例。它显示了目前CPU的使用情况和Load Average及JVM head的使用情况。点击上面的超链接：

![](https://img-blog.csdnimg.cn/20191230172900192.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)


我们可以看到更加详细的使用情况。我们也可以查看pipeline的状况：

![](https://img-blog.csdnimg.cn/20191231091805702.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)


# Logstash集中管理
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

一旦启动了logstash的集中管理，我们就可以直接启动logstash，而不用跟任何的参数：
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


好了到此，我们关于如何启动Logstash的监控及集中管理讲完了。
————————————————
版权声明：本文为CSDN博主「Elastic 中国社区官方博客」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/UbuntuTouch/article/details/103767088