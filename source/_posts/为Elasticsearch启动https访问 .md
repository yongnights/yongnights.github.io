---
title: 为Elasticsearch启动https访问 
top: 
date: 
tags: 
- elk
- Elasticsearch
categories: 
- elk
- Elasticsearch
password: 
---

# 导语
介绍如何使我们的 Elasticsearch 启动 https 服务。这个在很多的场合是非常有用的。特别是在 Elastic SIEM 的安全领域，我们需要把 Elasticsearch 的访问变为https的访问，这样使得我们的数据更加安全可靠。

# 安装Elastic Stack

安装Elasticsearch 及 Kibana。等我们安装好Elasticsearch和Kibana后，我们可以分别在 localhost:9200 及 localhost:5601 看到我们想要的输出

# 为Elasticsearch启动安全
设置 Elastic 账户安全”为我们的 Elasticsearch 设置安全。我们可以不创建新的用户，只使用默认的 super 用户 elastic。

# 生产p12证书
在 Elasticsearch 的安装目录下，使用如下的命令：

<escape><!-- more --></escape>

```
./bin/elasticsearch-certutil ca
```
```
$ pwd
/Users/liuxg/elastic9/elasticsearch-7.6.0
liuxg:elasticsearch-7.6.0 liuxg$ ./bin/elasticsearch-certutil ca
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.bouncycastle.jcajce.provider.drbg.DRBG (file:/Users/liuxg/elastic9/elasticsearch-7.6.0/lib/tools/security-cli/bcprov-jdk15on-1.61.jar) to constructor sun.security.provider.Sun()
WARNING: Please consider reporting this to the maintainers of org.bouncycastle.jcajce.provider.drbg.DRBG
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
This tool assists you in the generation of X.509 certificates and certificate
signing requests for use with SSL/TLS in the Elastic stack.


The 'ca' mode generates a new 'certificate authority'
This will create a new X.509 certificate and private key that can be used
to sign certificate when running in 'cert' mode.


Use the 'ca-dn' option if you wish to configure the 'distinguished name'
of the certificate authority


By default the 'ca' mode produces a single PKCS#12 output file which holds:
    * The CA certificate
    * The CA's private key


If you elect to generate PEM format certificates (the -pem option), then the output will
be a zip file containing individual files for the CA certificate and private key


Please enter the desired output file [elastic-stack-ca.p12]: 
Enter password for elastic-stack-ca.p12 :
```
在上面我们接受缺省的文件名，并输入一个自己熟悉的密码（针对我的情况，我接受空）。我们在 Elasticsearch 的安装目录下，我们可以看见一个生产的证书文件：
```
$ ls
LICENSE.txt          config               lib
NOTICE.txt           data                 logs
README.asciidoc      elastic-stack-ca.p12 modules
bin                  jdk.app              plugins
```
我们接着运行如下的命令来生成一个证书：
```
bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
```
上面的命令将使用我们的 CA 来生成一个证书 elastic-certificates.p12:
```
$ pwd
/Users/liuxg/elastic9/elasticsearch-7.6.0
liuxg:elasticsearch-7.6.0 liuxg$ ls
LICENSE.txt              data                     logs
NOTICE.txt               elastic-certificates.p12 modules
README.asciidoc          elastic-stack-ca.p12     plugins
bin                      jdk.app
config                   lib
```
我们把上面的 elastic-certificates.p12 证书拷入到 Elasticsearch 安装目录下的 config 子目录。
```
$ pwd
/Users/liuxg/elastic9/elasticsearch-7.6.0
liuxg:elasticsearch-7.6.0 liuxg$ ls config/
elastic-certificates.p12 jvm.options              roles.yml
elasticsearch.keystore   log4j2.properties        users
elasticsearch.yml        role_mapping.yml         users_roles
```
我们使用如下的命令：
```
openssl pkcs12 -in elastic-stack-ca.p12 -out newfile.crt.pem -clcerts -nokeys
```
它将生成一个叫做 newfile.crt.pem 的文件。我们把这个文件拷入到 Kibana 安装目录下的 config 子目录中：
```
$ pwd
/Users/liuxg/elastic9/kibana-7.6.0-darwin-x86_64
liuxg:kibana-7.6.0-darwin-x86_64 liuxg$ ls config/
apm.js                   kibana.yml
elastic-certificates.p12 newfile.crt.pem
```
# 配置Elasticsearch
接下来配置在 Elasticsearch 中的config/elasticsearch.yml。我们参照 Elastic 官方文档“Encrypting communication in Elasticsearch”，我们添加如下的配置：
```
xpack.security.transport.ssl.enabled: true
xpack.security.http.ssl.enabled: true
xpack.security.authc.api_key.enabled: true
xpack.security.http.ssl.keystore.path: /Users/liuxg/elastic9/elasticsearch-7.6.0/config/elastic-certificates.p12
xpack.security.http.ssl.truststore.path: /Users/liuxg/elastic9/elasticsearch-7.6.0/config/elastic-certificates.p12
```

重新启动 Elasticsearch：
```
./bin/elasticsearch
```
这样我们的 Elasticsearch 已经成功地运行于 https 模式。我们在 chrome 中打入地址 https://localhost:9200,输入之前在创建安全账号时的用户名 elastic及密码，那么我们就可以访问 Elasticsearch：

如果我们使用 Postman，我们可以通过在 “Settings” 里做如下的配置来避免证书的检查：
"File","Settings","SSL certificate verification",关掉上面的 SSL certificate verification 开关
经过上面的设置后，我们可以在 Postman 中访问具有 https 的Elasticsearch。

# 配置Kibana

为了能够使我们的 Kibana 能够顺利地访问带有 https 的Elasticsearch。我们也需要做相应的配置。我们打开 config/kibana.yml。添加如下的设置：
```
elasticsearch.hosts: ["https://localhost:9200"]
elasticsearch.ssl.certificateAuthorities: ["/Users/liuxg/elastic9/kibana-7.6.0-darwin-x86_64/config/newfile.crt.pem"]
elasticsearch.ssl.verificationMode: none
```
在上面我们把之前生成的newfile.crt.pem的证书填入到上面的路径中，同时为了我们能够方便地访问，我们针对kibana不启用verificationMode。

等我们配置完后，我们重新启动 kibana,输入 elastic 用户的密码，我们就可以进入到 Kibana 的界面中

# 把Beats数据传入到https的Elasticsearch中
在导入数据时，我们必须把证书配置到 beats 的配置文件中。我们就以 filebeat 为例。我们在Elasticsearch 的安装目录中，打入如下的命令：
```
bin/elasticsearch-certutil cert --pem elastic-stack-ca.p12
```
上面的命令将会生成一个叫做“certificate-bundle.zip”的文件。
```
$ pwd
/Users/liuxg/elastic9/elasticsearch-7.6.0
liuxg:elasticsearch-7.6.0 liuxg$ ls
LICENSE.txt            certificate-bundle.zip lib
NOTICE.txt             config                 logs
README.asciidoc        data                   modules
bin                    jdk.app                plugins
```
我们可以把这个文件的一个进行解压，并把里面的 ca.crt 解压到 filebeat 的安装子目录中。

## 方法一
打开 filebeat 的配置文件 filebeat.yml，并添加证书信息：
```
# filebeat.yml

output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["localhost:9200"]


  # Protocol - either `http` (default) or `https`.
  protocol: "https"


  # Authentication credentials - either API key or username/password.
  #api_key: "id:api_key"
  username: "elastic"
  password: "123456"
  ssl.certificate_authorities: ["/Users/liuxg/elastic9/filebeat-7.6.0-darwin-x86_64/ca.crt"]
  ssl.verification_mode: none
```

在上面，你需要填入自己的 username 及 password，同时也需要把上面的路径换成自己的证书路径。

## 方法二
也可以用如下的命令来生产自己的证书。我们在 Elasticsearch 的安装目录下，在已经生成上面的 elastic-stack-ca.p12 前提下，运行如下的命令：
```
openssl pkcs12 -in elastic-stack-ca.p12 -out newfile.crt.pem -clcerts -nokeys
```
上面的命令将生成一个叫做 newfile.crt.pem 的文件。我们把这个文件拷贝到filebeat的安装目录下，并修改我们的 filebeat.yml 如下：
```
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["localhost:9200"]


  # Protocol - either `http` (default) or `https`.
  protocol: "https"


  # Authentication credentials - either API key or username/password.
  #api_key: "id:api_key"
  username: "elastic"
  password: "123456"
  ssl.certificate_authorities: ["/Users/liuxg/elastic9/filebeat-7.6.0-darwin-x86_64/newfile.crt.pem"]
  ssl.verification_mode: none
```

# 运行Filebeat
修改完上面的配置后，我们启动 system 模块：
```
./filebeat modules enable system
./filebeat setup
$ ./filebeat setup
Overwriting ILM policy is disabled. Set `setup.ilm.overwrite:true` for enabling.


Index setup finished.
Loading dashboards (Kibana must be running and reachable)
Loaded dashboards
Setting up ML using setup --machine-learning is going to be removed in 8.0.0. Please use the ML app instead.
See more: https://www.elastic.co/guide/en/elastic-stack-overview/current/xpack-ml.html
Loaded machine learning job configurations
Loaded Ingest pipelines
```
可以通过如下的命令来运行 filebeat:
```
./filebeat -e
```
打开 Kibana,点击上面的[Filebeat System] Syslog dashboard ECS,可以看到 filebeat 的数据成功地传入到 Elasticsearch中了。

转载自：https://mp.weixin.qq.com/s/uy-LvGlttnNxXA2jNEuCwQ

