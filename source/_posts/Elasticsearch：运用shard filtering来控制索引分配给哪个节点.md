---
title: Elasticsearch：运用shard filtering来控制索引分配给哪个节点
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在我们的实际部署中，我们的各个node（节点）的能力是不一样的。比如有的节点的计算能力比较强，而且配有高性能的存储，速度也比较快，同时我们可能有一些node的能力稍微差一点，比如计算能力及存储器的速度都比较差一点。针对这两种情况，我们其实可以把这两种节点用来做不同的用途：运算能力较强的节点可以用来做indexing（建立索引表格）的工作，而那些能力较差一点的节点，我们可以用来做搜索用途。我们可以把这两种节点分别叫做：

- hot node：用于支持索引并写入新文档
- warm node：用于处理不太频繁查询的只读索引

这种架构在Elasticsearch中，我们称之为hot/warm架构。

# Hot node

我们可以使用hot node来做indexing：

- indexing是CPU和IO的密集操作，因此热节点应该是功能强大的服务器
- 比warm node更快的存储

![](https://img-blog.csdnimg.cn/20191022203619461.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

# Warm node

对较旧的只读索引使用热节点：

- 倾向于利用大型附加磁盘（通常是旋转磁盘）
- 大量数据可能需要其他节点才能满足性能要求

![](https://img-blog.csdnimg.cn/20191022203841566.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

# Shard filtering

Shard filtering在Elasticsearch中，我们可以利用这个能力来把我们想要的index放入到我们想要的node里。我们可以使用在elasticsearch.yml配置文件中的：

- node.attr来指定我们node属性：hot或是warm。
- 在index的settings里通过index.routing.allocation来指定索引（index)到一个满足要求的node

为节点分配索引有三种规则：

![](https://img-blog.csdnimg.cn/2019102220445254.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

就像上面的表格说明的一样：include指的是至少包含其中的一个值；exclude指的是不包含任何值；require指的是必须包含里面索引的值。这些值实际上我们用来标识node的tag。针对自己的配置这些tag可以由厂商自己标识。


## 标识node

![](https://img-blog.csdnimg.cn/20191022205226934.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

在上面的图中，我们标识my_temp属性为hot或是warm，表明我们的cluster中分为两类：hot或是warm。在这里特别指出：这里的my_temp，hot及warm都是我们任意取的可以让我们记住的属性及名称。只要在使用时和index.routing.allocation.include index.routing.allocation.exclude及index.routing.allocation.require中的值相对应即可。

## 配置index的settings

我们可以通过配置在Index中的settings来分配我们的index到相应的具有哪些属性的node里，比如：
```
    PUT logs-2019-03
    {
      "settings": {
        "index.routing.allocation.require.my_temp": "hot"
      }
    }
```
在上面我们通过logs-2019-03的这个index的settings来控制这个index必须分配到具有hot属性的node里。

假如我们上面的index logs-2019-03由于一些原因不再是当前的用来做indexing的index，比如我们可以通过rollover API接口来自动滚动我们的index名字。我们可以通过如下的命令把该index移动到warm node里：
```
    PUT logs-2019-03
    {
      "settings": {
        "index.routing.allocation.require.my_temp": "warm"
      }
    }
```
这样Elasticsearch会自动帮我们把logs-2019-03索引移动到warm node中，以便直供搜索之用。

# 例子

首先，我们我们按照如下的方式来做一个实验，虽然不能应用于实际的生产环境中：

1. 按照“如何在Linux，MacOS及Windows上进行安装Elasticsearch”安装好自己的Elasticsearh，但是不要运行Elasticsearch
2. 按照“如何在Linux及MacOS上安装Elastic栈中的Kibana”安装好自己的Kibana

在我们完成上面的两个安装后，我们分别打开两个terminal，然后分别在两个terminal中运行如下的指令：
```
./bin/elasticsearch -E node.name=node1 -E node.attr.data=hot -Enode.max_local_storage_nodes=2
```
上面的指令运行一个名字叫做node1的，data属性为hot的node。
```
./bin/elasticsearch -E node.name=node2 -E node.attr.data=warm -Enode.max_local_storage_nodes=2
```
上面的指令运行一个名字叫做node2的，data属性为hot的warm。

我们可以在Kibana里查看我们的nodes：

![](https://img-blog.csdnimg.cn/20191022213646237.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看出来有两个node正在运行：node1及node2。如果我们想了解这两个node的更多属性，我们可以打入如下的命令：
```
GET _cat/nodeattrs?v&s=name
```
显示的结果为：

![](https://img-blog.csdnimg.cn/201910222140357.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看到node被标识为hot node，而node2被标识为warm node。

接下来，我们运用我们上面命令来把我们的logs-2019-03置于我们的hot node里。我们可以通过如下的命令：
```
    PUT logs-2019-03
    {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0, 
        "index.routing.allocation.require.data": "hot"
      }
    }
```
运行上面的结果后，可以通过如下的命令来查看：
```
GET _cat/shards/logs-*?v&h=index,shard,prirep,state,node&s=index,shard,prirep
```
显示的结果为：

![](https://img-blog.csdnimg.cn/20191022215525154.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

从上面我们可以看出来我们的logs-2019-03是分配到node1上面的。

假如我们由于某种原因，想把logs-2019-03分配到node2上面，那么该怎么做呢？我们可以通过如下的命令来实现：
```
    PUT logs-2019-03/_settings
    {
      "index.routing.allocation.require.data": "warm"
    }
```
运行上面的指令显示的结果是：

显然我们logs-2019-03已经成功地移到node2了。


# 针对硬件的shard filtering

上面我们说了，对于node.attr来说，我们可以添加任意的属性。在上面的我们已经使用hot/warm来标识我们的my_temp属性。其实我们也可以同时定义一些能标识硬件的属性my_server，这个属性值可以为small，medium及large。有多个属性组成的集群就像是如下的结构：

![](https://img-blog.csdnimg.cn/20191024180643722.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

那么这样的集群里的每个node可能具有不同的属性。我们可以通过如下的方法来分配index到同时具有两个或以上属性的node里:
```
     PUT my_index1 
     {
       "settings": {
          "number_of_shards": 2,
           "number_of_replicas": 1, 
           "index.routing.allocation.include.my_server": "medium",             
           "index.routing.allocation.require.my_temp": "hot"
       }
     }
```
如上所示，我们把我们的my_index1分配到这么一个node：这个node必须具有hot属性，同时也具有medium的属性。针对我们上面显示的图片，只有node1满足我们的要求。

总结：在今天的这篇文章中，我们介绍了如何使用shard filtering来控制我们的index的分配。在实际的操作中，可能大家会觉得麻烦一点，因为这个比较需要我们自己来管理这个。这个技术可以和我之前的文章“Elasticsearch: rollover API”一起配合使用。Elasticsearch实际已经帮我做好了。在接下来的文章里，我会来介绍如何使用Index life cycle policy来自动管理我们的Index。
