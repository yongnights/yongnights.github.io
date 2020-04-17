---
title: Elasticsearch：使用_update_by_query更新文档
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---

在很多的情况下，我们我们想更新我们所有的文档：

- 添加一个新的field或者是一个字段变成一个multi-field
- 用一个值更新所有的文档，或者更新复合查询条件的所有文档

在今天的文章中，我们来讲一下_update_by_query的这几个用法。

# 准备数据

我们来创建一个叫做twitter的索引：

<escape><!-- more --></escape>

```shell
PUT twitter
{
  "mappings": {
    "properties": {
      "DOB": {
        "type": "date"
      },
      "address": {
        "type": "keyword"
      },
      "city": {
        "type": "text"
      },
      "country": {
        "type": "keyword"
      },
      "uid": {
        "type": "long"
      },
      "user": {
        "type": "keyword"
      },
      "province": {
        "type": "keyword"
      },
      "message": {
        "type": "text"
      },
      "location": {
        "type": "geo_point"
      }
    }
  }
}
```

我们使用如下的bulk API来把数据导入：

```shell
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

## 把一个字段变为multi-field

在上面，我们有意识地把city字段设置为text，但是在实际的应用中city一般来说是keyword类型。比如我们想对city这个字段来进行aggregation。那么我们该如何纠正这个错误呢？我们需要把我们之前的index删除，并使用新的mapping再次重建吗？这在我们的实际的是使用中可能并不现实。这是因为你的数据可能是非常大的，而且这种改动可能会造成很多的问题。那么我们该如何解决这个问题呢？

一种办法是在不删除之前索引的情况下，我们把city变成为一个mulit-field的字段，这样它既可以是一个keyword的类型，也可以同样是一个text类型的字段。为此，我们来修改twitter的mapping:

```shell
PUT twitter/_mapping
{
  "properties": {
    "DOB": {
      "type": "date"
    },
    "address": {
      "type": "keyword"
    },
    "city": {
      "type": "text",
      "fields": {
        "keyword": {
          "type": "keyword",
          "ignore_above": 256
        }
      }
    },
    "country": {
      "type": "keyword"
    },
    "uid": {
      "type": "long"
    },
    "user": {
      "type": "keyword"
    },
    "province": {
      "type": "keyword"
    },
    "message": {
      "type": "text"
    },
    "location": {
      "type": "geo_point"
    }
  }
}
```

请注意在上面，我们把message的字段变为一个mult-field的字段。即便我们已经把mapping修改了，但是我们的索引并没有把我们的message字段进行分词。为了达到这个目的，我们可以进行如下的操作：

`POST twitter/_update_by_query`

经过上面的操作后，message字段将会被重新被索引，并可以被我们搜索。

```shell
GET twitter/_search
{
  "query": {
    "match": {
      "city.keyword": "北京"
    }
  }
}
```

上面显示的结果为：

```shell
  "hits" : {
    "total" : {
      "value" : 5,
      "relation" : "eq"
    },
    "max_score" : 0.21357408,
    "hits" : [
      {
        "_index" : "twitter",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.21357408,
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
}
```

当然由于这个字段变为multi-field的字段，它含有city.keyword，我们可以对它进行聚合搜索：

```shell
GET twitter/_search
{
  "size": 0,
  "aggs": {
    "city_distribution": {
      "terms": {
        "field": "city.keyword",
        "size": 5
      }
    }
  }
}
```

上面我们对city进行统计，上面显示结果为：

```shell
  "aggregations" : {
    "city_distribution" : {
      "doc_count_error_upper_bound" : 0,
      "sum_other_doc_count" : 0,
      "buckets" : [
        {
          "key" : "北京",
          "doc_count" : 5
        },
        {
          "key" : "上海",
          "doc_count" : 1
        }
      ]
    }
  }
```

如果我们不修改city为multi-field，我们将不能对这个字段进行统计了。

## 增加一个新的字段

同样我们可以通过script的方法来为我们的twitter增加一个新的字段，比如：

```shell
POST twitter/_update_by_query
{
  "script": {
    "source": "ctx._source['contact'] = \"139111111111\""
  }
}
```

通过上面的方法，我们把所有的文档都添加一个新的字段contact，并赋予它一个同样的值：

```shell
GET twitter/_search
{
  "query": {
    "match_all": {}
  }
}
```

上面的命令显示结果：

```shell
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
          "uid" : 2,
          "country" : "中国",
          "address" : "中国北京市海淀区",
          "province" : "北京",
          "city" : "北京",
          "DOB" : "1980-12-01",
          "contact" : "139111111111",
          "location" : {
            "lon" : "116.325747",
            "lat" : "39.970718"
          },
          "message" : "今儿天气不错啊，出去转转去",
          "user" : "张三"
        }
      },
  ...
}
```

从上面我们可以看出来，有增加一个新的字段contact。

## 修改已有的字段

假如我们想对所有在北京的文档里的uid都加1，那么我么有通过如下的方法：

```shell
POST twitter/_update_by_query
{
  "query": {
    "match": {
      "city.keyword": "北京"
    }
  },
  "script": {
    "source": "ctx._source['uid'] += params['one']",
    "params": {
      "one": 1
    }
  }
}
```

在执行上面的命令后，我们进行查询：

```shell
GET twitter/_search
{
  "query": {
    "match": {
      "city.keyword": "北京"
    }
  }
}
```

显示结果：

```shell
  "hits" : {
    "total" : {
      "value" : 5,
      "relation" : "eq"
    },
    "max_score" : 0.24116206,
    "hits" : [
      {
        "_index" : "twitter",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.24116206,
        "_source" : {
          "uid" : 3,
          "country" : "中国",
          "address" : "中国北京市海淀区",
          "province" : "北京",
          "city" : "北京",
          "DOB" : "1980-12-01",
          "contact" : "139111111111",
          "location" : {
            "lon" : "116.325747",
            "lat" : "39.970718"
          },
          "message" : "今儿天气不错啊，出去转转去",
          "user" : "张三"
        }
      },
   ...
}
```

上面显示city为北京的所有的文档的uid的数值都被加1了。上面_id为1的原来的uid值为2，现在变为3。

## 没有动态mapping时，reindex索引

假设您创建了一个没有动态mapping的索引，将其填充了数据，然后添加了一个mapping值以从数据中获取更多字段：

```shell
PUT test
{
  "mappings": {
    "dynamic": false,   
    "properties": {
      "text": {"type": "text"}
    }
  }
}
 
POST test/_doc?refresh
{
  "text": "words words",
  "flag": "bar"
}
 
POST test/_doc?refresh
{
  "text": "words words",
  "flag": "foo"
}
 
PUT test/_mapping   
{
  "properties": {
    "text": {"type": "text"},
    "flag": {"type": "text", "analyzer": "keyword"}
  }
}
```

在上面我们创建一个叫做test的索引。首先它的动态mapping被禁止了，也就是在索引时凡是不在mapping定义的字段将被自动识别，它们仅仅存在于source里，我们不能对它进行搜索。为了纠正这个错误，我们在上面的最后一步尝试来修改它的mapping来解决这个问题。那么在新的mapping下，我们之前导入的文档能进行搜索吗？我们尝试如下的命令：

```shell
POST test/_search?filter_path=hits.total
{
  "query": {
    "match": {
      "flag": "foo"
    }
  }
}
```

我们尝试搜索所有flag中含有foo的文档，但是上面的返回结果是：

```shell
{
  "hits" : {
    "total" : {
      "value" : 0,
      "relation" : "eq"
    }
  }
}
```

那么问题出现在哪里呢？其实在我们修改完mapping以后，我们没有更新我们之前已经导入的文档。我们需要使用_update_by_query来做类似reindex的工作。我们使用如下的命令：

POST test/_update_by_query?refresh&conflicts=proceed

我们重新来搜索我们的文档：

```shell
POST test/_search?filter_path=hits.total
{
  "query": {
    "match": {
      "flag": "foo"
    }
  }
}
```

上面的查询显示的结果是：

```shell
{
  "hits" : {
    "total" : {
      "value" : 1,
      "relation" : "eq"
    }
  }
}
```

显然，在运行完_update_by_query后，我们可以找到我们的文档了。

## 针对大量数据的reindex

上面所有的_update_by_query针对少量的数据还是很不错的。但是在我们的实际应用中，我们可能遇到很大的数据量，那么万一在reindex的过程中发生意外，那我们还需要从头开始吗？或者我们已经处理过的数据还需要再做一遍吗？一种通用的解决办法就是在我们的mapping中定义一个字段，比如叫做reindexBatch，那么我们可以通过添加这个字段来跟踪我们的进度：

```shell
POST blogs_fixed/_update_by_query
{
  "query": {
    "range": {
      "flag": {
        "lt": 1
      }
    }
  },
  "script": {
    "source": "ctx._source['flag']=1"
  }
}
```

即使在reindex的过程已经失败了，我们再次运行上面的_update_by_query时，之前已经处理过的文件将不再被处理了。

_update_by_query 除了上面的用法之外，我们也可以结合pipepline来对我们的索引数据进行加工。详细的用法请参阅我之前的文章“运用Elastic Stack分析COVID-19数据并进行可视化分析”。

更多阅读[Elasticsearch: Reindex接口](https://elasticstack.blog.csdn.net/article/details/100531645 "")。