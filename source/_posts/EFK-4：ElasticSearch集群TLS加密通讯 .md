---
title: EFK-4 ElasticSearch集群TLS加密通讯 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
转载自：https://mp.weixin.qq.com/s?__biz=MzUyNzk0NTI4MQ==&mid=2247483822&idx=1&sn=6813b22eb5bd3a727a56e0fb5ba3f7fb&chksm=fa769a80cd011396cb6717124ebb9fb17bbff2f9d1fbcae50578cb2959225055cce0268d3633&mpshare=1&scene=1&srcid=1205igKg8cJK4Owayo9UNt4Q&sharer_sharetime=1575553256278&sharer_shareid=6ec87ec9a11a0c18d61cde7663a9ef87#rd

基于TLS实现ElasticSearch集群加密通讯，为ES集群创建CA、CERT证书，实现ElasticSearch集群之间数据通过TLS进行双向加密交互。

<escape><!-- more --></escape>

![](/elk/elk4.png)

# Step1. 关闭服务
首先，需要停止所有ElasticSearch、kibana、filebeat服务，待证书配置完成后再启动

# Step2. 创建CA证书
找任一一台ElasticSearch节点服务器操作即可
```
cd /opt/elasticsearch/
# --days: 表示有效期多久
sudo -u elasticsearch ./bin/elasticsearch-certutil ca --days 3660

```
务必将生成的CA证书，传到安全地方永久存储，因为后期若需要新增ES节点，还会用到该证书
请将elastic-stack-ca.p12证书传到所有ES实例服务器上

# Step3. 创建CERT证书
按上面表格进入相对应的目录创建CERT证书
```
# 在ES目录中建立证书目录及给予elasticsearch权限
mkdir -p config/certs;chown elasticsearch.elasticsearch config/certs -R

# 每一个实例一个证书
# --ca CA证书的文件名，必选参数
# --dns 服务器名，多服务器名用逗号隔开，可选参数
# --ip 服务器IP，多IP用逗号隔开，可选参数
# --out 输出到哪里，可选参数
# --days 有效期多久，可选参数
sudo -u elasticsearch ./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --ip ${本机IP},127.0.0.1 --out config/certs/cert.p12 --days 3660
# 例如elasticsearch-master-1（192.168.1.31）执行命令：sudo -u elasticsearch ./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --ip 192.168.1.31,127.0.0.1 --out config/certs/cert.p12 --days 3660
```
如果想批量生成CERT证书，请自行查阅附录链接，不过批量生成有时会碰到生成的证书不可用，因此建议一台一台生成

# Step4. 创建密钥库
按上面表格进入相对应的目录创建密钥库
```
# 每一个实例都要操作
# 创建密钥库
sudo -u elasticsearch ./bin/elasticsearch-keystore create
# PKCS＃12文件的密码
sudo -u elasticsearch ./bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
# 信任库的密码
sudo -u elasticsearch ./bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```
确认keystore、truststore已录入至密钥库
```
sudo -u elasticsearch ./bin/elasticsearch-keystore list
```

# Step5. 删除CA证书
由于上面创建的elastic-stack-ca.p12含有私钥，因此为了安全，建议将该文件删除（请务必提前备份好，因为后期增加节点还会用到）
按上面表格进入相对应的目录删除CA证书
```
rm -f elastic-stack-ca.p12
```

# Step6. 修改elasticsearch.yml配置
按上面表格对应的实例配置conf目录下elasticsearch.yml
```
# 在所有实例上加上以下配置
# 开启transport.ssl认证
xpack.security.transport.ssl.enabled: true
# xpack认证方式 full为主机或IP认证及证书认证，certificates为证书认证，不对主机和IP认证，默认为full
xpack.security.transport.ssl.verification_mode: full
# xpack包含私钥和证书的PKCS＃12文件的路径
xpack.security.transport.ssl.keystore.path: certs/cert.p12
# xpack包含要信任的证书的PKCS＃12文件的路径
xpack.security.transport.ssl.truststore.path: certs/cert.p12
```

# Step7. 启动服务
```
# 开启所有ES实例
sudo -u elasticsearch ./bin/elasticsearch

# 开启filebeat
/opt/filebeat/filebeat -e -c /opt/filebeat/filebeat.yml -d "publish"

# 开启kibana
sudo -u kibana /opt/kibana/bin/kibana -c /opt/kibana/config/kibana.yml
```

# 附. 参考文档
```
https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-tls.html
https://www.elastic.co/guide/en/elasticsearch/reference/7.3/certutil.html
```