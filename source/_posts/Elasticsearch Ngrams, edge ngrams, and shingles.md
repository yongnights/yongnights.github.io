Ngrams和edge ngrams是在Elasticsearch中标记文本的两种更独特的方式。 Ngrams是一种将一个标记分成一个单词的每个部分的多个子字符的方法。 ngram和edge ngram过滤器都允许您指定min_gram以及max_gram设置。 这些设置控制单词被分割成的标记的大小。 这可能令人困惑，让我们看一个例子。 假设你想用ngram分析仪分析“spaghetti”这个词，让我们从最简单的情况开始，1-gams（也称为unigrams）。

在实际的搜索例子中，比如谷歌搜索：

![](https://img-blog.csdnimg.cn/20190903195523448.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

每当我们打入前面的几个字母时，就会出现相应的很多的候选名单。这个就是autocomplete功能。在Elasticsearch中，我们可以通过Edge ngram来实现这个目的。


# 1-grams
“spaghetti”的1-grams是s，p，a，g，h，e，t，t，i。 根据ngram的大小将字符串拆分为较小的token。 在这种情况下，每个token都是一个字符，因为我们谈论的是unigrams。

# Bigrams
如果你要将字符串拆分为双字母组（这意味着大小为2），你将获得以下较小的token：sp，pa，ag，gh，he，et，tt，ti。

# Trigrams
再说一次，如果你要使用三个大小，你将得到token为spa，pag，agh，ghe，het，ett，tti。

# 设置min_gram和max_gram

使用此分析器时，需要设置两种不同的大小：一种指定要生成的最小ngrams（min_gram设置），另一种指定要生成的最大ngrams。 使用前面的示例，如果您指定min_gram为2且max_gram为3，则您将获得前两个示例中的组合标记：
```
sp, spa, pa, pag, ag, agh, gh, ghe, he, het, et, ett, tt, tti, ti
```
如果你要将min_gram设置为1并将max_gram设置为3，那么你将得到更多的标记，从s，sp，spa，p，pa，pag，a，....开始。

以这种方式分析文本具有一个有趣的优点。 当你查询文本时，你的查询将以相同的方式被分割成文本，所以说你正在寻找拼写错误的单词“spaghety”。搜索这个的一种方法是做一个fuzzy query，它允许你 指定单词的编辑距离以检查匹配。 但是你可以通过使用ngrams来获得类似的行为。 让我们将原始单词（“spaghetti”）生成的bigrams与拼写错误的单词（“spaghety”）进行比较：

- “spaghetti”的bigrams：sp，pa，ag，gh，he，et，tt，ti
- “spaghety”的bigrams：sp，pa，ag，gh，he，et，ty

您可以看到六个token重叠，因此当查询包含“spaghety”时，其中带有“spaghetti”的单词仍然匹配。请记住，这意味着您可能不打算使用的原始“spaghetti”单词更多的单词 ，所以请务必测试您的查询相关性！

ngrams做的另一个有用的事情是允许您在事先不了解语言时或者当您使用与其他欧洲语言不同的方式组合单词的语言时分析文本。 这还有一个优点，即能够使用单个分析器处理多种语言，而不必指定。

# Edge ngrams

常规ngram拆分的变体称为edge ngrams，仅从前沿构建ngram。 在“spaghetti”示例中，如果将min_gram设置为2并将max_gram设置为6，则会获得以下标记：
```
sp, spa, spag, spagh, spaghe
```
您可以看到每个标记都是从边缘构建的。 这有助于搜索共享相同前缀的单词而无需实际执行前缀查询。 如果你需要从一个单词的后面构建ngrams，你可以使用side属性从后面而不是默认前面获取边缘。

# Ngram 设置

当你不知道语言是什么时，Ngrams是分析文本的好方法，因为它们可以分析单词之间没有空格的语言。 使用min和max grams配置edge ngram analyzer的示例如下所示:
```
    PUT my_index
    {
      "settings": {
        "analysis": {
          "analyzer": {
            "my_analyzer": {
              "tokenizer": "my_tokenizer"
            }
          },
          "tokenizer": {
            "my_tokenizer": {
              "type": "edge_ngram",
              "min_gram": 2,
              "max_gram": 10,
              "token_chars": [
                "letter",
                "digit"
              ]
            }
          }
        }
      }
    }
```
我们可以用刚才创建的my_tokenizer来分析我们的字符串：
```
    POST my_index/_analyze
    {
      "analyzer": "my_analyzer",
      "text": "2 Quick Foxes."
    }
```
显示的结果是：
```
    {
      "tokens" : [
        {
          "token" : "Qu",
          "start_offset" : 2,
          "end_offset" : 4,
          "type" : "word",
          "position" : 0
        },
        {
          "token" : "Qui",
          "start_offset" : 2,
          "end_offset" : 5,
          "type" : "word",
          "position" : 1
        },
        {
          "token" : "Quic",
          "start_offset" : 2,
          "end_offset" : 6,
          "type" : "word",
          "position" : 2
        },
        {
          "token" : "Quick",
          "start_offset" : 2,
          "end_offset" : 7,
          "type" : "word",
          "position" : 3
        },
        {
          "token" : "Fo",
          "start_offset" : 8,
          "end_offset" : 10,
          "type" : "word",
          "position" : 4
        },
        {
          "token" : "Fox",
          "start_offset" : 8,
          "end_offset" : 11,
          "type" : "word",
          "position" : 5
        },
        {
          "token" : "Foxe",
          "start_offset" : 8,
          "end_offset" : 12,
          "type" : "word",
          "position" : 6
        },
        {
          "token" : "Foxes",
          "start_offset" : 8,
          "end_offset" : 13,
          "type" : "word",
          "position" : 7
        }
      ]
    }
```
因为我们定义的min_gram是2，所以生成的token的长度是从2开始的。

通常我们建议在索引时和搜索时使用相同的分析器。 在edge_ngram tokenizer的情况下，建议是不同的。 仅在索引时使用edge_ngram标记生成器才有意义，以确保部分单词可用于索引中的匹配。 在搜索时，只需搜索用户输入的术语，例如：Quick Fo。

下面是如何为搜索类型设置字段的示例：
```
    PUT my_index
    {
      "settings": {
        "analysis": {
          "analyzer": {
            "autocomplete": {
              "tokenizer": "autocomplete",
              "filter": [
                "lowercase"
              ]
            },
            "autocomplete_search": {
              "tokenizer": "lowercase"
            }
          },
          "tokenizer": {
            "autocomplete": {
              "type": "edge_ngram",
              "min_gram": 2,
              "max_gram": 10,
              "token_chars": [
                "letter"
              ]
            }
          }
        }
      },
      "mappings": {
        "properties": {
          "title": {
            "type": "text",
            "analyzer": "autocomplete",
            "search_analyzer": "autocomplete_search"
          }
        }
      }
    }
```
在我们的例子中，我们索引时和搜索时时用了两个不同的analyzer：autocomplete及autocomplete_search。
```
    PUT my_index/_doc/1
    {
      "title": "Quick Foxes" 
    }
     
    POST my_index/_refresh
```
上面我们加入一个文档。下面我们来进行搜索：
```
    GET my_index/_search
    {
      "query": {
        "match": {
          "title": {
            "query": "Quick Fo", 
            "operator": "and"
          }
        }
      }
    }
```
显示结果：
```
    {
      "took" : 3,
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
        "max_score" : 0.5753642,
        "hits" : [
          {
            "_index" : "my_index",
            "_type" : "_doc",
            "_id" : "1",
            "_score" : 0.5753642,
            "_source" : {
              "title" : "Quick Foxes"
            }
          }
        ]
      }
    }
```
在这里autocomplete analyzer可以把字符串“Quick Foxes”分解为[qu, qui, quic, quick, fo, fox, foxe, foxes]。而自autocomplete_search analyzer搜索条目[quick，fo]，两者都出现在索引中。

当然我们也可以做如下的搜索：
```
    GET my_index/_search
    {
      "query": {
        "match": {
          "title": {
            "query": "Fo"
          }
        }
      }
    }
```
显示的和上面一样的结果。

# Shingles

与ngrams和edge ngrams一样，有一个称为shingle的过滤器（不，不是疾病的那个shingle！）。 Shingle token过滤器基本上是token级别的ngrams而不是字符级别。
想想我们最喜欢的单词“spaghetti”。使用最小和最大设置为1和3的ngrams，Elasticsearch将生成标记s，sp，spa，p，pa，pag，a，ag等。 一个shingle过滤器在token级别执行此操作，因此如果您有文本“foo bar baz”并再次使用in_shingle_size为2且max_shingle_size为3，则您将生成以下token：
```
foo, foo bar, foo bar baz, bar, bar baz, baz
```
为什么仍然包含单token输出？ 这是因为默认情况下，shingle过滤器包含原始token，因此原始标记生成令牌foo，bar和baz，然后将其传递给shingle token过滤器，生成标记foo bar，foo bar baz和bar baz。 所有这些token组合在一起形成最终token流。 您可以通过将output_unigrams选项设置为false来禁用此行为，也即不需要最原始的token：foo, bar及baz

下一个清单显示了shingle token过滤器的示例; 请注意，min_shingle_size选项必须大于或等于2。
```
    PUT my_index
    {
      "settings": {
        "analysis": {
          "analyzer": {
            "shingle": {
              "type": "custom",
              "tokenizer": "standard",
              "filter": [
                "shingle-filter"
              ]
            }
          },
          "filter": {
            "shingle-filter": {
              "type": "shingle",
              "min_shingle_size": 2,
              "max_shingle_size": 3,
              "output_unigrams": false
            }
          }
        }
      }
    }
```
在这里，我们定义了一个叫做shingle-filter的过滤器。最小的shangle大小是2，最大的shingle大小是3。同时我们设置output_unigrams为false，这样最初的那些token将不被包含在最终的结果之中。

下面我们来做一个例子，看看显示的结果：
```
    GET /my_index/_analyze
    {
      "text": "foo bar baz",
      "analyzer": "shingle"
    }
```
显示的结果为：
```
    {
      "tokens" : [
        {
          "token" : "foo bar",
          "start_offset" : 0,
          "end_offset" : 7,
          "type" : "shingle",
          "position" : 0
        },
        {
          "token" : "foo bar baz",
          "start_offset" : 0,
          "end_offset" : 11,
          "type" : "shingle",
          "position" : 0,
          "positionLength" : 2
        },
        {
          "token" : "bar baz",
          "start_offset" : 4,
          "end_offset" : 11,
          "type" : "shingle",
          "position" : 1
        }
      ]
    }
```

参考：
【1】 https://www.elastic.co/guide/en/elasticsearch/reference/7.3/analysis-edgengram-tokenizer.html
