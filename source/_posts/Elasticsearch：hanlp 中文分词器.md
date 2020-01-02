---
title: Elasticsearch：hanlp 中文分词器
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
HanLP 中文分词器是一个开源的分词器，是专为Elasticsearch而设计的。它是基于HanLP，并提供了HanLP中大部分的分词方式。它的源码位于：

https://github.com/KennFalcon/elasticsearch-analysis-hanl

从Elasticsearch 5.2.2开始，一直有跟随Elasticsearch的不同发行版而更新。

# 安装

1） 方式一：

a. 下载对应的release安装包，最新release包可从baidu盘下载（链接:https://pan.baidu.com/s/1mFPNJXgiTPzZeqEjH_zifw 密码:i0o7）

b. 执行如下命令安装，其中PATH为插件包绝对路径：
```
./bin/elasticsearch-plugin install file://${PATH}
```
2）方式二：

a. 使用elasticsearch插件脚本安装command如下：
```
./bin/elasticsearch-plugin install https://github.com/KennFalcon/elasticsearch-analysis-hanlp/releases/download/v7.4.2/elasticsearch-analysis-hanlp-7.4.2.zip
```
安装完后，我们可以使用如下的方式来验证我们的安装是否成功：
```
    $ ./bin/elasticsearch-plugin list
    analysis-hanlp
```
如果我们安装时成功的话，我们可以看到上面的输出。

<escape><!-- more --></escape>

## 安装数据包

release包中存放的为HanLP源码中默认的分词数据，若要下载完整版数据包，请查看HanLP Release。

数据包目录：`ES_HOME/plugins/analysis-hanlp`

注：因原版数据包自定义词典部分文件名为中文，这里的hanlp.properties中已修改为英文，请对应修改文件名

## 重启Elasticsearch

注：上述说明中的ES_HOME为自己的ES安装路径，需要绝对路径。

这一步非常重要。如果我们不重新启动，新安装的分词器将不会工作。

## 热更新

在本版本中，增加了词典热更新，修改步骤如下：

a. 在ES_HOME/plugins/analysis-hanlp/data/dictionary/custom目录中新增自定义词典
b. 修改hanlp.properties，修改CustomDictionaryPath，增加自定义词典配置
c. 等待1分钟后，词典自动加载

> 注：每个节点都需要做上述更改

提供的分词方式说明

- hanlp: hanlp默认分词
- hanlp_standard: 标准分词
- hanlp_index: 索引分词
- hanlp_nlp: NLP分词
- hanlp_n_short: N-最短路分词
- hanlp_dijkstra: 最短路分词
- hanlp_crf: CRF分词（已有最新方式）
- hanlp_speed: 极速词典分词

我们来做一个简单的例子：
```
    GET _analyze
    {
      "text": "美国阿拉斯加州发生8.0级地震",
      "tokenizer": "hanlp"
    }
```
那么显示的结果为：
```
    {
      "tokens" : [
        {
          "token" : "美国",
          "start_offset" : 0,
          "end_offset" : 2,
          "type" : "nsf",
          "position" : 0
        },
        {
          "token" : "阿拉斯加州",
          "start_offset" : 2,
          "end_offset" : 7,
          "type" : "nsf",
          "position" : 1
        },
        {
          "token" : "发生",
          "start_offset" : 7,
          "end_offset" : 9,
          "type" : "v",
          "position" : 2
        },
        {
          "token" : "8.0",
          "start_offset" : 9,
          "end_offset" : 12,
          "type" : "m",
          "position" : 3
        },
        {
          "token" : "级",
          "start_offset" : 12,
          "end_offset" : 13,
          "type" : "q",
          "position" : 4
        },
        {
          "token" : "地震",
          "start_offset" : 13,
          "end_offset" : 15,
          "type" : "n",
          "position" : 5
        }
      ]
    }
```
更多详细阅读，请参阅链接https://github.com/KennFalcon/elasticsearch-analysis-hanlp
