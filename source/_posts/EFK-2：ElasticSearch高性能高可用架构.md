---
title: EFK-2 ElasticSearch高性能高可用架构
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
转载自：https://mp.weixin.qq.com/s?__biz=MzUyNzk0NTI4MQ==&mid=2247483811&idx=1&sn=a413dea65f8f64abb24d82feea55db5b&chksm=fa769a8dcd01139b1da8794914e10989c6a39a99971d8013e9d3b26766b80d5833e2fbaf0ab8&mpshare=1&scene=1&srcid=1125tjbylqn3EdoMtaX2p73J&sharer_sharetime=1574686271229&sharer_shareid=6ec87ec9a11a0c18d61cde7663a9ef87#rd

阐述了EFK的data/ingest/master角色的用途及分别部署三节点，在实现性能最大化的同时保障高可用

<escape><!-- more --></escape>

![](/elk/elk2.png)

# elasticsearch-data
## 安装
3台均执行相同的安装步骤
```
    tar -zxvf elasticsearch-7.3.2-linux-x86_64.tar.gz

    mv elasticsearch-7.3.2 /opt/elasticsearch

    useradd elasticsearch -d /opt/elasticsearch -s /sbin/nologin

    mkdir -p /opt/logs/elasticsearch

    chown elasticsearch.elasticsearch /opt/elasticsearch -R

    chown elasticsearch.elasticsearch /opt/logs/elasticsearch -R

    # 数据盘需要elasticsearch写权限

    chown elasticsearch.elasticsearch /data/SAS -R


    # 限制一个进程可以拥有的VMA(虚拟内存区域)的数量要超过262144，不然elasticsearch会报max virtual memory areas vm.max_map_count [65535] is too low, increase to at least [262144]

    echo "vm.max_map_count = 655350" >> /etc/sysctl.conf

    sysctl -p
```
## elasticsearch-data配置
```
# 192.168.1.51 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.51

    # 数据盘位置，如果有多个硬盘位置，用","隔开

    path.data: /data/SAS

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.51


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 关闭master功能

    node.master: false

    # 关闭ingest功能

    node.ingest: false

    # 开启data功能

    node.data: true

# 192.168.1.52 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.52

    # 数据盘位置，如果有多个硬盘位置，用","隔开

    path.data: /data/SAS

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.52


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 关闭master功能

    node.master: false

    # 关闭ingest功能

    node.ingest: false

    # 开启data功能

    node.data: true

# 192.168.1.53 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.53

    # 数据盘位置，如果有多个硬盘位置，用","隔开

    path.data: /data/SAS

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.53


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 关闭master功能

    node.master: false

    # 关闭ingest功能

    node.ingest: false

    # 开启data功能

    node.data: true
```
## elasticsearch-data启动
```
    sudo -u elasticsearch /opt/elasticsearch/bin/elasticsearch
```
## elasticsearch集群状态
```
    curl "http://192.168.1.31:9200/_cat/health?v"
```
## elasticsearch-data状态
```
    curl "http://192.168.1.31:9200/_cat/nodes?v"
```
## elasticsearch-data参数说明
```
    status: green  # 集群健康状态

    node.total: 6  # 有6台机子组成集群

    node.data: 6  # 有6个节点的存储

    node.role: d  # 只拥有data角色

    node.role: i  # 只拥有ingest角色

    node.role: m  # 只拥有master角色

    node.role: mid  # 拥master、ingest、data角色
```

# elasticsearch-ingest
新增三台ingest节点加入集群，同时关闭master和data功能
## elasticsearch-ingest安装
3台es均执行相同的安装步骤
```
    tar -zxvf elasticsearch-7.3.2-linux-x86_64.tar.gz

    mv elasticsearch-7.3.2 /opt/elasticsearch

    useradd elasticsearch -d /opt/elasticsearch -s /sbin/nologin

    mkdir -p /opt/logs/elasticsearch

    chown elasticsearch.elasticsearch /opt/elasticsearch -R

    chown elasticsearch.elasticsearch /opt/logs/elasticsearch -R


    # 限制一个进程可以拥有的VMA(虚拟内存区域)的数量要超过262144，不然elasticsearch会报max virtual memory areas vm.max_map_count [65535] is too low, increase to at least [262144]

    echo "vm.max_map_count = 655350" >> /etc/sysctl.conf

    sysctl -p
```
## elasticsearch-ingest配置
```
# 192.168.1.41 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.41

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.41


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 关闭master功能

    node.master: false

    # 开启ingest功能

    node.ingest: true

    # 关闭data功能

    node.data: false

# 192.168.1.42 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.42

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.42


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 关闭master功能

    node.master: false

    # 开启ingest功能

    node.ingest: true

    # 关闭data功能

    node.data: false

# 192.168.1.43 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.43

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.43


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 关闭master功能

    node.master: false

    # 开启ingest功能

    node.ingest: true

    # 关闭data功能

    node.data: false
```

## elasticsearch-ingest启动
```
    sudo -u elasticsearch /opt/elasticsearch/bin/elasticsearch
```
## elasticsearch集群状态
```
    curl "http://192.168.1.31:9200/_cat/health?v"
```
## elasticsearch-ingest状态
```
    curl "http://192.168.1.31:9200/_cat/nodes?v"
```
## elasticsearch-ingest参数说明
```
    status: green  # 集群健康状态

    node.total: 9  # 有9台机子组成集群

    node.data: 6  # 有6个节点的存储

    node.role: d  # 只拥有data角色

    node.role: i  # 只拥有ingest角色

    node.role: m  # 只拥有master角色

    node.role: mid  # 拥master、ingest、data角色
```            

# elasticsearch-master
首先，将上一篇《EFK-1》中部署的3台es（192.168.1.31、192.168.1.32、192.168.1.33）改成只有master的功能， 因此需要先将这3台上的索引数据迁移到本次所做的data节点中
## 索引迁移
一定要做这步，将之前的索引放到data节点上
```
    curl -X PUT "192.168.1.31:9200/*/_settings?pretty" -H 'Content-Type: application/json' -d'
    {
      "index.routing.allocation.include._ip": "192.168.1.51,192.168.1.52,192.168.1.53"
    }'
```
## 确认当前索引存储位置
确认所有索引不在192.168.1.31、192.168.1.32、192.168.1.33节点上
```
    curl "http://192.168.1.31:9200/_cat/shards?h=n"
```
## elasticsearch-master配置
注意事项：修改配置，重启进程，需要一台一台执行，要确保第一台成功后，再执行下一台。
```
# 192.168.1.31 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.31

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.31


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    #开启master功能

    node.master: true

    #关闭ingest功能

    node.ingest: false

    #关闭data功能

    node.data: false

# 192.168.1.32 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.32

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.32


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    #开启master功能

    node.master: true

    #关闭ingest功能

    node.ingest: false

    #关闭data功能

    node.data: false

# 192.168.1.33 /opt/elasticsearch/config/elasticsearch.yml
    cluster.name: my-application

    node.name: 192.168.1.33

    path.logs: /opt/logs/elasticsearch

    network.host: 192.168.1.33


    discovery.seed_hosts: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    cluster.initial_master_nodes: ["192.168.1.31","192.168.1.32","192.168.1.33"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    #开启master功能

    node.master: true

    #关闭ingest功能

    node.ingest: false

    #关闭data功能

    node.data: false

```
## elasticsearch集群状态
```
    curl "http://192.168.1.31:9200/_cat/health?v"
```
## elasticsearch-master状态
```
    curl "http://192.168.1.31:9200/_cat/nodes?v"
```

**至此，当node.role里所有服务器都不再出现“mid”，则表示一切顺利完成。**