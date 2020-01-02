---
title: Elasticsearch：Pinyin 分词器
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
Elastic的Medcl提供了一种搜索Pinyin搜索的方法。拼音搜索在很多的应用场景中都有被用到。比如在百度搜索中，我们使用拼音就可以出现汉字：

![](https://img-blog.csdnimg.cn/20190910135147850.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

对于我们中国人来说，拼音搜索也是非常直接的。那么在Elasticsearch中我们该如何使用pinyin来进行搜索呢？答案是我们采用Medcl所创建的elasticsearch-analysis-pinyin分析器。下面我们简单介绍一下如何进行安装和测试。

# 下载Pinyin分析器源码进行编译及安装

由于elasticsearch-analysis-pinyin目前没有可以下载的可以安装的发布文件，我们必须自己下载源码，并编译。首先，我们可以通过如下的命名来进行下载：
```
$ git clone https://github.com/medcl/elasticsearch-analysis-pinyin
```

下载源码后，进入到项目的根目录。整个项目的源码显示为：

```
$ tree -L 2
.
├── LICENSE.txt
├── README.md
├── lib
│   └── nlp-lang-1.7.jar
├── pom.xml
└── src
    ├── main
    └── test
```

这样在我们的电脑里就会发现下载好的elasticsearch-analysis-pinyin源码。在进行编译之前，我们必须修改一下我们的版本号以便和我们的Elasticsearch的版本号是一致的。否则我们的plugin将不会被正确装载。我们已知我们的Elasticsearch版本号码是7.3.0，那么我们修改我们的pom.xml文件：
![](https://img-blog.csdnimg.cn/20190910142842841.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

<escape><!-- more --></escape>

在我们的电脑上必须安装好Maven。然后进入项目的根目录，并在命令行中打入如下的命令：

```
$ mvn install
```

这样整个项目的编译工作就完成了。我们在命令行中打入如下的命令：

```
$ find ./ -name "*.zip"
.//target/releases/elasticsearch-analysis-pinyin-7.3.0.zip
```

它显示在tagert目录下已经生产了一个叫做elasticsearch-analysis-pinyin-7.3.0.zip的压缩文件。这个版本号码刚好和我们的Elasticsearch的版本是一样的。

我们到Elasticsearch的安装目录下的plugin目录下创建一个叫做pinyin的子目录：



```
/Users/liuxg/elastic/elasticsearch-7.3.0/plugins
localhost:plugins liuxg$ ls 
analysis-ik	pinyin
```

然后，把我们刚才在上一步生产的elasticsearch-analysis-pinyin-7.0.0.zip文件进行解压，并把文件放入到我们刚才创建的pinyin目录下。这样整个pinyin文件夹的文件显示如下：

```
$ ls
analysis-ik	pinyin
localhost:plugins liuxg$ tree pinyin/ -L 3
pinyin/
├── elasticsearch-analysis-pinyin-7.3.0.jar
├── nlp-lang-1.7.jar
└── plugin-descriptor.properties
```

至此，我们的安装工作已经完成，我需要重新启动我们的Elasticsearch。

# 测试Pinyin analyzer

下面我们来测试一下我们已经安装好的Pinyin分词器是否已经工作。我们可以仿照https://github.com/medcl/elasticsearch-analysis-pinyin上面的介绍来做一些简单的测试：

## 创建一个定制的pinyin分词器

```
PUT /medcl/ 
{
    "settings" : {
        "analysis" : {
            "analyzer" : {
                "pinyin_analyzer" : {
                    "tokenizer" : "my_pinyin"
                    }
            },
            "tokenizer" : {
                "my_pinyin" : {
                    "type" : "pinyin",
                    "keep_separate_first_letter" : false,
                    "keep_full_pinyin" : true,
                    "keep_original" : true,
                    "limit_first_letter_length" : 16,
                    "lowercase" : true,
                    "remove_duplicated_term" : true
                }
            }
        }
    }
}
```

## 测试一些中文汉字

```
GET /medcl/_analyze
{
  "text": ["天安门"],
  "analyzer": "pinyin_analyzer"
}

# 显示结果为：
{
  "tokens" : [
    {
      "token" : "tian",
      "start_offset" : 0,
      "end_offset" : 0,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "天安门",
      "start_offset" : 0,
      "end_offset" : 0,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "tam",
      "start_offset" : 0,
      "end_offset" : 0,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "an",
      "start_offset" : 0,
      "end_offset" : 0,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "men",
      "start_offset" : 0,
      "end_offset" : 0,
      "type" : "word",
      "position" : 2
    }
  ]
}
```

上面的token显示，如果我们打入搜索tam是完全可以搜索到我们的结果的。

## 创建mapping

```
POST /medcl/_mapping
{
  "properties": {
    "name": {
      "type": "keyword",
      "fields": {
        "pinyin": {
          "type": "text",
          "store": false,
          "term_vector": "with_offsets",
          "analyzer": "pinyin_analyzer",
          "boost": 10
        }
      }
    }
  }
}
```

## Index文档

```
POST /medcl/_create/andy
{"name":"刘德华"}
```

## 搜索文档

```
curl http://localhost:9200/medcl/_search?q=name:%E5%88%98%E5%BE%B7%E5%8D%8E
curl http://localhost:9200/medcl/_search?q=name.pinyin:%e5%88%98%e5%be%b7
curl http://localhost:9200/medcl/_search?q=name.pinyin:liu
curl http://localhost:9200/medcl/_search?q=name.pinyin:ldh
curl http://localhost:9200/medcl/_search?q=name.pinyin:de+hua
```

或者：

```
GET medcl/_search?q=name:%E5%88%98%E5%BE%B7%E5%8D%8E
GET medcl/_search?q=name.pinyin:%e5%88%98%e5%be%b7
GET medcl/_search?q=name.pinyin:liu
GET medcl/_search?q=name.pinyin:ldh
GET medcl/_search?q=name.pinyin:de+hua
```

上面的第一个[Unicode](http://tool.chinaz.com/tools/urlencode.aspx)是“刘德华”，第二个是“刘德”。

## 使用pinyin-tokenFilter

```
PUT /medcl1/ 
{
    "settings" : {
        "analysis" : {
            "analyzer" : {
                "user_name_analyzer" : {
                    "tokenizer" : "whitespace",
                    "filter" : "pinyin_first_letter_and_full_pinyin_filter"
                }
            },
            "filter" : {
                "pinyin_first_letter_and_full_pinyin_filter" : {
                    "type" : "pinyin",
                    "keep_first_letter" : true,
                    "keep_full_pinyin" : false,
                    "keep_none_chinese" : true,
                    "keep_original" : false,
                    "limit_first_letter_length" : 16,
                    "lowercase" : true,
                    "trim_whitespace" : true,
                    "keep_none_chinese_in_first_letter" : true
                }
            }
        }
    }
}
```

Token Test:刘德华 张学友 郭富城 黎明 四大天王

```
GET /medcl1/_analyze
{
  "text": ["刘德华 张学友 郭富城 黎明 四大天王"],
  "analyzer": "user_name_analyzer"
}
```

```

{
  "tokens" : [
    {
      "token" : "ldh",
      "start_offset" : 0,
      "end_offset" : 3,
      "type" : "word",
      "position" : 0
    },
    {
      "token" : "zxy",
      "start_offset" : 4,
      "end_offset" : 7,
      "type" : "word",
      "position" : 1
    },
    {
      "token" : "gfc",
      "start_offset" : 8,
      "end_offset" : 11,
      "type" : "word",
      "position" : 2
    },
    {
      "token" : "lm",
      "start_offset" : 12,
      "end_offset" : 14,
      "type" : "word",
      "position" : 3
    },
    {
      "token" : "sdtw",
      "start_offset" : 15,
      "end_offset" : 19,
      "type" : "word",
      "position" : 4
    }
  ]
}
```

其它请参阅链接https://github.com/medcl/elasticsearch-analysis-pinyin。

如果想了解中文IK分词器，请参阅文章“[Elasticsearch：IK中文分词器](https://blog.csdn.net/UbuntuTouch/article/details/100516428)”。