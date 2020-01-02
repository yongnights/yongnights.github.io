---
title: Elasticsearch：Index生命周期管理入门
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
如果您要处理时间序列数据，则不想将所有内容连续转储到单个索引中。 取而代之的是，您可以定期将数据滚动到新索引，以防止数据过大而又缓慢又昂贵。 随着索引的老化和查询频率的降低，您可能会将其转移到价格较低的硬件上，并减少分片和副本的数量。

要在索引的生命周期内自动移动索引，可以创建策略来定义随着索引的老化对索引执行的操作。 索引生命周期策略在与Beats数据发件人一起使用时特别有用，Beats数据发件人不断将运营数据（例如指标和日志）发送到Elasticsearch。 当现有索引达到指定的大小或期限时，您可以自动滚动到新索引。 这样可以确保所有索引具有相似的大小，而不是每日索引，其大小可以根beats数和发送的事件数而有所不同。

让我们通过动手操作场景跳入索引生命周期管理（Index cycle management: ILM）。 本文章将利用您可能不熟悉的ILM独有的许多新概念。 我们先用一个示例来展示。本示例的目标是建立一组索引，这些索引将封装来自时间序列数据源的数据。 我们可以想象有一个像Filebeat这样的系统，可以将文档连续索引到我们的书写索引中。 我们希望在索引达到50 GB，或文档的数量超过10000，或已在30天前创建索引后对其进行rollover，然后在90天后删除该索引。

![](https://img-blog.csdnimg.cn/2019120310105848.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

上图显示一个Log文档在Elasticsearch中生命周期。

<escape><!-- more --></escape>

# 运行两个node的Elasticsearch集群

我们可以参考文章“Elasticsearch：运用shard filtering来控制索引分配给哪个节点”运行起来两个node的cluster。其实非常简单，当我们安装好Elasticsearch后，打开一个terminal，并运行如下的命令：
```
./bin/elasticsearch -E node.name=node1 -E node.attr.data=hot -Enode.max_local_storage_nodes=2
```
它将运行起来一个叫做node1的节点。同时在另外terminal中运行如下的命令：
```
./bin/elasticsearch -E node.name=node2 -E node.attr.data=warm -Enode.max_local_storage_nodes=2
```
它运行另外一个叫做node2的节点。我们可以通过如下的命令来进行查看：
```
GET _cat/nodes?v
```
显示两个节点：

![](https://img-blog.csdnimg.cn/20191024205412850.png)

我们可以用如下的命令来检查这两个node的属性：
```
GET _cat/nodeattrs?v&s=name
```
显然其中的一个node是hot，另外一个是warm。
![](https://img-blog.csdnimg.cn/20191024205645678.png)

# 准备数据

运行起来我们的Kibana:

![](https://img-blog.csdnimg.cn/20191021204701824.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们分别点击上面的1和2处：

![](https://img-blog.csdnimg.cn/2019102120481842.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

点击上面的“Add data”。这样我们就可以把我们的kibana_sample_data_logs索引加载到Elasticsearch中。我们可以通过如下的命令进行查看：
```
GET _cat/indices/kibana_sample_data_logs
```
命令显示结果为：

![](https://img-blog.csdnimg.cn/2019102120530923.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

它显示kibana_sample_data_logs具有11.1M的数据，并且它有14074个文档。


# 建立ILM policy

我们可以通过如下的方法来建立一个ILM的policy.
``` 

    PUT _ilm/policy/logs_policy
    {
      "policy": {
        "phases": {
          "hot": {
            "min_age": "0ms",
            "actions": {
              "rollover": {
                "max_size": "50gb",
                "max_age": "30d",
                "max_docs": 10000
              },
              "set_priority": {
                "priority": 100
              }
            }
          },
          "delete": {
            "min_age": "90d",
            "actions": {
              "delete": {}
            }
          }
        }
      }
    }
```
这里定义的一个policy意思是：

1. 如果一个index的大小超过50GB，那么自动rollover
2. 如果一个index日期已在30天前创建索引后，那么自动rollover
3. 如果一个index的文档数超过10000，那么也会自动rollover
4. 当一个index创建的时间超过90天，那么也自动删除

其实这个我们也可以通过Kibana帮我们来实现。请按照如下的步骤：

![](https://img-blog.csdnimg.cn/2019102421072436.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

紧接着点击“Index Lifecycle Policies”：

![](https://img-blog.csdnimg.cn/2019102421082922.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

再点击“Create Policy”:

![](https://img-blog.csdnimg.cn/20191024211000854.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

![](https://img-blog.csdnimg.cn/20191024211042795.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

最后点“Save as new Policy”及可以在我们的Kibana中同过如下的命令可以查看到：
```
GET _ilm/policy/logs_policy
```
显示结果：

![](https://img-blog.csdnimg.cn/20191024211434675.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

# 设置Index template

我们可以通过如下的方法来建立template:
```
    PUT _template/datastream_template
    {
      "index_patterns": ["logs*"],                 
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 1,
        "index.lifecycle.name": "logs_policy", 
        "index.routing.allocation.require.data": "hot",
        "index.lifecycle.rollover_alias": "logs"    
      }
    }
```
这里的意思是所有以logs开头的index都需要遵循这个规律。这里定义了rollover的alias为“logs ”。
这在我们下面来定义。同时也需要注意的是"index.routing.allocation.require.data": "hot"。
这个定义了我们需要indexing的node的属性是hot。请看一下我们上面的policy里定义的有一个叫做phases里的，它定义的是"hot"。
在这里我们把所有的`logs*`索引都置于hot属性的node里。在实际的使用中，hot属性的index一般用作indexing。我们其实还可以定义一些其它phase，比如warm，这样可以把我们的用作搜索的index置于warm的节点中。这里就不一一描述了。

# 定义Index alias

我们可以通过如下的方法来定义：
```
    PUT logs-000001
    {
      "aliases": {
        "logs": {
          "is_write_index": true
        }
      }
    }
```
在这里定义了一个叫做logs的alias，它指向logs-00001索引。注意这里的`is_write_index`为true。如果有rollover发生时，这个alias会自动指向最新rollover的index。

# 生产数据

在这里，我们使用之前我们已经导入的测试数据kibana_sample_data_logs，我们可以通过如下的方法来写入数据：
```
    POST _reindex?requests_per_second=500
    {
      "source": {
        "index": "kibana_sample_data_logs"
      },
      "dest": {
        "index": "logs"
      }
    }
```
上面的意思是每秒按照500个文档从kibana_sample_data_logs索引reindex文档到logs别名所指向的index。我们运行后，通过如下的命令来查看最后的结果：
```
GET logs*/_count
```
显示如下：

![](https://img-blog.csdnimg.cn/20191024212850745.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看到有14074个文档被reindex到`logs*`索引中。通过如下的命令来查看：
```
GET _cat/shards/logs*
```
![](https://img-blog.csdnimg.cn/20191024213031917.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看到`logs-000002`已经生产，并且所有的索引都在node1上面。我们可以通过如下的命令：
```
GET _cat/indices/logs?v
```
![](https://img-blog.csdnimg.cn/20191024213222400.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看到`logs-000001`索引中有10000个文档，而`logs-000002`中含有4074个文档。

由于我们已经设定了policy，那么所有的这些logs*索引的生命周期只有90天。90天过后（从索引被创建时算起），索引会自动被删除掉。
