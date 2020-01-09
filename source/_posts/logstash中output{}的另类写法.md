---
title: logstash中output{}的另类写法
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
日志传输路径如下：
filebeat->redis->logstash->es

在filebeat配置文件中，收集日志的时候配置的有如下参数：
```
  fields:
    log_source: messages
```
表示的是会把log_source作为fields的二级字段

若是配置如下，表示的是会把log_source作为顶级字段：
```
  fields:
    log_source: messages
  fields_under_root: true
```

使用这个字段来作为区分不同应用日志的来源；

<escape><!-- more --></escape>

在logstash中从redis读取后，output给es的时候，根据上述不同的字段来创建不同的应用日志索引。
常见的写法是多使用if条件进行区分，如下所示：
```
  if [fields][log_source] == 'test_custom' {
    elasticsearch {
      hosts => ["http://172.17.107.187:9203", "http://172.17.107.187:9201","http://172.17.107.187:9202"]
      index => "filebeat_test_custom-%{+YYYY.MM.dd}"
      user => "elastic"
      password => "escluter123456"
    }
  }

  if [fields][log_source] == "test_user" {
    elasticsearch {
      hosts => ["http://172.17.107.187:9203","http://172.17.107.187:9201","http://172.17.107.187:9202"]
      index => "filebeat_test_user-%{+YYYY.MM.dd}"
      user => "elastic"
      password => "escluter123456"
    }
  }
```

这样写也能使用，但是考虑到假设这个区分字段比较多的话，那这得写多少个if条件呀，所以可以使用如下的用法：
在创建索引的时候使用上这个区分用的字段，具体如下：
```
elasticsearch {
    hosts => ["http://172.17.107.187:9203","http://172.17.107.187:9201","http://172.17.107.187:9202"]
    index => "filebeat_%{[fields][log_source]}-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "escluter123456"
}
```

说明：`%{[fields][log_source]}`表示的是获取区分字段的值

若是顶级字段则是这样的用法：`%{[log_source]}`