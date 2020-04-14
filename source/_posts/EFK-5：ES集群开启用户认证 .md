---
title: EFK-5 ES集群开启用户认证 
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---

转载自:
https://mp.weixin.qq.com/s?__biz=MzUyNzk0NTI4MQ==&mid=2247483826&idx=1&sn=583e9a526050682ae060f601eced917b&chksm=fa769a9ccd01138a8740171769d1149a5df706ab3523eb0cbb5697293bda6e46954641d49f99&mpshare=1&scene=1&srcid=01245nkmqHupjQF7csKql1i5&sharer_sharetime=1579865464558&sharer_shareid=6ec87ec9a11a0c18d61cde7663a9ef87#rd

基于ES内置及自定义用户实现kibana和filebeat的认证

<escape><!-- more --></escape>

![](/elk/elk5.png)

# 关闭服务
先关闭所有ElasticSearch、kibana、filebeat进程

# elasticsearch-修改elasticsearch.yml配置
按以上表格对应的实例新增conf目录下elasticsearch.yml配置参数
```
    # 在所有实例上加上以下配置

    # 开启本地用户

    xpack.security.enabled: true

    # xpack的版本

    xpack.license.self_generated.type: basic
```
# elasticsearch-开启服务
开启所有ES服务
```
    sudo -u elasticsearch ./bin/elasticsearch
```
# elasticsearch-建立本地内置用户
本地内置elastic、apmsystem、kibana、logstashsystem、beatssystem、remotemonitoring_user用户
```
    # 在其中一台master节点操作

    # interactive 自定密码 auto自动生密码

    sudo -u elasticsearch ./bin/elasticsearch-setup-passwords interactive

    # 输入elastic密码

    # 输入apm_system密码

    # 输入kibana密码

    # 输入logstash_system密码

    # 输入beats_system密码

    # 输入remote_monitoring_user密码
```
## 测试内部用户
通过base64将elastic用户进行加密，格式为“elastic:elastic的密码“
```
    # 例如以下格式

    curl -H "Authorization: Basic ZWxhc3RpYzplbGFzdGkxMjM0NTY3OA==" "http://192.168.1.31:9200/_cat/nodes?v"
```
如果不通过Basic访问或base64加密错误会报以下错误:
"status": 401

# kibana-创建私钥库
## 在192.168.1.21创建私钥库
```
    cd /opt/kibana/

    # 创建密钥库

    sudo -u kibana ./bin/kibana-keystore create

    # 连接ES用户名，这里输入kibana

    sudo -u kibana ./bin/kibana-keystore add elasticsearch.username

    # 连接ES密码，这里输入刚刚设置kibana的密码

    sudo -u kibana ./bin/kibana-keystore add elasticsearch.password
```
## 在192.168.1.21确认私钥库
```
    sudo -u kibana ./bin/kibana-keystore list
```
## 启动服务
```
    sudo -u kibana /opt/kibana/bin/kibana -c /opt/kibana/config/kibana.yml
```

# filebeat-服务器上创建密钥库
## 在192.168.1.11创建filebeat密钥库
```
    cd /opt/filebeat/

    #创建密钥库

    ./filebeat keystore create

    #创建test-filebeat用户私钥

    ./filebeat keystore add test-filebeat
```
## 确认filebeat密钥库
```
    ./filebeat keystore list
```
# filebeat-配置filebeat.yml
## 配置filebeat.yml
```
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

          type: nginx_access # 类型是nginx_access,和上面fields.type是一致的


    # 输出至elasticsearch

    output.elasticsearch:

      # 连接ES集群的用户名

      username: test-filebeat

      # 连接ES集群的密码

      password: "${test-filebeat密码}"

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

## 启动filebeat
```
    /opt/filebeat/filebeat -e -c /opt/filebeat/filebeat.yml -d "publish"
```
# 测试
## 写入一条数据
```
    curl -I "http://192.168.1.11"
```
## 在kibana中查看

# 附录
## kibana角色权限相关文档链接
```
    https://www.elastic.co/guide/en/elasticsearch/reference/7.3/security-privileges.html#privileges-list-cluster
```
## base64加密解密网站链接
https://tool.oschina.net/encrypt?type=3
