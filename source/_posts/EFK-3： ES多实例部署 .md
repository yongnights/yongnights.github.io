---
title: EFK-3 ES多实例部署 
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
转载自：https://mp.weixin.qq.com/s?__biz=MzUyNzk0NTI4MQ==&mid=2247483816&idx=1&sn=bfaf70613bcb775ccf5d40c2871a05a8&chksm=fa769a86cd011390f22ff178071a580a8f17791e57166dfc8463984a5613c11875ef2ebb2ad7&mpshare=1&scene=1&srcid=11253n8AXjLegAeaoHiCssEs&sharer_sharetime=1574686178097&sharer_shareid=6ec87ec9a11a0c18d61cde7663a9ef87#rd

基于ElasticSearch多实例架构，实现资源合理分配、冷热数据分离。
ES多实例部署，将不同热度的数据存在不同的磁盘上，实现了数据冷热分离、资源合理分配。
在一个集群中部署多个ES实例，来实现资源合理分配。例如data服务器存在SSD与SAS硬盘，可以将热数据存放到SSD，而冷数据存放到SAS，实现数据冷热分离。

<escape><!-- more --></escape>

![](/elk/elk3.png)


# 192.168.1.51 elasticsearch-data部署双实例
## 索引迁移
（此步不能忽略）：将192.168.1.51上的索引放到其它2台data节点上
```
    curl -X PUT "192.168.1.31:9200/*/_settings?pretty" -H 'Content-Type: application/json' -d'
    {
      "index.routing.allocation.include._ip": "192.168.1.52,192.168.1.53"
    }'
```
## 确认当前索引存储位置
确认所有索引不在192.168.1.51节点上
```
    curl "http://192.168.1.31:9200/_cat/shards?h=n"
```
## 停掉192.168.1.51的进程，修改目录结构及配置：请自行按SSD和SAS硬盘挂载好数据盘

```
    # 安装包下载和部署请参考第一篇《EFK-1: 快速指南》

    cd /opt/software/

    tar -zxvf elasticsearch-7.3.2-linux-x86_64.tar.gz

    mv /opt/elasticsearch /opt/elasticsearch-SAS

    mv elasticsearch-7.3.2 /opt/

    mv /opt/elasticsearch-7.3.2 /opt/elasticsearch-SSD

    chown elasticsearch.elasticsearch /opt/elasticsearch-* -R

    rm -rf /data/SAS/*

    chown elasticsearch.elasticsearch /data/* -R

    mkdir -p /opt/logs/elasticsearch-SAS

    mkdir -p /opt/logs/elasticsearch-SSD

    chown elasticsearch.elasticsearch /opt/logs/* -R
```

```
# SAS实例/opt/elasticsearch-SAS/config/elasticsearch.yml配置
    cluster.name: my-application

    node.name: 192.168.1.51-SAS

    path.data: /data/SAS

    path.logs: /opt/logs/elasticsearch-SAS

    network.host: 192.168.1.51


    http.port: 9200

    transport.port: 9300

    # discovery.seed_hosts和cluster.initial_master_nodes 一定要带上端口号，不然会走http.port和transport.port端口

    discovery.seed_hosts: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    cluster.initial_master_nodes: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    node.master: false

    node.ingest: false

    node.data: true


    # 本机只允行启2个实例

    node.max_local_storage_nodes: 2

# SSD实例/opt/elasticsearch-SSD/config/elasticsearch.yml配置
    cluster.name: my-application

    node.name: 192.168.1.51-SSD

    path.data: /data/SSD

    path.logs: /opt/logs/elasticsearch-SSD

    network.host: 192.168.1.51


    http.port: 9201

    transport.port: 9301

    # discovery.seed_hosts和cluster.initial_master_nodes 一定要带上端口号，不然会走http.port和transport.port端口

    discovery.seed_hosts: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    cluster.initial_master_nodes: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    node.master: false

    node.ingest: false

    node.data: true


    # 本机只允行启2个实例

    node.max_local_storage_nodes: 2
```
## SAS实例和SSD实例启动方式
```
    sudo -u elasticsearch /opt/elasticsearch-SAS/bin/elasticsearch

    sudo -u elasticsearch /opt/elasticsearch-SSD/bin/elasticsearch
```
## 确认SAS和SSD已启2实例
```
    curl "http://192.168.1.31:9200/_cat/nodes?v"
```
# 192.168.1.52 elasticsearch-data部署双实例
## 索引迁移
（此步不能忽略）：将192.168.1.52上的索引放到其它2台data节点上
```
    curl -X PUT "192.168.1.31:9200/*/_settings?pretty" -H 'Content-Type: application/json' -d'
    {
      "index.routing.allocation.include._ip": "192.168.1.51,192.168.1.53"
    }'
```
## 确认当前索引存储位置
确认所有索引不在192.168.1.52节点上
```
    curl "http://192.168.1.31:9200/_cat/shards?h=n"
```
## 停掉192.168.1.52的进程，修改目录结构及配置：请自行按SSD和SAS硬盘挂载好数据盘

```
    # 安装包下载和部署请参考第一篇《EFK-1: 快速指南》

    cd /opt/software/

    tar -zxvf elasticsearch-7.3.2-linux-x86_64.tar.gz

    mv /opt/elasticsearch /opt/elasticsearch-SAS

    mv elasticsearch-7.3.2 /opt/

    mv /opt/elasticsearch-7.3.2 /opt/elasticsearch-SSD

    chown elasticsearch.elasticsearch /opt/elasticsearch-* -R

    rm -rf /data/SAS/*

    chown elasticsearch.elasticsearch /data/* -R

    mkdir -p /opt/logs/elasticsearch-SAS

    mkdir -p /opt/logs/elasticsearch-SSD

    chown elasticsearch.elasticsearch /opt/logs/* -R

```

```
# SAS实例/opt/elasticsearch-SAS/config/elasticsearch.yml配置
    cluster.name: my-application

    node.name: 192.168.1.52-SAS

    path.data: /data/SAS

    path.logs: /opt/logs/elasticsearch-SAS

    network.host: 192.168.1.52


    http.port: 9200

    transport.port: 9300

    # discovery.seed_hosts和cluster.initial_master_nodes 一定要带上端口号，不然会走http.port和transport.port端口

    discovery.seed_hosts: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    cluster.initial_master_nodes: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    node.master: false

    node.ingest: false

    node.data: true


    # 本机只允行启2个实例

    node.max_local_storage_nodes: 2

# SSD实例/opt/elasticsearch-SSD/config/elasticsearch.yml配置
    cluster.name: my-application

    node.name: 192.168.1.52-SSD

    path.data: /data/SSD

    path.logs: /opt/logs/elasticsearch-SSD

    network.host: 192.168.1.52


    http.port: 9201

    transport.port: 9301

    # discovery.seed_hosts和cluster.initial_master_nodes 一定要带上端口号，不然会走http.port和transport.port端口

    discovery.seed_hosts: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    cluster.initial_master_nodes: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    node.master: false

    node.ingest: false

    node.data: true


    # 本机只允行启2个实例

    node.max_local_storage_nodes: 2
```
## SAS实例和SSD实例启动方式
```
    sudo -u elasticsearch /opt/elasticsearch-SAS/bin/elasticsearch

    sudo -u elasticsearch /opt/elasticsearch-SSD/bin/elasticsearch
```
## 确认SAS和SSD已启2实例
```
    curl "http://192.168.1.31:9200/_cat/nodes?v"
```
# 192.168.1.53 elasticsearch-data部署双实例
## 索引迁移
（此步不能忽略）：一定要做这步，将192.168.1.53上的索引放到其它2台data节点上
```
    curl -X PUT "192.168.1.31:9200/*/_settings?pretty" -H 'Content-Type: application/json' -d'
    {
      "index.routing.allocation.include._ip": "192.168.1.51,192.168.1.52"
    }'
```

## 确认当前索引存储位置
确认所有索引不在192.168.1.52节点上
```
    curl "http://192.168.1.31:9200/_cat/shards?h=n"
```

## 停掉192.168.1.53的进程，修改目录结构及配置：请自行按SSD和SAS硬盘挂载好数据盘

```
    # 安装包下载和部署请参考第一篇《EFK-1: 快速指南》

    cd /opt/software/

    tar -zxvf elasticsearch-7.3.2-linux-x86_64.tar.gz

    mv /opt/elasticsearch /opt/elasticsearch-SAS

    mv elasticsearch-7.3.2 /opt/

    mv /opt/elasticsearch-7.3.2 /opt/elasticsearch-SSD

    chown elasticsearch.elasticsearch /opt/elasticsearch-* -R

    rm -rf /data/SAS/*

    chown elasticsearch.elasticsearch /data/* -R

    mkdir -p /opt/logs/elasticsearch-SAS

    mkdir -p /opt/logs/elasticsearch-SSD

    chown elasticsearch.elasticsearch /opt/logs/* -R
```

```
# SAS实例/opt/elasticsearch-SAS/config/elasticsearch.yml配置
    cluster.name: my-application

    node.name: 192.168.1.53-SAS

    path.data: /data/SAS

    path.logs: /opt/logs/elasticsearch-SAS

    network.host: 192.168.1.53


    http.port: 9200

    transport.port: 9300

    # discovery.seed_hosts和cluster.initial_master_nodes 一定要带上端口号，不然会走http.port和transport.port端口

    discovery.seed_hosts: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    cluster.initial_master_nodes: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    node.master: false

    node.ingest: false

    node.data: true


    # 本机只允行启2个实例

    node.max_local_storage_nodes: 2

# SSD实例/opt/elasticsearch-SSD/config/elasticsearch.yml配置
    cluster.name: my-application

    node.name: 192.168.1.53-SSD

    path.data: /data/SSD

    path.logs: /opt/logs/elasticsearch-SSD

    network.host: 192.168.1.53


    http.port: 9201

    transport.port: 9301

    # discovery.seed_hosts和cluster.initial_master_nodes 一定要带上端口号，不然会走http.port和transport.port端口

    discovery.seed_hosts: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    cluster.initial_master_nodes: ["192.168.1.31:9300","192.168.1.32:9300","192.168.1.33:9300"]

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    node.master: false

    node.ingest: false

    node.data: true


    # 本机只允行启2个实例

    node.max_local_storage_nodes: 2
```
## SAS实例和SSD实例启动方式
```
    sudo -u elasticsearch /opt/elasticsearch-SAS/bin/elasticsearch

    sudo -u elasticsearch /opt/elasticsearch-SSD/bin/elasticsearch
```
## 确认SAS和SSD已启2实例
```
    curl "http://192.168.1.31:9200/_cat/nodes?v"
```

# 测试
## 将所有索引移到SSD硬盘上
```
    # 下面的参数会在后面的文章讲解，此处照抄即可

    curl -X PUT "192.168.1.31:9200/*/_settings?pretty" -H 'Content-Type: application/json' -d'

    {

      "index.routing.allocation.include._host_ip": "",

      "index.routing.allocation.include._host": "",

      "index.routing.allocation.include._name": "",

      "index.routing.allocation.include._ip": "",

      "index.routing.allocation.require._name": "*-SSD"

    }'
```
## 确认所有索引全在SSD硬盘上
```
    curl "http://192.168.1.31:9200/_cat/shards?h=n"
```
## 将nginx9月份的日志索引迁移到SAS硬盘上
```
    curl -X PUT "192.168.1.31:9200/nginx_*_2019.09/_settings?pretty" -H 'Content-Type: application/json' -d'
    {
      "index.routing.allocation.require._name": "*-SAS"
    }'
```
## 确认nginx9月份的日志索引迁移到SAS硬盘上
```
    curl "http://192.168.1.31:9200/_cat/shards"
```