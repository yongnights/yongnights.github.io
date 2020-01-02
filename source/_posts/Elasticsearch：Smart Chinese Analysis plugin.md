---
title: Elasticsearch：Smart Chinese Analysis plugin
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
Smart Chinese Analysis插件将Lucene的Smart Chinese分析模块集成到Elasticsearch中，用于分析中文或中英文混合文本。 支持的分析器在大型训练语料库上使用基于隐马尔可夫（Markov）模型的概率知识来查找简体中文文本的最佳分词。 它使用的策略是首先将输入文本分解为句子，然后对句子进行切分以获得单词。 该插件提供了一个称为smartcn分析器的分析器，以及一个称为smartcn_tokenizer的标记器。 请注意，两者均不能使用任何参数进行配置。

要将smartcn Analysis插件安装在Elasticsearch Docker容器中，请使用以下屏幕截图中显示的命令。 然后，我们重新启动容器以使插件生效：
```
./bin/elasticsearch-plugin install analysis-smartcn
```
在Elasticsearch的安装目录运行上面的命令。显示的结果如下：
```
    $ ./bin/elasticsearch-plugin install analysis-smartcn
    -> Downloading analysis-smartcn from elastic
    [=================================================] 100%   
    WARNING: An illegal reflective access operation has occurred
    WARNING: Illegal reflective access by org.bouncycastle.jcajce.provider.drbg.DRBG (file:/Users/liuxg/elastic/elasticsearch-7.3.0/lib/tools/plugin-cli/bcprov-jdk15on-1.61.jar) to constructor sun.security.provider.Sun()
    WARNING: Please consider reporting this to the maintainers of org.bouncycastle.jcajce.provider.drbg.DRBG
    WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
    WARNING: All illegal access operations will be denied in a future release
    -> Installed analysis-smartcn
    (base) localhost:elasticsearch-7.3.0 liuxg$ ./bin/elasticsearch-plugin list
    analysis-icu
    analysis-ik
    analysis-smartcn
    pinyin
```
上面显示我们已经成功地把analysis-smartcn安装成功了。针对docker的安装，我们可以通过如下的命令来进入到docker里，再进行安装：
```
    $ docker exec -it es01 /bin/bash
    [root@ec4d19f59a7d elasticsearch]# ls
    LICENSE.txt  README.textile  config  jdk  logs     plugins
    NOTICE.txt   bin             data    lib  modules
    [root@ec4d19f59a7d elasticsearch]# 
```
在这里es01是docker中的Elasticsearch实例。具体安装请参阅我的文章“Elastic：用Docker部署Elastic栈”。

注意：在我们安装好smartcn分析器后，我们必须重新启动Elasticsearch使它开始起作用。

<escape><!-- more --></escape>

# 实例

在下面，我们在Kibana中用一个实例来展示这个用法：
```
    POST _analyze 
    {
      "text": "股市，投资，稳，赚，不，赔，必修课，如何，做，好，仓，位，管理，和，情绪，管理",
      "analyzer": "smartcn"
    }
```
显示结果：
```
    {
      "tokens" : [
        {
          "token" : "股市",
          "start_offset" : 0,
          "end_offset" : 2,
          "type" : "word",
          "position" : 0
        },
        {
          "token" : "投资",
          "start_offset" : 3,
          "end_offset" : 5,
          "type" : "word",
          "position" : 2
        },
        {
          "token" : "稳",
          "start_offset" : 6,
          "end_offset" : 7,
          "type" : "word",
          "position" : 4
        },
        {
          "token" : "赚",
          "start_offset" : 8,
          "end_offset" : 9,
          "type" : "word",
          "position" : 6
        },
        {
          "token" : "不",
          "start_offset" : 10,
          "end_offset" : 11,
          "type" : "word",
          "position" : 8
        },
        {
          "token" : "赔",
          "start_offset" : 12,
          "end_offset" : 13,
          "type" : "word",
          "position" : 10
        },
        {
          "token" : "必修课",
          "start_offset" : 14,
          "end_offset" : 17,
          "type" : "word",
          "position" : 12
        },
        {
          "token" : "如何",
          "start_offset" : 18,
          "end_offset" : 20,
          "type" : "word",
          "position" : 14
        },
        {
          "token" : "做",
          "start_offset" : 21,
          "end_offset" : 22,
          "type" : "word",
          "position" : 16
        },
        {
          "token" : "好",
          "start_offset" : 23,
          "end_offset" : 24,
          "type" : "word",
          "position" : 18
        },
        {
          "token" : "仓",
          "start_offset" : 25,
          "end_offset" : 26,
          "type" : "word",
          "position" : 20
        },
        {
          "token" : "位",
          "start_offset" : 27,
          "end_offset" : 28,
          "type" : "word",
          "position" : 22
        },
        {
          "token" : "管理",
          "start_offset" : 29,
          "end_offset" : 31,
          "type" : "word",
          "position" : 24
        },
        {
          "token" : "和",
          "start_offset" : 32,
          "end_offset" : 33,
          "type" : "word",
          "position" : 26
        },
        {
          "token" : "情绪",
          "start_offset" : 34,
          "end_offset" : 36,
          "type" : "word",
          "position" : 28
        },
        {
          "token" : "管理",
          "start_offset" : 37,
          "end_offset" : 39,
          "type" : "word",
          "position" : 30
        }
      ]
    }
```