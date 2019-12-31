---
title: elastic stack 7.2技术栈【三】部署单机版本的elasticsearch技术栈
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
## 在节点1上面安装单节点es
```
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.0-linux-x86_64.tar.gz
tar -xzvf elasticsearch-7.2.0-linux-x86_64.tar.gz
```
对elasticsearch.yml几个重要配置参数进行设置：
```
cluster.name: my-elastic
node.name: es-node1
# network.host: 10.20.0.11
bootstrap.memory_lock: true
```
- 暂不能启用network.host参数，否则会触发es的强调集群配置检查，因为es集群配置还不完整，所以这会导致启动失败
启动es服务：
```
cd elasticsearch-7.2.0
./bin/elasticsearch
```
检测下服务是否正常启动：
```
curl http://10.20.0.11:9200
```

<escape><!-- more --></escape>

## 在节点1上安装kibana
```
curl -L -O https://artifacts.elastic.co/downloads/kibana/kibana-7.2.0-linux-x86_64.tar.gz
tar xzvf kibana-7.2.0-linux-x86_64.tar.gz
cd kibana-7.2.0-linux-x86_64/
```
编辑config/kibana.yml文件：
```
elasticsearch.hosts: ["http://10.20.0.11:9200"]
server.host: "es-node1"
```
启动：
```
./bin/kibana
```
调整防火墙放行规则：
```
firewall-cmd --permanent --zone=public --add-port=5601/tcp
firewall-cmd --reload
```
检测服务是否正常启动：
```
curl http://10.20.0.11:5601
```
## 在节点1上安装Beats
Beats针对不同的使用场景，分别提供了不同的工具实现。这里我们使用Metricbeat对节点主机的系统进行监控。

Metricbeat提供预构建的模块，可以使用它们快速实施和部署系统监控解决方案。
```
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-linux-x86_64.tar.gz
tar xzvf metricbeat-7.2.0-linux-x86_64.tar.gz
```
在这里，我们将运行Metricbeat的system模块以从服务器上运行的操作系统和服务收集指标。system模块收集系统级指标，例如CPU使用率，内存，文件系统，磁盘IO和网络IO统计信息，以及系统上运行的每个进程的类似顶级的统计信息。
启用system模块：
```
./metricbeat modules enable system
```
初始化数据：
```
./metricbeat setup -e
```
如果前一步中kibana服务绑定的网卡变更为对外服务的网卡了，则在执行这个命令前请修改metricbeat.yml文件中kibana服务地址的定义。
启动Metricbeat服务：
```
./metricbeat -e
```
要看可视化系统指标，请打开浏览器并导航到Metricbeat系统概述仪表板：
http://10.20.0.11:5601/app/kibana#/dashboard/Metricbeat-system-overview-ecs

至此，单机版本的部署完成，在部署结果通过验收后，进入下一步骤，启用和配置出es安全管理功能。

