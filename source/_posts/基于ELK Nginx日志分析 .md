---
title: 基于ELK Nginx日志分析 
top: 
date: 
tags: 
- elk
- nginx 
categories: 
- elk
- nginx 
password: 
---
# 配置Nginx 日志
Nginx 默认的access 日志为log格式，需要logstash 进行正则匹配和清洗处理，从而极大的增加了logstash的压力 所以我们Nginx 的日志修改为json 格式 。
Nginx access 日志和 Nginx error  日志
```
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format  json  '{"@timestamp":"$time_iso8601",'
                      '"server_addr":"$server_addr",'
                      '"hostname":"$hostname",'
                      '"remote_add":"$remote_addr",'
                      '"request_method":"$request_method",'
                      '"scheme":"$scheme",'
                      '"server_name":"$server_name",'
                      '"http_referer":"$http_referer",'
                      '"request_uri":"$request_uri",'
                      '"args":"$args",'
                      '"body_bytes_sent":$body_bytes_sent,'
                      '"status": $status,'
                      '"request_time":$request_time,'
                      '"upstream_response_time":"$upstream_response_time",'
                      '"upstream_addr":"$upstream_addr",'
                      '"http_user_agent":"$http_user_agent",'
                      '"https":"$https"'
                      '}';
    access_log  /var/log/nginx/access.log json;
```

<escape><!-- more --></escape>

针对不同的虚拟主机配置Nginx日志
```
access_log  /var/log/nginx/80.access.log json;
error_log  /var/log/nginx/80.error.log error;
access_log  /var/log/nginx/8001.access.log json;
error_log  /var/log/nginx/8001.error.log error;
```

# Nginx error_log 类型
```
[ debug | info | notice | warn | error | crit ] 
```
例如：error_log  /var/log/nginx/8001.error.log  crit; 
解释：日志文件存储在/var/log/nginx/8001.error.log 文件中，错误类型为 crit ，也就是记录最少错误信息（debug最详细 crit最少）；

# filebeat 配置
针对*.access.log 和 *.error.log 的日志进行不同的标签封装
```
[root@elk-node1 nginx]# egrep -v "*#|^$" /etc/filebeat/filebeat.yml 
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.access.log
  tags: ["nginx.access"]
- type: log
  paths:
    - /var/log/nginx/*.error.log
  tags: ["nginx.error"]
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 3
setup.kibana:
output.logstash:
  hosts: ["192.168.99.186:6044"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
``` 
# logstash 配置
## 查看logstash 安装已经安装插件
```
/usr/share/logstash/bin/logstash-plugin list 
[root@elk-node2 ~]#/usr/share/logstash/bin/logstash-plugin list |grep geoip
logstash-filter-geoip
/usr/share/logstash/bin/logstash-plugin    install logstash-filter-geoip
```

## Nginx 日志清洗规则
```
[root@elk-node2 ~]# cat /etc/logstash/conf.d/nginx.conf 
input {
  beats {
    port => 6044
  }

}

filter {
    if "nginx.access" in [tags] {
        json {
            source => "message"
            remove_field => "message"
        }
        date {
            match => ["timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
        }
        useragent {
            target => "agent"
            source => "http_user_agent"
        }     
        geoip {
             #target => "geoip"
             source => "remote_add"
             fields => ["city_name", "country_code2", "country_name", "region_name","longitude","latitude","ip"]
             add_field => ["[geoip][coordinates]","%{[geoip][longitude]}"]
             add_field => ["[geoip][coordinates]","%{[geoip][latitude]}"]
        }
        mutate {
            convert => ["[geoip][coordinates]","float"] 
        }
    }
   else if "nginx.error" in [tags] {
        mutate {
            remove_field => ["@timestamp"]
        }
        grok {
            match => {"message" => "(?<datetime>%{YEAR}[./-]%{MONTHNUM}[./-]%{MONTHDAY}[- ]%{TIME}) \[%{LOGLEVEL:severity}\] %{POSINT:pid}#%{NUMBER}: %{GREEDYDATA:errormessage}(?:, client: (?<real_ip>%{IP}|%{HOSTNAME}))(?:, server: %{IPORHOST:domain}?)(?:, request: %{QS:request})?(?:, upstream: (?<upstream>\"%{URI}\"|%{QS}))?(?:, host: %{QS:request_host})?(?:, referrer: \"%{URI:referrer}\")?"}
        }   
        date {
            match => ["datetime", "yyyy/MM/dd HH:mm:ss"]
            target => "@timestamp"
        }
        mutate {
            remove_field => ["message"]
        }
   }
}

output{
    stdout{codec => rubydebug}
    
    if "nginx.access" in [tags]{
        elasticsearch{
            index => "logstash-nginx.access-%{+YYYY.MM.dd}"
            hosts => ["192.168.99.186:9200"]
        }
    }
    else if "nginx.error" in [tags]{
        elasticsearch {
            index => "nginx.error-%{+YYYY.MM.dd}"
            hosts => ["192.168.99.186:9200"]
        }
    }
}
```
注意：source 可以是任意处理后的字段，需要注意的是 IP 必须是公网 IP，否则logstash 的返回的geoip字段为空

## Logstash解析
Logstash 分为 Input、Output、Filter、Codec 等多种plugins。
- Input：数据的输入源也支持多种插件，如elk官网的beats、file、graphite、http、kafka、redis、exec等等。
- Output：数据的输出目的也支持多种插件，如本文的elasticsearch，当然这可能也是最常用的一种输出。以及exec、stdout终端、graphite、http、zabbix、nagios、redmine等等。
- Filter：使用过滤器根据日志事件的特征，对数据事件进行处理过滤后，在输出。支持grok、date、geoip、mutate、ruby、json、kv、csv、checksum、dns、drop、xml等等。
- Codec：编码插件，改变事件数据的表示方式，它可以作为对输入或输出运行该过滤。和其它产品结合，如rubydebug、graphite、fluent、nmap等等。

## 配置文件的含义
input
filebeat  传入

filter
grok：数据结构化转换工具
match：匹配条件格式
geoip：该过滤器从geoip中匹配ip字段，显示该ip的地理位置
source：ip来源字段　 
target：指定插入的logstash字段目标存储为geoip　 
add_field: 增加的字段，坐标经度　 
add_field: 增加的字段，坐标纬度
mutate：数据的修改、删除、类型转换　 
convert：将坐标转为float类型　 
replace：替换一个字段　 
remove_field：移除message 的内容，因为数据已经过滤了一份，这里不必在用到该字段了，不然会相当于存两份　 
date: 时间处理，该插件很实用，主要是用你日志文件中事件的事件来对timestamp进行转换　 
match：匹配到timestamp字段后，修改格式为`dd/MMM/yyyy:HH:mm:ss Z` 
mutate：数据修改　 
remove_field：移除timestamp字段。 

output
elasticsearch：输出到es中
host：es的主机ip＋端口或者es 的FQDN＋端口
index：为日志创建索引logstash-nginx-access-*，这里也就是kibana那里添加索引时的名称

# Kibana 配置
注意：默认配置中Kibana的访问日志会记录在/var/log/message 中，使用logging.quiet参数关闭日志
```
[root@elk-node1 nginx]# egrep -v "*#|^$" /etc/kibana/kibana.yml 
server.port: 5601
server.host: "192.168.99.185"
elasticsearch.hosts: ["http://192.168.99.185:9200"]
kibana.index: ".kibana"
logging.quiet: true
i18n.locale: "zh-CN"
tilemap.url: 'http://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}'
``` 
配置“tilemap.url:”参数使Kibana使用高德地图