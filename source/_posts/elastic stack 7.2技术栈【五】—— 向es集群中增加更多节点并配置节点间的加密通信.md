---
title: elastic stack 7.2技术栈【五】向es集群中增加更多节点并配置节点间的加密通信
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
本章节的配置内容，是建立在成功部署和配置了前面几个章节的基础之上。

## 制作数字证书
在一个安全的集群中，Elasticsearch节点在与其他节点通信时会使用证书来标识自己。
群集必须验证这些证书的真实性。 建议的方法是信任特定的证书颁发机构（CA）。 因此，当节点添加到群集时，需要他们使用由同一CA签名的证书。

制作ca证书：
```
./bin/elasticsearch-certutil ca
```
使用默认输出文件名elastic-stack-ca.p12，并为证书设置访问口令：my-elastic123。如果是你的生产集群，请注意做好证书和口令的保护。
创建一个目录用于存放证书：
```
cd ${ES_HOME}/config
mkdir certs
```
为节点1制作证书和密钥：
```
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --ip 10.20.0.11 --out config/certs/es-node1.p12
```
- 输入ca的口令，并为节点1的证书设置口令为：es-node123
- elasticsearch-certutil工具提供了更多复杂的证书管理功能，如果有使用需求可以参见：https://www.elastic.co/guide/en/elasticsearch/reference/7.2/certutil.html

<escape><!-- more --></escape>

## 配置集群节点间的加密通信
编辑elasticsearch.yml文件，修改以下参数。

1）禁用single-node discovery：
```
discovery.type: single-node
```
我们之前为了调试单节点的es功能而启用的这个参数，现在直接从配置文件中清除这一配置项，使用默认值即可。
2）设置这次启动中有资格成为master节点的主机列表：
```
cluster.initial_master_nodes: ["es-node1"]
```
因为此时我们还只有一个节点。如果是已经有多个具备master node资格的节点时，则这里需要把它们都维护在列表中。
这一参数仅在集群初次建立时有用。
3）为传输（节点间）通信启用传输层安全性（TLS / SSL）：
ES_PATH_CONF/elasticsearch.yml
```
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.keystore.path: certs/${node.name}.p12
xpack.security.transport.ssl.truststore.path: certs/${node.name}.p12
```
将PKCS＃12文件的密码存储在Elasticsearch密钥库中。
```
./bin/elasticsearch-keystore create
./bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
./bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```
- 如果elasticsearch keystore文件已经存在了，则可以跳过创建命令
- 系统将提示你提供为es-node1.p12文件创建的密码。 我们将此文件用于传输TLS密钥库和信任库，因此为这两个设置提供相同的密码。
```
[elastic@es-node1 elasticsearch-7.2.0]$ ./bin/elasticsearch-keystore list
keystore.seed
xpack.security.transport.ssl.keystore.secure_password
xpack.security.transport.ssl.truststore.secure_password
```
重新启动es服务：
```
./bin/elasticsearch
```
以及kibana服务：
```
./bin/kibana
```
## 向es集群中添加更多的节点
es可以使用的节点有很多类型，详见：https://www.elastic.co/guide/en/elasticsearch/reference/7.2/modules-node.html 。
我们在这里向集群中添加两个节点，每个节点都既作为master-eligible node（node.master: true），也作为data node（node.data： true）。

1）我们先配置好另外的两个主机节点

- 参照本文第一部分的内容对系统进行初始化配置；
- 参照本文第二部分，第1章节的内容部署elasticsearch程序，暂不启动es服务；
2）在节点1上为新增的两个节点制作证书
```
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --multiple
```
- 依次为es-node2, es-node3生成证书，得到名为certificate-bundle.zip的输出文件；
- 为简单起见，统一将两个新节点证书的密码也设置为和节点1相同的 es-node123 ；
- 将解压缩后得到证书文件，参照节点1的存放路径（/opt/elasticsearch-7.2.0/config/certs），分别部署到节点2和节点3上去。
3）编辑3个节点的ES_PATH_CONF/elasticsearch.yml文件

节点es-node1：
```
cluster.name: my-elastic
node.name: es-node1
bootstrap.memory_lock: true
network.host: 10.20.0.11
cluster.initial_master_nodes: ["es-node1","es-node2","es-node3"]
discovery.seed_hosts: ["10.20.0.11","10.20.0.12","10.20.0.13"]
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.keystore.path: certs/${node.name}.p12
xpack.security.transport.ssl.truststore.path: certs/${node.name}.p12
```
节点es-node2：
```
cluster.name: my-elastic
node.name: es-node2
bootstrap.memory_lock: true
network.host: 10.20.0.12
cluster.initial_master_nodes: ["es-node1","es-node2","es-node3"]
discovery.seed_hosts: ["10.20.0.11","10.20.0.12","10.20.0.13"]
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.keystore.path: certs/${node.name}.p12
xpack.security.transport.ssl.truststore.path: certs/${node.name}.p12
```
节点es-node3：
```
cluster.name: my-elastic
node.name: es-node3
bootstrap.memory_lock: true
network.host: 10.20.0.13
cluster.initial_master_nodes: ["es-node1","es-node2","es-node3"]
discovery.seed_hosts: ["10.20.0.11","10.20.0.12","10.20.0.13"]xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.keystore.path: certs/${node.name}.p12
xpack.security.transport.ssl.truststore.path: certs/${node.name}.p12
```
4）将两个新节点的PKCS#12 证书口令存储在Elasticsearch Keystore中
```
./bin/elasticsearch-keystore create
./bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
./bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```
根据提示，将节点证书的密码信息es-node123保存到es密钥库中
5）依次启动三个节点上的es服务
```
./bin/elasticsearch
```
注意观察日志输出
启动kibana，在dev tools中执行GET _cluster/health 查看集群健康状态。
![](https://img-blog.csdnimg.cn/20190716172517303.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhdGVybWVsb25iaWc=,size_16,color_FFFFFF,t_70)

执行 GET _cat/nodes?v 查看master node角色分布：
![](https://img-blog.csdnimg.cn/20190716172529482.png)


