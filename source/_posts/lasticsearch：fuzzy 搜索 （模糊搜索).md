---
title: lasticsearch：fuzzy 搜索(模糊搜索)
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---

在实际的搜索中，我们有时候会打错字，从而导致搜索不到。在Elasticsearch中，我们可以使用fuzziness属性来进行模糊查询，从而达到搜索有错别字的情形。

match查询具有“fuziness”属性。它可以被设置为“0”， “1”， “2”或“auto”。“auto”是推荐的选项，它会根据查询词的长度定义距离。

# Fuzzy query

返回包含与搜索词相似的词的文档，以Levenshtein编辑距离测量。

编辑距离是将一个术语转换为另一个术语所需的一个字符更改的次数。 这些更改可以包括：

- 更改字符（box→fox）
- 删除字符（black→lack）
- 插入字符（sic→sick）
- 转置两个相邻字符（act→cat）

为了找到相似的词，模糊查询会在指定的编辑距离内创建搜索词的所有可能变化或扩展的集合。 查询然后返回每个扩展的完全匹配。

![](https://img-blog.csdnimg.cn/20191014111717533.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

# 例子

我们首先输入如下的一个文档到fuzzyindex索引中：
```
    PUT fuzzyindex/_doc/1
    {
      "content": "I like blue sky"
    }
```
如果这个时候，我们进行如下的搜索：
```
    GET fuzzyindex/_search
    {
      "query": {
        "match": {
          "content": "ski"
        }
      }
    }
```
那么是没有任何被搜索到的结果，这是因为“I like blue sky" 里分词后没有ski这个词。
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
          "value" : 0,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      }
    }
```
这个时候，如果我们使用如下的搜索：
```
    GET fuzzyindex/_search
    {
      "query": {
        "match": {
          "content": {
            "query": "ski",
            "fuzziness": "1"
          }
        }
      }
    }
```
那么显示的结果是：
```
    {
      "took" : 18,
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
        "max_score" : 0.19178805,
        "hits" : [
          {
            "_index" : "fuzzyindex",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.19178805,
            "_source" : {
              "content" : "I like blue sky"
            }
          }
        ]
      }
    }
```
显然是找到我们需要的结果了。这是因为sky和ski时间上是只差别一个字母。

同样，如果我们选用“auto”选项看看：
```
    GET fuzzyindex/_search
    {
      "query": {
        "match": {
          "content": {
            "query": "ski",
            "fuzziness": "auto"
          }
        }
      }
    }
```
它显示的结果和上面的是一样的。也可以进行匹配。

如果我们进行如下的匹配：
```
    GET fuzzyindex/_search
    {
      "query": {
        "match": {
          "content": {
            "query": "bxxe",
            "fuzziness": "auto"
          }
        }
      }
    }
```
那么它不能匹配任何的结果，但是，如果我们进行如下的搜索：
```
    GET fuzzyindex/_search
    {
      "query": {
        "match": {
          "content": {
            "query": "bxxe",
            "fuzziness": "2"
          }
        }
      }
    }
```
我们也可以使用如下的格式：
```
    GET /_search
    {
        "query": {
            "fuzzy": {
                "content": {
                    "value": "bxxe",
                    "fuzziness": "2"
                }
            }
        }
    }
```
那么它可以显示搜索的结果，这是因为我们能够容许两个编辑的错误。

模糊性是拼写错误的简单解决方案，但具有很高的CPU开销和非常低的精度。

参考：
【1】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/query-dsl-fuzzy-query.html
