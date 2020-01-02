---
title: Elasticsearch：aggregation介绍
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
聚合(aggregation)功能集是整个Elasticsearch产品中最令人兴奋和有益的功能之一，主要是因为它提供了一个非常有吸引力对之前的facets的替代。

在本教程中，我们将解释Elasticsearch中的聚合（aggregation）并逐步介绍一些示例。 我们比较了指标聚合和存储桶聚合，并展示了如何利用聚合嵌套（对于facets而言这是不可能的）。 欢迎您在本文中复制所有示例代码。

# 关于Elastic Facets的一点背景

如果您曾经使用过Elasticsearch的facets，那么您肯定了解它们的实用性。 经过丰富的经验，我们在这里告诉您Elasticsearch聚合（aggregations)甚至更好。 facets使您可以快速计算和汇总查询结果，并且可以将其用于各种任务，例如结果值的动态计数或创建分布直方图。 尽管facets非常强大，但它们在Elasticsearch核心中的实现存在一些限制。 由于facets仅执行一级深度的计算，因此将它们组合起来并不容易。

聚合(Aggregation)API(https://www.elastic.co/guide/en/elasticsearch/client/java-api/7.4/java-aggs.html)解决了这些问题，并且还提供了一种简单的方法在查询时（在单个请求中）进行的非常精确的多级计算。 简而言之：Elasticsearch聚合是对facets的一个更加全面的提高的。

# 准备数据

为了完成我们今天的练习，我们先来准备一些数据。我们想创建一个叫做sports的索引。为此，我们先创建一个mapping：
```
    PUT sports
    {
      "mappings": {
        "properties": {
          "birthdate": {
            "type": "date",
            "format": "dateOptionalTime"
          },
          "location": {
            "type": "geo_point"
          },
          "name": {
            "type": "keyword"
          },
          "rating": {
            "type": "integer"
          },
          "sport": {
            "type": "keyword"
          }
        }
      }
    }
```
在上面，我们定义了一个sports索引的mapping。在下面，我们通过bulk API来把我们想要的数据导入到索引中。
<escape><!-- more --></escape>

```
    POST _bulk/
    {"index":{"_index":"sports"}}
    {"name":"Michael","birthdate":"1989-10-1","sport":"Baseball","rating":["5","4"],"location":"46.22,-68.45"}
    {"index":{"_index":"sports"}}
    {"name":"Bob","birthdate":"1989-11-2","sport":"Baseball","rating":["3","4"],"location":"45.21,-68.35"}
    {"index":{"_index":"sports"}}
    {"name":"Jim","birthdate":"1988-10-3","sport":"Baseball","rating":["3","2"],"location":"45.16,-63.58"}
    {"index":{"_index":"sports"}}
    {"name":"Joe","birthdate":"1992-5-20","sport":"Baseball","rating":["4","3"],"location":"45.22,-68.53"}
    {"index":{"_index":"sports"}}
    {"name":"Tim","birthdate":"1992-2-28","sport":"Baseball","rating":["3","3"],"location":"46.22,-68.85"}
    {"index":{"_index":"sports"}}
    {"name":"Alfred","birthdate":"1990-9-9","sport":"Baseball","rating":["2","2"],"location":"45.12,-68.35"}
    {"index":{"_index":"sports"}}
    {"name":"Jeff","birthdate":"1990-4-1","sport":"Baseball","rating":["2","3"],"location":"46.12,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Will","birthdate":"1988-3-1","sport":"Baseball","rating":["4","4"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Mick","birthdate":"1989-10-1","sport":"Baseball","rating":["3","4"],"location":"46.22,-68.45"}
    {"index":{"_index":"sports"}}
    {"name":"Pong","birthdate":"1989-11-2","sport":"Baseball","rating":["1","3"],"location":"45.21,-68.35"}
    {"index":{"_index":"sports"}}
    {"name":"Ray","birthdate":"1988-10-3","sport":"Baseball","rating":["2","2"],"location":"45.16,-63.58"}
    {"index":{"_index":"sports"}}
    {"name":"Ping","birthdate":"1992-5-20","sport":"Baseball","rating":["4","3"],"location":"45.22,-68.53"}
    {"index":{"_index":"sports"}}
    {"name":"Duke","birthdate":"1992-2-28","sport":"Baseball","rating":["5","2"],"location":"46.22,-68.85"}
    {"index":{"_index":"sports"}}
    {"name":"Hal","birthdate":"1990-9-9","sport":"Baseball","rating":["4","2"],"location":"45.12,-68.35"}
    {"index":{"_index":"sports"}}
    {"name":"Charge","birthdate":"1990-4-1","sport":"Baseball","rating":["3","2"],"location":"46.12,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Barry","birthdate":"1988-3-1","sport":"Baseball","rating":["5","2"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Bank","birthdate":"1988-3-1","sport":"Golf","rating":["6","4"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Bingo","birthdate":"1988-3-1","sport":"Golf","rating":["10","7"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"James","birthdate":"1988-3-1","sport":"Basketball","rating":["10","8"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Wayne","birthdate":"1988-3-1","sport":"Hockey","rating":["10","10"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Brady","birthdate":"1988-3-1","sport":"Football","rating":["10","10"],"location":"46.25,-68.55"}
    {"index":{"_index":"sports"}}
    {"name":"Lewis","birthdate":"1988-3-1","sport":"Football","rating":["10","10"],"location":"46.25,-68.55"}
```
通过上面的bulk API接口，我们可以把我们想要的数据输入到sports的索引中。我们可以通过如下的接口来获得我多少条数据：
```
GET sports/_count
```
显示结果：
```
    {
      "count" : 22,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      }
    }
```
在这个数据库里，我们有可以看到有22条的数据。
 
# 动手实践

聚合的两个主要系列是指标聚合（metric aggregations）(https://www.elastic.co/guide/en/elasticsearch/reference/master/search-aggregations-metrics.html)和存储桶聚合（bucket aggregation）(https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket.html)。
指标聚合计算一组文档中的某些值（例如平均值）； 存储桶聚合将文档分组到存储桶中。 在详细介绍之前，让我们看一下聚合请求的一般结构。除此之前，聚合还有Matrix(https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-matrix.html)及Pipleline(https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-pipeline.html聚合。

## Aggregation结构
```
    "aggregations" : {
        "<aggregation_name>" : {
            "<aggregation_type>" : { 
                <aggregation_body>
            },
            ["aggregations" : { [<sub_aggregation>]* } ]
        }
        [,"<aggregation_name_2>" : { ... } ]*
    }
```
请求json中的聚合（您也可以改用aggs）对象包含聚合名称，类型和主体。 <aggregation_name>是用户定义的名称（不带括号），该名称将唯一标识响应中的聚合名称/键。

<aggregation_type>通常是聚合中的第一个键。 它可以是terms，stats或geo-distance聚合，但这是它的起点。 在我们的<aggregation_type>中，我们有一个<aggregation_body>。 在<aggregation_body>中，我们指定聚合所需的属性。 可用属性取决于聚合的类型。

您可以选择提供子聚合，以将一个聚合元素的结果嵌套到另一个聚合元素中。 此外，您可以在查询中输入多个聚合（aggregation_name_2），以具有更多单独的顶级聚合。 尽管对嵌套级别没有限制，但是您不能将度量标准嵌套在度量标准聚合中，原因如下所述。 在研究可以聚合的不同类型的值之后，我们将了解桶聚合和度量聚合之间的区别。
 
# 例子

一些聚合使用从聚合文档中获取的值。 这些值可以从指定的文档字段（field）中获取，也可以从随每个文档生成值的脚本中获取。 下面的第一个示例在名称字段上提供了术语聚合(terms aggregation)，在子聚合rating_avg值上给出了顺序。 如您所见，我们使用嵌套的指标聚合对存储桶聚合的结果进行排序。

尽管我们使用上面给出的索引，但是我们鼓励您运行此查询（以及下面的其他查询）。 您可以从工作中获得直接结果，然后对其进行修改以匹配您的数据集。

另外，请仔细查看我们是否包含“ size”：0，因为我们的重点是聚合结果，而不是文档结果。这里设置为0，表示我们不想得到任何的文档。
```
    GET sports/_search
    {
      "size": 0, 
      "aggregations": {
        "the_name": {
          "terms": {
            "field": "name",
            "order": {
              "rating_avg": "desc"
            }
          },
          "aggregations": {
            "rating_avg": {
              "avg": {
                "field": "rating"
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
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "the_name" : {
          "doc_count_error_upper_bound" : 0,
          "sum_other_doc_count" : 12,
          "buckets" : [
            {
              "key" : "Brady",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 10.0
              }
            },
            {
              "key" : "Lewis",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 10.0
              }
            },
            {
              "key" : "Wayne",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 10.0
              }
            },
            {
              "key" : "James",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 9.0
              }
            },
            {
              "key" : "Bingo",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 8.5
              }
            },
            {
              "key" : "Bank",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 5.0
              }
            },
            {
              "key" : "Michael",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 4.5
              }
            },
            {
              "key" : "Will",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 4.0
              }
            },
            {
              "key" : "Barry",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 3.5
              }
            },
            {
              "key" : "Bob",
              "doc_count" : 1,
              "rating_avg" : {
                "value" : 3.5
              }
            }
          ]
        }
      }
    }
```
上面的结果显示：我们得到了按照每个人来进行分类的聚合，而他们的顺序是按照rating_avg聚合所获得平均分数来排序的。

我们还可以提供一个script脚本来生成聚合所使用的值:
```
    GET sports/_search
    {
      "size": 0,
      "aggs": {
        "age_range": {
          "range": {
            "script": {
              "source": 
                """
                ZonedDateTime dob = doc['birthdate'].value;
                return params.now - dob.getYear()
                """
                ,
              "params": {
                "now": 2019
              }
            },
            "ranges": [
              {
                "from": 30,
                "to": 31
              }
            ]
          }
        }
      }
    }
```

在上面，我们通过脚本生产value source，并对它做出统计。

显示的结果是：
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
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "age_range" : {
          "buckets" : [
            {
              "key" : "30.0-31.0",
              "from" : 30.0,
              "to" : 31.0,
              "doc_count" : 4
            }
          ]
        }
      }
    }
```
上面显示在30至31岁之间的有4个人。

# Metric Aggregations

指标聚合类型用于计算整个文档集的指标。 有单值指标聚合（例如avg）和多值指标聚合（例如stats）。 指标聚合的一个简单示例是value_count聚合，它仅返回已为给定字段建立索引的值的总数。 要在运动员数据集中的“sport”字段中找到值的数量，我们可以使用以下查询：
```
    GET sports/_search
    {
      "size": 0,
      "aggs": {
        "sport_count": {
          "value_count": {
            "field": "sport"
          }
        }
      }
    }
```
显示结果：
```
    {
      "took" : 2,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "sport_count" : {
          "value" : 22
        }
      }
    }
```
请注意，这将返回该字段的值总数，而不是唯一值的数目。 因此，在这种情况下（由于每个文档在“ sport”字段中都有一个单词值），结果仅等于索引中的文档数。

# Bucket Aggregations

存储桶聚合是用于对文档进行分组的机制。 每种类型的存储桶聚合都有自己的分割文档集的方法。 也许最简单的类型是术语聚合。 这个功能非常像术语方面，返回给定字段索引的唯一术语以及匹配文档的数量。 如果我们想在数据集中的“sport”字段中找到所有值，则可以使用以下方法：
```
    GET sports/_search
    {
      "size": 0,
      "aggs": {
        "sport": {
          "terms": {
            "field": "sport",
            "size": 10
          }
        }
      }
    }
```
返回值：
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
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "sport" : {
          "doc_count_error_upper_bound" : 0,
          "sum_other_doc_count" : 0,
          "buckets" : [
            {
              "key" : "Baseball",
              "doc_count" : 16
            },
            {
              "key" : "Football",
              "doc_count" : 2
            },
            {
              "key" : "Golf",
              "doc_count" : 2
            },
            {
              "key" : "Basketball",
              "doc_count" : 1
            },
            {
              "key" : "Hockey",
              "doc_count" : 1
            }
          ]
        }
      }
    }
```
您可能会发现geo_distance聚合更具吸引力。 尽管它有许多选项，但在最简单的情况下，它取一个原点和一个距离范围，然后根据给定的geo_point字段计算圆中有多少文档。

假设我们需要知道多少个运动员居住在距离地理位置“ 46.12，-68.55” 20英里范围内。 我们可以使用以下聚合：
```
    GET sports/_search
    {
      "size": 0,
      "aggregations": {
        "baseball_player_ring": {
          "geo_distance": {
            "field": "location",
            "origin": "46.12,-68.55",
            "unit": "mi",
            "ranges": [
              {
                "from": 0,
                "to": 20
              }
            ]
          }
        }
      }
    }
```
返回结果：
```
    {
      "took" : 4,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "baseball_player_ring" : {
          "buckets" : [
            {
              "key" : "*-20.0",
              "from" : 0.0,
              "to" : 20.0,
              "doc_count" : 14
            }
          ]
        }
      }
    }
```

# 内嵌 Bucket Aggregations

许多开发人员会同意，桶聚合的最强大方面是嵌套它们的能力。 您可以定义顶级存储桶聚合，并在其内部定义对每个结果存储桶进行操作的第二级聚合。 此嵌套可以根据需要扩展到多个级别。

继续我们的示例，我们可以使用按年龄划分的嵌套范围聚合（根据脚本的“出生日期”计算得出）来进一步细分geo_distance聚合的结果。 假设我们想知道属于两个年龄段的每个运动员中有多少运动员（他们生活在上一节中定义的圈子内）。 我们可以使用以下聚合来获取此信息：
```
    GET sports/_search
    {
       "size": 0,
       "aggregations": {
          "baseball_player_ring": {
             "geo_distance": {
                "field": "location",
                "origin": "46.12,-68.55",
                "unit": "mi",
                "ranges": [
                   {
                      "from": 0,
                      "to": 20
                   }
                ]
             },
             "aggregations": {
                "ring_age_ranges": {
                   "range": {
                     "script": {
                        "source": 
                        """
                        ZonedDateTime dob = doc['birthdate'].value;
                        return params.now - dob.getYear()
                        """
                      ,
                      "params": {
                        "now": 2019
                      }                 
                     }, 
                      "ranges": [
                          { "from": 30, "to": 31 },
                          { "from": 31, "to": 32 }
                      ]
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
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "baseball_player_ring" : {
          "buckets" : [
            {
              "key" : "*-20.0",
              "from" : 0.0,
              "to" : 20.0,
              "doc_count" : 14,
              "ring_age_ranges" : {
                "buckets" : [
                  {
                    "key" : "30.0-31.0",
                    "from" : 30.0,
                    "to" : 31.0,
                    "doc_count" : 2
                  },
                  {
                    "key" : "31.0-32.0",
                    "from" : 31.0,
                    "to" : 32.0,
                    "doc_count" : 8
                  }
                ]
              }
            }
          ]
        }
      }
    }
```
现在，让我们使用stats（多值指标汇总器）来计算最内部结果的一些统计数据。 对于居住在我们圈子中的运动员以及两个年龄段的每个年龄段，我们现在都希望根据结果文档计算“rating”字段的统计信息：
```
    GET sports/_search
    {
       "size": 0,
       "aggregations": {
          "baseball_player_ring": {
             "geo_distance": {
                "field": "location",
                "origin": "46.12,-68.55",
                "unit": "mi",
                "ranges": [
                   {
                      "from": 0,
                      "to": 20
                   }
                ]
             },
             "aggregations": {
                "ring_age_ranges": {
                   "range": {
                     "script": {
                        "source": 
                        """
                        ZonedDateTime dob = doc['birthdate'].value;
                        return params.now - dob.getYear()
                        """
                      ,
                      "params": {
                        "now": 2019
                      }                 
                     }, 
                      "ranges": [
                          { "from": 30, "to": 31 },
                          { "from": 31, "to": 32 }
                      ]
                   },
                  "aggregations": {
                    "rating_stats": {
                      "stats": {
                          "field": "rating"
                        }
                    }
                  }
                }
             }
          }
       }
    }
```
我们得到一个我们需要的统计信息的响应：
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
          "value" : 22,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "baseball_player_ring" : {
          "buckets" : [
            {
              "key" : "*-20.0",
              "from" : 0.0,
              "to" : 20.0,
              "doc_count" : 14,
              "ring_age_ranges" : {
                "buckets" : [
                  {
                    "key" : "30.0-31.0",
                    "from" : 30.0,
                    "to" : 31.0,
                    "doc_count" : 2,
                    "rating_stats" : {
                      "count" : 4,
                      "min" : 3.0,
                      "max" : 5.0,
                      "avg" : 4.0,
                      "sum" : 16.0
                    }
                  },
                  {
                    "key" : "31.0-32.0",
                    "from" : 31.0,
                    "to" : 32.0,
                    "doc_count" : 8,
                    "rating_stats" : {
                      "count" : 16,
                      "min" : 2.0,
                      "max" : 10.0,
                      "avg" : 7.5,
                      "sum" : 120.0
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }
```
如您所见，您可以创建一个包含多个存储更多存储桶的大存储桶。 您还可以获取每个存储分区的指标（metrics)，以及不断提高的复杂性。 通过这些简单的构建块，您可以使用嵌套聚合从数据中获得深刻而复杂的见解。
