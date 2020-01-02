
Index template定义在创建新index时可以自动应用的settings和mappings。 Elasticsearch根据与index名称匹配的index模式将模板应用于新索引。这个对于我们想创建的一系列的Index具有同样的settings及mappings。比如我们希望每一天/月的日志的index都具有同样的设置。

![](https://img-blog.csdnimg.cn/20190905104956284.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

Index template仅在index创建期间应用。 对index template的更改不会影响现有索引。 create index API请求中指定的设置和映射会覆盖索引模板中指定的任何设置或映射。

你可以在代码中加入像C语言那样的block注释。你可以把这个注释放在出来开头 “{”和结尾的“}”之间的任何地方。

# 定义一个Index template

我们可以使用如下的接口来定义一个index template：
```
PUT /_template/<index-template>
```
我们可以使用_template这个终点来创建，删除，查看一个index template。下面，我们来举一个例子：
```
    PUT _template/logs_template
    {
      "index_patterns": "logs-*",
      "order": 1, 
      "settings": {
        "number_of_shards": 4,
        "number_of_replicas": 1
      },
      "mappings": { 
        "properties": {
          "@timestamp": {
            "type": "date"
          }
        }
      }
    }
```
在上面，我们可以看到，我们定义了一个叫做logs_template的index template。它的index_patterns定义为“logs-*”，说明，任何以“logs-”为开头的任何一个index将具有在该template里具有的settings及mappings属性。这里的“order”的意思是：如果索引与多个模板匹配，则Elasticsearch应用此模板的顺序。该值为1，表明有最先合并，如果有更高order的template，这个settings或mappings有可能被其它的template所覆盖。

下面，我们来测试一下我们刚定义的index template：
```
PUT logs-2019-03-01
```
在这里，我们创建了一个叫做logs-2019-03-01的index。我们使用如下的命令来检查被创建的情况：
```
GET logs-2019-03-01
```
显示的结果为：
```
    {
      "logs-2019-03-01" : {
        "aliases" : { },
        "mappings" : {
          "properties" : {
            "@timestamp" : {
              "type" : "date"
            }
          }
        },
        "settings" : {
          "index" : {
            "creation_date" : "1567652671032",
            "number_of_shards" : "4",
            "number_of_replicas" : "1",
            "uuid" : "Dz5rqRS4SEyLM_gf5eEolQ",
            "version" : {
              "created" : "7030099"
            },
            "provided_name" : "logs-2019-03-01"
          }
        }
      }
    }
```
证如上所示，我们已经成功创建了一个我们想要的index，并且它具有我们之前定义的settings及mappings。

# Index template和alias

我们甚至可以为我们的index template添加index alias：
```
    PUT _template/logs_template
    {
      "index_patterns": "logs-*",
      "order": 1, 
      "settings": {
        "number_of_shards": 4,
        "number_of_replicas": 1
      },
      "mappings": { 
        "properties": {
          "@timestamp": {
            "type": "date"
          }
        }
      },
      "aliases": {
        "{index}-alias" : {}
      }
    }
```
在上面，我们已经创立了一个叫做{index}-alias的别名。这里的{index}就是实际生成index的文件名来代替。我们下面用一个例子来说明：
```
PUT logs-2019-04-01
```
我们创建一个叫做logs-2019-04-01的index, 那么它同时生成了一个叫做logs-2019-04-01-alias的别名。我们可以通过如下的命令来检查：
```
GET logs-2019-04-01-alias
```
显示的结果是：
```
    {
      "logs-2019-04-01" : {
        "aliases" : {
          "logs-2019-04-01-alias" : { }
        },
        "mappings" : {
          "properties" : {
            "@timestamp" : {
              "type" : "date"
            }
          }
        },
        "settings" : {
          "index" : {
            "creation_date" : "1567653644605",
            "number_of_shards" : "4",
            "number_of_replicas" : "1",
            "uuid" : "iLf-j_G2T4CYcHCqwz32Ng",
            "version" : {
              "created" : "7030099"
            },
            "provided_name" : "logs-2019-04-01"
          }
        }
      }
    }
```

# Index匹配多个template

多个索引模板可能与索引匹配，在这种情况下，设置和映射都合并到索引的最终配置中。 可以使用order参数控制合并的顺序，首先应用较低的顺序，并且覆盖它们的较高顺序。 例如：
```
    PUT /_template/template_1
    {
        "index_patterns" : ["*"],
        "order" : 0,
        "settings" : {
            "number_of_shards" : 1
        },
        "mappings" : {
            "_source" : { "enabled" : false }
        }
    }
     
    PUT /_template/template_2
    {
        "index_patterns" : ["te*"],
        "order" : 1,
        "settings" : {
            "number_of_shards" : 1
        },
        "mappings" : {
            "_source" : { "enabled" : true }
        }
    }
```
以上的template_1将禁用存储`_source`，但对于以`te *`开头的索引，仍将启用_source。 注意，对于映射，合并是“深度”的，这意味着可以在高阶模板上轻松添加/覆盖特定的基于对象/属性的映射，而较低阶模板提供基础。

我们可以来创建一个例子看看：
```
    PUT test10
     
    GET test10
```
显示的结果是：
```
    {
      "test10" : {
        "aliases" : { },
        "mappings" : { },
        "settings" : {
          "index" : {
            "creation_date" : "1567654333181",
            "number_of_shards" : "1",
            "number_of_replicas" : "1",
            "uuid" : "iEwaQFl9RAKyTt79PduN-Q",
            "version" : {
              "created" : "7030099"
            },
            "provided_name" : "test10"
          }
        }
      }
    }
```
如果我们创建另外一个不是以 “te”开头的index，我们可以看看如下的情况：
```
    PUT my_test_index
    GET my_test_index
```
显示的结果是：
```
    {
      "my_test_index" : {
        "aliases" : { },
        "mappings" : {
          "_source" : {
            "enabled" : false
          }
        },
        "settings" : {
          "index" : {
            "creation_date" : "1567654713059",
            "number_of_shards" : "1",
            "number_of_replicas" : "1",
            "uuid" : "aSsIZMT2RyWKT44G2dF2zg",
            "version" : {
              "created" : "7030099"
            },
            "provided_name" : "my_test_index"
          }
        }
      }
    }
```
显然在mappings里显示source是被禁止的。

如果对于两个templates来说，如果order是一样的话，我们可能陷于一种不可知论的合并状态。在实际的使用中必须避免。

# 查询Index template接口

我们可以通过如下的接口来查询已经被创建好的index template:
```
GET /_template/<index-template>
```
比如：
```
GET _template/logs_template
```
显示的结果是：
```
    {
      "logs_template" : {
        "order" : 1,
        "index_patterns" : [
          "logs-*"
        ],
        "settings" : {
          "index" : {
            "number_of_shards" : "4",
            "number_of_replicas" : "1"
          }
        },
        "mappings" : {
          "properties" : {
            "@timestamp" : {
              "type" : "date"
            }
          }
        },
        "aliases" : {
          "{index}-alias" : { }
        }
      }
    }
```
显示的内容就是我们之前已经创建的那个index template。

你也可以通过如下的方式来同时查询多个template的情况：
```
    GET /_template/template_1,template_2
    GET /_template/temp*
    GET /_template
```
 
# 删除一个index template

在之前的练习中，我们匹配“*”，也就是我们以后所有的创建的新的index将不存储source，这个显然不是我们所需要的。我们需要来把这个template进行删除。删除一个template的接口如下：
```
DELETE /_template/<index-template>
```
那么针对我们的情况，我们可以使用如下的命令来删除我们不需要的template:
```
    DELETE _template/template_1
    DELETE _template/template_2
```
这样我们删除了我们刚才创建的两个templates。

参考：
【1】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/indices-get-template.html
【2】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/indices-delete-template.html
【3】https://www.elastic.co/guide/en/elasticsearch/reference/7.4/indices-templates.html
