---
title: elastic stack 7.2技术栈【六】启用Kibana中的安全性配置
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
本章节主要包括配置kibana的会话安全和加密通信两项内容。

## 配置xpack.security.encryptionKey属性
用于加密cookie中的凭据的任意字符串，长度不超过32个字符。 至关重要的是，这个密钥不会暴露给Kibana的用户。 默认情况下，会在内存中自动生成一个值。 如果使用该默认行为，则在Kibana重新启动时，所有会话都将失效。

设置会话超时时间为30min。

在kibana.yml配置文件中：
```
xpack.security.encryptionKey: "something_at_least_32_characters"
xpack.security.sessionTimeout: 1800000
```
配置kibana使用https访问es服务
在节点1上es家目录下，为kibana服务制作数字证书：
```
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --name es-node1 --ip 10.20.0.11 --pem
```
将得到的证书文件存放到kibana部署路径的配置文件目录下certs子目录中：
```
[elastic@es-node1 certs]$ pwd
/opt/kibana-7.2.0-linux-x86_64/config/certs
[elastic@es-node1 certs]$ ls
es-node1.crt  es-node1.key
```

<escape><!-- more --></escape>

## 在kibana.yml文件中为kibana配置ssl的相关参数
```
server.ssl.enabled: true
server.ssl.key: config/certs/es-node1.key
server.ssl.certificate: config/certs/es-node1.crt
```
此时，启动kibana服务，验证通过 https://10.20.0.11:5601 是否可以成功访问网站。
至此，我们在访问kibana服务时已经实现的加密通信。接下来，继续将kibana访问elasticsearch服务的过程切换到https加密通信。

## 配置kibana通过https访问elasticsearch
因为我们使用的是自签名证书，所以需要为kibana提供ca证书。
我们先在节点1上，将pkcs12格式的ca证书转换为kibana适用的pem格式，其中cacert.pem是证书公钥文件。
```
openssl pkcs12 -nocerts -nodes -in elastic-stack-ca.p12 -out private.pem
openssl pkcs12 -clcerts -nokeys -in elastic-stack-ca.p12 -out cacert.pem
```
在kibana.yml文件中配置elasticsearch.hosts参数，并指定ca证书文件位置：：
```
elasticsearch.hosts: ["https://10.20.0.11:9200"]
elasticsearch.ssl.certificateAuthorities: [ "config/certs/cacert.pem" ]
```
将Kibana配置为通过HTTPS连接到Elasticsearch监控集群，在这里我们使用的是同一个es集群：
```
xpack.monitoring.elasticsearch.hosts: ["https://10.20.0.11:9200"]
xpack.monitoring.elasticsearch.ssl.certificateAuthorities: config/certs/cacert.pem
```
配置三个节点上的elasticsearch服务，在elasticsearch.yml文件中补充以下http.ssl服务使用的配置参数：
```
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: certs/${node.name}.p12
xpack.security.http.ssl.truststore.path: certs/${node.name}.p12
```
将http.ssl访问证书时使用的密码信息存储在密钥库中：
```
bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password
bin/elasticsearch-keystore add xpack.security.http.ssl.truststore.secure_password
```
在前面章节中我们为节点证书设置的密码是：es-node123
三个es节点上均需要设置
重启服务进程并验证配置结果
重启三节点上的es服务进程：bin/elasticsearch
重启节点1上的kibana服务进程：bin/kibana
看到下面这样的日志输出时，可以确认配置成功了：
```
  log   [18:46:19.967] [info][listening] Server running at https://es-node1:5601
  log   [18:46:19.997] [info][status][plugin:spaces@7.2.0] Status changed from yellow to green - Read
```