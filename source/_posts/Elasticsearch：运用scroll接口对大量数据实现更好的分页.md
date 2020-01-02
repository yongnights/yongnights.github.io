---
title: Elasticsearch：运用scroll接口对大量数据实现更好的分页
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在Elasticsearch中，我们可以通过size和from来对我们的结果来进行分页。但是对于数据量很大的索引，这是有效的吗？Scroll API可用于从单个搜索请求中检索大量结果（甚至所有结果），这与在传统数据库上使用cursor的方式非常相似。Scroll不是用于实时用户请求，而是用于处理大量数据，例如，用于处理大量数据。 为了将一个索引的内容重新索引到具有不同配置的新索引中。

为了说明问题，我们今天先创建一个叫做twitter的Index:
```
    POST _bulk
    { "index" : { "_index" : "twitter", "_id": 1} }
    {"user":"双榆树-张三","message":"今儿天气不错啊，出去转转去","uid":2,"age":20,"city":"北京","province":"北京","country":"中国","address":"中国北京市海淀区","location":{"lat":"39.970718","lon":"116.325747"}}
    { "index" : { "_index" : "twitter", "_id": 2 }}
    {"user":"东城区-老刘","message":"出发，下一站云南！","uid":3,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区台基厂三条3号","location":{"lat":"39.904313","lon":"116.412754"}}
    { "index" : { "_index" : "twitter", "_id": 3} }
    {"user":"东城区-李四","message":"happy birthday!","uid":4,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区","location":{"lat":"39.893801","lon":"116.408986"}}
    { "index" : { "_index" : "twitter", "_id": 4} }
    {"user":"朝阳区-老贾","message":"123,gogogo","uid":5,"age":35,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区建国门","location":{"lat":"39.718256","lon":"116.367910"}}
    { "index" : { "_index" : "twitter", "_id": 5} }
    {"user":"朝阳区-老王","message":"Happy BirthDay My Friend!","uid":6,"age":50,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区国贸","location":{"lat":"39.918256","lon":"116.467910"}}
    { "index" : { "_index" : "twitter", "_id": 6} }
    {"user":"虹桥-老吴","message":"好友来了都今天我生日，好友来了,什么 birthday happy 就成!","uid":7,"age":90,"city":"上海","province":"上海","country":"中国","address":"中国上海市闵行区","location":{"lat":"31.175927","lon":"121.383328"}}
```
在上面，我们创建了6个文档。这些文档的数量虽然不是很多，但是我们想为了说明问题的方便。在实际的使用中，我们可能有成百上千的文档。

<escape><!-- more --></escape>

下面，我们通过size和from的方法来进行分页。假如我们把sizs设置为2，那么，我们可以通过如下写的方法来进行分页。
```
    GET twitter/_search?size=2&from=0
    GET twitter/_search?size=2&from=2
    GET twitter/_search?size=2&from=4
```
这样，我们每次可以得到2个文档，从而对我们的Index进行分页。我们可以得到这些数据并在自己的页面上或应用里进行展示。通常这样的每个请求返回的上线是10K。如果超过这个上限的话，这样的方法将不再适合。

上面的这种方法，对于小量的数据是可行的，但是对于大量的数据，而且我们需要进行sort时，这个有可能变得力不从心，比如：
```
    GET twitter/_search
    {
      "query": {
        "match": {
          "city": "北京"
        }
      },
      "from": 2,
      "size": 2,
      "sort": [
        {
          "user.keyword": {
            "order": "desc"
          }
        }
      ]
    }
```
你可以想象当你更深入地进行分页时，它会变得多么低效。 例如，如果更改mapping并希望将所有现有数据重新索引到新索引中，您可能没有足够的内存来对所有结果进行排序以返回最后一页的数据。

对于这种应用场景，你可以使用scan搜索类型。我们可以这么做：
# 1. 使用scroll来返回一个初始的搜索，并返回一个scroll ID
```
    GET twitter/_search?scroll=1m
    {
      "query": {
        "match": {
          "city": "北京"
        }
      },
      "size": 2
    }
```
这里的scroll=1m，表明Elasticsearch允许等待的时间是1分钟。如果在一分钟之内，接下来的scroll请求没有到达的话，那么当前的请求的上下文将会丢失。

返回的结果是：
```
    {
      "_scroll_id" : "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAFh8WWUdCVlRMUllRb3UzMkdqb0IxVnZNUQ==",
      "took" : 31,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 5,
          "relation" : "eq"
        },
        "max_score" : 0.48232412,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.48232412,
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
            "_score" : 0.48232412,
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
在这里，我们可以看到一个返回的_scroll_id。这个_scroll_id将会被用于接下来的请求。

# 2. 使用_scroll_id，再次请求

利用上次请求返回来的_scroll_id，再次请求以获得下一个page的信息：
```
    GET _search/scroll
    {
      "scroll": "1m",
      "scroll_id":"DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAHC8WWUdCVlRMUllRb3UzMkdqb0IxVnZNUQ=="
    }
```
在这里必须指出的是：

- 这里填写的scroll_id是上一个请求返回的值
- 这个scroll_id的有效期是我们在第一次搜索时定义的1m，也就是1分钟。如果超过了，这个就没有用

运行后返回的结果是：
```
    {
      "_scroll_id" : "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAHS0WWUdCVlRMUllRb3UzMkdqb0IxVnZNUQ==",
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
          "value" : 5,
          "relation" : "eq"
        },
        "max_score" : 0.48232412,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "3",
            "_score" : 0.48232412,
            "_source" : {
              "user" : "东城区-李四",
              "message" : "happy birthday!",
              "uid" : 4,
              "age" : 30,
              "city" : "北京",
              "province" : "北京",
              "country" : "中国",
              "address" : "中国北京市东城区",
              "location" : {
                "lat" : "39.893801",
                "lon" : "116.408986"
              }
            }
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "4",
            "_score" : 0.48232412,
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
          }
        ]
      }
    }
```
显然这次返回的是2个文档。我们需要再次使用同样的办法来得到最后一个page的结果：
```
    {
      "_scroll_id" : "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAADeoWeno1UkF2RWZRd202VW1HQXRlOWFUdw==",
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
          "value" : 5,
          "relation" : "eq"
        },
        "max_score" : 0.48232412,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "5",
            "_score" : 0.48232412,
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
          }
        ]
      }
    }
```
显然，这次返回的结果只有一个数值，比我们请求的page大小2要小。如果我们利用返回的_scroll_id再次请求时，我们可以看返回的结果是：
```
    {
      "_scroll_id" : "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAADeoWeno1UkF2RWZRd202VW1HQXRlOWFUdw==",
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
          "value" : 5,
          "relation" : "eq"
        },
        "max_score" : 0.48232412,
        "hits" : [ ]
      }
    }
```
这次是一个结果都没有。

如果完成此过程，则需要清理上下文，因为上下文在超时之前仍会占用计算资源。 如下面的屏幕快照所示，您可以使用scroll_id参数在DELETE API中指定一个或多个上下文：
```
    DELTE_search/scroll
    {
      "scroll_id":"DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAHC8WWUdCVlRMUllRb3UzMkdqb0IxVnZNUQ=="
    }
```

参考：
【1】Elasticsearch Scroll
【2】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/search-request-body.html#request-body-search-scroll
