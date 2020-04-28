---
title: Elasticsearch IK 分词器 
top: 
date: 
tags: 
- Elasticsearch
- IK 分词器 
categories: 
- Elasticsearch
- IK 分词器 
password: 
---

# IK分词器介绍

在elasticsearch 中查询数据，使用了默认的分词器，分词效果不太理想。会把字段分成一个一个汉字，搜索时会把搜索到的句子进行分词，非常不智能，所以本次引入更为智能的IK分词器。
IK分词器提供两种分词算法 ik_smart和ik_max_word，ik_smar为最少切分，ik_max_word最精细度切分。

# IK 分词器下载安装
根据es版本选择对应的IK版本，本次使用的7.3.0 IK分析器版本。
```
https://github.com/medcl/elasticsearch-analysis-ik/releases
```

将IK分词器压缩文件解压到elasticsearch安装目录的plugins目录下命名ik目录
```
#解压analysis-ik文件
[root@elk-node1 plugins]# pwd
/usr/share/elasticsearch/plugins
unzip elasticsearch-analysis-ik-7.3.0.zip  -d ik
#删除源压缩文件
rm -rf elasticsearch-analysis-ik-7.3.0.zip
```
重启 es 服务
```
systemctl  restart  elasticsearch
```

<escape><!-- more --></escape>

查看es安装的插件
```
#es 命令查看插件列表
[root@elk-node1 elasticsearch]# pwd
/usr/share/elasticsearch
[root@elk-node1 elasticsearch]# ./bin/elasticsearch-plugin list
ik

#curl查看es插件
[root@elk-node1 elasticsearch]#  curl -u elastic:qZXo7E -XGET "http://192.168.99.185:9200/_cat/plugins"
elk-node1 analysis-ik 7.3.0
elk-node2 analysis-ik 7.3.0
```

# IK分词器测试
以”我爱你中国“为例， 

默认的分词器会直接分为 "我" "爱" "你" "中" "国" 。

```
GET _analyze
{
    "text":"我爱你中国"
}
```

IK分词器 ik_smart算法

ik_smart算法会将"我爱你中国"分为 "我爱你" "中国"。
```
GET _analyze
{
    "analyzer":"ik_smart",
    "text":"我爱你中国"
}
```

IK分词器ik_max_word算法

ik_max_word算法会将"我爱你中国"分为 "我爱你" "我" "爱你" "中国"。
```
GET _analyze
{
    "analyzer":"ik_max_word",
    "text":"我爱你中国"
}
```

## 自定义IK分词字典

以”我爱你中国“为例，自定义"爱你中国"组成一个分词。
编辑IK插件配置文件
```
[root@elk-node2 config]# pwd
/usr/share/elasticsearch/plugins/ik/config

#添加songhp.dic 扩展字典
[root@elk-node2 config]# cat songhp.dic 
爱你中国

#配置IK配置文件
[root@elk-node2 config]# vim IKAnalyzer.cfg.xml 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
	<comment>IK Analyzer 扩展配置</comment>
	
	<!--用户可以在这里配置自己的扩展字典 -->
	<entry key="ext_dict">songhp.dic</entry>
	
	 <!--用户可以在这里配置自己的扩展停止词字典-->
	<entry key="ext_stopwords"></entry>
	
	<!--用户可以在这里配置远程扩展字典 -->
	<!-- <entry key="remote_ext_dict">words_location</entry> -->
	
	<!--用户可以在这里配置远程扩展停止词字典-->
	<!-- <entry key="remote_ext_stopwords">words_location</entry> -->
</properties>


#重启es服务
systemctl    restart  elasticsearch
```
Kibana测试分词