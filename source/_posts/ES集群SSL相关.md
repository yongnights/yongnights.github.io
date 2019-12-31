---
title: ES集群SSL相关
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
# 为您的每个Elasticsearch节点生成一个私钥和X.509证书
## 在Elasticsearch加密通讯
前提条件：确认xpack.security.enabled设置为true

### 生成节点证书
1. 为您的Elasticsearch集群创建一个证书颁发机构
`bin/elasticsearch-certutil ca`
您可以将群集配置为信任具有此CA签名的证书的所有节点。
该命令输出单个文件，默认名称为elastic-stack-ca.p12。此文件是PKCS＃12密钥库，其中包含CA的公共证书和用于对每个节点的证书签名的私钥。
该elasticsearch-certutil命令还会提示您输入密码以保护文件和密钥。如果您打算将来将更多节点添加到群集中，请保留该文件的副本并记住其密码。

2. 为集群中的每个节点生成证书和私钥
`bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12`
输出是单个PKCS＃12密钥库，其中包括节点证书，节点密钥和CA证书。
还提示您输入密码。您可以输入证书和密钥的密码，也可以按Enter键将密码保留为空白。
默认情况下，elasticsearch-certutil生成的证书中没有主机名信息（即，它们没有任何“使用者备用名称”字段）。这意味着您可以对群集中的每个节点使用证书，但是必须关闭主机名验证，如下面的配置所示。
如果你想用你的集群中的主机名的验证，运行 elasticsearch-certutil cert命令一次，每个节点和提供的--name，--dns和--ip选项。

<escape><!-- more --></escape>

3. 将节点证书复制到适当的位置
将适用的.p12文件复制到每个节点上的Elasticsearch配置目录内的目录中。例如，/home/es/config/certs。无需将CA文件复制到此目录。
对于要配置的每个其他Elastic产品，将证书复制到相关的配置目录。

### 加密集群中的节点之间的通信
启用TLS并指定访问节点证书所需的信息
1. 如果签名证书为PKCS＃12格式，则将以下信息添加到elasticsearch.yml每个节点上的 文件中：
```
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate 
xpack.security.transport.ssl.keystore.path: certs/elastic-certificates.p12 
xpack.security.transport.ssl.truststore.path: certs/elastic-certificates.p12 
```

- 如果在命令中使用--dns或--ip选项，elasticsearch-certutil cert并且要启用严格的主机名检查，请将验证模式设置为 full。有关xpack.security.transport.ssl.verification_mode这些值的描述，请参见。
- 如果为每个节点创建了单独的证书，则可能需要在每个节点上自定义此路径。如果文件名与节点名称匹配，则可以使用certs/${node.name}.p12例如格式。
- 所述elasticsearch-certutil输出PKCS＃12密钥库，其包括CA证书作为信任证书的条目。这允许密钥库也用作信任库。在这种情况下，路径值应与该keystore.path值匹配。但是请注意，这不是一般规则。有些密钥库不能用作信任库，只有经过特殊设计的密钥库才能使用

2. 如果证书为PEM格式，则将以下信息添加到elasticsearch.yml每个节点上的 文件中：
```
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate 
xpack.security.transport.ssl.key: /home/es/config/node01.key 
xpack.security.transport.ssl.certificate: /home/es/config/node01.crt 
xpack.security.transport.ssl.certificate_authorities: [ "/home/es/config/ca.crt" ]
```

- 如果在命令中使用--dns或--ip选项，elasticsearch-certutil cert并且要启用严格的主机名检查，请将验证模式设置为 full。有关xpack.security.transport.ssl.verification_mode这些值的描述，请参见。
- 节点密钥文件的完整路径。该位置必须在Elasticsearch配置目录中。
- 节点证书的完整路径。该位置必须在Elasticsearch配置目录中。
- 应当信任的CA证书路径的数组。这些路径必须是Elasticsearch配置目录中的位置。

3. 如果您使用密码保护了节点证书的安全，请将密码添加到您的Elasticsearch密钥库中：
3.1 如果签名证书为PKCS＃12格式，请使用以下命令：
```
bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```

3.2 如果证书为PEM格式，请使用以下命令：
```
bin/elasticsearch-keystore add xpack.security.transport.ssl.secure_key_passphrase
```

4. 重新启动Elasticsearch
您必须执行完全集群重启。配置为使用TLS的节点无法与使用未加密网络的节点通信（反之亦然）。启用TLS之后，您必须重新启动所有节点，以维护整个群集之间的通信。

> Elasticsearch监视配置为TLS相关节点设置值的所有文件，例如证书，密钥，密钥库或信任库。如果您更新了这些文件中的任何一个（例如，当您的主机名更改或您的证书到期时），Elasticsearch将重新加载它们。以全局Elasticsearch resource.reload.interval.high 设置（默认为5秒）确定的频率轮询文件是否有更改

### 加密HTTP客户端通信
启用TLS并指定访问节点证书所需的信息
1. 如果证书采用PKCS＃12格式，则将以下信息添加到elasticsearch.yml每个节点上的 文件中：
```
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: certs/elastic-certificates.p12 
xpack.security.http.ssl.truststore.path: certs/elastic-certificates.p12 
```

- 如果为每个节点创建了单独的证书，则可能需要在每个节点上自定义此路径。如果文件名与节点名称匹配，则可以使用certs/${node.name}.p12例如格式。
- 该elasticsearch-certutil输出包括PKCS＃12密钥库内部的CA证书，因此密钥库也可以被用作信任库。此名称应与keystore.path值匹配。

2. 如果证书为PEM格式，则将以下信息添加到elasticsearch.yml每个节点上的 文件中：
```
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.key:  /home/es/config/node01.key 
xpack.security.http.ssl.certificate: /home/es/config/node01.crt 
xpack.security.http.ssl.certificate_authorities: [ "/home/es/config/ca.crt" ] 
```
	
- 节点密钥文件的完整路径。该位置必须在Elasticsearch配置目录中。
- 节点证书的完整路径。该位置必须在Elasticsearch配置目录中。
- 应当信任的CA证书路径的数组。这些路径必须是Elasticsearch配置目录中的位置。

3. 如果您使用密码保护了节点证书的安全，请将密码添加到您的Elasticsearch密钥库中：
3.1 如果签名证书为PKCS＃12格式，请使用以下命令：
```
bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password
bin/elasticsearch-keystore add xpack.security.http.ssl.truststore.secure_password
```

3.2 如果证书为PEM格式，请使用以下命令：
```
bin/elasticsearch-keystore add xpack.security.http.ssl.secure_key_passphrase

```

4. 重新启动Elasticsearch

> Elasticsearch监视配置为TLS相关节点设置值的所有文件，例如证书，密钥，密钥库或信任库。如果您更新了这些文件中的任何一个（例如，当您的主机名更改或您的证书到期时），Elasticsearch将重新加载它们。以全局Elasticsearch resource.reload.interval.high 设置（默认为5秒）确定的频率轮询文件是否有更改

## 配置监视功能以使用加密的连接
Elastic Stack监视功能由两个组件组成：您在每个Elasticsearch和Logstash节点上安装的代理，以及Kibana中的Monitoring UI。监视代理程序从节点收集指标并为其建立索引，您可以通过Kibana中的“监视”仪表板可视化数据。代理可以为同一Elasticsearch集群上的数据建立索引，或将其发送到外部监视集群。
要在启用安全性功能的情况下使用监视功能，您需要 设置Kibana以使用安全性功能， 并为监视UI创建至少一个用户。如果使用的是外部监视群集，则还需要为监视代理程序配置用户，并配置代理程序以在与监视群集通信时使用适当的凭据。

### 在Kibana配置安全
当集群上启用了X-Pack安全性时，Kibana用户必须登录。您可以为Kibana用户配置X-Pack安全角色，以控制这些用户可以访问哪些数据。

通过Kibana向Elasticsearch发出的大多数请求都使用登录用户的凭据进行身份验证。但是，Kibana服务器需要向Elasticsearch集群提出一些内部请求。因此，您必须为Kibana服务器配置凭据以用于那些请求。

启用X-Pack安全性后，如果加载Kibana仪表板来访问未经授权查看的索引中的数据，则会出现错误，指示该索引不存在。X-Pack安全性当前不提供控制哪些用户可以加载哪些仪表板的方法。

1. 在Elasticsearch配置安全
1.1 验证xpack.security.enabled设置是否true在群集中的每个节点上。如果您使用基本或试用许可证，则默认值为false。
1.2 配置用于节点间通信的传输层安全性（TLS / SSL）
1.3 设置所有内置用户的密码
Elasticsearch安全功能提供 内置用户来帮助您启动和运行。该elasticsearch-setup-passwords命令是首次设置内置用户密码的最简单方法。
```
bin/elasticsearch-setup-passwords interactive
```
> 该elasticsearch-setup-passwords命令使用瞬态引导密码，该密码在命令成功运行后将不再有效。您不能elasticsearch-setup-passwords再次运行该命令。相反，您可以从Kibana中的“ 管理”>“用户” UI 更新密码，或使用安全用户API。

2. 配置Kibana以使用适当的内置用户
更新kibana.yml配置文件中的以下设置：
```
elasticsearch.username: "kibana"
elasticsearch.password: "kibanapassword"
```
- Kibana服务器以该用户身份提交请求，以访问集群监视API和.kibana索引。该服务器并没有需要访问用户索引。
- 内置kibana用户的密码通常是在Elasticsearch上的X-Pack安全配置过程中设置的。

3. xpack.security.encryptionKey在kibana.yml 配置文件中设置属性。您可以使用32个字符或更长的任何文本字符串作为加密密钥。
```
xpack.security.encryptionKey: "something_at_least_32_characters"
```
4. 可选：更改默认会话持续时间。默认情况下，会话保持活动状态，直到关闭浏览器。要更改持续时间，请xpack.security.sessionTimeout在kibana.yml配置文件中设置 属性。超时以毫秒为单位。例如，将超时设置为600000以使会话在10分钟后过期：
```
xpack.security.sessionTimeout: 600000
```

5. 可选：配置Kibana以加密通信。
Kibana支持客户端请求的传输层安全性（TLS / SSL）加密。

如果您正在使用X-Pack安全性或为Elasticsearch提供HTTPS端点的代理，则可以配置Kibana通过HTTPS访问Elasticsearch。因此，Kibana和Elasticsearch之间的通信也被加密。

5.1 配置Kibana以加密浏览器和Kibana服务器之间的通信：
> 您无需为这种类型的加密启用X-Pack安全性。
为Kibana生成服务器证书。

a. 您必须将证书的 subjectAltName名称设置为Kibana服务器的主机名，标准域名（FQDN）或IP地址，或者将CN设置为Kibana服务器的主机名或FQDN。将服务器的IP地址用作CN无效。
b. 设置server.ssl.enabled，server.ssl.key以及server.ssl.certificate 在性能kibana.yml：
```
server.ssl.enabled: true
server.ssl.key: /path/to/your/server.key
server.ssl.certificate: /path/to/your/server.crt
```
- 进行这些更改之后，您必须始终通过HTTPS访问Kibana。例如， https：// localhost：5601。

5.2 配置Kibana以通过HTTPS连接到Elasticsearch
> 要执行此步骤，您必须 启用Elasticsearch安全功能，或者必须具有为Elasticsearch提供HTTPS端点的代理。

a. elasticsearch.hosts在Kibana配置文件的设置中指定HTTPS协议kibana.yml：
```
elasticsearch.hosts: ["https://<your_elasticsearch_host>.com:9200"]
```

b. 如果您使用自己的CA为Elasticsearch签名证书，请在中进行 elasticsearch.ssl.certificateAuthorities设置kibana.yml以指定PEM文件的位置。
```
elasticsearch.ssl.certificateAuthorities: /path/to/your/cacert.pem
```
设置certificateAuthorities属性可以使您使用默认 verificationMode选项full。

5.3 （可选）如果启用了弹性监视功能，请配置Kibana以通过HTTPS连接到Elasticsearch监视集群：
> 要执行此步骤，您必须启用Elasticsearch安全功能，或者必须具有为Elasticsearch提供HTTPS端点的代理。

a. xpack.monitoring.elasticsearch.hosts在Kibana配置文件的设置中指定HTTPS URL ，kibana.yml
```
xpack.monitoring.elasticsearch.hosts: ["https://<your_monitoring_cluster>:9200"]
```

b. `xpack.monitoring.elasticsearch.ssl.*`在kibana.yml文件中指定设置 。
例如，如果您使用自己的证书颁发机构来签署证书，请在文件中指定PEM文件的位置kibana.yml：
```
xpack.monitoring.elasticsearch.ssl.certificateAuthorities: /path/to/your/cacert.pem
```

6. 重新启动Kibana

7. 选择一种身份验证机制，并向用户授予使用Kibana所需的特权
可以在Kibana 的“ 管理/安全性/角色”页面上管理特权,授予用户访问将在Kibana中使用的索引的权限

### 在Elasticsearch中配置监视

### 在Kibana中配置监视

### 配置Logstash节点的监视

