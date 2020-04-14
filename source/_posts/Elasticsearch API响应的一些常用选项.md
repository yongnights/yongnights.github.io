---
title: Elasticsearch API响应的一些常用选项
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---

我们可以点击Elasticsearch API以获取所需的响应，但是如果要修改API响应，以便我们更改显示格式或过滤掉某些字段，然后我们可以将这些选项与查询一起应用。 有一些常见的选项可以适用于API，在下面我们来介绍一些常用的选项。

# 准备数据
我们首先使用Bulk API来把我们的文档导入到Elasticsearch中：
```
POST _bulk
{ "index" : { "_index" : "twitter", "_id": 1} }
{"user":"张三","message":"今儿天气不错啊，出去转转去","uid":2,"city":"北京","province":"北京","country":"中国","address":"中国北京市海淀区","location":{"lat":"39.970718","lon":"116.325747"}, "DOB":"1980-12-01"}
{ "index" : { "_index" : "twitter", "_id": 2 }}
{"user":"老刘","message":"出发，下一站云南！","uid":3,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区台基厂三条3号","location":{"lat":"39.904313","lon":"116.412754"}, "DOB":"1981-12-01"}
{ "index" : { "_index" : "twitter", "_id": 3} }
{"user":"李四","message":"happy birthday!","uid":4,"city":"北京","province":"北京","country":"中国","address":"中国北京市东城区","location":{"lat":"39.893801","lon":"116.408986"}, "DOB":"1982-12-01"}
{ "index" : { "_index" : "twitter", "_id": 4} }
{"user":"老贾","message":"123,gogogo","uid":5,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区建国门","location":{"lat":"39.718256","lon":"116.367910"}, "DOB":"1983-12-01"}
{ "index" : { "_index" : "twitter", "_id": 5} }
{"user":"老王","message":"Happy BirthDay My Friend!","uid":6,"city":"北京","province":"北京","country":"中国","address":"中国北京市朝阳区国贸","location":{"lat":"39.918256","lon":"116.467910"}, "DOB":"1984-12-01"}
{ "index" : { "_index" : "twitter", "_id": 6} }
{"user":"老吴","message":"好友来了都今天我生日，好友来了,什么 birthday happy 就成!","uid":7,"city":"上海","province":"上海","country":"中国","address":"中国上海市闵行区","location":{"lat":"31.175927","lon":"121.383328"}, "DOB":"1985-12-01"}
```
这样我们就有6个文档了。

<escape><!-- more --></escape>

# Pretty=true
我们在我们的请求里加入?pretty=true可以使用这个选项使我们的显示格式更加漂亮。当我们调试我们的接口时，这个是推荐的用法。比如：
```
GET twitter/_doc/1?pretty=true
```
显示结果：
```
{
  "_index" : "twitter",
  "_type" : "_doc",
  "_id" : "1",
  "_version" : 2,
  "_seq_no" : 6,
  "_primary_term" : 5,
  "found" : true,
  "_source" : {
    "user" : "张三",
    "message" : "今儿天气不错啊，出去转转去",
    "uid" : 2,
    "city" : "北京",
    "province" : "北京",
    "country" : "中国",
    "address" : "中国北京市海淀区",
    "location" : {
      "lat" : "39.970718",
      "lon" : "116.325747"
    },
    "DOB" : "1980-12-01"
  }
}
```
在一般的情况下，在Kibana的Dev tools中，显示就是这样的结果。

# format
在默认的情况先返回的结果都是以JSON格式的。对于有些情况来说，我们可能需要的结果是yml格式的，那么我们可以使用format-yaml格式来返回yaml格式的结果：
```
GET twitter/_doc/1?format=yaml
```
返回结果：
```
---
_index: "twitter"
_type: "_doc"
_id: "1"
_version: 2
_seq_no: 6
_primary_term: 5
found: true
_source:
  user: "张三"
  message: "今儿天气不错啊，出去转转去"
  uid: 2
  city: "北京"
  province: "北京"
  country: "中国"
  address: "中国北京市海淀区"
  location:
    lat: "39.970718"
    lon: "116.325747"
  DOB: "1980-12-01"
```
显然这个是yaml格式的结果。

# human
有一些人类可读的值将以某种方式返回结果让我们更容易理解。 例如，3,600,000毫秒令人困惑，但是1个小时是清楚的。 设置human=true可将结果转换为更易读的响应。假如我们想得到当前索引的配置：
```
GET twitter/_settings
```
那么显示的结果是：
```
{
  "twitter" : {
    "settings" : {
      "index" : {
        "creation_date" : "1577087951094",
        "number_of_shards" : "1",
        "number_of_replicas" : "1",
        "uuid" : "y3PqEnjBRnKPFHDPTrirkA",
        "version" : {
          "created" : "7050099"
        },
        "provided_name" : "twitter"
      }
    }
  }
}
```
显然这里的create_date和created版本信息都是我们没法理解的。在这个时候如果我们加上human=true再来看看显示的结果：
```
GET twitter/_settings?human=true
```
这次显示的结果是：
```
{
  "twitter" : {
    "settings" : {
      "index" : {
        "creation_date_string" : "2019-12-23T07:59:11.094Z",
        "number_of_shards" : "1",
        "provided_name" : "twitter",
        "creation_date" : "1577087951094",
        "number_of_replicas" : "1",
        "uuid" : "y3PqEnjBRnKPFHDPTrirkA",
        "version" : {
          "created_string" : "7.5.0",
          "created" : "7050099"
        }
      }
    }
  }
}
```
这一次，我们可以清楚地看到creation_date_string及created_string的值了。

# filter_path
在查询中使用filter_path参数，我们可以减少来自Elasticsearch。 它支持过滤器列表或通配符以匹配字段名称或部分字段名称。

首先，我们来做一个正常的查询：
```
GET twitter/_search
```
返回的结果是：
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
      "value" : 6,
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
          "user" : "张三",
          "message" : "今儿天气不错啊，出去转转去",
          "uid" : 2,
          "city" : "北京",
          "province" : "北京",
          "country" : "中国",
          "address" : "中国北京市海淀区",
          "location" : {
            "lat" : "39.970718",
            "lon" : "116.325747"
          },
          "DOB" : "1980-12-01"
        }
      },
    ...
   ]
...
```
假如我们只想返回我们想要的一些字段，那么怎么办？我们可以通过配置filter_path来进行选择，比如：
```
GET twitter/_search?filter_path=hits.hits._source.user, hits.hits._source.country
```
在上面，我们通过filter_path来选择想要的user及country字段。返回的结果是：
```
{
  "hits" : {
    "hits" : [
      {
        "_source" : {
          "user" : "张三",
          "country" : "中国"
        }
      },
      {
        "_source" : {
          "user" : "老刘",
          "country" : "中国"
        }
      },
      {
        "_source" : {
          "user" : "李四",
          "country" : "中国"
        }
      },
      {
        "_source" : {
          "user" : "老贾",
          "country" : "中国"
        }
      },
      {
        "_source" : {
          "user" : "老王",
          "country" : "中国"
        }
      },
      {
        "_source" : {
          "user" : "老吴",
          "country" : "中国"
        }
      }
    ]
  }
}
```

# flat_settings
将flat_settings过滤器设置为true将以flat格式返回结果。 如果设置为假，它将以更易理解的格式返回结果，比如，正常情况下：
```
GET twitter/_settings
```
返回的结果是:
```
{
  "twitter" : {
    "settings" : {
      "index" : {
        "creation_date" : "1577862721663",
        "number_of_shards" : "1",
        "number_of_replicas" : "1",
        "uuid" : "4IwiEL23Roa8DIs2chxVTQ",
        "version" : {
          "created" : "7050099"
        },
        "provided_name" : "twitter"
      }
    }
  }
}
```
如果我们设置flat_settings=true，那么：
```
GET twitter/_settings?flat_settings=true
```
返回的结果是：
```
{
  "twitter" : {
    "settings" : {
      "index.creation_date" : "1577862721663",
      "index.number_of_replicas" : "1",
      "index.number_of_shards" : "1",
      "index.provided_name" : "twitter",
      "index.uuid" : "4IwiEL23Roa8DIs2chxVTQ",
      "index.version.created" : "7050099"
    }
  }
}
```
————————————————
版权声明：本文为CSDN博主「Elastic 中国社区官方博客」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/UbuntuTouch/article/details/103792780