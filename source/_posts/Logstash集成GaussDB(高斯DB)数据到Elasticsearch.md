---
title: Logstash集成GaussDB(高斯DB)数据到Elasticsearch
top: 
date: 
tags: 
- elk
- Logstash
- GaussDB
- Elasticsearch
categories: 
- elk
- Logstash
- GaussDB
- Elasticsearch
password: 
---
# GaussDB 简介
GaussDB 数据库分为 GaussDB T 和 GaussDB A，分别面向 OLTP 和 OLAP 的业务用户。
GaussDB T 数据库是华为公司全自研的分布式数据库，支持x86和华为鲲鹏硬件架构。基于创新性数据库内核，提供高并发事务实时处理能力、两地三中心金融级高可用能力和分布式高扩展能力。
GaussDB A 是一款具备分析及混合负载能力的分布式数据库，支持x86和华为鲲鹏硬件架构，支持行存储与列存储，提供PB级数据分析能力、多模分析能力和实时处理能力，用于数据仓库、数据集市、实时分析、实时决策和混合负载等场景，广泛应用于金融、政府、电信等行业核心系统。

# Logstash 的 jdbc input plugin
参考 Logstash的 Jdbc input plugin 的官方文档，该插件可以通过JDBC接口将任何数据库中的数据导入 Logstash。周期性加载或一次加载，每一行是一个 event，列转成 filed。我们先解读下文档里提到的重要配置项。
```
jdbc_driver_library：JDBC驱动包路径。
jdbc_driver_class：JDBC驱动程序类。
jdbc_connection_string：JDBC连接串。
jdbc_user：数据库用户名。
jdbc_password：数据库用户口令。
statement_filepath：SQL语句所在文件路径。
scheduler：调度计划。
```

<escape><!-- more --></escape>

以上参数已经支持了周期性加载或一次性加载。如果想按字段的自增列或时间戳来集成数据，还需要以下参数：
```
sql_last_value：这个参数内置在sql语句里。作为条件的变量值。
last_run_metadata_path：sql_last_value 上次运行值所在的文件路径。
use_column_value：设置为时true时，将定义的 tracking_column 值用作 :sql_last_value。默认false。
tracking_column：值设置为将被跟踪的列。
tracking_column_type：跟踪列的类型。目前仅支持数字和时间戳。
record_last_run：上次运行 sql_last_value 值是否保存到 last_run_metadata_path。默认true。
clean_run：是否应保留先前的运行状态。默认false。
```
另外如果想使用预编译语句，语句里用？作为占位符，再增加以下参数：
```
use_prepared_statements：设置为 true 时，启用预编译语句。
prepared_statement_name：预编译语句名称。
prepared_statement_bind_values：数组类型，存放绑定值。:sql_last_value 可以作为预定义参数。
```
参考：https://www.elastic.co/guide/en/logstash/7.5/plugins-inputs-jdbc.html

# 对接 GaussDB T 
按每分钟一次频率的周期性来加载 GaussDB T 的会话信息到 Elasticsearch 中，input 区域的配置如下：
```
input {
    jdbc {
      jdbc_connection_string => "jdbc:zenith:@vip:40000"
      jdbc_user => "omm"
      jdbc_password => "omm_password"
      jdbc_driver_library => "/opt/gs/com.huawei.gauss.jdbc.ZenithDriver-GaussDB_100_1.0.1.SPC2.B003.jar"
      jdbc_driver_class => "com.huawei.gauss.jdbc.ZenithDriver"
      statement_filepath => "/opt/statement_filepath/gs_100_session.sql"
      schedule => "*/1 * * * *"
    }
}
```
statement_filepath 路径文件里配置的sql如下：
```sql
select * from dv_sessions
```
启动 logstash，可以看到logstash 日志中显示有`select * from dv_sessions`的信息


# 对接 GaussDB A 

按字段的时间戳来增量加载数据，注意 GaussDB A 的驱动和 GaussDB T 是不同的。input 区域的配置如下：
```
input {
    jdbc {
      jdbc_connection_string => "jdbc:postgresql://vip:25308/postgres"
      jdbc_user => "monitor"
      jdbc_password => "monitor_password"
      jdbc_driver_library => "/opt/gsdriver/gsjdbc4.jar"
      jdbc_driver_class => "org.postgresql.Driver"
      statement_filepath => "/opt/statement_filepath/gauss_active_session.sql"
      schedule => "*/1 * * * *"
      record_last_run => "true"
      use_column_value => "true"
      tracking_column => "sample_time"
      tracking_column_type => "timestamp"
      clean_run => "false"
      last_run_metadata_path => "/opt/last_run_metadata_path/gauss_last_sample_time"
    }
}

```
statement_filepath 路径文件里配置的sql如下，注意里面的预定义变量 :sql_last_value。
```sql
select clustername,coorname,sample_time,datid,datname,pid,usesysid,usename,application_name,abbrev(client_addr) AS client_addr,client_hostname,client_port,backend_start,xact_start,query_start,state_change,waiting,enqueue,state,resource_pool,query_id,query from monitor.ash_pg_stat_activity_r where sample_time > :sql_last_value
```
last_run_metadata_path 路径下的文件内容：
```
--- 2020-02-05 12:10:00.000000000 +08:00
```
启动 logstash，可以看到 logstash 日志，注意 :sql_last_value的地方

# 数据 output 到 Elasticsearch
logstash 的 output 区域的配置如下：
```
output {       
    elasticsearch {
        hosts => ["https://vip:9200"] 
        index => "gauss_active_session-%{+YYYY.MM.dd}"
        document_type => "gauss_active_session"
        user => "elastic"
        password => "elastic_password"
        ssl => true
        cacert => "../es_client-ca.cer"
    }
}
```
登入 kibana 查看，按每分钟增量加载的会话表数据已经集成到了 elasticsearch，后续就可以开始做数据分析和可视化了。