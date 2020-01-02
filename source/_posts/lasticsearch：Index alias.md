---
title: lasticsearch：Index alias
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
现在让我们来谈谈Elasticsearch最简单和最有用的功能之一：别名 （alias)。为了区分这里alias和文章“Elasticsearch : alias数据类型”，这里的别名（alias）指的是index的别名。 别名正是他们听起来的样子; 它们是您可以使用的指针或名称，对应于一个或多个具体索引。 事实证明这非常有用，因为它在扩展集群和管理数据在索引中的布局方式时提供了灵活性。 即使使用Elasticsearch 只有一个索引的集群，使用别名。 您将在以后感谢我们给予您的灵活性。
 
# 别名到底是什么？

您可能想知道别名究竟是什么，以及Elasticsearch在创建别名时涉及何种开销。 别名将其生命置于群集状态内，由主节点（master node)管理; 这意味着如果你有一个名为idaho的别名指向一个名为potato的索引，那么开销就是群集状态映射中的一个额外键，它将名称idaho映射到具体的索引字符串。 这意味着与其他指数相比，别名的重量要轻得多; 可以维护数千个而不会对集群产生负面影响。 也就是说，我们会警告不要创建数十万或数百万个别名，因为在这一点上，即使映射中单个条目的最小开销也会导致集群状态增长到大小。 这意味着创建新群集状态的操作将花费更长时间，因为每次更改时都会将整个群集状态发送到每个节点。

 
# 为什么别名是有用的？

我们建议每个人都为他们的Elasticsearch索引使用别名，因为在重新索引时，它将在未来提供更大的灵活性。 假设您首先创建一个包含单个主分片的索引，然后再决定是否需要更多索引容量。 如果您使用原始别名index，您现在可以将该别名更改为指向另外创建的索引，而无需更改您正在搜索的索引的名称（假设您从头开始使用别名进行搜索）。 另一个有用的功能是可以创建不同索引的窗口; 例如，如果您为数据创建每日索引，则可能需要创建一个名为last-7-days的别名的上周数据的滑动窗口; 然后每天创建新的每日索引时，可以将其添加到别名中，同时删除8天的索引。

另外的一种场景是，当我们修改了我们的index的mapping，让后通过reindex API来把我们的现有的index转移到新的index上，那么如果在我们的应用中，我们利用alias就可以很方便地做这间事。在我们成功转移到新的index之后，我们只需要重新定义我们的alias指向新的index，而在我们的客户端代码中，我们一直使用alias来访问我们的index，这样我们的代码不需要任何的改动。

![](https://img-blog.csdnimg.cn/20190905093209136.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

# 建立index

为了验证我们的API，我们先建立一些数据：
```
    PUT twitter/_doc/1
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
     
    PUT twitter/_doc/2
    {
      "user" : "东城区-老刘",
      "message" : "出发，下一站云南！",
      "uid" : 3,
      "age" : 30,
      "city" : "北京",
      "province" : "北京",
      "country" : "中国",
      "address" : "中国北京市东城区台基厂三条3号",
      "location" : {
        "lat" : "39.904313",
        "lon" : "116.412754"
      }
    }
     
    PUT twitter/_doc/3
    {
      "user" : "虹桥-老吴",
      "message" : "好友来了都今天我生日，好友来了,什么 birthday happy 就成!",
      "uid" : 7,
      "age" : 90,
      "city" : "上海",
      "province" : "上海",
      "country" : "中国",
      "address" : "中国上海市闵行区",
      "location" : {
        "lat" : "31.175927",
        "lon" : "121.383328"
      }
    }
```
这样，我们建立了三个文档的twitter索引。

 
# 管理别名

## 添加一个index alias

一个index别名就是一个用来引用一个或多个已经存在的索引的另外一个名字，我们可以用如下的方法来创建
```
PUT /twitter/_alias/alias1
```
请求的格式：
```
PUT /<index>/_alias/<alias>
POST /<index>/_alias/<alias>
PUT /<index>/_aliases/<alias>
POST /<index>/_aliases/<alias>
```
路径参数：
```
<index>:要添加到别名的索引名称的逗号分隔列表或通配符表达式。
         要将群集中的所有索引添加到别名，请使用_all值。
<alias>:(必需,字符串)要创建或更新的索引别名的名称。
```
比如经过上面的REST 请求，我们为twitter创建了另外一个别名alias1。我们以后可以通过alias1来访问这个index:
```
GET alias1/_search
```
显示的结果：
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
          "value" : 3,
          "relation" : "eq"
        },
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "4",
            "_score" : 1.0,
            "_source" : {
              "user" : "朝阳区-老贾",
              "message" : "123,gogogo",
              "uid" : 5,
              "age" : 35,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市朝阳区建国门",
              "location" : {
                "lat" : "39.718256",
                "lon" : "116.367910"
              }
            }
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "5",
            "_score" : 1.0,
            "_source" : {
              "user" : "朝阳区-老王",
              "message" : "Happy BirthDay My Friend!",
              "uid" : 6,
              "age" : 50,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市朝阳区国贸",
              "location" : {
                "lat" : "39.918256",
                "lon" : "116.467910"
              }
            }
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "6",
            "_score" : 1.0,
            "_source" : {
              "user" : "虹桥-老吴",
              "message" : "好友来了都今天我生日，好友来了,什么 birthday happy 就成!",
              "uid" : 7,
              "age" : 90,
              "city" : "上海",
              "province" : "上海",
              "country" : "中国",
              "address" : "中国上海市闵行区",
              "location" : {
                "lat" : "31.175927",
                "lon" : "121.383328"
              }
            }
          },
      ...
```
显然这样做的好处是非常明显的，我们可以把我们想要的进行搜索的index取一个和我们搜索方法里一样的别名就可以了，这样我们可以不修改我们的搜索方法，就可以分别对不同的index进行搜索。比如我们可以用同样的搜索方法对每天的log进行分析。只有把每天的log的index的名字都改成一样的alias就可以了。

创建一个基于城市的alias：
```
    PUT twitter/_alias/city_beijing
    {
      "filter": {
        "term": {
          "city": "北京"
        }
      }
    }
```
在这里，我们创建了一个名称为city_beijing的alias。如果我们运行如下的搜索：
```
GET city_beijing/_search
```
它将返回所有关于城市为北京的搜索结果：
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
          "value" : 4,
          "relation" : "eq"
        },
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "4",
            "_score" : 1.0,
            "_source" : {
              "user" : "朝阳区-老贾",
              "message" : "123,gogogo",
              "uid" : 5,
              "age" : 35,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市朝阳区建国门",
              "location" : {
                "lat" : "39.718256",
                "lon" : "116.367910"
              }
            }
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "5",
            "_score" : 1.0,
            "_source" : {
              "user" : "朝阳区-老王",
              "message" : "Happy BirthDay My Friend!",
              "uid" : 6,
              "age" : 50,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市朝阳区国贸",
              "location" : {
                "lat" : "39.918256",
                "lon" : "116.467910"
              }
    ...
```
alias也可以在创建index时被创建，比如：
```
    DELETE twitter
     
    PUT twitter
    {
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
              "type" : "keyword",
              "copy_to" : [
                "region"
              ]
            },
            "country" : {
              "type" : "keyword",
              "copy_to" : [
                "region"
              ]
            },
            "explain" : {
              "type" : "boolean"
            },
            "location" : {
              "type" : "geo_point"
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
              "type" : "keyword",
              "copy_to" : [
                "region"
              ]
            },
            "region" : {
              "type" : "text"
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
        },
        "aliases": {
          "city_beijing": {
            "filter": {
              "term": {
                "city": "北京"
              }
            }
          }
        }
    }
```
在这里，我们删除了twitter索引，同时我们重新定义twitter索引的mapping，并同时定义了city_beijing你别名。重新index我们上面的三个文档，那么我们再次搜索我们的数据：
```
GET city_beijing/_search
```
我们可以看到两个城市为北京的搜索结果：
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
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "twitter",
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
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 1.0,
            "_source" : {
              "user" : "东城区-老刘",
              "message" : "出发，下一站云南！",
              "uid" : 3,
              "age" : 30,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市东城区台基厂三条3号",
              "location" : {
                "lat" : "39.904313",
                "lon" : "116.412754"
              }
            }
          }
        ]
      }
    }
```

# 获取alias

我们可以通过如下的API来获取当前以及定义好的alias:
```
GET /_alias
GET /_alias/<alias>
GET /<index>/_alias/<alias>
```
比如：
```
GET /twitter/_alias/alias1
```
这里获取在twitter下的名字叫做alias1的别名。针对我们的情况，我们使用如下的接口：
```
GET /twitter/_alias/city_beijing
```
我们获取我们之前得到的city_beijing的alias。显示的结果如下：
```
    {
      "twitter" : {
        "aliases" : {
          "city_beijing" : {
            "filter" : {
              "term" : {
                "city" : "北京"
              }
            }
          }
        }
      }
    }
```
你也可以通过如下的wild card方式来获取所有的alias:
```
GET /twitter/_alias/*
```
比如，我们新增加一个alias1的别名：
```
PUT /twitter/_alias/alias1
```
上面的wild card方式返回来得结果为：
```
    {
      "twitter" : {
        "aliases" : {
          "alias1" : { },
          "city_beijing" : {
            "filter" : {
              "term" : {
                "city" : "北京"
              }
            }
          }
        }
      }
    }
```
显然这里有两个别名：alias1及city_beijing。

你可以通过如下的方式来搜寻你的alias:
```
GET /_alias/city_*
```
它将显示名字以city开始的所有的alias。


# 检查一个alias是否存在

我们可以通过如下的方式来检查一个alias是否存在：
```
HEAD /_alias/<alias>
HEAD /<index>/_alias/<alias>
```
比如：
```
HEAD /_alias/alias1
```
它显示的结果是：
```
200 - OK
```
同样你也可通过wild card方式来查询：
```
HEAD /_alias/city*
```
这个用来检查所有以city为开头的alias。
 
# 更新alias

我们这里所说的更新包括：添加及删除

接口为：
```
POST /_aliases
```
比如：
```
    POST /_aliases
    {
        "actions" : [
            { "add" : { "index" : "twitter", "alias" : "alias2" } }
        ]
    }
```
在这里，我们为twitter索引添加了一个叫做alias2的别名。运行后，我们可以通过alias2来重新搜索我们的twitter
```
GET /alias2/_search
```
我们可以看到我们想要的结果：
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
          "value" : 3,
          "relation" : "eq"
        },
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "twitter",
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
          },
     
    ...
```
在action里，我们可以有如下的几种：
```
add: 添加一个别名
remove: 删除一个别名
remove_index: 删除一个index或它的别名
```
比如我们可以通过如下的方法来删除一个alias
```
    POST /_aliases
    {
        "actions" : [
            { "remove": { "index" : "twitter", "alias" : "alias2" } }
        ]
    }
```
一旦删除后，之前的定义的alias2就不可以用了。
 
# 重新命名一个alias

重命名别名是一个简单的删除然后在同一API中添加操作。 此操作是原子操作，无需担心别名未指向索引的短时间段：
```
    POST /_aliases
    {
        "actions" : [
            { "remove" : { "index" : "twitter", "alias" : "alias1" } },
            { "add" : { "index" : "twitter", "alias" : "alias2" } }
        ]
    }
```
上面的操作，删除alias1，同时创建一个新的叫做alias2的别名。

我们也可以把同一个alias在指向不同时期的index，比如我们的log index滚动下一个月，我们可以修改我们的alias总是指向最新的index。

![](https://img-blog.csdnimg.cn/20190905094821417.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

# 为多个索引添加同样一个alias

将别名与多个索引相关联只需几个添加操作：
```
    POST /_aliases
    {
        "actions" : [
            { "add" : { "index" : "test1", "alias" : "alias1" } },
            { "add" : { "index" : "test2", "alias" : "alias1" } }
        ]
    }
```
你也可以通过如下的方式，通过一个add命令来完成：
```
    POST /_aliases
    {
        "actions" : [
            { "add" : { "indices" : ["test1", "test2"], "alias" : "alias1" } }
        ]
    }
```
甚至：
```
    POST /_aliases
    {
        "actions" : [
            { "add" : { "index" : "test*", "alias" : "all_test_indices" } }
        ]
    }
```
这样所有以`test*`为开头的索引都共同一个别名。

当我们index我们的文档时，对一个指向多个index的别名进行索引是错误的。

也可以在一个操作中使用别名交换索引：
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

# Filtered alias

带有过滤器的别名提供了一种创建同一索引的不同“视图”的简便方法。 可以使用Query DSL定义过滤器，并使用此别名将其应用于所有“搜索”，“计数”，“按查询删除”和“更多此类操作”。

要创建过滤后的别名，首先我们需要确保映射中已存在这些字段：
```
    PUT /test1
    {
      "mappings": {
        "properties": {
          "user" : {
            "type": "keyword"
          }
        }
      }
    }
```
现在我们可以利用filter来创建一个alias，是基于user字段
```
    POST /_aliases
    {
        "actions" : [
            {
                "add" : {
                     "index" : "test1",
                     "alias" : "alias2",
                     "filter" : { "term" : { "user" : "kimchy" } }
                }
            }
        ]
    }
```

# Write index

可以将别名指向的索引关联为write索引。 指定后，针对指向多个索引的别名的所有索引和更新请求将尝试解析为write索引的一个索引。 每个别名只能将一个索引分配为一次write索引。 如果未指定write索引且别名引用了多个索引，则不允许写入。

可以使用别名API和索引创建API将与别名关联的索引指定为write索引。
```
    POST /_aliases
    {
        "actions" : [
            {
                "add" : {
                     "index" : "test",
                     "alias" : "alias1",
                     "is_write_index" : true
                }
            },
            {
                "add" : {
                     "index" : "test2",
                     "alias" : "alias1"
                }
            }
        ]
    }
```
在这里，我们定义了alias1同时指向test及test2两个索引。其中test中，注明了is_write_index，那么，如下的操作：
```
    PUT /alias1/_doc/1
    {
        "foo": "bar"
    }
```
相当于如下的操作：
```
PUT /test/_doc/1
```
也就是写入到test索引中，而不会写入到test2中。

要交换哪个索引是别名的写入索引，可以利用别名API进行原子交换。 交换不依赖于操作的顺序。
```
    POST /_aliases
    {
        "actions" : [
            {
                "add" : {
                     "index" : "test",
                     "alias" : "alias1",
                     "is_write_index" : false
                }
            }, {
                "add" : {
                     "index" : "test2",
                     "alias" : "alias1",
                     "is_write_index" : true
                }
            }
        ]
    }
```
参考：
【1】https://www.elastic.co/guide/en/elasticsearch/reference/7.3/indices-aliases.html
【2】https://www.elastic.co/guide/en/elasticsearch/reference/7.3/indices-get-alias.html
【3】https://www.elastic.co/guide/en/elasticsearch/reference/7.3/indices-add-alias.html
