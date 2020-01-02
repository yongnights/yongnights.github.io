---
title: Elasticsearch：Dynamic mapping
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
Elasticsearch最重要的功能之一是它试图摆脱你的方式，让你尽快开始探索你的数据。 要索引文档，您不必首先创建索引，定义映射类型和定义字段 - 您只需索引文档，那么index，type和field将自动生效。比如：

    PUT data/_doc/1 
    { "count": 5 }

上面的命令将自动帮我们生成一个叫做data的index，并同时生成一个叫做_doc的type及一个叫做count的field。count的数据类型是long。这个非常方便，我们不想传统的RDMS那样，先要创建一个数据库，让后一个table，然后才可以向table里写入数据。

自动检测和添加新字段称为动态映射。 动态映射规则可以根据您的目的进行定制：

- 动态字段映射：管理动态field检测的规则
- 动态模板：用于配置动态添加字段的映射的自定义规则

在今天的这篇文章中，我们来分别介绍这两个方面的内容。

<escape><!-- more --></escape>

# 动态模板

假设您有包含大量字段的文档

- 或者在映射定义时未知的动态字段名称的文档
- 和nested的key/value对不是一个很好的解决方案

使用动态模板，您可以基于定义字段的映射

- 字段的数据类型, 使用match_mapping_type
- 字段的名字，使用match and unmatch 或match_pattern.
- 或者字段的路径，使用path_match 及 path_unmatch.

动态模板由命名对象的数组来定义的：
```
    "dynamic_templates": [
        {
          "my_template_name": {   (1)
            ...  match conditions ...  (2) 
            "mapping": { ... }  (3)
          }
        },
        ...
      ]
```
1. template的名字可以是任何一个字符串
2. 匹配的条件可以是这里的任何一种match_mapping_type, match, match_pattern, unmatch, path_match, path_unmatch
3. 被匹配的字段的mapping

例如，如果我们想要将所有整数字段映射为整数而不是long，并将所有字符串字段映射为text和keyword，我们可以使用以下模板：

    PUT my_index
    {
      "mappings": {
        "dynamic_templates": [
          {
            "integers": {
              "match_mapping_type": "long",
              "mapping": {
                "type": "integer"
              }
            }
          },
          {
            "strings": {
              "match_mapping_type": "string",
              "mapping": {
                "type": "text",
                "fields": {
                  "raw": {
                    "type":  "keyword",
                    "ignore_above": 256
                  }
                }
              }
            }
          }
        ]
      }
    }
     
    PUT my_index/_doc/1
    {
      "my_integer": 5, 
      "my_string": "Some string" 
    }

通过上面的动态template映射，我们可以看到my_integer被映射为integer而不是long。my_string是一个multi_field字段。

假设您希望任何未映射的字符串字段默认情况下映射为“keyword”类型，那么我们可以这么定义：

    PUT test2
    {
      "mappings": {
        "dynamic_templates": [
          {
            "my_string_fields": {
              "match_mapping_type": "string",
              "mapping": {
                "type": "keyword"
              }
            }
          }
        ]
      }
    }

## match及unmatch

match参数使用模式匹配字段名称，而unmatch使用模式排除匹配匹配的字段。

以下示例匹配名称以long_开头的所有字符串字段（以_text结尾的字符串除外）并将它们映射为长字段：
```
    PUT my_index
    {
      "mappings": {
        "dynamic_templates": [
          {
            "longs_as_strings": {
              "match_mapping_type": "string",
              "match":   "long_*",
              "unmatch": "*_text",
              "mapping": {
                "type": "long"
              }
            }
          }
        ]
      }
    }
     
    PUT my_index/_doc/1
    {
      "long_num": "5", 
      "long_text": "foo" 
    }
```
我们可以通过如下的命令来查看它们的数据类型：

`GET my_index/_mapping`

显示的结果为：
```
    {
      "my_index" : {
        "mappings" : {
          "dynamic_templates" : [
            {
              "longs_as_strings" : {
                "match" : "long_*",
                "unmatch" : "*_text",
                "match_mapping_type" : "string",
                "mapping" : {
                  "type" : "long"
                }
              }
            }
          ],
          "properties" : {
            "long_num" : {
              "type" : "long"
            },
            "long_text" : {
              "type" : "text",
              "fields" : {
                "keyword" : {
                  "type" : "keyword",
                  "ignore_above" : 256
                }
              }
            }
          }
        }
      }
    }
```
从上面，我们可以看出来，long_num的数据类型是long，而long_text的数据类型是text。

# 控制动态字段

默认情况下，当在文档中找到以前未见过的字段时，Elasticsearch会将新字段添加到类型映射中。 通过将dynamic参数设置为false（忽略新字段）或strict（如果遇到未知字段则抛出异常），可以在文档和对象级别禁用此行为。

在生产(product)环境中，你极有可能会创建你的mapping在索引你的数据之前，而且你极有可能不想你的mapping会被修改：
```
POST blogs/_doc/2
{
"some_new_field": "What should we do?" 
}
```
在通常的情况下，上面的一个命令可能会自动帮我们在blogs索引里增加一个新的叫做some_new_field的字段。

您可以使用“动态”属性（三个选项）控制添加到映射的新字段的效果：
![](https://img-blog.csdnimg.cn/2019090515355114.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)
```
    PUT blogs_example/_mapping
    {
      "dynamic": "strict"
    }
```
在上面我们在mapping中加入了dynamic，并且设置为strict，它表明如果现有的mapping里没有定义这个字段，那么就不index这个文档。
```
    PUT /blogs_example/_doc/1
    {
      "new_field": "this is a new field"
    }
```
如果new_field从来没有在mapping中定义过，那么，上面的命令会出现如下的错误：
```
    {
      "error": {
        "root_cause": [
          {
            "type": "strict_dynamic_mapping_exception",
            "reason": "mapping set to strict, dynamic introduction of [new_field] within [_doc] is not allowed"
          }
        ],
        "type": "strict_dynamic_mapping_exception",
        "reason": "mapping set to strict, dynamic introduction of [new_field] within [_doc] is not allowed"
      },
      "status": 400
    }
```
如果这个问题出现了，我们必须修改我们现有的index的mapping：
```
    PUT blogs_example/_mapping
    {
      "properties": {
        "new_field": {
          "type": "text"
        }
      }
    }
```
那么重新运行之前的那个命令就可以了。


## settings以防止映射爆炸

在索引中定义太多字段是一种可能导致映射爆炸的情况，这可能导致内存不足错误和难以恢复的情况。 这个问题可能比预期更常见。 例如，考虑插入的每个新文档引入新字段的情况。 这在动态映射中非常常见。 每次文档包含新字段时，这些字段最终都会出现在索引的映射中。 这并不需要担心少量数据，但随着映射的增加，它可能会成为一个问题。 以下设置允许您限制可手动或动态创建的字段映射的数量，以防止错误的文档导致映射爆炸：
index.mapping.total_fields.limit

索引中的最大字段数。 字段和对象映射以及字段别名都计入此限制。 默认值为1000
index.mapping.depth.limit

字段的最大深度，以内部对象的数量来衡量。 例如，如果所有字段都在根对象级别定义，则深度为1.如果有一个对象映射，则深度为2，等等。默认值为20。
index.mapping.nested_fields.limit

索引中不同nested映射的最大数量，默认为50。
index.mapping.nested_objects.limit

所有nested类型中单个文档中嵌套JSON对象的最大数量，默认为10000。
index.mapping.field_name_length.limit

设置字段名称的最大长度。 默认值为Long.MAX_VALUE（无限制）。 此设置实际上不是解决映射爆炸的问题，但如果要限制字段长度，则可能仍然有用。 通常不需要设置此设置。 默认是可以的，除非用户开始添加大量具有真正长名称的字段。

上面的字段都可以在一个index的设置中进行设置，比如：
```
    PUT test_blog 
    {
      "settings": {
        "index.mapping.total_fields.limit": 2000,
        "number_of_replicas": 0,
        "number_of_shards": 1
      }
    }
```