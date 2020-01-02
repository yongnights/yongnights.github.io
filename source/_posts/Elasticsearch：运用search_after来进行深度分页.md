---
title: Elasticsearch：运用search_after来进行深度分页
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在上一篇文章 “Elasticsearch：运用scroll接口对大量数据实现更好的分页”，我们讲述了如何运用scroll接口来对大量数据来进行有效地分页。在那篇文章中，我们讲述了两种方法：

- from加上size的方法来进行分页
- 运用scroll接口来进行分页

对于大量的数据而言，我们尽量避免使用from+size这种方法。这里的原因是index.max_result_window的默认值是10K，也就是说from+size的最大值是1万。搜索请求占用堆内存和时间与from+size成比例，这限制了内存。假如你想hit从990到1000，那么每个shard至少需要1000个文档：

![](https://img-blog.csdnimg.cn/20190919215711682.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

为了避免过度使得我们的cluster繁忙，通常Scroll接口被推荐作为深层次的scrolling，但是因为维护scroll上下文也是非常昂贵的，所以这种方法不推荐作为实时用户请求。search_after参数通过提供实时cursor来解决此问题。 我们的想法是使用上一页的结果来帮助检索下一页。

我们先输入如下的文档到twitter索引中：
```
    POST _bulk
    { "index" : { "_index" : "twitter", "_id": 1} }
    {"user":"双榆树-张三", "DOB":"1980-01-01", "message":"今儿天气不错啊，出去转转去","uid":2,"age":20,"city":"北京","province":"北京","country":"中国","address":"中国北京市海淀区","location":{"lat":"39.970718","lon":"116.325747"}}
    { "index" : { "_index" : "twitter", "_id": 2 }}
    {"user":"东城区-老刘", "DOB":"1981-01-01", "message":"出发，下一站云南！","uid":3,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区台基厂三条3号","location":{"lat":"39.904313","lon":"116.412754"}}
    { "index" : { "_index" : "twitter", "_id": 3} }
    {"user":"东城区-李四", "DOB":"1982-01-01", "message":"happy birthday!","uid":4,"age":30,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区","location":{"lat":"39.893801","lon":"116.408986"}}
    { "index" : { "_index" : "twitter", "_id": 4} }
    {"user":"朝阳区-老贾","DOB":"1983-01-01", "message":"123,gogogo","uid":5,"age":35,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区建国门","location":{"lat":"39.718256","lon":"116.367910"}}
    { "index" : { "_index" : "twitter", "_id": 5} }
    {"user":"朝阳区-老王","DOB":"1984-01-01", "message":"Happy BirthDay My Friend!","uid":6,"age":50,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区国贸","location":{"lat":"39.918256","lon":"116.467910"}}
    { "index" : { "_index" : "twitter", "_id": 6} }
    {"user":"虹桥-老吴", "DOB":"1985-01-01", "message":"好友来了都今天我生日，好友来了,什么 birthday happy 就成!","uid":7,"age":90,"city":"上海","province":"上海","country":"中国","address":"中国上海市闵行区","location":{"lat":"31.175927","lon":"121.383328"}}
```

<escape><!-- more --></escape>

这里共有6个文档。假设检索第一页的查询如下所示：
```
    GET twitter/_search
    {
      "size": 2,
      "query": {
        "match": {
          "city": "北京"
        }
      },
      "sort": [
        {
          "DOB": {
            "order": "asc"
          }
        },
        {
          "user.keyword": {
            "order": "asc"
          }
        }
      ]
    }
```
显示的结果为：
```
    {
      "took" : 29,
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
        "max_score" : null,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : null,
            "_source" : {
              "user" : "双榆树-张三",
              "DOB" : "1980-01-01",
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
            },
            "sort" : [
              315532800000,
              "双榆树-张三"
            ]
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : null,
            "_source" : {
              "user" : "东城区-老刘",
              "DOB" : "1981-01-01",
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
            },
            "sort" : [
              347155200000,
              "东城区-老刘"
            ]
          }
        ]
      }
    }
```
上述请求的结果包括每个文档的sort值数组。 这些sort值可以与search_after参数一起使用，以开始返回在这个结果列表之后的任何文档。 例如，我们可以使用上一个文档的sort值并将其传递给search_after以检索下一页结果：
```
    GET twitter/_search
    {
      "size": 2,
      "query": {
        "match": {
          "city": "北京"
        }
      },
      "search_after": [
        347155200000,
        "东城区-老刘"
      ],
      "sort": [
        {
          "DOB": {
            "order": "asc"
          }
        },
        {
          "user.keyword": {
            "order": "asc"
          }
        }
      ]
    }
```
在这里在search_after中，我们把上一个搜索结果的sort值放进来。 显示的结果为：
```
    {
      "took" : 47,
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
        "max_score" : null,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "3",
            "_score" : null,
            "_source" : {
              "user" : "东城区-李四",
              "DOB" : "1982-01-01",
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
            },
            "sort" : [
              378691200000,
              "东城区-李四"
            ]
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "4",
            "_score" : null,
            "_source" : {
              "user" : "朝阳区-老贾",
              "DOB" : "1983-01-01",
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
            },
            "sort" : [
              410227200000,
              "朝阳区-老贾"
            ]
          }
        ]
      }
    }
```
注意：当我们使用search_after时，from值必须设置为0或者-1。

search_after不是自由跳转到随机页面而是并行scroll多个查询的解决方案。 它与scroll API非常相似，但与它不同，search_after参数是无状态的，它始终针对最新版本的搜索器进行解析。 因此，排序顺序可能会在步行期间发生变化，具体取决于索引的更新和删除。
