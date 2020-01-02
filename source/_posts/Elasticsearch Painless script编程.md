我们之前看见了在Elasticsearch里的ingest node里，我们可以通过以下processor的处理帮我们处理我们的一些数据。它们的功能是非常具体而明确的。那么在Elasticsearch里，有没有一种更加灵活的方式可供我们来进行编程处理呢？如果有，它使用的语言是什么呢？

在Elasticsearc中，它使用了一个叫做Painless的语言。它是专门为Elasticsearch而建立的。Painless是一种简单，安全的脚本语言，专为与Elasticsearch一起使用而设计。 它是Elasticsearch的默认脚本语言，可以安全地用于inline和stored脚本。它具有像Groovy那样的语法。自Elasticsearch 6.0以后的版本不再支持Groovy，Javascript及Python语言。


# 如何使用脚本

脚本的语法为:
```
    "script": {
        "lang":   "...",  
        "source" | "id": "...", 
        "params": { ... } 
      }
```
- 这里lang默认的值为"painless"。在实际的使用中可以不设置，除非有第二种语言供使用
- source可以为inline脚本，或者是一个id，那么这个id对应于一个stored脚本
- 任何有名字的参数，可以被用于脚本的输入参数
  

# Painless的简单使用例子
## inline 脚本

首先我们来创建一个简单的文档：
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
```
在这个文档里，我们现在想把age修改为30，那么一种办法就是把所有的文档内容都读出来，让修改其中的age想为30，再重新用同样的方法写进去。首先这里需要有几个动作：先读出数据，然后修改，再次写入数据。显然这样比较麻烦。在这里我们可以直接使用Painless语言直接进行修改：
```
    POST twitter/_update/1
    {
      "script": {
        "source": "ctx._source.age = 30"
      }
    }
```
这里的source表明是我们的Painless代码。这里我们只写了很少的代码在DSL之中。这种代码称之为inline。在这里我们直接通过`ctx._source.age`来访问 `_souce`里的age。这样我们通过编程的办法直接对年龄进行了修改。运行的结果是：
```
    {
      "_index" : "twitter",
      "_type" : "_doc",
      "_id" : "1",
      "_version" : 16,
      "_seq_no" : 20,
      "_primary_term" : 1,
      "found" : true,
      "_source" : {
        "user" : "双榆树-张三",
        "message" : "今儿天气不错啊，出去转转去",
        "uid" : 2,
        "age" : 30,
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
```
显然这个age已经改变为30。上面的方法固然好，但是每次执行scripts都是需要重新进行编译的。编译好的script可以cache并供以后使用。上面的script如果是改变年龄的话，需要重新进行编译。一种更好的方法是改为这样的：
```
    POST twitter/_update/1
    {
      "script": {
        "source": "ctx._source.age = params.value",
        "params": {
          "value": 34
        }
      }
    }
```
这样，我们的script的source是不用改变的，只需要编译一次。下次调用的时候，只需要修改params里的参数即可。

在Elasticsearch里：
```
    "script": {
      "source": "ctx._source.num_of_views += 2"
    }
```
和
```
    "script": {
      "source": "ctx._source.num_of_views += 3"
    }
```
被视为两个不同的脚本，需要分别进行编译，所以最好的办法是使用params来传入参数。


# 存储的脚本 (stored script)

在这种情况下，scripts可以被存放于一个集群的状态中。它之后可以通过ID进行调用：
```
    PUT _scripts/add_age
    {
      "script": {
        "lang": "painless",
        "source": "ctx._source.age += params.value"
      }
    }
```
在这里，我们定义了一个叫做add_age的script。它的作用就是帮我们把source里的age加上一个数值。我们可以在之后调用它：
```
    POST twitter/_update/1
    {
      "script": {
        "id": "add_age",
        "params": {
          "value": 2
        }
      }
    }
```
通过上面的执行，我们可以看到，age将会被加上2。


# 访问source里的字段

Painless中用于访问字段值的语法取决于上下文。在Elasticsearch中，有许多不同的Plainless上下文。就像那个链接显示的那样，Plainless上下文包括：ingest processor, update, update by query, sort，filter等等。
Context 	访问字段
Ingest node: 访问字段使用ctx 	ctx.field_name
Updates: 使用`_source` 字段 	`ctx._source.field_name`

这里的updates包括`_update`，`_reindex`以及update_by_query。这里，我们对于context（上下文的理解）非常重要。它的意思是针对不同的API，在使用中ctx所包含的字段是不一样的。在下面的例子中，我们针对一些情况来做具体的分析。


# Painless脚本例子

首先我们创建一个叫做add_field_c的pipeline。关于如何创建一个pipleline，大家可以参考我之前写过的一个文章“如何在Elasticsearch中使用pipeline API来对事件进行处理”。
## 例子1
```
    PUT _ingest/pipeline/add_field_c
    {
      "processors": [
        {
          "script": {
            "lang": "painless",
            "source": "ctx.field_c = (ctx.field_a + ctx.field_b) * params.value",
            "params": {
              "value": 2
            }
          }
        }
      ]
    }
```
这个pipepline的作用是创建一个新的field：field_c。它的结果是field_a及field_b的和，并乘以2。那么我们创建一个如下的文档：
```
    PUT test_script/_doc/1?pipeline=add_field_c
    {
      "field_a": 10,
      "field_b": 20
    }
```
在这里，我们使用了pipleline add_field_c。执行后的结果是：
```
    {
      "took" : 147,
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
            "_index" : "test_script",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 1.0,
            "_source" : {
              "field_c" : 60,
              "field_a" : 10,
              "field_b" : 20
            }
          }
        ]
      }
    }
```
显然，我们可以看到field_c被成功创建了。
## 例子2


在ingest过程中，可以使用脚本处理器来处理metadata，如_index和_type。 下面是一个Ingest Pipeline的示例，无论原始索引请求中提供了什么，它都会将索引和类型重命名为my_index：
```
    PUT _ingest/pipeline/my_index
    {
        "description": "use index:my_index and type:_doc",
        "processors": [
          {
            "script": {
              "source": """
                ctx._index = 'my_index';
                ctx._type = '_doc';
              """
            }
          }
        ]
    }
```
使用上面的pipeline，我们可以尝试index一个文档到any_index：
```
    PUT any_index/_doc/1?pipeline=my_index
    {
      "message": "text"
    }
```
显示的结果是：
```
    {
      "_index": "my_index",
      "_type": "_doc",
      "_id": "1",
      "_version": 1,
      "result": "created",
      "_shards": {
        "total": 2,
        "successful": 1,
        "failed": 0
      },
      "_seq_no": 89,
      "_primary_term": 1,
    }
```
也就是说真正的文档时存到my_index之中，而不是any_index。
## 例子3
```
    PUT _ingest/pipeline/blogs_pipeline
    {
      "processors": [
        {
          "script": {
            "source": """
              if (ctx.category == "") { 
                 ctx.category = "None"
              } 
    """
          }
        }
      ]
    }
```
我们上面定义了一个pipeline，它可以帮我们检查如果 category字段是否为空，如果是，就修改为“None”。还是以之前的那个test_script索引为例：
```
    PUT test_script/_doc/2?pipeline=blogs_pipeline
    {
      "field_a": 5,
      "field_b": 10,
      "category": ""
    }
     
    GET test_script/_doc/2
```
显示的结果是：
```
    {
      "_index" : "test_script",
      "_type" : "_doc",
      "_id" : "2",
      "_version" : 2,
      "_seq_no" : 6,
      "_primary_term" : 1,
      "found" : true,
      "_source" : {
        "field_a" : 5,
        "field_b" : 10,
        "category" : "None"
      }
    }
```
显然，它把category为“”的字段变为“None”了。
## 例子4
```
    POST _reindex
    {
      "source": {
        "index": "blogs"
      },
      "dest": {
        "index": "blogs_fixed"
      },
      "script": {
        "source": """
          if (ctx._source.category == "") {
              ctx._source.category = "None" 
          }
    """
      }
    }
```
上面的这个例子在reindex时，如果category为空时，写入“None”。我们可以从上面的两个例子中看出来，针对pipeline，我们可以直接对cxt.field进行操作，而针对update来说，我们可以对cxt._source下的字段进行操作。这也是之前提到的上下文的区别。
## 例子5
```
    PUT test/_doc/1
    {
        "counter" : 1,
        "tags" : ["red"]
    }
```
您可以使用和update脚本将tag添加到tags列表（这只是一个列表，因此即使存在标记也会添加）：
```
    POST test/_update/1
    {
        "script" : {
            "source": "ctx._source.tags.add(params.tag)",
            "lang": "painless",
            "params" : {
                "tag" : "blue"
            }
        }
    }
```
显示结果：
```
GET test/_doc/1

    {
      "_index" : "test",
      "_type" : "_doc",
      "_id" : "1",
      "_version" : 4,
      "_seq_no" : 3,
      "_primary_term" : 11,
      "found" : true,
      "_source" : {
        "counter" : 1,
        "tags" : [
          "red",
          "blue"
        ]
      }
    }
```
显示“blue”，已经被成功加入到tags列表之中了。

您还可以从tags列表中删除tag。 删除tag的Painless函数采用要删除的元素的数组索引。 为避免可能的运行时错误，首先需要确保tag存在。 如果列表包含tag的重复项，则此脚本只删除一个匹配项。
```
    POST test/_update/1
    {
      "script": {
        "source": "if (ctx._source.tags.contains(params.tag)) { ctx._source.tags.remove(ctx._source.tags.indexOf(params.tag)) }",
        "lang": "painless",
        "params": {
          "tag": "blue"
        }
      }
    }
     
    GET test/_doc/1
```
显示结果：
```
    {
      "_index" : "test",
      "_type" : "_doc",
      "_id" : "1",
      "_version" : 5,
      "_seq_no" : 4,
      "_primary_term" : 11,
      "found" : true,
      "_source" : {
        "counter" : 1,
        "tags" : [
          "red"
        ]
      }
    }
```
“blue”显然已经被删除了。


# Painless脚本简单的操练

为了说明Painless的工作原理，让我们将一些曲棍球统计数据加载到Elasticsearch索引中：
```
    PUT hockey/_bulk?refresh
    {"index":{"_id":1}}
    {"first":"johnny","last":"gaudreau","goals":[9,27,1],"assists":[17,46,0],"gp":[26,82,1],"born":"1993/08/13"}
    {"index":{"_id":2}}
    {"first":"sean","last":"monohan","goals":[7,54,26],"assists":[11,26,13],"gp":[26,82,82],"born":"1994/10/12"}
    {"index":{"_id":3}}
    {"first":"jiri","last":"hudler","goals":[5,34,36],"assists":[11,62,42],"gp":[24,80,79],"born":"1984/01/04"}
    {"index":{"_id":4}}
    {"first":"micheal","last":"frolik","goals":[4,6,15],"assists":[8,23,15],"gp":[26,82,82],"born":"1988/02/17"}
    {"index":{"_id":5}}
    {"first":"sam","last":"bennett","goals":[5,0,0],"assists":[8,1,0],"gp":[26,1,0],"born":"1996/06/20"}
    {"index":{"_id":6}}
    {"first":"dennis","last":"wideman","goals":[0,26,15],"assists":[11,30,24],"gp":[26,81,82],"born":"1983/03/20"}
    {"index":{"_id":7}}
    {"first":"david","last":"jones","goals":[7,19,5],"assists":[3,17,4],"gp":[26,45,34],"born":"1984/08/10"}
    {"index":{"_id":8}}
    {"first":"tj","last":"brodie","goals":[2,14,7],"assists":[8,42,30],"gp":[26,82,82],"born":"1990/06/07"}
    {"index":{"_id":39}}
    {"first":"mark","last":"giordano","goals":[6,30,15],"assists":[3,30,24],"gp":[26,60,63],"born":"1983/10/03"}
    {"index":{"_id":10}}
    {"first":"mikael","last":"backlund","goals":[3,15,13],"assists":[6,24,18],"gp":[26,82,82],"born":"1989/03/17"}
    {"index":{"_id":11}}
    {"first":"joe","last":"colborne","goals":[3,18,13],"assists":[6,20,24],"gp":[26,67,82],"born":"1990/01/30"}
```
## 使用Painless访问Doc里的值

文档里的值可以通过一个叫做doc的Map值来访问。例如，以下脚本计算玩家的总进球数。 此示例使用类型int和for循环。
```
    GET hockey/_search
    {
      "query": {
        "function_score": {
          "script_score": {
            "script": {
              "lang": "painless",
              "source": """
                int total = 0;
                for (int i = 0; i < doc['goals'].length; ++i) {
                  total += doc['goals'][i];
                }
                return total;
              """
            }
          }
        }
      }
    }
```
这里我们通过script来计算每个文档的_score。通过script把每个运动员的goal都加起来，并形成最终的_score。这里我们通过doc['goals']这个Map类型来访问我们的字段值。显示的结果为：
```
    {
      "took" : 25,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "skipped" : 0,
        "failed" : 0
      },
      "hits" : {
        "total" : {
          "value" : 11,
          "relation" : "eq"
        },
        "max_score" : 87.0,
        "hits" : [
          {
            "_index" : "hockey",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 87.0,
            "_source" : {
              "first" : "sean",
              "last" : "monohan",
              "goals" : [
                7,
                54,
                26
              ],
              "assists" : [
                11,
                26,
                13
              ],
              "gp" : [
                26,
                82,
                82
              ],
              "born" : "1994/10/12"
            }
          },
    ...
```
或者，您可以使用script_fields而不是function_score执行相同的操作：
```
    GET hockey/_search
    {
      "query": {
        "match_all": {}
      },
      "script_fields": {
        "total_goals": {
          "script": {
            "lang": "painless",
            "source": """
              int total = 0;
              for (int i = 0; i < doc['goals'].length; ++i) {
                total += doc['goals'][i];
              }
              return total;
            """
          }
        }
      }
    }
```
显示的结果为：
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
          "value" : 11,
          "relation" : "eq"
        },
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "hockey",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 1.0,
            "fields" : {
              "total_goals" : [
                37
              ]
            }
          },
          {
            "_index" : "hockey",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 1.0,
            "fields" : {
              "total_goals" : [
                87
              ]
            }
          },
    ...
```
以下示例使用Painless脚本按其组合的名字和姓氏对玩家进行排序。 使用doc ['first']。value和doc ['last']。value访问名称。
```
    GET hockey/_search
    {
      "query": {
        "match_all": {}
      },
      "sort": {
        "_script": {
          "type": "string",
          "order": "asc",
          "script": {
            "lang": "painless",
            "source": "doc['first.keyword'].value + ' ' + doc['last.keyword'].value"
          }
        }
      }
    }
```
## 检查缺失项

doc ['field'].value。如果文档中缺少该字段，则抛出异常。

要检查文档是否缺少值，可以调用`doc ['field'] .size（）== 0`。
使用Painless更新字段

您还可以轻松更新字段。 您可以使用`ctx._source.<field-name>`访问字段的原始源。

首先，让我们通过提交以下请求来查看玩家的源数据：
```

    GET hockey/_search
    {
      "stored_fields": [
        "_id",
        "_source"
      ],
      "query": {
        "term": {
          "_id": 1
        }
      }
    }
```
显示的结果为：
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
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "hockey",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 1.0,
            "_source" : {
              "first" : "johnny",
              "last" : "gaudreau",
              "goals" : [
                9,
                27,
                1
              ],
              "assists" : [
                17,
                46,
                0
              ],
              "gp" : [
                26,
                82,
                1
              ],
              "born" : "1993/08/13"
            }
          }
        ]
      }
    }
```
要将玩家1的姓氏更改为hockey，只需将ctx._source.last设置为新值：
```
    POST hockey/_update/1
    {
      "script": {
        "lang": "painless",
        "source": "ctx._source.last = params.last",
        "params": {
          "last": "hockey"
        }
      }
    }
```
您还可以向文档添加字段。 例如，此脚本添加一个包含玩家nickname为hockey的新字段。
```
    POST hockey/_update/1
    {
      "script": {
        "lang": "painless",
        "source": """
          ctx._source.last = params.last;
          ctx._source.nick = params.nick
        """,
        "params": {
          "last": "gaudreau",
          "nick": "hockey"
        }
      }
    }
```
显示的结果为：
```
GET hockey/_doc/1
    {
      "_index" : "hockey",
      "_type" : "_doc",
      "_id" : "1",
      "_version" : 2,
      "_seq_no" : 11,
      "_primary_term" : 1,
      "found" : true,
      "_source" : {
        "first" : "johnny",
        "last" : "gaudreau",
        "goals" : [
          9,
          27,
          1
        ],
        "assists" : [
          17,
          46,
          0
        ],
        "gp" : [
          26,
          82,
          1
        ],
        "born" : "1993/08/13",
        "nick" : "hockey"
      }
    }
```
有一个叫做 “nick”的新字段被加入了。

我们甚至可以对日期类型来进行操作从而得到年月等信息：
```
    GET hockey/_search
    {
      "script_fields": {
        "birth_year": {
          "script": {
            "source": "doc.born.value.year"
          }
        }
      }
    }
```
显示结果：
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
          "value" : 11,
          "relation" : "eq"
        },
        "max_score" : 1.0,
        "hits" : [
          {
            "_index" : "hockey",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : 1.0,
            "fields" : {
              "birth_year" : [
                1994
              ]
            }
          },
    ...
```

## Script Caching

Elasticsearch第一次看到一个新脚本，它会编译它并将编译后的版本存储在缓存中。无论是inline或是stored脚本都存储在缓存中。新脚本可以驱逐缓存的脚本。默认的情况下是可以存储100个脚本。我们可以通过设置script.cache.max_size来改变其大小，或者通过script.cache.expire来设置过期的时间。这些设置需要在config/elasticsearch.yml里设置。

## Script 调试

不能调试的脚本是非常难的。有一个好的调试手段无疑对我们的脚本编程是非常有用的。
Debug.explain

Painless没有REPL，虽然有一天它很好，但它不会告诉你关于调试Elasticsearch中嵌入的Painless脚本的全部故事，因为脚本可以访问的数据或“上下文” 是如此重要。 目前，调试嵌入式脚本的最佳方法是在选择位置抛出异常。 虽然您可以抛出自己的异常（throw new exception('whatever'），但Painless的沙箱会阻止您访问有用的信息，如对象的类型。 所以Painless有一个实用工具方法Debug.explain，它会为你抛出异常。 例如，您可以使用_explain来探索script query可用的上下文。

    PUT /hockey/_doc/1?refresh
    {"first":"johnny","last":"gaudreau","goals":[9,27,1],"assists":[17,46,0],"gp":[26,82,1]}
     
    POST /hockey/_explain/1
    {
      "query": {
        "script": {
          "script": "Debug.explain(doc.goals)"
        }
      }
    }

这表明doc.goals类是org.elasticsearch.index.fielddata.ScriptDocValues.Longs通过响应：

    {
      "error": {
        "root_cause": [
          {
            "type": "script_exception",
            "reason": "runtime error",
            "painless_class": "org.elasticsearch.index.fielddata.ScriptDocValues.Longs",
            "to_string": "[1, 9, 27]",
            "java_class": "org.elasticsearch.index.fielddata.ScriptDocValues$Longs",
            "script_stack": [
              "Debug.explain(doc.goals)",
              "                 ^---- HERE"
            ],
            "script": "Debug.explain(doc.goals)",
            "lang": "painless"
          }
        ],
        "type": "script_exception",
        "reason": "runtime error",
        "painless_class": "org.elasticsearch.index.fielddata.ScriptDocValues.Longs",
        "to_string": "[1, 9, 27]",
        "java_class": "org.elasticsearch.index.fielddata.ScriptDocValues$Longs",
        "script_stack": [
          "Debug.explain(doc.goals)",
          "                 ^---- HERE"
        ],
        "script": "Debug.explain(doc.goals)",
        "lang": "painless",
        "caused_by": {
          "type": "painless_explain_error",
          "reason": null
        }
      },
      "status": 400
    }

您可以使用相同的技巧来查看_source是_update API中的LinkedHashMap：
```
    POST /hockey/_update/1
    {
      "script": "Debug.explain(ctx._source)"
    }
```
显示的结果是：
```
    {
      "error": {
        "root_cause": [
          {
            "type": "remote_transport_exception",
            "reason": "[localhost][127.0.0.1:9300][indices:data/write/update[s]]"
          }
        ],
        "type": "illegal_argument_exception",
        "reason": "failed to execute script",
        "caused_by": {
          "type": "script_exception",
          "reason": "runtime error",
          "painless_class": "java.util.LinkedHashMap",
          "to_string": "{first=johnny, last=gaudreau, goals=[9, 27, 1], assists=[17, 46, 0], gp=[26, 82, 1], born=1993/08/13, nick=hockey}",
          "java_class": "java.util.LinkedHashMap",
          "script_stack": [
            "Debug.explain(ctx._source)",
            "                 ^---- HERE"
          ],
          "script": "Debug.explain(ctx._source)",
          "lang": "painless",
          "caused_by": {
            "type": "painless_explain_error",
            "reason": null
          }
        }
      },
      "status": 400
    }
```


参考：

【1】https://www.elastic.co/guide/en/elasticsearch/painless/current/painless-walkthrough.html

【2】https://www.elastic.co/guide/en/elasticsearch/painless/current/painless-debugging.html
