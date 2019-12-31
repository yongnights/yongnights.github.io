---
title: elastic stack 7.2技术栈【八】Filebeat与Logstash两个工具之间怎样配置SSL加密通信
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在目前比较流行的技术实践方案里，Filebeat大多用作日志采集工具，虽然它可以直接将数据写入Elasticsearch中，但出于各方面的效率考虑，一般都会通过Logstash做一个日志数据的汇聚、转换和分发处理。
为了保证应用日志数据的传输安全，我们可以使用SSL相互身份验证来保护Filebeat和Logstash之间的连接。 这可以确保Filebeat仅将加密数据发送到受信任的Logstash服务器，并确保Logstash服务器仅从受信任的Filebeat客户端接收数据。
下面就讲述一下配置Filebeat与Logstash之间进行加密通信的方法。全文是在CentOS7上基于Elastic 7.2技术栈所验证的。

我们需要一个自签的CA证书，以及使用该CA证书签署的两份数据证书。一份是给Logstash作为server端验证自己身份时使用，一份是提供给Filebeat客户端验证自己身份使用。

在这里，我们是直接利用的Elasticsearch随安装包提供的数字证书工具elasticsearch-certutil来制作需要的证书。如果您需要对该工具做更多的了解，参考官网的这个资料：elasticsearch-certutil

## 制作自签的CA证书
在Linux下，进入到Elasticsearch程序的部署家目录中，执行以下命令可以生成一份自签的CA证书：
```
./bin/elasticsearch-certutil ca
```
使用默认输出文件名elastic-stack-ca.p12，并为证书设置访问口令。
根据证书文件导出一份CA公钥文件，用于后续各应用配置文件中引用CA公钥时使用：
```
openssl pkcs12 -clcerts -nokeys -in elastic-stack-ca.p12 -out cacert.pem
```
## 制作Logstash使用的数字证书
Logstash服务在启用SSL加密通信支持时，会有一个特殊的问题。因为Logstash在底层是通过集成了Netty来提供的对外服务端口，而Netty在支持数字证书这一功能上面，有一个局限性，即Netty仅支持使用PKCS#8的密钥格式。
对于我们使用最多的PEM格式证书，Logstash会毫不留情地打印出以下异常信息：
```
[2019-08-06T14:48:35,643][ERROR][logstash.inputs.beats    ] Looks like you either have a bad certificate, an invalid key or your private key was not in PKCS8 format.
[2019-08-06T14:48:35,643][WARN ][io.netty.channel.ChannelInitializer] Failed to initialize a channel. Closing: [id: 0x81e7ac55, L:/172.17.0.6:5044 - R:/100.200.106.60:32500]
java.lang.IllegalArgumentException: File does not contain valid private key: /data/logstash/config/certs/logstash.key
    at io.netty.handler.ssl.SslContextBuilder.keyManager(SslContextBuilder.java:270) ~[netty-all-4.1.30.Final.jar:4.1.30.Final]
    at io.netty.handler.ssl.SslContextBuilder.forServer(SslContextBuilder.java:90) ~[netty-all-4.1.30.Final.jar:4.1.30.Final]
    at org.logstash.netty.SslSimpleBuilder.build(SslSimpleBuilder.java:112) ~[logstash-input-beats-6.0.0.jar:?]
```
由于Elastic官网上对于Filebeat和Logstash之间配置SSL加密通信时的说明资料对制作Logstash使用的数字证书的操作一带而过，只是简单的说既可以使用elasticsearch自带的证书工具，也可以使用通用的openssl。所以，按照Elastic技术栈中处理其它工具配置SSL功能支持时的方法，制作和得到PEM格式的证书后，便会遇到Logstash抛出的上面的异常信息了。
由于Logstash打印的错误信息比较多，分析了很长时间才定位到是由于未使用PKCS8密钥格式所引发的。
有兴趣进一步了解Netty这方面配置特性的同学，可以参考这个链接：https://netty.io/wiki/sslcontextbuilder-and-private-key.html 。

<escape><!-- more --></escape>

## 制作Logstash Server证书的正确方法
```
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --name logstash --dns testserver --ip 172.17.0.6 --pem
unzip certificate-bundle.zip
cd logstash
openssl pkcs8 -in logstash.key -topk8 -nocrypt -out logstash.p8
```
经由命令1，我们使用自签的CA签署生成了一份名为logstash的数字证书；
得到的数字证书是pem格式的，解压后会各有一个.key和.crt后缀的文件；
命令3，使用openssl转换出一份PKCS#8格式的密钥文件，即logstash.p8；
对于我们制作的logstash.crt的证书，可以使用以下命令查看证书中的信息：
```
openssl x509 -in logstash.crt -text
```
## 将证书文件部署到Logstash配置目录下
假定我们部署Logstash的路径为/data/logstash ，我们创建下面这样的证书存放目录，并把包括logstash证书和ca证书在内的文件部署于此。
```
mkdir /data/logstash/config/certs

$ ls /data/logstash/config/certs
cacert.pem  logstash.crt  logstash.key  logstash.p8
```
安全起见，将以上文件权限调整为600 。
## 为Filebeat服务制作和配置数字证书
回到刚才我们制作CA证书的地方，继续为Filebeat生成一份数字证书：
```
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12 --name filebeat  --dns  test-filebeat --pem
```
在生成证书时至少需要提供–dns参数的值，可以使用逗号分隔指定多个，简单处理的话可以直接指定为Filebeat工具所在主机的hostname即可。
也可以使用–ip为证书绑定IP地址，或者二者同时使用。
最终会得到一个zip文件，内含PEM格式的证书与密钥文件。
请将得到的数字证书和密钥文件，以及ca证书文件，存放到Filebeat以下部署路径中：
```
mkdir /data/filebeat/certs

ls /data/filebeat/certs
filebeat.crt  filebeat.key  cacert.pem
```
安全起见，将以上文件权限调整为600 。
## 配置Filebeat使用SSL
编辑filebeat.yml文件，参照以下内容进行配置：
```
output.logstash:
  hosts: ["log.mytestserver.com:5044"]
  ssl.certificate_authorities: ["/data/filebeat/certs/cacert.pem"]
  ssl.certificate: "/data/filebeat/certs/filebeat.crt"
  ssl.key: "/data/filebeat/certs/filebeat.key"
```
## 配置Logstash在通过beats接收日志数据时使用SSL

```
input {
  beats {
    id => "logstash-1"
    port => 5044
    codec => plain {
      charset => "UTF-8"
    }
    ssl => true
    ssl_certificate_authorities => ["/data/logstash/config/certs/cacert.pem"]
    ssl_certificate => "/data/logstash/config/certs/logstash.crt"
    ssl_key => "/data/logstash/config/certs/logstash.p8"
    ssl_verify_mode => "force_peer"
  }
}
```
如上所示，在ssl_key参数中，引用的是我们制作的PCKS#8格式的密钥文件。
Logstash的filter和output插件配置不是本文的重点，这里直接省略掉了。
启动Filebeat服务并观察日志
观察日志输出，显示有类似以下信息时表示Filebeat正常连接到Logstash服务且SSL功能工作正常。
```
2019-08-06T16:29:08.745+0800	INFO	pipeline/output.go:95	Connecting to backoff(async(tcp://log.mytestserver.com:5044))
2019-08-06T16:29:08.992+0800	INFO	pipeline/output.go:105	Connection to backoff(async(tcp://log.mytestserver.com:5044)) established
```
参考材料：https://www.elastic.co/guide/en/beats/filebeat/7.2/configuring-ssl-logstash.html

