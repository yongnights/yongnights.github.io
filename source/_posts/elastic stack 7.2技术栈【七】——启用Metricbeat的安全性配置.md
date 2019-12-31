---
title: elastic stack 7.2技术栈【七】启用Metricbeat的安全性配置
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
我们使用Metricbeat采集es主机节点的系统监控指标数据，以及监控es集群中索引等服务。

1. 对每个es服务节点编辑elasticsearch.yml，以启用监控数据采集
```
xpack.monitoring.collection.enabled: true
```
2. 在每个节点的metricbeat部署目录下，启用elasticsearch-xpack模块
```
./metricbeat modules enable elasticsearch-xpack
```

<escape><!-- more --></escape>

3. 进入elasticsearch部署目录，为每个节点上的Metricbeat制作一个数字证书
```
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --name es-node1 --ip 10.20.0.11 --pem
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --name es-node2 --ip 10.20.0.12 --pem
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --name es-node3 --ip 10.20.0.13 --pem
```
执行以上命令，将输出结果分别保存为es-node1.zip es-node2.zip es-node3.zip
将压缩包解压后的证书文件，分别部署到每个主机节点上Metricbeat下的certs子目录中，文件属主elastic.elastic，访问权限600
因为我们使用的是自签CA证书，所以还需要把CA证书公钥文件cacert.pem，同样在certs目录中放一份
4. 编辑modules.d/elasticsearch-xpack.yml文件
```
- module: elasticsearch
  metricsets:
    - ccr
    - cluster_stats
    - index
    - index_recovery
    - index_summary
    - ml_job
    - node_stats
    - shard
  period: 10s
  hosts: ["https://10.20.0.11:9200"]
  username: "remote_monitoring_user"
  password: "remote_monitoring_user123"
  ssl.certificate_authorities: ["certs/cacert.pem"]
  ssl.certificate: "certs/es-node1.crt"
  ssl.key: "certs/es-node1.key"
  xpack.enabled: true
```
这里使用了一个es提供的内建管理账号remote_monitoring_user
5. 编辑metricbeat.yml文件
在节点1上面：
```
setup.kibana:
  host: "https://es-node1:5601"
  username: "metricbeat_internal"
  password: "${ES_PWD}"

output.elasticsearch:
  hosts: ["10.20.0.11:9200"]
  protocol: "https"
  ssl.certificate_authorities: ["certs/cacert.pem"]
  username: "metricbeat_internal"
  password: "${ES_PWD}"
  ssl.certificate: "certs/es-node1.crt"
  ssl.key: "certs/es-node1.key"
```
在这里我们使用前面章节中创建的账号metricbeat_internal同时作为metricbeat访问kibana和elasticsearch时的授权账号；
需要注意的是，在启用了es安全特性后，metricbeat采集和向es索引写入监控指标数据时需要拥有适当的角色授权，请使用elastic账号登录kibana并为metricbeat_internal用户增加remote_monitoring_collector、remote_monitoring_agent两个角色的授权。
参照上面的说明，对节点2和节点3上的Metricbeat配置文件metricbeat.yml进行修改，注意要引用本节点的密钥文件名。
6. 启动Metricbeat服务
```
./metricbeat -e
```
确认日志输出中没有需要引起注意的warning或error信息
7. 登录kibana并查看Stack Monitor页面，如果能正常看到以下内容则表示监控数据采集和展示是正确的
![](https://img-blog.csdnimg.cn/20190716174016431.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhdGVybWVsb25iaWc=,size_16,color_FFFFFF,t_70)

