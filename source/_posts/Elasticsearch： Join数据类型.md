---
title: Elasticsearch： Join数据类型
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
在Elasticsearch中，Join可以让我们创建parent/child关系。Elasticsearch不是一个RDMS。通常join数据类型尽量不要使用，除非不得已。那么Elasticsearch为什么需要Join数据类型呢？

在Elasticsearch中，更新一个object需要root object一个完整的reindex：

- 即使是一个field的一个字符的改变
- 即便是nested object也需要完整的reindex才可以实现搜索

通常情况下，这是完全OK的，但是在有些场合下，如果我们有频繁的更新操作，这样可能对性能带来很大的影响。

如果你的数据需要频繁的更新，并带来性能上的影响，这个时候，join数据类型可能是你的一个解决方案。

join数据类型可以完全地把两个object分开，但是还是保持这两者之前的关系。

1. parent及child是完全分开的两个文档
2. parent可以单独更新而不需要重新reindex child
3. children可以任意被添加/串改/删除而不影响parent及其它的children

与 nested类型类似，父子关系也允许您将不同的实体关联在一起，但它们在实现和行为上有所不同。 与nested文档不同，它们不在同一文档中，而parent/child文档是完全独立的文档。 它们遵循一对多关系原则，允许您将一种类型定义为parent类型，将一种或多种类型定义为child类型

即便join数据类型给我们带来了方便，但是，它也在搜索时给我带来额外的内存及计算方便的开销。

注意：目前Kibana对nested及join数据类型有比较少的支持。如果你想使用Kibana来在dashboard里展示数据，这个方面的你需要考虑。在未来，这种情况可能会发生改变。

**join数据类型是一个特殊字段，用于在同一索引的文档中创建父/子关系。 关系部分定义文档中的一组可能关系，每个关系是父（parent)名称和子（child)名称。 **

<escape><!-- more --></escape>

一个例子：
```
    PUT my_index
    {
      "mappings": {
        "properties": {
          "my_join_field": { 
            "type": "join",
            "relations": {
              "question": "answer" 
            }
          }
        }
      }
    }
```
在这里我们定义了一个叫做my_index的索引。在这个索引中，我们定义了一个field，它的名字是my_join_field。它的类型是join数据类型。同时我们定义了单个关系：question是answer的parent。

要使用join来index文档，必须在source中提供关系的name和文档的可选parent。 例如，以下示例在question上下文中创建两个parent文档：
```
    PUT my_index/_doc/1?refresh
    {
      "text": "This is a question",
      "my_join_field": {
        "name": "question" 
      }
    }
     
    PUT my_index/_doc/2?refresh
    {
      "text": "This is another question",
      "my_join_field": {
        "name": "question"
      }
    }
```
这里采用refresh来强制进行索引，以便接下来的搜索。在这里name标识question，说明这个文档时一个question文档。

索引parent文档时，您可以选择仅将关系的名称指定为快捷方式，而不是将其封装在普通对象表示法中：
```
    PUT my_index/_doc/1?refresh
    {
      "text": "This is a question",
      "my_join_field": "question" 
    }
     
    PUT my_index/_doc/2?refresh
    {
      "text": "This is another question",
      "my_join_field": "question"
    }
```
这种方法和前面的是一样的，只是这里我们只使用了question, 而不是一个像第一种方法那样，使用如下的一个对象来表达：
```
    "my_join_field": {
        "name": "question"
      }
```
在实际的使用中，你可以根据自己的喜好来使用。

索引child项时，必须在_source中添加关系的名称以及文档的parent id。

> 注意：需要在同一分片中索引父级的谱系，必须使用其parent的id来确保这个child和parent是在一个shard中。每个文档分配在那个shard之中在默认的情况下是按照文档的id进行一些hash来分配的，当然也可以通过routing来进行。针对child，我们使用其parent的id，这样就可以保证。否则在我们join数据的时候，跨shard是非常大的一个消费。

例如，以下示例显示如何索引两个child文档：
```
    PUT my_index/_doc/3?routing=1?refresh  (1)
    {
      "text": "This is an answer",
      "my_join_field": {
        "name": "answer",   (2)
        "parent": "1"       (3)
      }
    }
     
    PUT my_index/_doc/4?routing=1?refresh
    {
      "text": "This is another answer",
      "my_join_field": {
        "name": "answer",
        "parent": "1"
      }
    }
```
在上面的（1）处，我们必须使用routing，这样能确保parent和child是在同一个shard里。我们这里routing为1，这是因为parent的id 为1，在（3）处定义。(2) 处定义了该文档join的名称。

## parent-join及其性能

join字段不应像关系数据库中的连接一样使用。 在Elasticsearch中，良好性能的关键是将数据去规范化为文档。 每个连接字段has_child或has_parent查询都会对查询性能产生重大影响。

join字段有意义的唯一情况是，如果您的数据包含一对多关系，其中一个实体明显超过另一个实体。 这种情况的一个例子是产品的用例和这些产品的报价。 如果提供的产品数量明显多于产品数量，则将产品建模为父文档并将产品建模为子文档是有意义的。

## parent-join的限制

- 对于每个index来说，只能有一个join字段
- parent及child文档，必须是在一个shard里建立索引。这也意味着，同样的routing值必须应用于getting, deleting或updating一个child文档。
- 一个元素可以有多个children，但是只能有一个parent.
- 可以对已有的join项添加新的关系
- 也可以将child添加到现有元素，但仅当元素已经是parent时才可以。

## 针对parent-join的搜索

parent-join创建一个字段来索引文档中关系的名称（my_parent，my_child，...）。

它还为每个parent/child关系创建一个字段。 此字段的名称是join字段的名称，后跟`＃`和关系中parent的名称。 因此，例如对于my_parent⇒[my_child，another_child]关系，join字段会创建一个名为my_join_field＃my_parent的附加字段。

如果文档是子文件（my_child或another_child），则此字段包含文档链接到的parent_id，如果文档是parent文件（my_parent），则包含文档的_id。

搜索包含join字段的索引时，始终在搜索响应中返回这两个字段：

上面的描述比较绕口，我们还是以一个例子来说说明吧：
```
    GET my_index/_search
    {
      "query": {
        "match_all": {}
      },
      "sort": ["_id"]
    }
```
这里我们搜索所有的文档，并以_id进行排序：
```
    {
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
          "value" : 4,
          "relation" : "eq"
        },
        "max_score" : null,
        "hits" : [
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : null,
            "_source" : {
              "text" : "This is a question",
              "my_join_field" : "question" (1)
            },
            "sort" : [
              "1"
            ]
          },
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "2",
            "_score" : null,
            "_source" : {
              "text" : "This is another question",
              "my_join_field" : "question" (2)
            },
            "sort" : [
              "2"
            ]
          },
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "3",
            "_score" : null,
            "_routing" : "1",
            "_source" : {
              "text" : "This is an answer",
              "my_join_field" : {
                "name" : "answer", (3)
                "parent" : "1"     (4)
              }
            },
            "sort" : [
              "3"
            ]
          },
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "4",
            "_score" : null,
            "_routing" : "1",
            "_source" : {
              "text" : "This is another answer",
              "my_join_field" : {
                "name" : "answer",
                "parent" : "1"
              }
            },
            "sort" : [
              "4"
            ]
          }
        ]
      }
    }
```
在这里，我们可以看到4个文档：

(1)表明这个文档是一个question join
(2)表明这个文档是一个question join
(3)表明这个文档是一个answer join
(4)表明这个文档的parent是id为1的文档

## Parent-join 查询及aggregation

可以在aggregation和script中访问join字段的值，并可以使用parent_id查询进行查询：
```
    GET my_index/_search
    {
      "query": {
        "parent_id": { 
          "type": "answer",
          "id": "1"
        }
      }
    }
```
我们通过查询parent_id，返回所有parent_id为1的所有answer类型的文档：
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
    "max_score" : 0.35667494,
    "hits" : [
      {
        "_index" : "my_index",
        "_type" : "_doc",
        "_id" : "4",
        "_score" : 0.35667494,
        "_routing" : "1",
        "_source" : {
          "text" : "This is another answer",
          "my_join_field" : {
            "name" : "answer",
            "parent" : "1"
          }
        }
      },
      {
        "_index" : "my_index",
        "_type" : "_doc",
        "_id" : "3",
        "_score" : 0.35667494,
        "_routing" : "1",
        "_source" : {
          "text" : "This is an answer",
          "my_join_field" : {
            "name" : "answer",
            "parent" : "1"
          }
        }
      }
    ]
  }
}
```

在这里，我们可以看到返回id为3和4的文档。我们也可以对这些文档进行aggregation:
```
    GET my_index/_search
    {
      "query": {
        "parent_id": {
          "type": "answer",
          "id": "1"
        }
      },
      "aggs": {
        "parents": {
          "terms": {
            "field": "my_join_field#question",
            "size": 10
          }
        }
      },
      "script_fields": {
        "parent": {
          "script": {
            "source": "doc['my_join_field#question']"
          }
        }
      }
    }
```
就像我们在上一节中介绍的那样， 在我们的应用实例中，在index时，它也创建一个额外的一个字段，虽然在source里我们看不到。这个字段就是my_join_filed#question，这个字段含有parent _id。在上面的查询中，我们首先查询所有的parent_id为1的所有的answer类型的文档。接下来对所有的文档以parent_id进行聚合：
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
        "max_score" : 0.35667494,
        "hits" : [
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "4",
            "_score" : 0.35667494,
            "_routing" : "1",
            "fields" : {
              "parent" : [
                "1"
              ]
            }
          },
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "3",
            "_score" : 0.35667494,
            "_routing" : "1",
            "fields" : {
              "parent" : [
                "1"
              ]
            }
          }
        ]
      },
      "aggregations" : {
        "parents" : {
          "doc_count_error_upper_bound" : 0,
          "sum_other_doc_count" : 0,
          "buckets" : [
            {
              "key" : "1",
              "doc_count" : 2
            }
          ]
        }
      }
    }
```

## 一个parent对应多个child

对于一个parent来说，我们可以定义多个child，比如：
```
    PUT my_index
    {
      "mappings": {
        "properties": {
          "my_join_field": {
            "type": "join",
            "relations": {
              "question": ["answer", "comment"]  
            }
          }
        }
      }
    }
```
在这里，question是answer及comment的parent。

## 多层的parent join

虽然这个不建议，这样做可能会可能在query时带来更多的内存及计算方面的开销：
```
    PUT my_index
    {
      "mappings": {
        "properties": {
          "my_join_field": {
            "type": "join",
            "relations": {
              "question": ["answer", "comment"],  
              "answer": "vote" 
            }
          }
        }
      }
    }
```
这里question是answer及comment的parent，同时answer也是vote的parent。它表明了如下的关系：

索引grandchild文档需routing值等于grand-parent（谱系里的更大parent）：
```
    PUT my_index/_doc/3?routing=1&refresh 
    {
      "text": "This is a vote",
      "my_join_field": {
        "name": "vote",
        "parent": "2" 
      }
    }
```
这个child文档必须是和他的grand-parent在一个shard里。在这里它使用了1，也即question的id。同时，对于vote来说，它的parent必须是它的parent，也即answer的id。

更多参考：https://www.elastic.co/guide/en/elasticsearch/reference/7.3/parent-join.html
