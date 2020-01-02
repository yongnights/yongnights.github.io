---
title: 如何使用Elasticsearch中的copy_to来提高搜索效率
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在今天的这个教程中，我们来着重讲解一下如何使用Elasticsearch中的copy来提高搜索的效率。比如在我们的搜索中，经常我们会遇到如下的文档：
```
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
在这里，我们可以看到在这个文档中，我们有这样的几个字段：
```
     "city" : "北京",
     "province" : "北京",
     "country" : "中国",
```
它们是非常相关的。我们在想是不是可以把它们综合成一个字段，这样可以方便我们的搜索。假如我们要经常对这三个字段进行搜索，那么一种方法我们可以在must子句中使用should子句运行bool查询。这种方法写起来比较麻烦。有没有一种更好的方法呢？

<escape><!-- more --></escape>

我们其实可以使用Elasticsearch所提供的copy_to来提高我们的搜索效率。我们可以首先把我们的index的mapping设置成如下的项（这里假设我们使用的是一个叫做twitter的index)。
```
    PUT twitter
    {
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
            "type": "keyword",
            "copy_to": "region"
          },
          "country": {
            "type": "keyword",
            "copy_to": "region"
          },
          "province": {
            "type": "keyword",
            "copy_to": "region"
          },
          "region": {
            "type": "text",
            "store": true
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
          "uid": {
            "type": "long"
          },
          "user": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          }
        }
      }
    }
```
在这里，我们特别注意如下的这个部分：
```
        "city": {
          "type": "keyword",
          "copy_to": "region"
        },
        "country": {
          "type": "keyword",
          "copy_to": "region"      
        },
        "province": {
          "type": "keyword",
          "copy_to": "region"
        },
        "region": {
          "type": "text"
        }
```
我们把city, country及province三个项合并成为一个项region，但是这个region并不存在于我们文档的source里。当我们这么定义我们的mapping的话，在文档被索引之后，有一个新的region项可以供我们进行搜索。

我们可以采用如下的数据来进行展示：
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
在Kibnana中执行上面的语句，它将为我们生产我们的twitter索引。同时我们可以通过如下的语句来查询我们的mapping:

![](https://img-blog.csdnimg.cn/20190817110033320.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们可以看到twitter的mapping中有一个新的被称作为region的项。它将为我们的搜索带来方便。

那么假如我们想搜索country:中国，province:北京 这样的记录的话，我们可以只写如下的一条语句就可以了：
```
    GET twitter/_search 
    {
      "query": {
        "match": {
          "region": {
            "query": "中国 北京",
            "minimum_should_match": 4
          }
        }
      }
    }
```
下面显示的是搜索的结果：
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
          "value" : 5,
          "relation" : "eq"
        },
        "max_score" : 0.8114117,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.8114117,
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
            "_score" : 0.8114117,
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
          },
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "3",
            "_score" : 0.8114117,
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
            "_score" : 0.8114117,
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
            "_score" : 0.8114117,
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
这样我们只对一个region进行操作就可以了，否则我们需要针对country, city及province分别进行搜索。
 
# 如何查看copy_to的内容

在之前的mapping中，我们对region字段加入了如下的一个属性：
```
          "region": {
            "type": "text",
            "store": true
          }
```
这里的store属性为true，那么我们可以通过如下的命令来查看文档的region的内容：
```
GET twitter/_doc/1?stored_fields=region
```
那么它显示的内容如下：
```
    {
      "_index" : "twitter",
      "_type" : "_doc",
      "_id" : "1",
      "_version" : 1,
      "_seq_no" : 0,
      "_primary_term" : 1,
      "found" : true,
      "fields" : {
        "region" : [
          "北京",
          "北京",
          "中国"
        ]
      }
    }
```
如果你想了解更多关于Elastic Stack，请参阅文章“Elasticsearch简介”
