---
title: Elasticsearch rollover API
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
rollover使您可以根据索引大小，文档数或使用期限自动过渡到新索引。 当rollover触发后，将创建新索引，写别名（write alias)将更新为指向新索引，所有后续更新都将写入新索引。

对于基于时间的rollover来说，基于大小，文档数或使用期限过渡至新索引是比较适合的。 在任意时间rollover通常会导致许多小的索引，这可能会对性能和资源使用产生负面影响。

Rollover历史数据

- 在大多数情况下，无限期保留历史数据是不可行的
    - 时间序列数据随着时间的流逝而失去价值，我们最终不得不将其删除
    - 但是其中一些数据对于分析仍然非常有用 

- Elasticsearch 6.3引入了一项新的rollover功能，该功能
    - 以紧凑的聚合格式保存旧数据
    - 仅保存您感兴趣的数据

![](https://img-blog.csdnimg.cn/2019102120221648.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

就像上面的图片看到的那样，我们定义了一个叫做logs-alias的alias，对于写操作来说，它总是会自动指向最新的可以用于写入index的一个索引。针对我们上面的情况，它指向logs-000002。如果新的rollover发生后，新的logs-000003将被生成，并对于写操作来说，它自动指向最新生产的logs-000003索引。而对于读写操作来说，它将同时指向最先的logs-1，logs-000002及logs-000003。在这里我们需要注意的是：在我们最早设定index名字时，最后的一个字符必须是数字，比如我们上面显示的logs-1。否则，自动生产index将会失败。

# rollover例子

我们还是先拿一个rollover的例子来说明，这样比较清楚。首先我们定义一个log-alias的alias:
```
    PUT /%3Clogs-%7Bnow%2Fd%7D-1%3E
    {
      "aliases": {
        "log_alias": {
          "is_write_index": true
        }
      }
    }
```
如果大家对于上面的字符串“%3Clogs-%7Bnow%2Fd%7D-1%3E”比较陌生的话，可以参考网站https://www.urlencoder.io/。实际上它就是字符串“<logs-{now/d}-1>”的url编码形式。请注意上面的is_write_index必须设置为true。运行上面的结果是：
<escape><!-- more --></escape>

```
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "index" : "logs-2019.10.21-1"
    }
```
显然，它帮我们生产了一个叫做logs-2019.10.21-1的index。接下来，我们先使用我们的Kibana来准备一下我们的index数据。我们运行起来我们的Kibana:

![](https://img-blog.csdnimg.cn/20191021204701824.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们分别点击上面的1和2处：

![](https://img-blog.csdnimg.cn/2019102120481842.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

点击上面的“Add data”。这样我们就可以把我们的kibana_sample_data_logs索引加载到Elasticsearch中。我们可以通过如下的命令进行查看：
```
GET _cat/indices/kibana_sample_data_logs
```
命令显示结果为：

![](https://img-blog.csdnimg.cn/2019102120530923.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

它显示kibana_sample_data_logs具有11.1M的数据，并且它有14074个文档：

![](https://img-blog.csdnimg.cn/20191021210113731.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们接下来运行如下的命令：
```
    POST _reindex
    {
      "source": {
        "index": "kibana_sample_data_logs"
      },
      "dest": {
        "index": "log_alias"
      }
    }
```
这个命令的作用是把kibana_sample_data_logs里的数据reindex到log_alias所指向的index。也就是把kibana_sample_data_logs的文档复制一份到我们上面显示的logs-2019.10.21-1索引里。我们做如下的操作查看一下结果：
```
GET logs-2019.10.21-1/_count
```
显示的结果是：
```
    {
      "count" : 14074,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      }
    }
```
显然，我们已经复制到所有的数据。那么接下来，我们来运行如下的一个指令：
```
    POST /log_alias/_rollover?dry_run
    {
      "conditions": {
        "max_age": "7d",
        "max_docs": 14000,
        "max_size": "5gb"
      }
    }
```
在这里，我们定义了三个条件：

- 如果时间超过7天，那么自动rollover，也就是使用新的index
- 如果文档的数目超过14000个，那么自动rollover
- 如果index的大小超过5G，那么自动rollover

在上面我们使用了dry_run参数，表明就是运行时看看，但不是真正地实施。显示的结果是：
```
    {
      "acknowledged" : false,
      "shards_acknowledged" : false,
      "old_index" : "logs-2019.10.21-1",
      "new_index" : "logs-2019.10.21-000002",
      "rolled_over" : false,
      "dry_run" : true,
      "conditions" : {
        "[max_docs: 1400]" : true,
        "[max_size: 5gb]" : false,
        "[max_age: 7d]" : false
      }
    }
```
根据目前我们的条件，我们的logs-2019.10.21-1文档数已经超过14000个了，所以会生产新的索引logs-2019.10.21-000002。因为我使用了dry_run，也就是演习，所以显示的rolled_over是false。

为了能真正地rollover，我们运行如下的命令：
```
    POST /log_alias/_rollover
    {
      "conditions": {
        "max_age": "7d",
        "max_docs": 1400,
        "max_size": "5gb"
      }
    }
```
显示的结果是：
```
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "old_index" : "logs-2019.10.21-1",
      "new_index" : "logs-2019.10.21-000002",
      "rolled_over" : true,
      "dry_run" : false,
      "conditions" : {
        "[max_docs: 1400]" : true,
        "[max_size: 5gb]" : false,
        "[max_age: 7d]" : false
      }
    }
```
说明它已经rolled_ovder了。我们可以通过如下写的命令来检查：
```
GET _cat/indices/logs-2019*
```
显示的结果为：

![](https://img-blog.csdnimg.cn/20191021213828389.png)

我们现在可以看到有两个以logs-2019.10.21为头的index，并且第二文档logs-2019.10.21-000002文档数为0。如果我们这个时候直接再想log_alias写入文档的话：
```
    POST log_alias/_doc
    {
      "agent": "Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1",
      "bytes": 6219,
      "clientip": "223.87.60.27",
      "extension": "deb",
      "geo": {
        "srcdest": "IN:US",
        "src": "IN",
        "dest": "US",
        "coordinates": {
          "lat": 39.41042861,
          "lon": -88.8454325
        }
      },
      "host": "artifacts.elastic.co",
      "index": "kibana_sample_data_logs",
      "ip": "223.87.60.27",
      "machine": {
        "ram": 8589934592,
        "os": "win 8"
      },
      "memory": null,
      "message": """          
      223.87.60.27 - - [2018-07-22T00:39:02.912Z] "GET /elasticsearch/elasticsearch-6.3.2.deb_1 HTTP/1.1" 200 6219 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1"
      """,
      "phpmemory": null,
      "referer": "http://twitter.com/success/wendy-lawrence",
      "request": "/elasticsearch/elasticsearch-6.3.2.deb",
      "response": 200,
      "tags": [
        "success",
        "info"
      ],
      "timestamp": "2019-10-13T00:39:02.912Z",
      "url": "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.2.deb_1",
      "utc_time": "2019-10-13T00:39:02.912Z"
    }
```
显示的结果：
```
    {
      "_index" : "logs-2019.10.21-000002",
      "_type" : "_doc",
      "_id" : "xPyQ7m0BsjOKp1OsjsP8",
      "_version" : 1,
      "result" : "created",
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "failed" : 0
      },
      "_seq_no" : 1,
      "_primary_term" : 1
    }
```
显然它写入的是logs-2019.10.21-000002索引。我们再次查询log_alias的总共文档数：
```
GET log_alias/_count
```
显示的结果是：
```
    {
      "count" : 14075,
      "_shards" : {
        "total" : 2,
        "successful" : 2,
        "skipped" : 0,
        "failed" : 0
      }
    }
```
显然它和之前的14074个文档多增加了一个文档，也就是说log_alias是同时指向logs-2019.10.21-1及logs-2019.10.21-000002。

总结：在今天的文档里，我们讲述了如何使用rollover API来自动管理我们的index。利用rollover API，它可以很方便地帮我们自动根据我们设定的条件帮我们把我们的Index过度到新的index。在未来的文章里，我们将讲述如何使用Index life cycle policy来帮我们管理我们的index。
