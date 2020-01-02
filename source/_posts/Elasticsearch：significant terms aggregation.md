---
title: Elasticsearch：significant terms aggregation
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在本文中，我们将重点关注significant terms和significant text聚合。这些聚合旨在搜索数据集中有趣和/或不寻常的术语，这些术语可以告诉您有关数据的隐藏属性的更多信息。此功能对于以下用例特别有用：

- 为用户查询标识包含同义词，首字母缩略词等的相关文档。例如，当用户搜索H1N1时，重要术语聚合可能会建议带有“bird flu”的文档。
- 识别数据中的异常和有趣的事件。例如，通过基于位置过滤文档，我们可以确定特定区域中最常见的犯罪类型。
- 使用对整数字段（例如身高，体重，收入等）的significant term聚合来确定一组主题的最重要属性。

应当注意，重要术语和重要文本聚合都对直接查询（前景集）和索引中所有其他文档（背景集）检索的文档执行复杂的统计计算。因此，两种聚合都需要大量计算，因此应正确配置以快速工作。但是，一旦在本教程的帮助下掌握了它们，您将获得一个强大的工具，可以在应用程序中构建非常有用的功能并从数据集中获取有用的见解。让我们开始吧！

在教程开始，我们假定您已经把Elasticsearch及Kibana完整地安装好了。

# 创建Index mapping

为了说明significant terms和significant text的工作方式，我们首先需要创建一个测试“news”索引来存储新闻文章的集合。 索引映射将包含诸如作者，出版日期，文章标题，视图数和主题之类的字段。 让我们创建映射：
```
    PUT news
    {
      "mappings": {
        "properties": {
          "published": {
            "type": "date",
            "format": "dateOptionalTime"
          },
          "author": {
            "type": "keyword"
          },
          "title": {
            "type": "text"
          },
          "topic": {
            "type": "keyword"
          },
          "views": {
            "type": "integer"
          }
        }
      }
    }
```
如您所见，我们在topic和author字段中使用了keyword数据类型，在title字段中使用了text数据类型。 提醒您，关键字字段只能按其确切值进行搜索，而文本字段可用于全文搜索。

<escape><!-- more --></escape>

接下来，让我们使用Bulk API将一些任意新闻文档添加到索引中。
```
    POST news/_bulk
    {"index":{"_index":"news"}}
    {"author":"John Michael","published":"2018-07-08","title":"Tesla is flirting with its lowest close in over 1 1/2 years (TSLA)","topic":"automobile","views":"431"}
    {"index":{"_index":"news"}}
    {"author":"John Michael","published":"2018-07-22","title":"Tesla to end up like Lehman Brothers (TSLA)","topic":"automobile","views":"1921"}
    {"index":{"_index":"news"}}
    {"author":"John Michael","published":"2018-07-29","title":"Tesla (TSLA) official says that they are going to release a new self-driving car model in the coming year","topic":"automobile","views":"1849"}
    {"index":{"_index":"news"}}
    {"author":"John Michael","published":"2018-08-14","title":"Five ways Tesla uses AI and Big Data","topic":"ai","views":"871"}
    {"index":{"_index":"news"}}
    {"author":"John Michael","published":"2018-08-14","title":"Toyota partners with Tesla (TSLA) to improve the security of self-driving cars","topic":"automobile","views":"871"}
    {"index":{"_index":"news"}}
    {"author":"Robert Cann","published":"2018-08-25","title":"Is AI dangerous for humanity","topic":"ai","views":"981"}
    {"index":{"_index":"news"}}
    {"author":"Robert Cann","published":"2018-09-13","title":"Is AI dangerous for humanity","topic":"ai","views":"871"}
    {"index":{"_index":"news"}}
    {"author":"Robert Cann","published":"2018-09-27","title":"Introduction to Generative Adversarial Networks (GANs) in self-driving cars","topic":"automobile","views":"1183"}
    {"index":{"_index":"news"}}
    {"author":"Robert Cann","published":"2018-10-09","title":"Introduction to Natural Language Processing","topic":"ai","views":"786"}
    {"index":{"_index":"news"}}
    {"author":"Robert Cann","published":"2018-10-15","title":"New Distant Objects Found in the Fight for Planet X ","topic":"astronomy","views":"542"}
```
在这里，我们共同插入了20条数据。

# Significant Terms Aggregation

正如我们已经提到的，重要的术语聚合可以识别数据中异常和有趣的术语。 对于以下用例，聚合功能非常强大：

- 识别与用户查询相关的相关术语/文档。 例如，当用户查询“Spain”时，聚合可能会建议诸如“Madrid”，“Corrida”之类的术语，或有关Spain的文档中常见的其他任何术语。
- Significant term聚合可用于自动新闻分类器，其中基于频繁连接的术语图对文档进行分类。
- 发现数据中的异常。 例如，借助这种汇总，我们可以识别某些地理区域中的异常犯罪类型或疾病。

重要的是要理解，significant terms聚合选择的术语不仅是文档集中最受欢迎的术语。 例如，即使首字母缩略词“ MSFT”仅存在于一千万个文档索引中的10个文档中，但如果在与用户查询“ Microsoft”相匹配的50个文档中有10个找到了这个MSFT，则它仍然是相关的。 该频率使acronym（比如MSFT）与用户的搜索相关。

为了识别重要术语，聚合对与查询匹配的搜索结果以及从中收集结果的索引执行复杂的统计分析。 与查询直接匹配的搜索结果代表前景集，而从中检索它们的索引代表背景集。 重要术语聚合的任务是比较这些集合并找到最常与用户查询关联的术语。

![](https://img-blog.csdnimg.cn/20191029135617753.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

上面的意思可以用上面的一幅图来解释。比如上面的绿色代表一个很大的索引，它里面可能含有比如Nokia这个term很高的出现率。即便如此，只要我们所搜索的FG那个红色的结果里，它出现的几率非常低，也不能够出现在significant terms的聚合里。相反，如果一个term比如TECNO（中国一个非常出名的在非洲的品牌）出现我们所搜索的set里（比如搜索 africa phone），那么我们搜索的聚合将会是是TECNO尽管TECNO可能在整个BG所包含的文档里出现的几率非常之低。

让我们使用真实示例，演示聚合如何工作。 在下面的示例中，我们将尝试在索引中查找每个author的重要topics。 为此，我们首先在author字段上使用术语“桶聚合(bucket aggregation)”。 您还记得，terms aggregation为找到索引的所有唯一术语（即author）构造了存储桶。 接下来，我们在“topics”字段上使用significant terms聚合，以找出每个author的最重要topic。 看一下下面的查询：
```
    GET news/_search
    {
      "size": 0,
      "aggregations": {
        "authors": {
          "terms": {
            "field": "author"
          },
          "aggregations": {
            "significant_topic_types": {
              "significant_terms": {
                "field": "topic"
              }
            }
          }
        }
      }
    }
```
显示的结果为：
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
          "value" : 20,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "authors" : {
          "doc_count_error_upper_bound" : 0,
          "sum_other_doc_count" : 0,
          "buckets" : [
            {
              "key" : "John Michael",
              "doc_count" : 10,
              "significant_topic_types" : {
                "doc_count" : 10,
                "bg_count" : 20,
                "buckets" : [
                  {
                    "key" : "automobile",
                    "doc_count" : 8,
                    "score" : 0.4800000000000001,
                    "bg_count" : 10
                  }
                ]
              }
            },
            {
              "key" : "Robert Cann",
              "doc_count" : 10,
              "significant_topic_types" : {
                "doc_count" : 10,
                "bg_count" : 20,
                "buckets" : [
                  {
                    "key" : "ai",
                    "doc_count" : 6,
                    "score" : 0.2999999999999999,
                    "bg_count" : 8
                  }
                ]
              }
            }
          ]
        }
      }
    }
```
显然对于作者John Michael来说，在他所发表的书里automobile是最经常出现的词。共有8次，而bg_count是10。同样对于作者Robert Cann来说，在他发布的作品里，ai是最最经常出现的词，在他的8个作品中，有6词提到ai。可以断定他就是一个ai专家！

针对上面的significant terms聚合查询，我们也可以通过如下的方法来查询针对某个作者（author）的聚合。
```
    GET news/_search
    {
      "size": 0, 
      "query": {
        "term": {
          "author": "John Michael"
        }
      },
      "aggregations": {
        "significant_topics": {
          "significant_terms": {
            "field": "topic"
          }
        }
      }
    }
```
显示的结果为：
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
          "value" : 10,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "significant_topics" : {
          "doc_count" : 10,
          "bg_count" : 20,
          "buckets" : [
            {
              "key" : "automobile",
              "doc_count" : 8,
              "score" : 0.4800000000000001,
              "bg_count" : 10
            }
          ]
        }
      }
    }
```
这种表述更适合解释我们上面的那个BG和FG的图。

针对significant text aggregation，基本它和significant terms aggregation非常相似，只是它作用于一个text字段而不是一个keyword字段。比如:
```
    GET news/_search
    {
      "size": 0, 
      "query": {
        "match": {
          "title": "Tesla ai"
        }
      },
      "aggregations": {
        "significant_topics": {
          "significant_text": {
            "field": "topic"
          }
        }
      }
    }
```
注意这里的title字段是text，它同时搜索Telsa及ai，再根据这两个词来进行聚合：
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
          "value" : 14,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "significant_topics" : {
          "doc_count" : 14,
          "bg_count" : 20,
          "buckets" : [
            {
              "key" : "automobile",
              "doc_count" : 8,
              "score" : 0.08163265306122446,
              "bg_count" : 10
            },
            {
              "key" : "ai",
              "doc_count" : 6,
              "score" : 0.030612244897959134,
              "bg_count" : 8
            }
          ]
        }
      }
    }
```

参考：
【1】significant terms aggregation(https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-significantterms-aggregation.html)
【2】significant text aggregation(https://www.elastic.co/guide/en/elasticsearch/reference/master/search-aggregations-bucket-significanttext-aggregation.html)
