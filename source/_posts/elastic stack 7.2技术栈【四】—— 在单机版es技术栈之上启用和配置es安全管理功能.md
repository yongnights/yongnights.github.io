---
title: elastic stack 7.2技术栈【四】在单机版es技术栈之上启用和配置es安全管理功能
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
Elasticsearch安全功能使得可以轻松保护群集。 可以对数据进行基础的密码保护，并实施更高级的安全措施，例如加密通信，基于角色的访问控制，IP过滤和审计。
在最新发行的es和kinaba版本中，basic级别的许可中已经开放了部分安全管理的功能特性，可以免费使用。详细信息参见：https://www.elastic.co/subscriptions

1. 依次停止Metricbeat、kibana和elasticsearch服务进程

2. 编辑ES_PATH_CONF/elasticsearch.yml文件，启用xpack服务
添加以下内容：
```
xpack.security.enabled: true
```
3. 编辑ES_PATH_CONF/elasticsearch.yml文件，启用 single-node discovery功能
```
discovery.type: single-node
```
通过将discovery.type设置为single-node， 在这种情况下，节点将选择自己作为主节点，并且不会加入任何其他节点的集群。

启用Elasticsearch安全功能后，默认情况下会启用基本身份验证。 要与群集通信，必须指定用户名和密码。 除非启用了匿名访问，否则所有不包含用户名和密码的请求都将被拒绝。

<escape><!-- more --></escape>

4. 为内置用户创建密码
有一些管理用途的集群内建用户，如apm_system, beats_system, elastic, kibana, logstash_system, and remote_monitoring_user，我们需要为其设置密码。
这些内建管理用户的说明信息参见： https://www.elastic.co/guide/en/elastic-stack-overview/7.2/built-in-users.html

启动es服务：
```
./bin/elasticsearch
```
执行下面命令设置内建管理用户的密码：
```
./bin/elasticsearch-setup-passwords interactive
```
这里设置的账号密码，在后续各种服务集成配置中会使用到，所以务必做好记录。该命令仅可以执行一次。
```
elastic/elastic123
apm_system/apm_system123
kibana/kibana123
logstash_system/logstash_system123
beats_system/beats_system123
remote_monitoring_user/remote_monitoring_user123
```
5. 账号与密码信息的管理
这里又有两种方式进行配置，一个是直接将账号/密码维护在配置文件中。另一个方法是，把账号/密码存储到keystore密钥库中。后一种的安全性更高些。
编辑 KIBANA_HOME/config/kibana.yml ：
```
elasticsearch.username: "kibana"
elasticsearch.password: "kibana123"
```
或者存储在keystore中：
```
# 放置历史操作记录被查看到
set +o history
export LOGSTASH_KEYSTORE_PASS=mypassword 
set -o history

./bin/kibana-keystore create
./bin/kibana-keystore add elasticsearch.username
./bin/kibana-keystore add elasticsearch.password
```
在提示输入时，根据提示输入kibana/kibana123的用户名和密码信息。该账号将被用于kibana访问es服务时使用。
启动kibana服务：
```
./bin/kibana
```
现在我们已经设置好了内置用户，需要决定如何管理所有其他用户。

Elastic Stack对用户进行身份验证以确保它们有效。 身份验证过程由realm进行处理。 可以使用一个或多个内置realm，例如native，file，LDAP，PKI，Active Directory，SAML或Kerberos realm。 也可以创建自己的自定义realm。 在本教程中，我们将使用本机native realm，这也是basic许可所允许免费使用的用户身份验证方式之一。

通常，可以通过在elasticsearch.yml文件中添加xpack.security.authc.realm设置来配置realm。 但是，如果未配置其他域，则默认情况下为使用本机native realm。 因此，无需在本教程中执行任何额外的配置步骤，就可以直接跳转到创建用户了！

6. 创建用户
我们创建两个基于native realm的用户。

使用浏览器打开kibana服务地址，会发现此时已经需要登录才能使用kibana服务了。
1）使用elastic/elastic123账号，登录进入kibana。
2）转到Management / Security / Users页面。
3）点击Create new user，创建一个账号gqtest/gqtest123，但暂时先不设置Roles，该账号将作为查看kibana的个人账号使用。
4）再创建一个logstash_internal/logstash_internal123用户，用于logstash向es写入数据时使用。

![](https://img-blog.csdnimg.cn/20190716170928851.png)

5）配置角色授权
每个角色定义一组特定的操作（如读取，创建或删除），这些操作可以在特定的安全资源（例如索引，别名，文档，字段或集群）上执行。 es已经提供了很多内置角色可以直接使用。

打开Management / Security / Roles页面，查看系统内置的各种Roles。点击某个角色的名称，可以查看该角色都被授予了哪些权限。

我们将kibana_user角色分配给你的用户。 返回Management / Security / Users页面并选择你的用户。 添加kibana_user角色并保存更改。该角色将提供kibana的所有使用权限。

在实际使用中，我们可能需要为特定的用户创建专用的kibana账号，仅显示部分kibana功能菜单，同时控制各菜单项的读、写权限。这些可以通过在kibana上自定义Role角色来实现。
详情配置方法参见：https://www.elastic.co/guide/en/kibana/7.2/kibana-role-management.html

在前面配置步骤中，我们在Elasticsearch中存储Metricbeat数据。 让我们创建两个角色，授予对该数据的不同级别的访问权限。
转到Management / Security / Roles页面，然后单击Create role。

创建一个metricbeat_reader角色，该角色对metricbeat- *索引具有read和view_index_metadata特权：
创建一个metricbert_writer角色，该角色具有manage_index_templates的权限并监视集群特权，以及对metricbeat- *索引的write, delete, create_index, manage的特权：
Role metricbert_writer：

![](https://img-blog.csdnimg.cn/20190716170949577.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dhdGVybWVsb25iaWc=,size_16,color_FFFFFF,t_70)

现在返回Management / Security / Users页面并将这些角色分配给适当的用户。 将metricbeat_reader角色分配给你的个人用户。 将metricbeat_writer角色分配给logstash_internal用户。

如果需要了解更多的授权和角色管理知识，请参见：https://www.elastic.co/guide/en/elastic-stack-overview/7.2/authorization.html

6）配置Logstash或Metricbeat使用es账号
Logstash的配置方法参见：https://www.elastic.co/guide/en/elastic-stack-overview/7.2/get-started-logstash-user.html

Metricbeat配置使用es账号

创建一个keystore密钥库：
```
./metricbeat keystore create
```
将敏感的密码信息存放在密钥库里：
```
./metricbeat keystore add ES_PWD
```
使用账号metricbeat_internal/metricbeat_internal123，将其密码信息保存于keystore中的ES_PWD变量中。
metricbeat_internal是我们创建的一个用户，授予了beats_system, kibana_user，metricbert_writer这3个角色权限。
查看与删除的方法：
```
./metricbeat keystore list
./metricbeat keystore remove ES_PWD
```
编辑metricbeat.yml配置文件：
```
setup.kibana:
  host: "es-node1:5601"
  username: "metricbeat_internal"
  password: "${ES_PWD}"

#-------------------------- Elasticsearch output ------------------------------
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["localhost:9200"]
  # Optional protocol and basic auth credentials.
  #protocol: "https"
  username: "beats_system"
  password: "${ES_PWD}"
```
启动Metricbeat服务：
```
./metricbeat -e
```
回到kibana的web页面，使用之前创建的gqtest/gqtest123账号登录并查看系统指标数据，该账号具有metricbeat_reader 和 kibana_user的授权。
可以看到Metricbeat采集的系统指标数据正常写入elasticsearch，且在kibana上正常展示，则可以继续配置下面的步骤。
