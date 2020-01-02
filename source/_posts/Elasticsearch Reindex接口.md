---
title: Elasticsearch Reindex接口
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在我们开发的过程中，我们有很多时候需要用到Reindex接口。它可以帮我们把数据从一个index到另外一个index进行重新reindex。这个对于特别适用于我们在修改我们数据的mapping后，需要重新把数据从现有的index转到新的index建立新的索引，这是因为我们不能修改现有的index的mapping一旦已经定下来了。在接下来的介绍中，我们将学习如何使用reindex接口。

![](https://img-blog.csdnimg.cn/20190904082441854.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

为了能够使用reindex接口，我们必须满足一下的条件：
- `_source`选项对所有的源index文档是启动的，也即源index的source是被存储的
- reindex不是帮我们尝试设置好目的地index。它不拷贝源index的设置到目的地的index里去。你应该在做reindex之前把目的地的源的index设置好，这其中包括mapping, shard数目，replica等

下面，我们来一个具体的例子，比如建立一个blogs的index。
```
    PUT twitter2/_doc/1
    {
      "user" : "双榆树-张三",
      "message" : "今儿天气不错啊，出去转转去",
      "uid" : 2,
      "age" : 20,
      "city" : "北京",
      "province" : "北京",
      "country" : "中国",
      "address" : "中国北京市海淀区",
      "location" : {
        "lat" : "39.970718",
        "lon" : "116.325747"
      }
    }
```
上面的命令让我们建立了一个叫做twitter2的index，并同时帮我们生产了一个如下的mapping:
<escape><!-- more --></escape>

```
GET /twitter2/_mapping
```
显示的结果是：
```
    {
      "twitter2" : {
        "mappings" : {
          "properties" : {
            "address" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "age" : {
              "type" : "long"
            },
            "city" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "country" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "location" : {
              "properties" : {
                "lat" : {
                  "type" : "text",
                  "fields" : {
                    "keyword" : {
                      "type" : "keyword",
                      "ignore_above" : 256
                    }
                  }
                },
                "lon" : {
                  "type" : "text",
                  "fields" : {
                    "keyword" : {
                      "type" : "keyword",
                      "ignore_above" : 256
                    }
                  }
                }
              }
            },
            "message" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "province" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            },
            "uid" : {
              "type" : "long"
            },
            "user" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            }
          }
        }
      }
    }
```
显然系统帮我们生产的location数据类型是不对的，我们必须进行修改。一种办法是删除现有的twitter2索引，让后修改它的mapping，再重新索引所有的数据。这对于一个两个文档还是可以的，但是如果已经有很多的数据了，这个方法并不可取。另外一种方式，是建立一个完全新的index，使用新的mapping进行reindex。下面我们展示如何使用这种方法。

创建一个新的twitter3的index，使用如下的mapping:
```
    PUT twitter3
    {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 1
      },
      "mappings": {
        "properties": {
          "address": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "age": {
            "type": "long"
          },
          "city": {
            "type": "text"
          },
          "country": {
            "type": "text"
          },
          "location": {
            "type": "geo_point"
          },
          "message": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "province": {
            "type": "text"
          },
          "uid": {
            "type": "long"
          },
          "user": {
            "type": "text"
          }
        }
      }
    }
```
这里我们我们修改了location及其它的一些数据项的数据类型。运行上面的指令，我们就可以创建一个完全新的twitter3的index。我们可以通过如下的命令来进行reindex：
```
    POST _reindex
    {
      "source": {
        "index": "twitter2"
      },
      "dest": {
        "index": "twitter3"
      }
    }
```
显示的结果是：
```
    {
      "took" : 52,
      "timed_out" : false,
      "total" : 1,
      "updated" : 0,
      "created" : 1,
      "deleted" : 0,
      "batches" : 1,
      "version_conflicts" : 0,
      "noops" : 0,
      "retries" : {
        "bulk" : 0,
        "search" : 0
      },
      "throttled_millis" : 0,
      "requests_per_second" : -1.0,
      "throttled_until_millis" : 0,
      "failures" : [ ]
    }
```
我们可以通过如下的命令来检查我们的twitter3是否已经有新的数据：
```
GET /twitter3/_search
```
显示的结果是：
```
    {
      "took" : 100,
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
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "twitter3",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 1.0,
            "_source" : {
              "user" : "双榆树-张三",
              "message" : "今儿天气不错啊，出去转转去",
              "uid" : 2,
              "age" : 20,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市海淀区",
              "location" : {
                "lat" : "39.970718",
                "lon" : "116.325747"
              }
            }
          }
        ]
      }
    }
```
显然我们的数据已经从twitter2到twitter3，并且它的数据类型已经是完全符合我们要求的数据类型。
 
# Reindex执行

- Reindex是一个时间点的副本
- 就像上面返回的结果显示的那样，它是以batch（批量）的方式来执行的。默认的批量大小为1000
- 你也可以只拷贝源index其中的一部分数据
    -  通过加入query到source中
    -  通过定义max_docs参数

比如：
```
    POST _reindex
    {
      "max_docs": 100,
      "source": {
        "index": "twitter2",
        "query": {
          "match": {
            "city": "北京"
          }
        }
      },
      "dest": {
        "index": "twitter3"
      }
    }
```
这里，我们定义最多不超过100个文档，同时，我们只拷贝来自“北京”的twitter记录。

设置op_type to create将导致_reindex仅在目标索引中创建缺少的文档。 所有现有文档都会导致版本冲突，比如：
```
    POST _reindex
    {
      "source": {
        "index": "twitter2"
      },
      "dest": {
        "index": "twitter3",
        "op_type": "create"
      }
    }
```
如果我们之前已经做过reindex，那么我们可以看到如下的结果：
```
    {
      "took": 2,
      "timed_out": false,
      "total": 1,
      "updated": 0,
      "created": 0,
      "deleted": 0,
      "batches": 1,
      "version_conflicts": 1,
      "noops": 0,
      "retries": {
        "bulk": 0,
        "search": 0
      },
      "throttled_millis": 0,
      "requests_per_second": -1,
      "throttled_until_millis": 0,
      "failures": [
        {
          "index": "twitter3",
          "type": "_doc",
          "id": "1",
          "cause": {
            "type": "version_conflict_engine_exception",
            "reason": "[1]: version conflict, document already exists (current version [5])",
            "index_uuid": "ffz2LNIIQqqDx211R5f4fQ",
            "shard": "0",
            "index": "twitter3"
          },
          "status": 409
        }
      ]
    }
```
它表明我们之前的文档id为1的有版本上的冲突。

默认情况下，版本冲突会中止_reindex进程。 “conflict”请求body参数可用于指示_reindex继续处理版本冲突的下一个文档。 请务必注意，其他错误类型的处理不受“conflict”参数的影响。 当“conflict”：在请求正文中设置“proceed”时，_reindex进程将继续发生版本冲突并返回遇到的版本冲突计数：
```
    POST _reindex
    {
      "conflicts": "proceed",
      "source": {
        "index": "twitter"
      },
      "dest": {
        "index": "new_twitter",
        "op_type": "create"
      }
    }
```

# Throttling

重新索引大量文档可能会使您的群集泛滥甚至崩溃。requests_per_second限制索引操作速率。
```
    POST _reindex?requests_per_second=500 
    {
      "source": {
        "index": "blogs",
        "size": 500
      },
      "dest": {
        "index": "blogs_fixed"
      }
    }
```
 
# 运用index别名来进行reindex

我们可以通过如下的方法来实现从一个index到另外一个index的数据转移：
```
    PUT test     
    PUT test_2   
    POST /_aliases
    {
        "actions" : [
            { "add":  { "index": "test_2", "alias": "test" } },
            { "remove_index": { "index": "test" } }  
        ]
    }
```
在上面的例子中，假如我们地添加了一个叫做test的index，而test_2是我们想要的。我们直接可以通过上面的方法吧test中的数据交换到test_2中，并同时把test索引删除。

 
# 从远处进行reindex

`_reindex`也支持从一个远处的Elasticsearch的服务器进行reindex，它的语法为：
```
    POST _reindex
    {
      "source": {
        "index": "blogs",
        "remote": {
          "host": "http://remote_cluster_node1:9200",
          "username": "USERNAME",
          "password": "PASSWORD"
        }
      },
      "dest": {
        "index": "blogs"
      }
    }
```
这里显示它从一个在http://remote_cluster_node1:9200的服务器来拷贝文件从一个index到另外一个index。

参考：
【1】https://www.elastic.co/guide/en/elasticsearch/reference/7.3/docs-reindex.html