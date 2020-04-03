---
title: 使用 Auditbeat 模块监控 shell 命令
top: 
date: 
tags: 
- elk
- Auditbeat 
- shell
categories: 
- elk
- Auditbeat 
- shell
password: 
---
> 使用 Auditbeat 模块监控 shell 命令
> Auditbeat Audited 模块可以用来监控所有用户在系统上执行的 shell 命令。在终端用户偶尔才会登录的服务器上，通常需要进行监控。
> 该示例是在 CentOS Linux 7.6 上使用 Auditbeat 7.4.2 RPM 软件包和  Elasticsearch Service（ESS）[https://www.elastic.co/products/elasticsearch/service]上的 Elastic Stack ] 7.4.2 部署的。

*可以参考其中的思路，配置流程等，使用本机自建的ES，不使用Elasticsearch Service（ESS）集群*

# 禁用 Auditd
系统守护进程 auditd 会影响 Auditbeat Audited 模块的正常使用，所以必须将其禁用。
```
# 停止 auditd：
service auditd stop

# 禁用服务：
systemctl disable auditd.service
```
如果您在使用 Auditbeat Auditd 模块的同时也必须要运行 Audited 进程，那么在内核版本为 3.16 或者更高的情况下可以考虑设置 socket_type: multicast 参数。默认值为 unicast。有关此参数的更多信息，请参见文档[https://www.elastic.co/guide/en/beats/auditbeat/master/auditbeat-module-auditd.html#_configuration_options_14]的配置选项部分。

<escape><!-- more --></escape>

# 配置 Auditbeat
Auditbeat 守护进程将事件数据发送到一个 Elasticsearch Service（ESS）集群中。有关更多详细信息，请参见文档Auditbeat[https://www.elastic.co/guide/en/beats/auditbeat/master/configuring-howto-auditbeat.html] 
中的配置部分。
要想获取工作示例，必须配置 Auditbeat 的 cloud.id 和 cloud.auth 参数，详情参见此文档[https://www.elastic.co/guide/en/beats/auditbeat/master/configure-cloud-id.html]。
编辑 /etc/auditbeat/auditbeat.yml：
```
cloud.id: <your_cloud_id>
cloud.auth: ingest_user:password
```
如果您要将数据发送到 Elasticsearch 集群（例如本地实例），请参见此文档：[https://www.elastic.co/guide/en/beats/auditbeat/master/configure-cloud-id.html]。

# Auditbeat 模块规则
Audited 模块订阅内核以接收系统事件。定义规则以捕获这些事件，并且使用Linux Auditctl 进程所使用的格式，详情参见此文档：[https://linux.die.net/man/8/auditctl]。
```
# cat /etc/auditbeat/audit.rules.d/rules.conf
-a exit,always -F arch=b64 -F euid=0 -S execve -k root_acct
-a exit,always -F arch=b32 -F euid=0 -S execve -k root_acct
-a exit,always -F arch=b64 -F euid>=1000 -S execve -k user_acct
-a exit,always -F arch=b32 -F euid>=1000 -S execve -k user_acct
```
- euid 是用户的有效ID。0 代表会获取 root 用户和 uid >=1000 或者权限更高的其他用户的所有活动。
- -k <key> 用于为事件分配任意“键”，它将显示在 tags 字段中。它还可以在 Kibana 中用来对事件进行过滤和分类。

# Auditbeat 设置命令
运行Auditbeat 加载索引模板，读取 node pipelines，索引文件周期策略和Kibana 仪表板。
`auditbeat -e setup`
如果您不使用ESS，欢迎参考此文档[https://www.elastic.co/guide/en/beats/auditbeat/current/setup-kibana-endpoint.html] 来设置您的 Kibana 端点。

# 开始使用
```
systemctl start auditbeat

# 列出启用的规则：
auditbeat show auditd-rules
-a never,exit -S all -F pid=23617
-a always,exit -F arch=b64 -S execve -F euid=root -F key=root_acct
-a always,exit -F arch=b32 -S execve -F euid=root -F key=root_acct
-a always,exit -F arch=b64 -S execve -F euid>=vagrant -F key=user_acct
-a always,exit -F arch=b32 -S execve -F euid>=vagrant -F key=user_acct
```

# 监控数据
当用户执行一些类似于 whoami，ls 以及 lsblk 的 shell 命令时，kibana 中就会发现这些事件。
- Kibana 会显示出 user.name，process.executable，process.args 和 tags 这些选定的字段。
- 过滤的字段是 user.name: root 和 auditd.data.syscall: execve。
- 每秒刷新一次数据。

# TTY 审计
当系统中发生 TTY 事件时，Auditbeat Audited 模块也可以接收它们。配置system-auth PAM 配置文件以启用 TTY。只有 root 用户的 TTY 事件将被实时记录。其他用户的事件通常会被缓冲直到 exit。TTY 审计会捕获系统内置命令像pwd，test 等。
追加以下内容到 /etc/pam.d/system-auth 便可以对所有用户启用审核，关于 pam_tty_audit 的详细信息，参见此文档：[https://linux.die.net/man/8/pam_tty_audit]。
`session  required   pam_tty_audit.so enable=*`

# 测试
```
$ sudo su -
Last login: Fri Nov 22 23:43:00 UTC 2019 on pts/0
$ helllloooo there!
-bash: helllloooo: command not found
$ exit
```

# Kibana 发现

# 思考
Auditbeat 还可以做什么：
- 当一个文件在磁盘上更改（创建，更新或删除）时可以发送事件，得益于 file_integrity 模块，详情参考此文档：[https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-module-file_integrity.html]。
- 通过 system 模块发送有关系统的指标，详情参考此文档：[https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-module-system.html]。
该链接还提供了 Auditbeat 的相关文档，详情参考此文档：[https://www.elastic.co/guide/en/beats/auditbeat/current/index.html]。