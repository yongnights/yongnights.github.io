---
title: lasticsearch：ICU分词器介绍
top: 
date: 
tags: 
- elk
categories: 
- elk
password: 
---
ICU Analysis插件是一组将Lucene ICU模块集成到Elasticsearch中的库。 本质上，ICU的目的是增加对Unicode和全球化的支持，以提供对亚洲语言更好的文本分割分析。 从Elasticsearch的角度来看，此插件提供了文本分析中的新组件，如下表所示:

![](https://img-blog.csdnimg.cn/20191004233028283.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

# 安装

我们可以首先到Elasticsearch的安装目录打入如下的命令：
```
    $ pwd
    /Users/liuxg/elastic/elasticsearch-7.3.0
    (base) localhost:elasticsearch-7.3.0 liuxg$ ./bin/elasticsearch-plugin list
    analysis-icu
    analysis-ik
    pinyin
```
上面显示我已经安装好了三个插件。上面的analysis-ik及pinyin都是为中文而准备的。

> 注意：如果你们在使用上面的elasticsearch-plug list命名出现如下的错误的话：

![](https://img-blog.csdnimg.cn/20191004233733548.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

那么请使用如下的命令来删除在当前目录下的.DS_Store目录：
```
sudo find /Path/to/your/elasticsearch-folder -name ".DS_Store" -depth -exec rm {} \;
```
然后重新运行上面的命令就不会有问题了。

<escape><!-- more --></escape>

上面显示我已经安装好了。如果在你的电脑里没有安装好，可以使用如下的命令来进行安装：
```
./bin/elasticsearch-plugin install analysis-icu
```
上面的命令在Elasticsearch的安装目录里进行运行。等安装好后，我们需要重新启动Elasticsearch让它起作用。重新运行：
```
./bin/elasticsearch-plugin list
```
来检查analysis-icu是否已经被成功安装好了。

# 例子

等我们完全安装好了analysis_icu，那么，我们可以使用如下的例子在Kibana中来做一个实验：
```
    POST _analyze 
    {
      "text": "我爱北京天安门",
      "analyzer": "icu_analyzer"
    }
```
那么显示的结果是：

![](https://img-blog.csdnimg.cn/20191006160617927.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

上面显示，我们analysis可以正确地帮我们把中文词语安装中文的分词方法正确地进行分词。

我们可以和standard分词器来进行一个比较：

![](https://img-blog.csdnimg.cn/20191004235039310.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

我们从上面可以看出来，在默认的情况下，icu_analyzer通常是一个及以上的字符的token，而standard的analyzer只有一个字符。

通过更改字符过滤器和token的方法和模式参数，ICU分析器可以具有多种自定义变量类型。 下表描述了不同类型的ICU分析仪的组合：

![](https://img-blog.csdnimg.cn/20191006160916654.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1VidW50dVRvdWNo,size_16,color_FFFFFF,t_70)

让我们尝试nfkd_normalized分析器。 遵循定义并在Kibana Dev Tools控制台中对其进行测试。 响应显示在以下屏幕截图中。 但是，由于使用nfkd_normalized分析器和icu_analyzer分析器，我们无法在结果中找到任何差异：
```
    POST _analyze 
    {
      "text": "股市投资稳赚不赔必修课：如何做好仓位管理和情绪管理",
      "char_filter": [{"type": "icu_normalizer", "name": "nfkc", "mode":"decompose"}], 
      "tokenizer": "icu_tokenizer"
    }
```
运行结果：
```
    {
      "tokens" : [
        {
          "token" : "股市",
          "start_offset" : 0,
          "end_offset" : 2,
          "type" : "<IDEOGRAPHIC>",
          "position" : 0
        },
        {
          "token" : "投资",
          "start_offset" : 2,
          "end_offset" : 4,
          "type" : "<IDEOGRAPHIC>",
          "position" : 1
        },
        {
          "token" : "稳赚",
          "start_offset" : 4,
          "end_offset" : 6,
          "type" : "<IDEOGRAPHIC>",
          "position" : 2
        },
        {
          "token" : "不",
          "start_offset" : 6,
          "end_offset" : 7,
          "type" : "<IDEOGRAPHIC>",
          "position" : 3
        },
        {
          "token" : "赔",
          "start_offset" : 7,
          "end_offset" : 8,
          "type" : "<IDEOGRAPHIC>",
          "position" : 4
        },
        {
          "token" : "必修",
          "start_offset" : 8,
          "end_offset" : 10,
          "type" : "<IDEOGRAPHIC>",
          "position" : 5
        },
        {
          "token" : "课",
          "start_offset" : 10,
          "end_offset" : 11,
          "type" : "<IDEOGRAPHIC>",
          "position" : 6
        },
        {
          "token" : "如何",
          "start_offset" : 12,
          "end_offset" : 14,
          "type" : "<IDEOGRAPHIC>",
          "position" : 7
        },
        {
          "token" : "做好",
          "start_offset" : 14,
          "end_offset" : 16,
          "type" : "<IDEOGRAPHIC>",
          "position" : 8
        },
        {
          "token" : "仓",
          "start_offset" : 16,
          "end_offset" : 17,
          "type" : "<IDEOGRAPHIC>",
          "position" : 9
        },
        {
          "token" : "位",
          "start_offset" : 17,
          "end_offset" : 18,
          "type" : "<IDEOGRAPHIC>",
          "position" : 10
        },
        {
          "token" : "管理",
          "start_offset" : 18,
          "end_offset" : 20,
          "type" : "<IDEOGRAPHIC>",
          "position" : 11
        },
        {
          "token" : "和",
          "start_offset" : 20,
          "end_offset" : 21,
          "type" : "<IDEOGRAPHIC>",
          "position" : 12
        },
        {
          "token" : "情绪",
          "start_offset" : 21,
          "end_offset" : 23,
          "type" : "<IDEOGRAPHIC>",
          "position" : 13
        },
        {
          "token" : "管理",
          "start_offset" : 23,
          "end_offset" : 25,
          "type" : "<IDEOGRAPHIC>",
          "position" : 14
        }
      ]
    }
```
要使用新定义的分析器，我们必须在Index setting中对其进行定义。请参阅我之前的文章“Elasticsearch: analyzer”。
