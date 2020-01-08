---
title: ES配置生成SSL使用的证书
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
```
cd /usr/local/elasticsearch/bin/
./elasticsearch-certgen
 
 #####################################
 Please enter the desired output file [certificate-bundle.zip]: cert.zip  （生成的压缩包名称，输入或者保持默认，直接回车）
 Enter instance name: my-application (实例名)
 Enter name for directories and files [my-application]: elasticsearch（存储实例证书的文件夹名，可以随意指定或保持默认）
 Enter IP Addresses for instance (comma-separated if more than one) []: 127.0.0.1(实例ip，多个ip用逗号隔开)
 Enter DNS names for instance (comma-separated if more than one) []: node-1（节点名，多个节点用逗号隔开）
 Would you like to specify another instance? Press 'y' to continue entering instance information: (到达这一步,不需要按y重新设置,按空格键就完成了)
 Certificates written to /usr/local/elasticsearch/bin/cert.zip（这个是生成的文件存放地址，不用填写）

```

<escape><!-- more --></escape>

解压cert.zip文件会得到
```
   creating: ca/
  inflating: ca/ca.crt               
  inflating: ca/ca.key               
   creating: my-applicaiton/
  inflating: my-applicaiton/my-applicaiton.crt  
  inflating: my-applicaiton/my-applicaiton.key 
```

es配置文件中使用如下：
```
xpack.security.transport.ssl.enabled: true
xpack.ssl.key: my-applicaiton.key
xpack.ssl.certificate: my-applicaiton.crt
xpack.ssl.certificate_authorities: ca.crt

```