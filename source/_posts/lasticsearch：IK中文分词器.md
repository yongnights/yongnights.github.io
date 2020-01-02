---
title: lasticsearch：IK中文分词器
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
Elasticsearch内置的分词器对中文不友好，只会一个字一个字的分，无法形成词语，比如：
```
    POST /_analyze
    {
      "text": "我爱北京天安门",
      "analyzer": "standard"
    }
```
如果我们使用的是standard的分词器，那么结果就是：
```
    {
      "tokens" : [
        {
          "token" : "我",
          "start_offset" : 0,
          "end_offset" : 1,
          "type" : "<IDEOGRAPHIC>",
          "position" : 0
        },
        {
          "token" : "爱",
          "start_offset" : 1,
          "end_offset" : 2,
          "type" : "<IDEOGRAPHIC>",
          "position" : 1
        },
        ...
        {
          "token" : "门",
          "start_offset" : 6,
          "end_offset" : 7,
          "type" : "<IDEOGRAPHIC>",
          "position" : 6
        }
      ]
    }
```
显然这对中文来说并不友好，它显示的每一个汉字。好在Elastic的大拿medcl已经为我们做好IK中文分词器。下面我们来详细介绍如何安装并使用中文分词器。具体的安装步骤可以在地址https://github.com/medcl/elasticsearch-analysis-ik找到。

<escape><!-- more --></escape>

# 安装

首先，我们可以到如下的地址查看一下是否有最新的版本对应你的Elasticsearch的发行版：

https://github.com/medcl/elasticsearch-analysis-ik/releases

到目前截止日期，我们可以看到有最新的v7.3.1发行版。

那么，我们直接进入到我们的Elasticsearch的安装目录下，并打入如下的命令：
```
./bin/elasticsearch-plugin nstall https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.3.1/elasticsearch-analysis-ik-7.3.1.zip
```
替代上面的7.3.1安装你自己想要的版本：

安装好后，我们可以通过如下的命令来检查是否已经安装好：
```
localhost:elasticsearch-7.3.0 liuxg$ ./bin/elasticsearch-plugin list
analysis-ik
```
上面的命令显示我们的IK已经安装成功了。

这个时候需要我们重新启动一下我们的Elasticsearch，以便这个plugin能装被加载。
 
# 使用IK分词器

首先我们创建一个index:
```
PUT chinese
```
接下来，我们来为这个index 创建一个mapping
```
    PUT /chinese/_mapping
    {
      "properties": {
        "content": {
          "type": "text",
          "analyzer": "ik_max_word",
          "search_analyzer": "ik_smart"
        }
      }
    }
```
运行上面的命令后，如果出现如下的信息：
```
    {
      "acknowledged" : true
    }
```
它表明我们的安装时成功的。

接下来，我们来index一些文档：
```
    GET /chinese/_analyze
    {
      "text": "我爱北京天安门",
      "analyzer": "ik_max_word"
    }
```
显示的结果为：
```
    {
      "tokens" : [
        {
          "token" : "我",
          "start_offset" : 0,
          "end_offset" : 1,
          "type" : "CN_CHAR",
          "position" : 0
        },
        {
          "token" : "爱",
          "start_offset" : 1,
          "end_offset" : 2,
          "type" : "CN_CHAR",
          "position" : 1
        },
        {
          "token" : "北京",
          "start_offset" : 2,
          "end_offset" : 4,
          "type" : "CN_WORD",
          "position" : 2
        },
        {
          "token" : "天安门",
          "start_offset" : 4,
          "end_offset" : 7,
          "type" : "CN_WORD",
          "position" : 3
        },
        {
          "token" : "天安",
          "start_offset" : 4,
          "end_offset" : 6,
          "type" : "CN_WORD",
          "position" : 4
        },
        {
          "token" : "门",
          "start_offset" : 6,
          "end_offset" : 7,
          "type" : "CN_CHAR",
          "position" : 5
        }
      ]
    }
```
从上面的结果我们可以看出来，在我们的token中显示“北京”，“天安”及“天安门”。这个和我们之前的是不一样的。

下面，我们输入两个文档：
```
    PUT /chinese/_doc/1
    {
      "content":"我爱北京天安门"
    }
     
    PUT  /chinese/_doc/2
    {
      "content": "北京，你好"
    }
```
那么我们可以，通过如下的方式来进行搜索：
```
    GET /chinese/_search
    {
      "query": {
        "match": {
          "content": "北京"
        }
      }
    }
```
我们显示的结果是：
```
    {
      "took" : 1,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 2,
          "relation" : "eq"
        },
        "max_score" : 0.15965709,
        "hits" : [
          {
            "_index" : "chinese",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 0.15965709,
            "_source" : {
              "content" : "北京，你好"
            }
          },
          {
            "_index" : "chinese",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.100605845,
            "_source" : {
              "content" : "我爱北京天安门"
            }
          }
        ]
      }
    }
```
因为两个文档里都含有“北京”，我们可以看出来两个文档都被显示出来了。

我们同时做另外一个搜索：
```
    GET /chinese/_search
    {
      "query": {
        "match": {
          "content": "天安门"
        }
      }
    }
```
那么显示的结果是：
```
    {
      "took" : 0,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 1,
          "relation" : "eq"
        },
        "max_score" : 0.73898095,
        "hits" : [
          {
            "_index" : "chinese",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.73898095,
            "_source" : {
              "content" : "我爱北京天安门"
            }
          }
        ]
      }
    }
```
因为“天安门”只出现在第二个文档里，所以，我们可以看出来只有一个结果。

我们也同时做另外一个搜索：
```
    GET /chinese/_search
    {
      "query": {
        "match": {
          "content": "北京天安门"
        }
      }
    }
```
在这里，我们来搜索“北京天安门”。请注意我们在mapping中使用了
```
"search_analyzer": "ik_smart"
```
也就是说，search_analyzer会把我们的“北京天安门”，分解成两个词“北京”及“天安门”。这两个词将被用于搜索。通常对于match来说是OR关系，也就是说只要匹配到“北京”或“天安门”，这两个之中的任何一个，那么就是匹配：
```
    {
      "took" : 3,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 2,
          "relation" : "eq"
        },
        "max_score" : 0.7268042,
        "hits" : [
          {
            "_index" : "chinese",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.7268042,
            "_source" : {
              "content" : "我爱北京天安门"
            }
          },
          {
            "_index" : "chinese",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 0.22920427,
            "_source" : {
              "content" : "北京，你好"
            }
          }
        ]
      }
    }
```
上面显示的结果显示“我爱北京天安门”是最贴切的搜索结果。

参考：
【1】https://github.com/medcl/elasticsearch-analysis-ik
