---
title: Elasticsearch：如何把Elasticsearch中的数据导出为CSV格式的文件
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
本教程向您展示如何将数据从Elasticsearch导出到CSV文件。 想象一下，您想要在Excel中打开一些Elasticsearch中的数据，并根据这些数据创建数据透视表。 这只是一个用例，其中将数据从Elasticsearch导出到CSV文件将很有用。
 
# 方法一
其实这种方法最简单了。我们可以直接使用Kibana中提供的功能实现这个需求。

我们首先来准备数据：

![](https://img-blog.csdnimg.cn/20191219192355642.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20191219192543840.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

再接着选择Add data。这样我们的Elasticsearch中就会有我们的eCommerce索引了。

我们接着选择Discover，并选择我们刚才建立的eCommerce索引。

![](https://img-blog.csdnimg.cn/20191219193027904.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们同时要记得在time picker里选择我们所需要的时间段：

![](https://img-blog.csdnimg.cn/2019121919305845.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

我们可以做一些我们想要的搜索：

![](https://img-blog.csdnimg.cn/20191219193238837.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们点击左上角的Save按钮：

![](https://img-blog.csdnimg.cn/20191219193357231.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

接下来，我们点击Share按钮：

![](https://img-blog.csdnimg.cn/2019121919352965.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

这样我们就可以得到我们当前搜索结果的csv文件。我们只需要在Kibana中下载即可：

![](https://img-blog.csdnimg.cn/20191219193739183.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)


# 方法二
我们可以使用Logstash提供的功能来做这个。这个的好处是可以通过编程的方式来进行。Logstash不只光可以把数据传上Elasticsearch，同时它还可以把数据从Elasticsearch中导出。

我们首先必须安装和Elasticsearch相同版本的 Logstash。如果大家还不指定如安装Logstash的话，请参阅我的文章“如何安装Elastic栈中的Logstash”。

我们可以进一步查看我们的Logstash是否支持csv的output:
```
./bin/logstash-plugin list --group output
```
显示：
```
logstash-output-cloudwatch
logstash-output-csv
logstash-output-elastic_app_search
logstash-output-elasticsearch
logstash-output-email
logstash-output-file
logstash-output-graphite
logstash-output-http
logstash-output-lumberjack
logstash-output-nagios
logstash-output-null
logstash-output-pipe
logstash-output-rabbitmq
logstash-output-redis
logstash-output-s3
logstash-output-sns
logstash-output-sqs
logstash-output-stdout
logstash-output-tcp
logstash-output-udp
logstash-output-webhdfs
```
显然logstash-ouput-csv是在列表中。也就是说我们logstash支持csv格式的输出。

我们建立如下的Logstash的配置文件：
```
convert_csv.conf

input {
 elasticsearch {
    hosts => "localhost:9200"
    index => "kibana_sample_data_ecommerce"
    query => '{  
    "query": {
        "bool": {
          "must": [
            {
              "match": {
                "currency": "EUR"
              }
            },
            {
              "match": {
                "products.quantity": 1
              }
            }
          ]
        }
      }
    }'
  }
}
 
output {
  csv {
    # This is the fields that you would like to output in CSV format.
    # The field needs to be one of the fields shown in the output when you run your
    # Elasticsearch query
 
    fields => ["category", "customer_birth_date", "customer_first_name", "customer_full_name", "day_of_week"]
  
    # This is where we store output. We can use several files to store our output
    # by using a timestamp to determine the filename where to store output.    
    path => "/Users/liuxg/tmp/csv-export.csv"
  }
}
```
请注意上面的path需要自己去定义时候自己环境的路径。这里我们在fields里定义了我们想要的字段。

然后，我们可以运行我们的Logstash应用：
```
./bin/logstash -f ~/data/convert_csv.conf 
```
这样在我们定义的文件路径/Users/liuxg/tmp/csv-export.csv可以看到一个输出的csv文件。我们可以打开这个文件，并看到像这样的文档：
