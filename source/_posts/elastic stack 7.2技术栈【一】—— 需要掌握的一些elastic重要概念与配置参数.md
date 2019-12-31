---
title: elastic stack 7.2技术栈【一】Elasticsearch 7.2 技术栈安装与配置概要的说明
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
# Elasticsearch 7.2 技术栈安装与配置概要的说明
我们将大体上按以下步骤逐步安装和配置出一套满足生产环境运行要求和信息安全管理要求的三节点es服务集群。

1. 在节点1上面先行安装一套es+kinaba+beats的单节点服务
详细步骤可以参考官网这个教程：get-started-elastic-stack

2. 继续在单节点的结构下启用和配置出es安全管理功能
详细步骤可以参考官网这个教程：security-getting-started

3. 进行面向支持多节点的加密通信改造的相关配置，同时将节点2、3加入es集群中
详细步骤可以参考官网这个教程：encrypting-internode-communications

我们之所以没有选择按一步到位的方法部署整套es集群，是因为在启用和配置xpack的部分很容易遇到问题。参照上面的三个步骤，可以依次部署、配置并对结果进行验证，在前一步骤部署成功的基础上继续做更多内容的部署，这样处理的成功率会比较高。

<escape><!-- more --></escape>

# 版本及许可的说明
操作系统使用centos7 minimual，升级到最新小版本。
elasticsearch技术栈均采用 7.2版本，默认使用basic许可，可免费使用xpack部分安全管理服务。
使用官网下载的tar.gz安装包进行部署。

# 一些elastic重要概念与配置参数
ES 是在 lucene 的基础上进行研发的，隐藏了 lucene 的复杂性，提供简单易用的 RESTful Api接口。ES 的分片相当于 lucene 的索引。

## Node 节点的几种部署实例
实例一: 只用于数据存储和数据查询，降低其资源消耗率
```
node.master: false
node.data: true
```
实例二: 来协调各种创建索引请求或者查询请求，但不存储任何索引数据
```
node.master: true
node.data: false
```
实例三: 主要用 于查询负载均衡， 并请求分发到多个指定的node服务器，并对各个node服务器返回的结果进行一个汇总处理，最终返回给客户端
```
node.master: false
node.data: false
```
实例四: 即有成为主节点的资格，又存储数据
```
node.master: true
node.data: true
```
在只有3个节点的部署方案中，建议设置3个节点均有成为master节点的资格，且存储索引数据。

数据目录配置与物理磁盘的使用
一般来说，是这样配置：
```
path:
  logs: /var/log/elasticsearch
  data: /var/data/elasticsearch
```
数据目录可以支持使用多个：
```
path:
  data:
    - /mnt/elasticsearch_1
    - /mnt/elasticsearch_2
    - /mnt/elasticsearch_3
```
物理磁盘的使用：

- 由于es已经提供了数据副本的冗余，所以建议使用raid0，不通过raid提供额外的数据保护；
- 当有多块数据盘时，通过path.data配置把数据条带化分配到多块盘上是可行的，但建议是通过设置raid0将多块物理磁盘整合为一块逻辑盘使用，以确保每个分片都是被放入的同样的目录；
## 集群名称配置
```
cluster.name: logging-prod
```
## node节点名称
默认为使用主机名，也可以在elasticsearch.yml中指定。在一个主机上同时跑多个es实例时，这个配置项就会很有帮助了。
```
node.name: prod-data-2
```
## 网络地址配置
默认将服务绑定到loopback接口，这需要按实际情况调整。
```
network.host: 10.20.0.11
```
注：变更服务绑定接口后，会被认为是作为生产环境使用，会触发es的环境检查操作。当有不符要求的系统或集群配置参数时，es服务会无法启动。

## 节点发现和cluster初始化参数
单播主机列表通过discovery.zen.ping.unicast.hosts来配置。
这个配置在 elasticsearch.yml 文件中：
```
discovery.zen.ping.unicast.hosts: ["host1", "host2:port"]
```
具体的值是一个主机数组或逗号分隔的字符串。每个值应采用host：port或host的形式（其中port默认为设置transport.profiles.default.port，如果未设置则返回transport.tcp.port）。请注意，必须将IPv6主机置于括号内。此设置的默认值为127.0.0.1，[:: 1]。

使用单播，你可以为 Elasticsearch 提供一些它应该去尝试连接的节点列表。当一个节点联系到单播列表中的成员时，它就会得到整个集群所有节点的状态，然后它会联系 master 节点，并加入集群。
```
discovery.seed_hosts:
   - 192.168.1.10:9300
   - 192.168.1.11
   - seeds.mydomain.com
cluster.initial_master_nodes:
   - master-node-a
   - master-node-b
   - master-node-c
```
提供了seed.hosts参数的三种赋值方式

- initial_master_nodes参数只能使用节点的node.name参数值，一般来说是主机名
- Zen Discovery 是 ES 默认内建发现机制。它提供单播和多播的发现方式，并且可以扩展为通过插件支持云环境和其他形式的发现。
- Elasticsearch 官方推荐我们使用 单播 代替 组播。而且 Elasticsearch 默认被配置为使用 单播 发现，以防止节点无意中加入集群。

## 设置JVM heap size
通过jvm.options文件设置jvm缓存参数，过大或过小都不好，过大的缓存也会让垃圾回收变慢。

当jvm缓存设置大于26GB时，需要评估zero-based compressed oops限制，参见下面的说明：
https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

由于ES构建基于lucene, 而lucene设计强大之处在于lucene能够很好的利用操作系统内存来缓存索引数据，以提供快速的查询性能。lucene的索引文件segements是存储在单文件中的，并且不可变，对于OS来说，能够很友好地将索引文件保持在cache中，以便快速访问；因此，我们很有必要将一半的物理内存留给lucene ; 另一半的物理内存留给ES（JVM heap )。所以， 在ES内存设置方面，可以遵循以下原则：

- 当机器内存小于64G时，遵循通用的原则，50%给ES，50%留给lucene。

- 当机器内存大于64G时，遵循以下原则：
	a. 如果主要的使用场景是全文检索, 那么建议给ES Heap分配 4~32G的内存即可；其它内存留给操作系统, 供lucene使用（segments cache), 以提供更快的查询性能。
	b. 如果主要的使用场景是聚合或排序， 并且大多数是numerics, dates, geo_points 以及not_analyzed的字符类型， 建议分配给ES Heap分配 4~32G的内存即可，其它内存留给操作系统，供lucene使用(doc values cache)，提供快速的基于文档的聚类、排序性能。
	c. 如果使用场景是聚合或排序，并且都是基于analyzed 字符数据，这时需要更多的 heap size, 建议机器上运行多ES实例，每个实例保持不超过50%的ES heap设置(但不超过32G，堆内存设置32G以下时，JVM使用对象指标压缩技巧节省空间)，50%以上留给lucene。
	
- 禁止swap，一旦允许内存与磁盘的交换，会引起致命的性能问题。 通过： 在elasticsearch.yml 中 bootstrap.memory_lock: true， 以保持JVM锁定内存，保证ES的性能。操作系统通过交换（swap）将内存的分页写入磁盘，es在内存中保留了很多运行时必需的数据和缓存，所以消耗磁盘的操作将严重影响正在运行的集群。
关闭es交换最彻底的方法是，在elasticsearch.yml文件中将bootstrap.mlockall设置为true 。

- GC设置原则：
	a. 保持GC的现有设置，默认设置为：Concurrent-Mark and Sweep (CMS)，别换成G1GC，因为目前G1还有很多BUG。
	b. 保持线程池的现有设置，目前ES的线程池较1.X有了较多优化设置，保持现状即可；默认线程池大小等于CPU核心数。如果一定要改，按公式（（CPU核心数* 3）/ 2）+ 1 设置；不能超过CPU核心数的2倍；但是不建议修改默认配置，否则会对CPU造成硬伤。
## Temp directory配置
在使用.tar.gz方式部署es服务时，建议指定一个安全的临时文件目录，避免因为默认使用的/tmp下的临时目录被操作系统定期删除，造成服务故障。
通过环境变量 `$ES_TMPDIR` 来设置。

## 分片分配的感知
分配感知（allocation awareness）是管理在哪里放置数据的副本。
https://www.elastic.co/guide/en/elasticsearch/reference/7.2/allocation-awareness.html

### 1. 基于分片的分配
分配感知允许用户使用自定义的参数来配置分片的分配。通过定义一组键，然后在合适的节点上设置这个键，就可以开启分配感知。
elasticsearch.yml
```
cluster.routing.allocation.awareness.attributes: rack_id
```
注：支持赋多个值同时用作感知属性，如cluster.routing.allocation.awareness.attributes: rack, group, zone

针对每个es节点，用户可以修改elasticsearch.yml，按期待的网络配置来设置该值。ES允许用户在节点上设置元数据，这些元数据的键将成为我们要使用的分配感知参数。
```
node.attr.rack_id: rack_one
```
当有多个es节点可用时，es会尽量把分片与副本均衡到rack_id值不同的节点上去。但如果只剩一个可用的es数据节点了，es也会选择把一个索引的分片和副本全部部署在同一个节点上面。

常见的使用场景是按照地点、机架或是虚拟机等来划分集群的拓扑。

### 2. 强制性的分配感知
在用户事先规则好分片分组信息，且希望限制每个分组的副本分片数量时，强制分配感知是适用的解决方法。
在这种情况下，即便因为部分分组的数据节点不可用，导致es服务可用性风险，es也不会把索引的分片与副本都部署在相同的分组节点上面。

例如，用户想在区域级别使用强制分配。可以先指定一个zone的属性，然后为该分组添加多个维度。如下所示：
```
cluster.routing.allocation.awareness.attributes: zone
cluster.routing.allocation.force.zone.values: us-east, us-west
```
此时，我们在东部地区启用了一批节点，这些节点的配置都是node.attr.zone: us-east ，在创建索引时由于以上限制，副本分片只会被均衡到没有相应zone值的节点上去。

### 3. 动态设置分片感知
可以通过集群设置API在运行时进行修改，这个修改的效果可以自行选择是持久的，还是临时性的。
```
curl -XPUT localhost:9200/_cluster/settings -d '{
  "persistent": {
  "cluster.routing.allocation.awareness.attributes": zone
  "cluster.routing.allocation.force.zone.values": us-east, us-west
  }
}'
```
