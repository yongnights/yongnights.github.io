---
title: Elasticsearch：search template
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
我们发现一些用户经常编写了一些非常冗长和复杂的查询 - 在很多情况下，相同的查询会一遍又一遍地执行，但是会有一些不同的值作为参数来查询。在这种情况下，我们觉得使用一个search template（搜索模板）来做这样的工作非常合适。搜索模板允许您使用可在执行时定义的参数定义查询。

Search template的好处是：

- 避免在多个地方重复代码
- 更容易测试和执行您的查询
- 在应用程序间共享查询
- 允许用户只执行一些预定义的查询
- 将搜索逻辑与应用程序逻辑分离

# 定义一个Search template

首先，我们来定义一个search template来看看它到底是什么东西。使用`_scripts`端点将模板存储在集群状态中。在search template中使用的语言叫做mustache。(http://mustache.github.io/mustache.5.html)
```
    POST _scripts/my_search_template
    {
      "script": {
        "lang": "mustache",
        "source": {
          "query": {
            "match": {
              "{{my_field}}": "{{my_value}}"
            }
          }
        }
      }
    }
```
在这里，我们定义了一个叫做my_search_template的search template。如果我们想更新这个search template，我们可以直接进行修改，然后再次运行上面的命令即可。

<escape><!-- more --></escape>

在match的字段里，我们定义了两个参数：my_field及my_value。下面，我们来首先建立一个叫做twitter的数据库：
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
我们这里把上面的两个文档存于到twitter的index之中。我们现在可以使用我们刚才定义的search template来进行搜索：
```
    GET twitter/_search/template
    {
      "id": "my_search_template",
      "params": {
        "my_field": "city",
        "my_value": "北京"
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
          "value" : 1,
          "relation" : "eq"
        },
        "max_score" : 0.9808292,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.9808292,
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
显示它只显示了我们的city为北京的一个文档，另外一个上海的文档没有做任何的显示。说明我们定义的search template是工作的。

# 条件判断


在Mustache语言中，它没有if/else这样的判断，但是你可以定section来跳过它如果那个变量是false还是没有被定义：
```
    {{#param1}}
        "This section is skipped if param1 is null or false"
    {{/param1}}
```
我们定义如下的一个search template:
```
    POST _scripts/docs_from_beijing_and_age
    {
      "script": {
        "lang": "mustache",
        "source": 
    """
        {
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "city": "{{search_term}}"
                  }
                }
                {{#search_age}}
                ,
                {
                  "range": {
                    "age": {
                      "gte": {{search_age}}
                    }
                  }
                }
                {{/search_age}}
              ]
            }
          }
        }
    """
      }
    }
```
在这里，我们同时定义了两个变量：search_term及search_age。针对search_age，我们做了一个判断，如果它有定义，及做一个range的查询。如果没有定义，就只用search_term。那么我们来做如下的实验：
```
    GET twitter/_search/template
    {
      "id": "docs_from_beijing_and_age",
      "params": {
        "search_term": "北京"
      }
    }
```
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
          "value" : 1,
          "relation" : "eq"
        },
        "max_score" : 0.9808292,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.9808292,
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
显然，city为北京的文档已经被搜索到了。如果我们做如下的查询：
```
    GET twitter/_search/template
    {
      "id": "docs_from_beijing_and_age",
      "params": {
        "search_term": "北京",
        "search_age": "30"
      }
    }
```
我们将搜索不到任何的结果，这是因为在这次查询中search_age已经被启用，而且在数据库中没有一个文档是来自“北京”，并且年龄大于30的。我们可以做如下的查询：
```
    GET twitter/_search/template
    {
      "id": "docs_from_beijing_and_age",
      "params": {
        "search_term": "北京",
        "search_age": "20"
      }
    }
```
那么这次的显示结果为：
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
          "value" : 1,
          "relation" : "eq"
        },
        "max_score" : 1.9808292,
        "hits" : [
          {
            "_index" : "twitter",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 1.9808292,
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
显然这次我们搜索到我们想要的结果。

# 查询search template
```
GET _scripts/<templateid>
```
针对我们的情况：
```
GET _scripts/docs_from_beijing_and_age
```
显示的结果为：
```
    {
      "_id" : "docs_from_beijing_and_age",
      "found" : true,
      "script" : {
        "lang" : "mustache",
        "source" : """
        {
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "city": "{{search_term}}"
                  }
                }
                {{#search_age}}
                ,
                {
                  "range": {
                    "age": {
                      "gte": {{search_age}}
                    }
                  }
                }
                {{/search_age}}
              ]
            }
          }
        }
    """
      }
    }
```
这个正是我们之前定义的一个search template。

# 删除一个search template

我们可以通过如下的命令来删除一个已经创建的search template:
```
DELETE _scripts/<templateid>
```

# 验证search template

我们可以通过_render端点来验证我们的search template。比如：
```
    GET _render/template
    {
      "source": """
        {
          "query": {
            "bool": {
              "must": [
                {
                  "match": {
                    "city": "{{search_term}}"
                  }
                }
                {{#search_age}}
                ,
                {
                  "range": {
                    "age": {
                      "gte": {{search_age}}
                    }
                  }
                }
                {{/search_age}}
              ]
            }
          }
        }
    """,
      "params": {
        "search_term": "北京",
        "search_age": "20"
      }
    }
```
那么显示的结果是：
```
    {
      "template_output" : {
        "query" : {
          "bool" : {
            "must" : [
              {
                "match" : {
                  "city" : "北京"
                }
              },
              {
                "range" : {
                  "age" : {
                    "gte" : 20
                  }
                }
              }
            ]
          }
        }
      }
    }
```
显然，这个就是我们想要的结果。

参考：
【1】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/search-template.html
