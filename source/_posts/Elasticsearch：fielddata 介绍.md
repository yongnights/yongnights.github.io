---
title: Elasticsearch：fielddata 介绍
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
默认情况下，大多数字段都已编入索引，这使它们可搜索。 但是，脚本中的排序，聚合和访问字段值需要与搜索不同的访问模式。

搜索需要回答“哪个文档包含该术语？”这个问题，而排序和汇总则需要回答一个不同的问题：“此字段对该文档的值是什么？”。

大多数字段可以将索引时生产的磁盘doc_values(https://www.elastic.co/guide/en/elasticsearch/reference/current/doc-values.html)用于此数据访问模式，但是文本（text）字段不支持doc_values。

替代的方案，文本（text）字段使用查询时内存中的数据结构，称为fielddata。 当我们首次将该字段用于聚合，排序或在脚本中使用时，将按需构建此数据结构。 它是通过从磁盘读取每个段的整个反向索引，反转术语↔︎文档关系并将结果存储在JVM堆中的内存中来构建的。

# Fielddata针对text字段在默认时是禁用的

Fielddata会占用大量堆空间，尤其是在加载大量的文本字段时。 一旦将字段数据加载到堆中，它在该段的生命周期内将一直保留在那里。 同样，加载字段数据是一个昂贵的过程，可能导致用户遇到延迟的情况。 这就是默认情况下禁用字段数据的原因。

<escape><!-- more --></escape>

假如我们创建一个如下的myindex的索引：
```
    PUT myindex
    {
      "mappings": {
        "properties": {
          "address": {
            "type": "text"
          }
        }
      }
    }
     
    PUT myindex/_doc/1
    {
      "address": "New York"  
    }
```
如果您尝试对文本字段中的脚本进行排序，汇总或访问值:
```
    GET myindex/_search
    {
      "size": 20,
      "aggs": {
        "aggr_mame": {
          "terms": {
            "field": "address",
            "size": 5
          }
        }
      }
    }
```
则会看到以下异常：

![](https://img-blog.csdnimg.cn/20191214142324132.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

显然，我们不能对text字段进行聚合处理。那么我们该如何处理这个问题呢？

我们的一种方法就是在配置mapping的时候加入"fielddata"=true这个选项。我们来重新对我们的myindex的mapping进行配置：
```
    DELETE myindex
     
    PUT myindex
    {
      "mappings": {
        "properties": {
          "address": {
            "type": "text",
            "fielddata": true
          }
        }
      }
    }
     
    PUT myindex/_doc/1
    {
      "address": "New York"  
    }
     
    GET myindex/_search
    {
      "size": 0,
      "aggs": {
        "aggr_mame": {
          "terms": {
            "field": "address",
            "size": 5
          }
        }
      }
    }
```
在这里，我们尽管还是把address这个字段设置为text，但是由于我们加入了"fielddata"=true，那么我们，我们就可以对这个项进行统计了。

![](https://img-blog.csdnimg.cn/20191214143306375.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

与简单的搜索操作不同，排序和聚合需要能够发现在特定文档的特定字段中可以找到哪些术语。 对于这些任务和其他任务，必须具有与Elasticsearch（反向）索引相反的数据结构。 这就是fielddata的目的。

细心的开发者，如果这个时候去Kibana创建一个以myindex为索引的index pattern，我们可以发现：

![](https://img-blog.csdnimg.cn/20191214143726893.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9lbGFzdGljc3RhY2suYmxvZy5jc2RuLm5ldA==,size_16,color_FFFFFF,t_70)

我们的address字段变为aggregatable，也就是说我们可以对它进行做聚合分析尽管它没有doc_values。

# 在启动fielddata之前

在启用fielddata之前，请考虑为什么将文本字段用于聚合，排序或在脚本中使用。 这样做通常没有任何意义。

在索引之前会分析文本字段，以便可以通过搜索new或york来找到类似New York的值。 当您可能想要一个名为New York的存储桶时，此字段上的术语汇总将返回一个叫做new存储桶和一个叫做york存储桶。

相反，您应该有一个用于全文搜索的文本字段，以及一个为聚合启用doc_values的未分析的keyword字段，如下所示：
```
    DELETE myindex
     
    PUT myindex
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
          }
        }
      }
    }
```
这样，我们可以使用address来做全文的搜索，而address.keyword被用来做aggregations, sorting 及在脚本中使用。

参考：
【1】https://www.elastic.co/guide/en/elasticsearch/reference/current/fielddata.html
【2】https://qbox.io/blog/field-data-elasticsearch-cluster-instability