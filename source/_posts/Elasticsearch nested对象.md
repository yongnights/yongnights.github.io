
在处理大量数据时，关系数据库存在很多问题。 无论是速度，高效处理，有效并行化，可扩展性还是成本，当数据量开始增长时，关系数据库都会失败。该关系数据库的另一个挑战是必须预先定义关系和模式。Elasticsearch也是一个NoSQL文档数据存储。 但是，尽管是一个NoSQL数据存储，Elasticsearch在一定程度上提供了很多帮助来管理关系数据。 它支持类似SQL的连接，并且在嵌套和相关的数据实体上工作得非常棒。

比如，对于一个像下面的blog形式的文档：

![](https://img-blog.csdnimg.cn/2019082522133538.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

一个blog可能对应于很多的comments，或者一个员工对应于很多的经验。这种数据就是关系数据。使用Elasticsearch，您可以通过保留轻松地工作与不同实体的关联以及强大的全文搜索和分析。 Elasticsearch通过引入两种类型的文档关系模型使这成为可能：

- nested 关系: 在这种关系中，这种一对多的关系存在于同一个文档之中
- parent-child 关系：在这种关系中，它们存在于不同的文档之中。

这两种关系在同一个模式下工作，即一对多个的关系。一个root或parent可以有一个及多个子object。

如上图所示，在嵌套关系中，有一个根对象，它是我们拥有的主文档，它包含一个称为嵌套文档的子文档数组。 根对象内的文档嵌套级别没有限制。 例如，查看以下JSON以进行多级嵌套：
```
     {
         "location_id": "axdbyu",
         "location_name": "gurgaon",
         "company": [
           {
             "name": "honda",
             "modelName": [
               { "name": "honda cr-v", "price": "2 million" }
             ]
    }, {
             "name": "bmw",
             "modelName": [
               { "name": "BMW 3 Series", "price": "2 million"},
               { "name": "BMW 1 Series", "price": "3 million" }
             ]
      } ]
    }
```
下面，我们来做一个例子来展示一下为什么nested对象可以解决我们的问题。
 
# Object数据类型

 我们首先创建一个叫做developer的index，并输入如下的两个数据：
```
    POST developer/_doc/101
    {
      "name": "zhang san",
      "skills": [
        {
          "language": "ruby",
          "level": "expert"
        },
        {
          "language": "javascript",
          "level": "beginner"
        }
       ]
    }
     
    POST developer/_doc/102
    {
      "name": "li si",
      "skills": [
        {
          "language": "ruby",
          "level": "beginner"
        }
       ]
    }
```
上面显示是一对多的一个index。

# Object Query

这个时候我们想搜一个skills: language是ruby，并且level是biginner的文档。我们可能想到的方法是：
```
    GET developer/_search
    {
      "query": {
        "bool": {
          "filter": [
            {
              "match": {
                "skills.language": "ruby"
              }
            },
            {
              "match": {
                "skills.level": "beginner"
              }
            }
          ]
        }
      }
    }
```
通过上面的搜寻，我们得到的结果是：
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
          "value" : 2,
          "relation" : "eq"
        },
        "max_score" : 0.0,
        "hits" : [
          {
            "_index" : "developer",
            "_type" : "_doc",
            "_id" : "101",
            "_score" : 0.0,
            "_source" : {
              "name" : "zhang san",
              "skills" : [
                {
                  "language" : "ruby",
                  "level" : "expert"
                },
                {
                  "language" : "javascript",
                  "level" : "beginner"
                }
              ]
            }
          },
          {
            "_index" : "developer",
            "_type" : "_doc",
            "_id" : "102",
            "_score" : 0.0,
            "_source" : {
              "name" : "li si",
              "skills" : [
                {
                  "language" : "ruby",
                  "level" : "beginner"
                }
              ]
            }
          }
        ]
      }
    }
```
我们可以看到，我们得到两个结果。但是我们仔细查看一下发现得到的结果并不是我们想得到的。从我们的原意来说，我们想得到的是li si，因为只有li si这个人的language是ruby，并且他的level是biginner。zhang san这个文档，应该不在搜寻之列。这是为什么呢？

原来，langauge及level是skills的JSON内部数组项。当JSON对象被Lucene扁平化后，我们失去了language和level之间的对应关系。取而代之的是如下的这种关系：
```
    {
      "name": "zhang san",
      "skills.language" :["ruby", "javascript"],
      "skills.level": ["expert", "beginner"]
    }
```
如上所示，我们看到的是一个扁平化的数组。之前的那种language和level之间的那种对应关系已经不存在了。

# Object aggregation


同样的问题也存在于aggregation中，比如我们想做一下的aggregation:
```
    GET developer/_search
    {
      "size": 0,
      "aggs": {
        "languages": {
          "terms": {
            "field": "skills.language.keyword"
          },
          "aggs": {
            "level": {
              "terms": {"field": "skills.level.keyword"}
            }
          }
        }
      }
    }
```
显示的结果是：
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
          "value" : 2,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "languages" : {
          "doc_count_error_upper_bound" : 0,
          "sum_other_doc_count" : 0,
          "buckets" : [
            {
              "key" : "ruby",
              "doc_count" : 2,
              "level" : {
                "doc_count_error_upper_bound" : 0,
                "sum_other_doc_count" : 0,
                "buckets" : [
                  {
                    "key" : "beginner",
                    "doc_count" : 2
                  },
                  {
                    "key" : "expert",
                    "doc_count" : 1
                  }
                ]
              }
            },
            {
              "key" : "javascript",
              "doc_count" : 1,
              "level" : {
                "doc_count_error_upper_bound" : 0,
                "sum_other_doc_count" : 0,
                "buckets" : [
                  {
                    "key" : "beginner",
                    "doc_count" : 1
                  },
                  {
                    "key" : "expert",
                    "doc_count" : 1
                  }
                ]
              }
            }
          ]
        }
      }
    }
```
显然，对于key javascript来说，它并没有expert对应的level，但是在我们的aggregation里显示出来了。这个结果显然是错误的。

# nested 数据类型

nested数据类型能够让我们对object数组建立索引，并且分别进行查询。

如果需要维护数组中每个对象的关系，请使用nested数据类型

为了能够把我们的数据定义为nested，我们必须修改之前的索引mapping为：
```
    DELETE developer
     
    PUT developer
    {
      "mappings": {
        "properties": {
          "name": {
            "type": "text"
          },
          "skills": {
            "type": "nested",
            "properties": {
              "language": {
                "type": "keyword"
              },
              "level": {
                "type": "keyword"
              }
            }
          }
        }
      }
    }
```
经过这样的改造之后，重新把我们之前的数据输入到index里：
```
    POST developer/_doc/101
    {
      "name": "zhang san",
      "skills": [
        {
          "language": "ruby",
          "level": "expert"
        },
        {
          "language": "javascript",
          "level": "beginner"
        }
       ]
    }
     
    POST developer/_doc/102
    {
      "name": "li si",
      "skills": [
        {
          "language": "ruby",
          "level": "beginner"
        }
       ]
    }
```
针对101，在Lucence中的数据结构变为：
```
    {
      "name": "zhang san",
      {
        "skills.language": "ruby",
        "skills.level": "expert"
      },
      {
        "skills.language": "javascript",
        "skills.level", "beginner"
      }
    }
```

# nested query

我们来重新做我们之前的搜索：
```
    GET developer/_search
    {
      "query": {
        "nested": {
          "path": "skills",
          "query": {
            "bool": {
              "filter": [
                {
                  "match": {
                    "skills.language": "ruby"
                  }
                },
                {
                  "match": {
                    "skills.level": "beginner"
                  }
                }
              ]
            }
          }
        }
      }
    }
```
注意上面的“nested”字段。显示的结果是：
```
    {
      "took" : 5,
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
        "max_score" : 0.0,
        "hits" : [
          {
            "_index" : "developer",
            "_type" : "_doc",
            "_id" : "102",
            "_score" : 0.0,
            "_source" : {
              "name" : "li si",
              "skills" : [
                {
                  "language" : "ruby",
                  "level" : "beginner"
                }
              ]
            }
          }
        ]
      }
    }
```

显然，我们只得到了一个我们想要的结果。
 
# nested aggregation

同样，我们可以对我们的index来做一个aggregation:
```
    GET developer/_search
    {
      "size": 0,
      "aggs": {
        "nested_skills": {
          "nested": {
            "path": "skills"
          },
          "aggs": {
            "languages": {
              "terms": {
                "field": "skills.language"
              },
              "aggs": {
                "levels": {
                  "terms": {
                    "field": "skills.level"
                  }
                }
              }
            }
          }
        }
      }
    }
```
显示的结果是：
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
        "max_score" : null,
        "hits" : [ ]
      },
      "aggregations" : {
        "nested_skills" : {
          "doc_count" : 3,
          "languages" : {
            "doc_count_error_upper_bound" : 0,
            "sum_other_doc_count" : 0,
            "buckets" : [
              {
                "key" : "ruby",
                "doc_count" : 2,
                "levels" : {
                  "doc_count_error_upper_bound" : 0,
                  "sum_other_doc_count" : 0,
                  "buckets" : [
                    {
                      "key" : "beginner",
                      "doc_count" : 1
                    },
                    {
                      "key" : "expert",
                      "doc_count" : 1
                    }
                  ]
                }
              },
              {
                "key" : "javascript",
                "doc_count" : 1,
                "levels" : {
                  "doc_count_error_upper_bound" : 0,
                  "sum_other_doc_count" : 0,
                  "buckets" : [
                    {
                      "key" : "beginner",
                      "doc_count" : 1
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    }
```
从上面显示的结果，可以看出来对于ruby来说，它分别对应于一个bigginer及一个expert。这个和我们之前的数据是一样的。对于javascript来说，它只有一个beginner的level。
