---
title: EFK-1：快速指南
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
转载自：https://mp.weixin.qq.com/s?__biz=MzUyNzk0NTI4MQ==&mid=2247483801&idx=1&sn=11fee5756c8770688238624802ac51ea&chksm=fa769ab7cd0113a1ad19241290abe374b857227eebe989b3ba6b671b1eca855d380b76eeedde&mpshare=1&scene=1&srcid=1125q5BPyFOD05H2trj4UdOf&sharer_sharetime=1574686325386&sharer_shareid=6ec87ec9a11a0c18d61cde7663a9ef87#

阐述了EFK的安装部署，其中ES的架构为三节点，即master、ingest、data角色同时部署在三台服务器上。

<escape><!-- more --></escape>

![](https://img2020.cnblogs.com/blog/794174/202004/794174-20200414130328058-246702048.png)

# elasticsearch安装：3台es均执行相同的安装步骤
```
    mkdir -p /opt/software && cd /opt/software

    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.3.2-linux-x86_64.tar.gz

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
# filebeat安装
```
    mkdir -p /opt/software && cd /opt/software

    wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.2-linux-x86_64.tar.gz

    mkdir -p /opt/logs/filebeat/

    tar -zxvf filebeat-7.3.2-linux-x86_64.tar.gz

    mv filebeat-7.3.2-linux-x86_64 /opt/filebeat
```
# kibana安装
```
    mkdir -p /opt/software && cd /opt/software

    wget https://artifacts.elastic.co/downloads/kibana/kibana-7.3.2-linux-x86_64.tar.gz

    tar -zxvf kibana-7.3.2-linux-x86_64.tar.gz

    mv kibana-7.3.2-linux-x86_64 /opt/kibana

    useradd kibana -d /opt/kibana -s /sbin/nologin

    chown kibana.kibana /opt/kibana -R
```
# nginx安装
```
    # 只在192.168.1.11安装

    yum install -y nginx

    /usr/sbin/nginx -c /etc/nginx/nginx.conf
```
# elasticsearch配置
```
# 192.168.1.31 /opt/elasticsearch/config/elasticsearch.yml
    # 集群名字

    cluster.name: my-application


    # 节点名字

    node.name: 192.168.1.31


    # 日志位置

    path.logs: /opt/logs/elasticsearch


    # 本节点访问IP

    network.host: 192.168.1.31


    # 本节点访问

    http.port: 9200


    # 节点运输端口

    transport.port: 9300


    # 集群中其他主机的列表

    discovery.seed_hosts: ["192.168.1.31", "192.168.1.32", "192.168.1.33"]


    # 首次启动全新的Elasticsearch集群时，在第一次选举中便对其票数进行计数的master节点的集合

    cluster.initial_master_nodes: ["192.168.1.31", "192.168.1.32", "192.168.1.33"]


    # 启用跨域资源共享

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 只要有2台数据或主节点已加入集群，就可以恢复

    gateway.recover_after_nodes: 2

# 192.168.1.32 /opt/elasticsearch/config/elasticsearch.yml
    # 集群名字

    cluster.name: my-application


    # 节点名字

    node.name: 192.168.1.32


    # 日志位置

    path.logs: /opt/logs/elasticsearch


    # 本节点访问IP

    network.host: 192.168.1.32


    # 本节点访问

    http.port: 9200


    # 节点运输端口

    transport.port: 9300


    # 集群中其他主机的列表

    discovery.seed_hosts: ["192.168.1.31", "192.168.1.32", "192.168.1.33"]


    # 首次启动全新的Elasticsearch集群时，在第一次选举中便对其票数进行计数的master节点的集合

    cluster.initial_master_nodes: ["192.168.1.31", "192.168.1.32", "192.168.1.33"]


    # 启用跨域资源共享

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 只要有2台数据或主节点已加入集群，就可以恢复

    gateway.recover_after_nodes: 2

# 192.168.1.33 /opt/elasticsearch/config/elasticsearch.yml
    # 集群名字

    cluster.name: my-application


    # 节点名字

    node.name: 192.168.1.33


    # 日志位置

    path.logs: /opt/logs/elasticsearch


    # 本节点访问IP

    network.host: 192.168.1.33


    # 本节点访问

    http.port: 9200


    # 节点运输端口

    transport.port: 9300


    # 集群中其他主机的列表

    discovery.seed_hosts: ["192.168.1.31", "192.168.1.32", "192.168.1.33"]


    # 首次启动全新的Elasticsearch集群时，在第一次选举中便对其票数进行计数的master节点的集合

    cluster.initial_master_nodes: ["192.168.1.31", "192.168.1.32", "192.168.1.33"]


    # 启用跨域资源共享

    http.cors.enabled: true

    http.cors.allow-origin: "*"


    # 只要有2台数据或主节点已加入集群，就可以恢复

    gateway.recover_after_nodes: 2
```
# filebeat配置
```
# 192.168.1.11 /opt/filebeat/filebeat.yml
    # 文件输入

    filebeat.inputs:

      # 文件输入类型

      - type: log

        # 开启加载

        enabled: true

        # 文件位置

        paths:

          - /var/log/nginx/access.log

        # 自定义参数

        fields:

          type: nginx_access  # 类型是nginx_access,和上面fields.type是一致的


    # 输出至elasticsearch

    output.elasticsearch:

      # elasticsearch集群

      hosts: ["http://192.168.1.31:9200",

              "http://192.168.1.32:9200",

              "http://192.168.1.33:9200"]


      # 索引配置

      indices:

        # 索引名

        - index: "nginx_access_%{+yyy.MM}"

          # 当类型是nginx_access时使用此索引

          when.equals:

            fields.type: "nginx_access"


    # 关闭自带模板

    setup.template.enabled: false


    # 开启日志记录

    logging.to_files: true

    # 日志等级

    logging.level: info

    # 日志文件

    logging.files:

      # 日志位置

      path: /opt/logs/filebeat/

      # 日志名字

      name: filebeat

      # 日志轮转期限，必须要2~1024

      keepfiles: 7

      # 日志轮转权限

      permissions: 0600
```
# kibana配置
```
# 192.168.1.21 /opt/kibana/config/kibana.yml
    # 本节点访问端口

    server.port: 5601


    # 本节点IP

    server.host: "192.168.1.21"


    # 本节点名字

    server.name: "192.168.1.21"


    # elasticsearch集群IP

    elasticsearch.hosts: ["http://192.168.1.31:9200",

                          "http://192.168.1.32:9200",

                          "http://192.168.1.33:9200"]
```
# 启动服务
```
    # elasticsearch启动（3台es均启动）

    sudo -u elasticsearch /opt/elasticsearch/bin/elasticsearch


    # filebeat启动

    /opt/filebeat/filebeat -e -c /opt/filebeat/filebeat.yml -d "publish"


    # kibana启动

    sudo -u kibana /opt/kibana/bin/kibana -c /opt/kibana/config/kibana.yml
```